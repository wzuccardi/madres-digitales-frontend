import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import '../config/app_config.dart';
import 'auth_service.dart';

class ApiService {
  static final String baseUrl = AppConfig.getApiUrl();
  static const String androidEmulatorUrl = AppConfig.androidEmulatorUrl;

  late final Dio _dio;
  static const _storage = FlutterSecureStorage();
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;
  
  // Getter para acceder a la instancia de Dio desde fuera de la clase
  Dio get dioInstance => _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: AppConfig.apiHeaders,
    ));

    _setupInterceptors();
  }
  

  
  void _setupInterceptors() {
    // Interceptor para agregar token de autenticaciÃ³n
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        
        // ðŸ” DEBUG: Verificar si AuthService estÃ¡ inicializado
        try {
          final authService = AuthService();
          
          // Forzar inicializaciÃ³n si no estÃ¡ autenticado
          if (!authService.isAuthenticated) {
            await authService.initialize();
          }
          
        } catch (e) {
        }
        
        String? token;
        
        // Intentar obtener el token de FlutterSecureStorage primero (mÃ¡s confiable)
        token = await _storage.read(key: 'auth_token');
        
        // Si no se encuentra en FlutterSecureStorage, intentar en SharedPreferences
        if (token == null) {
          try {
            final prefs = await SharedPreferences.getInstance();
            token = prefs.getString('auth_token');
            
            // Si se encuentra en SharedPreferences, guardarlo en FlutterSecureStorage para futuras solicitudes
            if (token != null) {
              await _storage.write(key: 'auth_token', value: token);
            }
          } catch (e) {
          }
        }
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        
        // Log response data but truncate if too large
        if (response.data.toString().length > 500) {
        } else {
        }
        
        handler.next(response);
      },
      onError: (error, handler) async {
        
        if (error.response?.statusCode == 401) {
          // Token expirado, limpiar storage
          await _storage.delete(key: 'auth_token');
          await _storage.delete(key: 'user_data');
        }
        
        // TEMPORAL: Manejar endpoints 404 hasta que se desplieguen
        if (error.response?.statusCode == 404) {
          final path = error.requestOptions.path;
          if (path.contains('/controles')) {
            // Devolver lista vacÃ­a directamente (sin wrapper success/data)
            final response = Response(
              requestOptions: error.requestOptions,
              statusCode: 200,
              data: [], // Lista vacÃ­a directamente
            );
            handler.resolve(response);
            return;
          } else if (path.contains('/contenido-crud')) {
            // Devolver lista vacÃ­a directamente
            final response = Response(
              requestOptions: error.requestOptions,
              statusCode: 200,
              data: [], // Lista vacÃ­a directamente
            );
            handler.resolve(response);
            return;
          } else if (path.contains('/auth/refresh')) {
            // Devolver respuesta de refresh exitoso
            final response = Response(
              requestOptions: error.requestOptions,
              statusCode: 200,
              data: {
                'success': true,
                'data': {
                  'token': 'demo-refreshed-token-${DateTime.now().millisecondsSinceEpoch}',
                  'refreshToken': 'refresh-${DateTime.now().millisecondsSinceEpoch}',
                  'expiresIn': 3600
                }
              },
            );
            handler.resolve(response);
            return;
          }
        }
        
        handler.next(error);
      },
    ));
    
    // Interceptor para logging en desarrollo
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => AppLogger.instance.debug(obj.toString()),
    ));
  }
  
  // MÃ©todos HTTP genÃ©ricos
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Si el cuerpo es FormData, aseguramos content-type multipart/form-data
      final bool isMultipart = data is FormData;
      final Options? effectiveOptions = isMultipart
          ? Options(contentType: Headers.multipartFormDataContentType)
          : options;

      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: effectiveOptions,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Tiempo de conexiÃ³n agotado. Verifica tu conexiÃ³n a internet.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Error del servidor';
        return Exception('Error $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Solicitud cancelada');
      case DioExceptionType.unknown:
        return Exception('Error de conexiÃ³n. Verifica que el servidor estÃ© ejecutÃ¡ndose.');
      default:
        return Exception('Error desconocido: ${error.message}');
    }
  }
  
  // ==================== MUNICIPIOS ====================

  // Obtener municipios con filtros
  Future<Map<String, dynamic>> _getMunicipios({
    int page = 1,
    int limit = 50,
    bool? activo,
    String? departamento,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (activo != null) queryParams['activo'] = activo;
      if (departamento != null) queryParams['departamento'] = departamento;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get('/municipios', queryParameters: queryParams);
      return response.data;
    } catch (e) {
      AppLogger.instance.error('Error obteniendo municipios: $e');
      if (e is DioException) {
        throw _handleError(e);
      } else {
        throw Exception('Error de conexiÃ³n: $e');
      }
    }
  }

  // Obtener municipio por ID
  Future<Map<String, dynamic>?> _getMunicipio(String id) async {
    try {
      final response = await _dio.get('/municipios/$id');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      AppLogger.instance.error('Error obteniendo municipio: $e');
      if (e is DioException) {
        throw _handleError(e);
      } else {
        throw Exception('Error de conexiÃ³n: $e');
      }
    }
  }

  // Activar municipio
  Future<Map<String, dynamic>> _activarMunicipio(String id) async {
    try {
      final response = await _dio.post('/municipios/$id/activar');
      return response.data;
    } catch (e) {
      AppLogger.instance.error('Error activando municipio: $e');
      if (e is DioException) {
        throw _handleError(e);
      } else {
        throw Exception('Error de conexiÃ³n: $e');
      }
    }
  }

  // Desactivar municipio
  Future<Map<String, dynamic>> _desactivarMunicipio(String id) async {
    try {
      final response = await _dio.post('/municipios/$id/desactivar');
      return response.data;
    } catch (e) {
      AppLogger.instance.error('Error desactivando municipio: $e');
      if (e is DioException) {
        throw _handleError(e);
      } else {
        throw Exception('Error de conexiÃ³n: $e');
      }
    }
  }

  // Obtener estadÃ­sticas de municipios
  Future<Map<String, dynamic>> _getEstadisticasMunicipios() async {
    try {
      final response = await _dio.get('/municipios/stats');
      return response.data;
    } catch (e) {
      AppLogger.instance.error('Error obteniendo estadÃ­sticas de municipios: $e');
      if (e is DioException) {
        throw _handleError(e);
      } else {
        throw Exception('Error de conexiÃ³n: $e');
      }
    }
  }

  // Buscar municipios cercanos
  Future<List<Map<String, dynamic>>> _buscarMunicipiosCercanos({
    required double latitude,
    required double longitude,
    double radius = 50,
  }) async {
    try {
      final response = await _dio.get('/municipios/cercanos', queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      });

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? 'Error buscando municipios cercanos');
      }
    } catch (e) {
      AppLogger.instance.error('Error buscando municipios cercanos: $e');
      if (e is DioException) {
        throw _handleError(e);
      } else {
        throw Exception('Error de conexiÃ³n: $e');
      }
    }
  }

  // Importar municipios de BolÃ­var
  Future<Map<String, dynamic>> _importarMunicipiosBolivar() async {
    try {
      final response = await _dio.post('/municipios/import/bolivar');
      return response.data;
    } catch (e) {
      AppLogger.instance.error('Error importando municipios de BolÃ­var: $e');
      if (e is DioException) {
        throw _handleError(e);
      } else {
        throw Exception('Error de conexiÃ³n: $e');
      }
    }
  }

  // ==================== MÃ‰TODOS ESTÃTICOS PARA COMPATIBILIDAD ====================

  // MÃ©todos estÃ¡ticos para municipios
  static Future<Map<String, dynamic>> getMunicipios({
    int page = 1,
    int limit = 50,
    bool? activo,
    String? departamento,
    String? search,
  }) async {
    return await _instance._getMunicipios(
      page: page,
      limit: limit,
      activo: activo,
      departamento: departamento,
      search: search,
    );
  }

  static Future<Map<String, dynamic>?> getMunicipio(String id) async {
    return await _instance._getMunicipio(id);
  }

  static Future<Map<String, dynamic>> activarMunicipio(String id) async {
    return await _instance._activarMunicipio(id);
  }

  static Future<Map<String, dynamic>> desactivarMunicipio(String id) async {
    return await _instance._desactivarMunicipio(id);
  }

  static Future<Map<String, dynamic>> getEstadisticasMunicipios() async {
    return await _instance._getEstadisticasMunicipios();
  }

  static Future<List<Map<String, dynamic>>> buscarMunicipiosCercanos({
    required double latitude,
    required double longitude,
    double radius = 50,
  }) async {
    return await _instance._buscarMunicipiosCercanos(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }

  static Future<Map<String, dynamic>> importarMunicipiosBolivar() async {
    return await _instance._importarMunicipiosBolivar();
  }

  // MÃ©todos de utilidad
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
  }

  // MÃ©todos para Municipios
  static Future<void> updateMunicipioEstado(String municipioId, bool nuevoEstado) async {
    try {
      await _instance._dio.put('/municipios/$municipioId/estado',
        data: {'activo': nuevoEstado}
      );
    } catch (e) {
      throw Exception('Error actualizando estado del municipio: $e');
    }
  }

  // MÃ©todos para IPS
  static Future<List<Map<String, dynamic>>> getIPS() async {
    try {
      final response = await _instance._dio.get('/ips');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Error obteniendo IPS: $e');
    }
  }

  static Future<void> createIPS(Map<String, dynamic> ipsData) async {
    try {
      await _instance._dio.post('/ips', data: ipsData);
    } catch (e) {
      throw Exception('Error creando IPS: $e');
    }
  }

  static Future<void> updateIPS(String ipsId, Map<String, dynamic> ipsData) async {
    try {
      await _instance._dio.put('/ips/$ipsId', data: ipsData);
    } catch (e) {
      throw Exception('Error actualizando IPS: $e');
    }
  }

  // MÃ©todos para MÃ©dicos
  static Future<List<Map<String, dynamic>>> getMedicos() async {
    try {
      final response = await _instance._dio.get('/medicos');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Error obteniendo mÃ©dicos: $e');
    }
  }

  static Future<void> createMedico(Map<String, dynamic> medicoData) async {
    try {
      await _instance._dio.post('/medicos', data: medicoData);
    } catch (e) {
      throw Exception('Error creando mÃ©dico: $e');
    }
  }

  static Future<void> updateMedico(String medicoId, Map<String, dynamic> medicoData) async {
    try {
      await _instance._dio.put('/medicos/$medicoId', data: medicoData);
    } catch (e) {
      throw Exception('Error actualizando mÃ©dico: $e');
    }
  }
}
