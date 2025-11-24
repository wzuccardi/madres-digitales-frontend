export '../../../core/network/api_service.dart';


/*
class ApiResponse<T> {
  final bool success;
  final T? data;
  final AppError? error;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? meta;

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
      final statusCode = response.statusCode ?? 0;
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
        final code = errorData['code']?.toString() ?? 'UNKNOWN_ERROR';
        final message = errorData['message']?.toString() ?? 'Unknown error';
        
        return ApiResponse.error(
          AppError(
            code: code,
            message: message,
          ),
          statusCode: statusCode,
          meta: jsonData['meta'],
        );
      }
    } catch (e) {
      AppLogger.error('Error parsing API response:', e);
      return ApiResponse.error(
        const ServerError('Failed to parse response'),
        statusCode: response.statusCode,
      );
    }
  }
}
*/

/* class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
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

  // Interceptor para autenticación
  final Interceptor _authInterceptor = InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Obtener token del almacenamiento seguro
      final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
      
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      
      return handler.next(options);
    },
    onError: (error, handler) async {
      // Manejar error 401 (Unauthorized)
      if (error.response?.statusCode == 401) {
        // Intentar refresh token
        final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
        
        if (refreshToken != null) {
          try {
            final response = await _dio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );
            
            if (response.statusCode == 200) {
              final newToken = response.data['data']['accessToken'];
              await _secureStorage.write(key: AppConstants.accessTokenKey, value: newToken);
              
              // Reintentar la petición original
              final originalOptions = error.requestOptions;
              originalOptions.headers['Authorization'] = 'Bearer $newToken';
              
              final retryResponse = await _dio.fetch(originalOptions);
              return handler.resolve(retryResponse);
            }
          } catch (e) {
            AppLogger.error('Error refreshing token:', e);
            // Si falla el refresh, limpiar tokens y redirigir a login
            await _secureStorage.delete(key: AppConstants.accessTokenKey);
            await _secureStorage.delete(key: AppConstants.refreshTokenKey);
          }
        }
      }
      
      return handler.next(error);
    },
  );

  // Interceptor para logging
  final Interceptor _loggingInterceptor = InterceptorsWrapper(
    onRequest: (options, handler) {
      AppLogger.debug('API Request: ${options.method} ${options.uri}');
      if (options.data != null) {
        AppLogger.debug('Request data: ${options.data}');
      }
      return handler.next(options);
    },
    onResponse: (response, handler) {
      AppLogger.debug('API Response: ${response.statusCode} ${response.requestOptions.uri}');
      return handler.next(response);
    },
    onError: (error, handler) {
      AppLogger.error('API Error: ${error.message} ${error.requestOptions.uri}');
      AppLogger.error('Error response: ${error.response?.statusCode}');
      return handler.next(error);
    },
  );

  // Interceptor para manejo de errores
  final Interceptor _errorInterceptor = InterceptorsWrapper(
    onError: (error, handler) {
      // Manejar errores de red
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        AppLogger.error('Network error: ${error.message}');
        return handler.next(const NetworkError(
          message: AppConstants.networkErrorMessage,
        ));
      }
      
      // Manejar errores de servidor
      if (error.response?.statusCode != null) {
        final statusCode = error.response!.statusCode!;
        
        if (statusCode >= 500) {
          AppLogger.error('Server error: ${error.message}');
          return handler.next(const ServerError(
            AppConstants.serverErrorMessage,
          ));
        }
        
        if (statusCode == 401) {
          AppLogger.error('Unauthorized error: ${error.message}');
          return handler.next(const AuthError(
            AppConstants.unauthorizedMessage,
          ));
        }
        
        if (statusCode == 403) {
          AppLogger.error('Forbidden error: ${error.message}');
          return handler.next(const PermissionError(
            AppConstants.unauthorizedMessage,
          ));
        }
        
        if (statusCode == 404) {
          AppLogger.error('Not found error: ${error.message}');
          return handler.next(const NotFoundError(
            'Resource not found',
          ));
        }
        
        if (statusCode == 429) {
          AppLogger.error('Rate limit error: ${error.message}');
          return handler.next(const TimeoutError(
            'Too many requests',
          ));
        }
      }
      
      return handler.next(error);
    },
  );

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
      
      return ApiResponse.fromDioResponse(response);
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
      
      return ApiResponse.fromDioResponse(response);
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
      
      return ApiResponse.fromDioResponse(response);
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
      
      return ApiResponse.fromDioResponse(response);
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
      
      return ApiResponse.fromDioResponse(response);
    } on DioException catch (e) {
      AppLogger.error('PATCH request failed: $e');
      return ApiResponse.error(
        NetworkError(
          message: e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      AppLogger.error('Unexpected error in PATCH request: $e');
      return ApiResponse.error(
        UnknownError(
          message: e.toString(),
        ),
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
          const ValidationError('File size exceeds maximum allowed size'),
        );
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file,
          fileName: fileName,
        ),
        ...?fields,
      });

      final response = await _dio.post<T>(
        endpoint,
        data: formData,
        options: options,
        onSendProgress: onSendProgress,
      );
      
      return ApiResponse.fromDioResponse(response);
    } on DioException catch (e) {
      AppLogger.error('File upload failed: $e');
      return ApiResponse.error(
        UnknownError(e.message ?? 'File upload failed'),
      );
    } catch (e) {
      AppLogger.error('Unexpected error in file upload: $e');
      return ApiResponse.error(
        UnknownError(e.toString()),
      );
    }
  }

  // Métodos para manejar tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: accessToken,
      );
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: refreshToken,
      );
      AppLogger.info('Tokens saved successfully');
    } catch (e) {
      AppLogger.error('Error saving tokens: $e');
      throw const CacheError('Failed to save tokens');
    }
  }

  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: AppConstants.accessTokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
      AppLogger.info('Tokens cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing tokens: $e');
      throw const CacheError('Failed to clear tokens');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.accessTokenKey);
    } catch (e) {
      AppLogger.error('Error getting access token: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      AppLogger.error('Error getting refresh token: $e');
      return null;
    }
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

  // Método para reintentar peticiones
  Future<ApiResponse<T>> retryRequest<T>(
    Future<ApiResponse<T>> Function() request,
    int maxRetries = 3, {
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
} */
