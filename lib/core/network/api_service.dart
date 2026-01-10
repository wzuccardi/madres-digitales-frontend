import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../config/app_config.dart';
import '../../core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';


class ApiResponse<T> {

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
    this.statusCode,
    this.meta,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(AppError error, {int? statusCode, String? message, Map<String, dynamic>? meta}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      message: message ?? error.message,
      statusCode: statusCode,
      meta: meta,
    );
  }

  factory ApiResponse.fromHttpResponse(http.Response response) {
    try {
      final statusCode = response.statusCode;
      final body = response.body;

      final Map<String, dynamic> jsonData = json.decode(body);
      final success = jsonData['success'] ?? false;
      
      if (success) {
        return ApiResponse.success(
          jsonData['data'],
          message: jsonData['message'],
        );
      } else {
        final errorData = jsonData['error'];
        final message = errorData['message']?.toString() ?? 'Unknown error';
        
        return ApiResponse.error(
          ServerError(message),
          statusCode: statusCode,
          meta: jsonData['meta'],
        );
      }
    } catch (e) {
      AppLogger.error('Error parsing API response: $e');
      return ApiResponse.error(
        const ServerError('Failed to parse response'),
        statusCode: response.statusCode,
      );
    }
  }

  factory ApiResponse.fromDioResponse(Response response) {
    try {
      final statusCode = response.statusCode ?? 0;
      final payload = response.data;

      if (payload is Map<String, dynamic>) {
        final success = payload['success'] ?? (statusCode >= 200 && statusCode < 300);
        if (success) {
          dynamic data = payload.containsKey('data') ? payload['data'] : payload;
          data ??= payload;
          return ApiResponse.success(data as T, message: payload['message']?.toString());
        } else {
          final err = payload['error'] as Map<String, dynamic>?;
          final message = err?['message']?.toString() ?? payload['message']?.toString() ?? 'Unknown error';
          return ApiResponse.error(
            ServerError(message),
            statusCode: statusCode,
            meta: payload['meta'] as Map<String, dynamic>?,
          );
        }
      } else {
        // Non-JSON or list payloads
        final ok = statusCode >= 200 && statusCode < 300;
        if (ok) {
          return ApiResponse.success(payload as T);
        }
        return ApiResponse.error(
          const ServerError('Request failed'),
          statusCode: statusCode,
        );
      }
    } catch (e) {
      AppLogger.error('Error parsing Dio response: $e');
      return ApiResponse.error(
        const ServerError('Failed to parse response'),
        statusCode: response.statusCode,
      );
    }
  }
  final bool success;
  final T? data;
  final AppError? error;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? meta;
}

class ApiService {
  factory ApiService() => _instance;
  ApiService._internal() {
    _initializeInterceptors();
    _initializeDio();
  }
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();

  void _initializeInterceptors() {
    // Inicializar interceptor para autenticación
    _authInterceptor = InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Obtener token usando el método que maneja web y móvil
        String? token = await getAccessToken();
        AppLogger.info('Auth interceptor - Token retrieved', context: {
          'hasToken': token != null,
          'tokenLength': token?.length ?? 0,
          'path': options.path,
          'isWeb': kIsWeb,
          'headersBefore': options.headers.toString()
        });
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          AppLogger.info('Auth interceptor - Authorization header added', context: {
            'path': options.path,
            'headerValue': 'Bearer ${token.substring(0, token.length > 10 ? 10 : token.length)}...',
            'headersAfter': options.headers.toString()
          });
        } else {
          AppLogger.warning('Auth interceptor - No token available', context: {
            'path': options.path,
            'token': token
          });
        }
        
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Manejar error 401 (Unauthorized)
        if (error.response?.statusCode == 401) {
          // Intentar refresh token
          final refreshToken = await getRefreshToken();
          
          if (refreshToken != null) {
            try {
              final response = await _dio.post(
                '/api/auth/refresh',
                data: {'refreshToken': refreshToken},
              );
               
              if (response.statusCode == 200) {
                final newToken = response.data['data']['accessToken'];
                await saveAccessToken(newToken);
               
                // Reintentar la petición original
                final originalOptions = error.requestOptions;
                originalOptions.headers['Authorization'] = 'Bearer $newToken';
               
                final retryResponse = await _dio.fetch(originalOptions);
                return handler.resolve(retryResponse);
              }
            } catch (e) {
              AppLogger.error('Error refreshing token: $e');
              // Si falla el refresh, limpiar tokens y redirigir a login
              await clearTokens();
            }
          }
        }
        
        return handler.next(error);
      },
    );

    // Inicializar interceptor para logging
    _loggingInterceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        if (AppConfig.shouldEnableLogging()) {
          AppLogger.debug('API Request: ${options.method} ${options.uri}');
          if (options.data != null) {
            AppLogger.debug('Request data: ${options.data}');
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (AppConfig.shouldEnableLogging()) {
          AppLogger.debug('API Response: ${response.statusCode} ${response.requestOptions.uri}');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        // Mantener errores siempre visibles
        AppLogger.error('API Error: ${error.message} ${error.requestOptions.uri}');
        AppLogger.error('Error response: ${error.response?.statusCode}');
        return handler.next(error);
      },
    );

    // Inicializar interceptor para manejo de errores
    _errorInterceptor = InterceptorsWrapper(
      onError: (error, handler) {
        // Manejar errores de red
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError) {
          AppLogger.error('Network error: ${error.message}');
          return handler.next(DioException(
            requestOptions: error.requestOptions,
            error: const NetworkError(AppConstants.networkErrorMessage),
          ));
        }
        
        // Manejar errores de servidor
        if (error.response?.statusCode != null) {
          final statusCode = error.response!.statusCode!;
          
          if (statusCode >= 500) {
            AppLogger.error('Server error: ${error.message}');
            return handler.next(DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: const ServerError(AppConstants.serverErrorMessage),
            ));
          }
          
          if (statusCode == 401) {
            AppLogger.error('Unauthorized error: ${error.message}');
            return handler.next(DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: const AuthError(
                AppConstants.unauthorizedMessage,
              ),
            ));
          }
          
          if (statusCode == 403) {
            AppLogger.error('Forbidden error: ${error.message}');
            return handler.next(DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: const PermissionError(
                AppConstants.unauthorizedMessage,
              ),
            ));
          }
          
          if (statusCode == 404) {
            AppLogger.error('Not found error: ${error.message}');
            return handler.next(DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: const NotFoundError(
                'Resource not found',
              ),
            ));
          }
          
          if (statusCode == 429) {
            AppLogger.error('Rate limit error: ${error.message}');
            return handler.next(DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: const TimeoutError(
                'Too many requests',
              ),
            ));
          }
        }
        
        return handler.next(error);
      },
    );
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.apiTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.apiTimeout),
      sendTimeout: Duration(milliseconds: AppConstants.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Agregar interceptores
    _dio.interceptors.add(_authInterceptor);
    _dio.interceptors.add(_loggingInterceptor);
    _dio.interceptors.add(_errorInterceptor);
  }

  // Exponer la instancia de Dio para compatibilidad
  Dio get dioInstance => _dio;

  // Interceptor para autenticación
  late final Interceptor _authInterceptor;

  // Interceptor para logging
  late final Interceptor _loggingInterceptor;

  // Interceptor para manejo de errores
  late final Interceptor _errorInterceptor;

  // Métodos HTTP genéricos
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.fromDioResponse(response as Response);
    } on DioException catch (e) {
      AppLogger.error('GET request failed: $e');
      return ApiResponse.error(
        NetworkError(e.message ?? 'Network error'),
      );
    } catch (e) {
      AppLogger.error('Unexpected error in GET request: $e');
      return ApiResponse.error(
        UnknownError(e.toString()),
      );
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    T? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.fromDioResponse(response as Response);
    } on DioException catch (e) {
      AppLogger.error('POST request failed: $e');
      return ApiResponse.error(
        NetworkError(e.message ?? 'Network error'),
      );
    } catch (e) {
      AppLogger.error('Unexpected error in POST request: $e');
      return ApiResponse.error(
        UnknownError(e.toString()),
      );
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    T? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.fromDioResponse(response as Response);
    } on DioException catch (e) {
      AppLogger.error('PUT request failed: $e');
      return ApiResponse.error(
        NetworkError(e.message ?? 'Network error'),
      );
    } catch (e) {
      AppLogger.error('Unexpected error in PUT request: $e');
      return ApiResponse.error(
        UnknownError(e.toString()),
      );
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.fromDioResponse(response as Response);
    } on DioException catch (e) {
      AppLogger.error('DELETE request failed: $e');
      return ApiResponse.error(
        NetworkError(e.message ?? 'Network error'),
      );
    } catch (e) {
      AppLogger.error('Unexpected error in DELETE request: $e');
      return ApiResponse.error(
        UnknownError(e.toString()),
      );
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    T? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.fromDioResponse(response as Response);
    } on DioException catch (e) {
      AppLogger.error('PATCH request failed: $e');
      return ApiResponse.error(
        NetworkError(e.message ?? 'Network error'),
      );
    } catch (e) {
      AppLogger.error('Unexpected error in PATCH request: $e');
      return ApiResponse.error(
        UnknownError(e.toString()),
      );
    }
  }

  // Métodos para subir archivos
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    File file, {
    Map<String, dynamic>? fields,
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final fileSize = await file.length();
      
      // Validar tamaño del archivo
      if (fileSize > AppConstants.maxFileSize) {
        return ApiResponse.error(
          const FileSizeExceededError('File size exceeds maximum allowed size'),
        );
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        ...?fields,
      });

      final response = await _dio.post<T>(
        endpoint,
        data: formData,
        options: options,
        onSendProgress: onSendProgress,
      );
      return ApiResponse.fromDioResponse(response as Response);
    } on DioException catch (e) {
      AppLogger.error('File upload failed: $e');
      return ApiResponse.error(
        FileUploadError(e.message ?? 'File upload failed'),
      );
    } catch (e) {
      AppLogger.error('Unexpected error in file upload: $e');
      return ApiResponse.error(
        UnknownError(e.toString()),
      );
    }
  }

  // Métodos para manejar tokens
  Future<void> saveAccessToken(String accessToken) async {
    try {
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: accessToken,
      );
      AppLogger.info('Access token saved successfully');
    } catch (e) {
      AppLogger.error('Error saving access token: $e');
      throw const StorageError('Failed to save access token');
    }
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: refreshToken,
      );
      AppLogger.info('Refresh token saved successfully');
    } catch (e) {
      AppLogger.error('Error saving refresh token: $e');
      throw const StorageError('Failed to save refresh token');
    }
  }
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      AppLogger.info('Saving tokens', context: {
        'accessTokenLength': accessToken.length,
        'refreshTokenLength': refreshToken.length,
        'isWeb': kIsWeb,
        'accessTokenKey': AppConstants.accessTokenKey,
        'refreshTokenKey': AppConstants.refreshTokenKey
      });
      
      // For web platform, use SharedPreferences instead of FlutterSecureStorage
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final accessResult = await prefs.setString(AppConstants.accessTokenKey, accessToken);
        final refreshResult = await prefs.setString(AppConstants.refreshTokenKey, refreshToken);
        AppLogger.info('Tokens saved to SharedPreferences (web)', context: {
          'accessTokenSaved': accessResult,
          'refreshTokenSaved': refreshResult
        });
      } else {
        // For mobile platforms, use secure storage
        await _secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: accessToken,
        );
        await _secureStorage.write(
          key: AppConstants.refreshTokenKey,
          value: refreshToken,
        );
        AppLogger.info('Tokens saved to secure storage');
      }
    } catch (e) {
      AppLogger.error('Error saving tokens: $e');
      throw const StorageError('Failed to save tokens');
    }
  }

  Future<void> clearTokens() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(AppConstants.accessTokenKey);
        await prefs.remove(AppConstants.refreshTokenKey);
      } else {
        await _secureStorage.delete(key: AppConstants.accessTokenKey);
        await _secureStorage.delete(key: AppConstants.refreshTokenKey);
      }
      AppLogger.info('Tokens cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing tokens: $e');
      throw const StorageError('Failed to clear tokens');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      AppLogger.info('Getting access token', context: {
        'isWeb': kIsWeb,
        'accessTokenKey': AppConstants.accessTokenKey
      });
      
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppConstants.accessTokenKey);
        AppLogger.info('Access token retrieved from SharedPreferences', context: {
          'hasToken': token != null,
          'tokenLength': token?.length ?? 0
        });
        if (token != null && token.isNotEmpty) return token;
        return null;
      } else {
        final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
        AppLogger.info('Access token retrieved from secure storage', context: {
          'hasToken': token != null,
          'tokenLength': token?.length ?? 0
        });
        if (token != null && token.isNotEmpty) return token;
        return null;
      }
    } catch (e) {
      AppLogger.error('Error getting access token: $e');
      return null;
    }
  }

  // Método para debugging - alias de getAccessToken
  Future<String?> getCurrentToken() async {
    return await getAccessToken();
  }

  Future<String?> getRefreshToken() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppConstants.refreshTokenKey);
        if (token != null && token.isNotEmpty) return token;
        return null;
      } else {
        final token = await _secureStorage.read(key: AppConstants.refreshTokenKey);
        if (token != null && token.isNotEmpty) return token;
        return null;
      }
    } catch (e) {
      AppLogger.error('Error getting refresh token: $e');
      return null;
    }
  }

  // Métodos adicionales para compatibilidad con código existente
    
    /// Obtener token de acceso (método de compatibilidad)
    Future<String?> getToken() async {
      return await getAccessToken();
    }
  
    /// Realizar petición autenticada genérica (método de compatibilidad)
  Future<http.Response> authenticatedRequest(
      String method,
      String endpoint, {
      Map<String, dynamic>? body,
      Map<String, String>? queryParams,
      bool requireAuth = true,
    }) async {
      try {
        final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint')
            .replace(queryParameters: queryParams);
        
        final headers = <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };
        
        if (requireAuth) {
          final token = await getAccessToken();
          if (token != null) {
            headers['Authorization'] = 'Bearer $token';
          }
        }
        
        final client = http.Client();
        http.Response response;
        
        switch (method.toUpperCase()) {
          case 'GET':
            response = await client.get(uri, headers: headers);
            break;
          case 'POST':
            response = await client.post(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'PUT':
            response = await client.put(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'DELETE':
            response = await client.delete(uri, headers: headers);
            break;
          case 'PATCH':
            response = await client.patch(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          default:
            throw UnsupportedError('Método HTTP no soportado: $method');
        }
        
        client.close();
        return response;
      } catch (e) {
        AppLogger.error('Error en authenticatedRequest: $e');
        rethrow;
      }
    }
  
    /// Método para obtener lista desde caché (compatibilidad)
    Future<List<dynamic>?> getList(String key) async {
      try {
        // Implementación básica usando SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          return jsonDecode(jsonString) as List<dynamic>;
        }
        return null;
      } catch (e) {
        AppLogger.error('Error obteniendo lista del caché: $e');
        return null;
      }
    }
  
    /// Método para guardar lista en caché (compatibilidad)
    Future<bool> setList(String key, List<dynamic> value) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonString = jsonEncode(value);
        return await prefs.setString(key, jsonString);
      } catch (e) {
        AppLogger.error('Error guardando lista en caché: $e');
        return false;
      }
    }

  
    /// Método para limpiar recursos
    void dispose() {
      _dio.close();
    }

  // Método para verificar conectividad
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty;
    } catch (e) {
      AppLogger.error('Error checking internet connection: $e');
      return false;
    }
  }

  Future<ApiResponse<dynamic>> authenticatedRequestApiResponse(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    bool requireAuth = true,
    Options? options,
  }) async {
    try {
      final opts = Options(method: method.toUpperCase(), headers: {});
      if (options?.headers != null) {
        opts.headers!.addAll(options!.headers!);
      }
      if (requireAuth) {
        final token = await getAccessToken();
        if (token != null) {
          opts.headers!['Authorization'] = 'Bearer $token';
        }
      }
      final response = await _dio.request(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: opts,
      );
      return ApiResponse.fromDioResponse(response);
    } on DioException catch (e) {
      return ApiResponse.error(
        NetworkError(e.message ?? 'Network error'),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(UnknownError(e.toString()));
    }
  }

  dynamic extractData(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload.containsKey('data') ? payload['data'] : payload;
    }
    return payload;
  }

  List<dynamic> extractList(dynamic payload) {
    final data = extractData(payload);
    if (data is List) return data;
    return const [];
  }

  Map<String, dynamic> extractObject(dynamic payload) {
    final data = extractData(payload);
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  // Método para reintentar peticiones
  Future<ApiResponse<T>> retryRequest<T>(
    Future<ApiResponse<T>> Function() request,
    int maxRetries, {
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    AppError? lastError;

    while (attempts < maxRetries) {
      try {
        final response = await request();
        
        if (response.success) {
          return response;
        }
        
        lastError = response.error;
        attempts++;
        
        if (attempts < maxRetries) {
          AppLogger.warning('Request failed, retrying in ${delay.inSeconds} seconds... (Attempt $attempts/$maxRetries)');
          await Future.delayed(delay);
        }
      } catch (e) {
        AppLogger.error('Unexpected error in retry request: $e');
        lastError = UnknownError(e.toString());
        attempts++;
        
        if (attempts < maxRetries) {
          await Future.delayed(delay);
        }
      }
    }

    return ApiResponse.error(
      lastError ?? const UnknownError('Max retries exceeded'),
    );
  }
}
