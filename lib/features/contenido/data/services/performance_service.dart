import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/contenido_model.dart';
import '../../domain/entities/contenido.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';

class PerformanceService {
  static const String _performanceLogTag = 'contenido_performance';
  static const String _errorLogTag = 'contenido_error';
  
  // Tiempos de espera para reintentos
  static const int _initialRetryDelayMs = 1000;
  static const int _maxRetryDelayMs = 30000;
  static const int _maxRetries = 3;
  
  // Límites para operaciones
  static const int _maxContenidosPerPage = 50;
  
  final NetworkInfo _networkInfo;
  
  PerformanceService(this._networkInfo);
  
  // Método para ejecutar operaciones con reintentos y manejo de errores
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    String? operationName,
    int? maxRetries,
    bool logPerformance = true,
    bool logErrors = true,
    Map<String, dynamic>? additionalInfo,
  }) async {
    final retries = maxRetries ?? _maxRetries;
    final name = operationName ?? 'unknown_operation';
    final info = additionalInfo ?? {};
    
    Stopwatch? stopwatch;
    if (logPerformance) {
      stopwatch = Stopwatch()..start();
    }
    
    int attempt = 0;
    Exception? lastException;
    
    while (attempt <= retries) {
      attempt++;
      
      try {
        final result = await operation();
        
        if (logPerformance && stopwatch != null) {
          stopwatch.stop();
          _logPerformance(name, stopwatch.elapsedMilliseconds, {
            'attempt': attempt,
            ...info,
          });
        }
        
        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        
        if (logErrors) {
          _logError(name, lastException, {
            'attempt': attempt,
            'maxRetries': retries,
            ...info,
          });
        }
        
        // Si no hay más reintentos, lanzar la excepción
        if (attempt >= retries) {
          break;
        }
        
        // Calcular tiempo de espera para el siguiente reintento
        final delay = _calculateRetryDelay(attempt);
        
        // Esperar antes del siguiente reintento
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
    
    // Si llegamos aquí, todos los reintentos fallaron
    throw lastException ?? ServerException('Operación falló después de $retries intentos');
  }
  
  // Método para optimizar imágenes
  Future<String?> optimizeImageForDisplay(String? imageUrl, {int maxWidth = 800, int maxHeight = 600}) async {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    
    try {
      // Verificar si ya es una URL optimizada
      if (imageUrl.contains('optimized=') || imageUrl.contains('w=') || imageUrl.contains('h=')) {
        return imageUrl;
      }
      
      // Agregar parámetros de optimización a la URL
      final uri = Uri.parse(imageUrl);
      final params = Map<String, String>.from(uri.queryParameters);
      
      params['w'] = maxWidth.toString();
      params['h'] = maxHeight.toString();
      params['fit'] = 'crop';
      params['optimized'] = 'true';
      
      final optimizedUri = Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.port,
        path: uri.path,
        queryParameters: params,
      );
      
      return optimizedUri.toString();
    } catch (e) {
      _logError('optimizeImage', Exception('Error optimizando imagen: $e'), {
        'imageUrl': imageUrl,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
      });
      
      // En caso de error, retornar la URL original
      return imageUrl;
    }
  }
  
  // Método para optimizar lista de contenidos
  Future<List<ContenidoModel>> optimizeContenidosForDisplay(
    List<ContenidoModel> contenidos, {
    int maxItems = 20,
    bool optimizeImages = true,
  }) async {
    if (contenidos.isEmpty) return [];
    
    try {
      // Limitar cantidad de elementos
      final limitedContenidos = contenidos.take(maxItems).toList();
      
      // Optimizar imágenes si se solicita
      if (optimizeImages) {
        final optimizedContenidos = <ContenidoModel>[];
        
        for (final contenido in limitedContenidos) {
          final optimizedThumbnailUrl = await optimizeImageForDisplay(contenido.thumbnailUrl);
          
          final optimizedContenido = contenido.copyWith(
            thumbnailUrl: optimizedThumbnailUrl,
          );
          
          optimizedContenidos.add(optimizedContenido);
        }
        
        return optimizedContenidos;
      }
      
      return limitedContenidos;
    } catch (e) {
      _logError('optimizeContenidos', Exception('Error optimizando contenidos: $e'), {
        'originalCount': contenidos.length,
        'maxItems': maxItems,
        'optimizeImages': optimizeImages,
      });
      
      // En caso de error, retornar la lista original limitada
      return contenidos.take(maxItems).toList();
    }
  }
  
  // Método para verificar y optimizar parámetros de paginación
  Map<String, dynamic> optimizePaginationParams({
    int page = 1,
    int limit = 20,
    int? maxLimit,
  }) {
    // Asegurar que page sea al menos 1
    final safePage = page < 1 ? 1 : page;
    
    // Asegurar que limit esté en un rango válido
    final safeLimit = limit.clamp(
      1,
      maxLimit ?? _maxContenidosPerPage,
    );
    
    return {
      'page': safePage,
      'limit': safeLimit,
    };
  }
  
  // Método para verificar y optimizar parámetros de búsqueda
  Map<String, dynamic> optimizeSearchParams({
    String? query,
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
    int? maxLimit,
  }) {
    // Optimizar parámetros de paginación
    final paginationParams = optimizePaginationParams(
      page: page,
      limit: limit,
      maxLimit: maxLimit,
    );
    
    // Limpiar y validar query
    String? safeQuery;
    if (query != null && query.trim().isNotEmpty) {
      safeQuery = query.trim();
      // Limitar longitud del query
      if (safeQuery.length > 100) {
        safeQuery = safeQuery.substring(0, 100);
      }
    }
    
    return {
      'query': safeQuery,
      'categoria': categoria,
      'tipo': tipo,
      'nivel': nivel,
      ...paginationParams,
    };
  }
  
  // Método para verificar si hay conexión y actuar en consecuencia
  Future<bool> checkConnectionAndAct({
    required Function() onlineAction,
    required Function() offlineAction,
    String? operationName,
  }) async {
    final isConnected = await _networkInfo.isConnected;
    final name = operationName ?? 'unknown_operation';
    
    if (isConnected) {
      _logPerformance(name, 0, {'status': 'online'});
      await onlineAction();
      return true;
    } else {
      _logPerformance(name, 0, {'status': 'offline'});
      await offlineAction();
      return false;
    }
  }
  
  // Método para manejar errores de manera centralizada
  Failure handleException(Exception exception, {String? operationName}) {
    final name = operationName ?? 'unknown_operation';
    
    if (exception is ServerException) {
      _logError(name, exception, {'type': 'ServerException'});
      return ServerFailure(exception.message);
    } else if (exception is NetworkException) {
      _logError(name, exception, {'type': 'NetworkException'});
      return NetworkFailure(exception.message);
    } else if (exception is CacheException) {
      _logError(name, exception, {'type': 'CacheException'});
      return CacheFailure(exception.message);
    } else if (exception is ParseException) {
      _logError(name, exception, {'type': 'ParseException'});
      return const ParseFailure('Error al procesar los datos');
    } else if (exception.toString().contains('Permission')) {
      _logError(name, exception, {'type': 'PermissionException'});
      return const PermissionFailure('No tienes permisos para realizar esta acción');
    } else {
      _logError(name, exception, {'type': 'UnknownException'});
      return ServerFailure('Error desconocido: ${exception.toString()}');
    }
  }
  
  // Método para registrar métricas de rendimiento
  void recordMetric(String name, dynamic value, {Map<String, dynamic>? additionalInfo}) {
    if (kDebugMode) {
      developer.log(
        'METRIC: $name = $value',
        name: _performanceLogTag,
        time: DateTime.now(),
        level: name == 'error' ? 1000 : 500,
        zone: Zone.current,
        error: additionalInfo,
      );
    }
  }
  
  // Método privado para calcular tiempo de espera entre reintentos
  int _calculateRetryDelay(int attempt) {
    // Usar backoff exponencial con jitter
    final baseDelay = _initialRetryDelayMs * (1 << (attempt - 1));
    final jitter = (baseDelay * 0.1).toInt();
    final delay = baseDelay + (jitter * (DateTime.now().millisecond % 10 - 5));
    
    return delay.clamp(_initialRetryDelayMs, _maxRetryDelayMs);
  }
  
  // Método privado para registrar logs de rendimiento
  void _logPerformance(String operation, int durationMs, Map<String, dynamic> info) {
    if (kDebugMode) {
      developer.log(
        'PERFORMANCE: $operation completed in ${durationMs}ms',
        name: _performanceLogTag,
        time: DateTime.now(),
        level: 700,
        zone: Zone.current,
        error: info,
      );
    }
    
    // Registrar métrica
    recordMetric('${operation}_duration', durationMs, additionalInfo: info);
  }
  
  // Método privado para registrar logs de errores
  void _logError(String operation, Exception exception, Map<String, dynamic> info) {
    if (kDebugMode) {
      developer.log(
        'ERROR: $operation failed - ${exception.toString()}',
        name: _errorLogTag,
        time: DateTime.now(),
        level: 1000,
        zone: Zone.current,
        error: {'exception': exception.toString(), ...info},
      );
    }
    
    // Registrar métrica de error
    recordMetric('${operation}_error', 1, additionalInfo: {
      'exception': exception.toString(),
      ...info,
    });
  }
}