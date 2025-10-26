import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';
import 'package:madres_digitales_flutter_new/services/api_service.dart';

/// Modelo para error offline
class OfflineError {
  final String id;
  final String type;
  final String message;
  final String? stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic>? context;
  final Map<String, dynamic>? requestData;
  final String? endpoint;
  final String? method;
  final bool isResolved;
  final DateTime? resolvedAt;
  final int retryCount;
  final int maxRetries;
  final DateTime? nextRetryAt;

  OfflineError({
    required this.id,
    required this.type,
    required this.message,
    this.stackTrace,
    required this.timestamp,
    this.context,
    this.requestData,
    this.endpoint,
    this.method,
    this.isResolved = false,
    this.resolvedAt,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.nextRetryAt,
  });

  /// Convertir a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'stackTrace': stackTrace,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'requestData': requestData,
      'endpoint': endpoint,
      'method': method,
      'isResolved': isResolved,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'retryCount': retryCount,
      'maxRetries': maxRetries,
      'nextRetryAt': nextRetryAt?.toIso8601String(),
    };
  }

  /// Crear desde JSON
  factory OfflineError.fromJson(Map<String, dynamic> json) {
    return OfflineError(
      id: json['id'],
      type: json['type'],
      message: json['message'],
      stackTrace: json['stackTrace'],
      timestamp: DateTime.parse(json['timestamp']),
      context: json['context'],
      requestData: json['requestData'],
      endpoint: json['endpoint'],
      method: json['method'],
      isResolved: json['isResolved'] ?? false,
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      retryCount: json['retryCount'] ?? 0,
      maxRetries: json['maxRetries'] ?? 3,
      nextRetryAt: json['nextRetryAt'] != null ? DateTime.parse(json['nextRetryAt']) : null,
    );
  }

  /// Crear una copia con valores actualizados
  OfflineError copyWith({
    String? id,
    String? type,
    String? message,
    String? stackTrace,
    DateTime? timestamp,
    Map<String, dynamic>? context,
    Map<String, dynamic>? requestData,
    String? endpoint,
    String? method,
    bool? isResolved,
    DateTime? resolvedAt,
    int? retryCount,
    int? maxRetries,
    DateTime? nextRetryAt,
  }) {
    return OfflineError(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      context: context ?? this.context,
      requestData: requestData ?? this.requestData,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      isResolved: isResolved ?? this.isResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    );
  }

  /// Verificar si se puede reintentar el error
  bool get canRetry {
    return !isResolved && 
           retryCount < maxRetries && 
           (nextRetryAt == null || DateTime.now().isAfter(nextRetryAt!));
  }

  /// Verificar si el error es crítico
  bool get isCritical {
    return type == 'network_timeout' || 
           type == 'server_error' || 
           type == 'authentication_error';
  }

  /// Verificar si el error es reciente (menos de 1 hora)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inHours < 1;
  }

  @override
  String toString() {
    return 'OfflineError{id: $id, type: $type, message: $message, isResolved: $isResolved}';
  }
}

/// Eventos de manejo de errores offline
enum OfflineErrorEventType {
  errorCaptured,
  errorRetried,
  errorResolved,
  errorFailed,
  queueCleared,
  syncCompleted,
}

/// Evento de manejo de errores offline
class OfflineErrorEvent {
  final OfflineErrorEventType type;
  final OfflineError? error;
  final DateTime timestamp;
  final String? message;

  OfflineErrorEvent({
    required this.type,
    this.error,
    this.message,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'OfflineErrorEvent{type: $type, error: $error, timestamp: $timestamp}';
  }
}

/// Estrategia de reintento para errores offline
enum RetryStrategy {
  immediate,      // Reintentar inmediatamente
  exponential,    // Backoff exponencial
  fixed,          // Intervalo fijo
  linear,         // Intervalo lineal creciente
}

/// Servicio para manejo consistente de errores offline
class OfflineErrorService {
  static const String _errorQueueKey = 'offline_error_queue';
  static const String _errorStatsKey = 'offline_error_stats';
  
  // NUEVO: Límite máximo de errores en la cola
  static const int _maxErrorQueueSize = 100;
  
  // NUEVO: Tiempo máximo para retener errores (7 días)
  static const Duration _maxErrorAge = Duration(days: 7);
  
  // NUEVO: Stream para notificar eventos de errores
  final StreamController<OfflineErrorEvent> _eventController = 
      StreamController<OfflineErrorEvent>.broadcast();
  
  Stream<OfflineErrorEvent> get events => _eventController.stream;
  
  // NUEVO: Cola de errores pendientes
  final List<OfflineError> _errorQueue = [];
  
  // NUEVO: Mapa para control de reintentos activos
  final Map<String, Completer<bool>> _activeRetries = {};
  
  // NUEVO: Timer para sincronización automática
  Timer? _syncTimer;
  
  // NUEVO: Estado de conectividad
  bool _isOnline = true;
  
  // NUEVO: Estrategia de reintento predeterminada
  RetryStrategy _retryStrategy = RetryStrategy.exponential;
  
  // NUEVO: API service para reintentos
  final ApiService? _apiService;

  OfflineErrorService({ApiService? apiService}) : _apiService = apiService {
    // Inicializar timer de sincronización
    _startSyncTimer();
    
    // Escuchar cambios de conectividad
    _initializeConnectivityListener();
  }

  /// NUEVO: Capturar error y agregar a la cola
  Future<void> captureError({
    required String type,
    required String message,
    String? stackTrace,
    Map<String, dynamic>? context,
    Map<String, dynamic>? requestData,
    String? endpoint,
    String? method,
    int maxRetries = 3,
  }) async {
    try {
      final errorId = _generateErrorId();
      final now = DateTime.now();
      
      final error = OfflineError(
        id: errorId,
        type: type,
        message: message,
        stackTrace: stackTrace,
        timestamp: now,
        context: context,
        requestData: requestData,
        endpoint: endpoint,
        method: method,
        maxRetries: maxRetries,
        nextRetryAt: _calculateNextRetryTime(now, 0, type),
      );
      
      // Agregar a la cola
      await _addErrorToQueue(error);
      
      // Intentar resolver si está online
      if (_isOnline) {
        _retryError(error);
      }
      
      'OfflineErrorService: Error capturado'.debug(context: {
        'errorId': errorId,
        'type': type,
        'message': message,
        'endpoint': endpoint,
        'method': method,
      });
      
      // Emitir evento de error capturado
      _eventController.add(OfflineErrorEvent(
        type: OfflineErrorEventType.errorCaptured,
        error: error,
      ));
    } catch (e) {
      'Error capturando error offline'.error(error: e);
    }
  }

  /// NUEVO: Reintentar error específico
  Future<bool> retryError(String errorId) async {
    try {
      final error = _errorQueue.firstWhere((e) => e.id == errorId);
      
      if (!error.canRetry) {
        'OfflineErrorService: Error no puede ser reintentado'.warn(context: {
          'errorId': errorId,
          'isResolved': error.isResolved,
          'retryCount': error.retryCount,
          'maxRetries': error.maxRetries,
        });
        return false;
      }
      
      // Verificar si ya hay un reintento activo
      if (_activeRetries.containsKey(errorId)) {
        'OfflineErrorService: Reintento ya en progreso'.debug(context: {
          'errorId': errorId,
        });
        
        try {
          return await _activeRetries[errorId]!.future;
        } catch (e) {
          'Error esperando reintento activo'.error(error: e);
          return false;
        }
      }
      
      return await _retryError(error);
    } catch (e) {
      'Error reintentando error offline'.error(error: e, context: {
        'errorId': errorId,
      });
      return false;
    }
  }

  /// NUEVO: Reintentar todos los errores pendientes
  Future<int> retryAllErrors() async {
    try {
      'OfflineErrorService: Reintentando todos los errores pendientes'.debug();
      
      final pendingErrors = _errorQueue.where((error) => error.canRetry).toList();
      
      if (pendingErrors.isEmpty) {
        'OfflineErrorService: No hay errores pendientes para reintentar'.debug();
        return 0;
      }
      
      int retriedCount = 0;
      
      // Ejecutar reintentos en paralelo con límite de concurrencia
      final futures = <Future<bool>>[];
      const concurrencyLimit = 5;
      
      for (final error in pendingErrors) {
        futures.add(_retryError(error));
        
        if (futures.length >= concurrencyLimit) {
          final results = await Future.wait(futures);
          retriedCount += results.where((success) => success).length;
          futures.clear();
        }
      }
      
      // Procesar los restantes
      if (futures.isNotEmpty) {
        final results = await Future.wait(futures);
        retriedCount += results.where((success) => success).length;
      }
      
      'OfflineErrorService: Reintentos completados'.debug(context: {
        'totalErrors': pendingErrors.length,
        'retriedCount': retriedCount,
      });
      
      // Emitir evento de sincronización completada
      _eventController.add(OfflineErrorEvent(
        type: OfflineErrorEventType.syncCompleted,
        message: 'Reintentados $retriedCount de ${pendingErrors.length} errores',
      ));
      
      return retriedCount;
    } catch (e) {
      'Error reintentando todos los errores'.error(error: e);
      return 0;
    }
  }

  /// NUEVO: Marcar error como resuelto
  Future<bool> resolveError(String errorId) async {
    try {
      final errorIndex = _errorQueue.indexWhere((e) => e.id == errorId);
      
      if (errorIndex == -1) {
        'OfflineErrorService: Error no encontrado'.warn(context: {
          'errorId': errorId,
        });
        return false;
      }
      
      final error = _errorQueue[errorIndex];
      final resolvedError = error.copyWith(
        isResolved: true,
        resolvedAt: DateTime.now(),
      );
      
      _errorQueue[errorIndex] = resolvedError;
      await _saveErrorQueue();
      
      'OfflineErrorService: Error marcado como resuelto'.debug(context: {
        'errorId': errorId,
        'type': error.type,
      });
      
      // Emitir evento de error resuelto
      _eventController.add(OfflineErrorEvent(
        type: OfflineErrorEventType.errorResolved,
        error: resolvedError,
      ));
      
      return true;
    } catch (e) {
      'Error resolviendo error offline'.error(error: e, context: {
        'errorId': errorId,
      });
      return false;
    }
  }

  /// NUEVO: Eliminar error de la cola
  Future<bool> removeError(String errorId) async {
    try {
      final initialLength = _errorQueue.length;
      _errorQueue.removeWhere((error) => error.id == errorId);
      
      if (_errorQueue.length < initialLength) {
        await _saveErrorQueue();
        
        'OfflineErrorService: Error eliminado de la cola'.debug(context: {
          'errorId': errorId,
        });
        
        return true;
      }
      
      'OfflineErrorService: Error no encontrado para eliminar'.warn(context: {
        'errorId': errorId,
      });
      
      return false;
    } catch (e) {
      'Error eliminando error offline'.error(error: e, context: {
        'errorId': errorId,
      });
      return false;
    }
  }

  /// NUEVO: Limpiar todos los errores
  Future<void> clearAllErrors() async {
    try {
      'OfflineErrorService: Limpiando todos los errores';
      
      _errorQueue.clear();
      await _saveErrorQueue();
      
      // Emitir evento de cola limpiada
      _eventController.add(OfflineErrorEvent(
        type: OfflineErrorEventType.queueCleared,
        message: 'Todos los errores han sido eliminados',
      ));
    } catch (e) {
      'Error limpiando todos los errores'.error(error: e);
    }
  }

  /// NUEVO: Obtener todos los errores
  Future<List<OfflineError>> getAllErrors() async {
    try {
      // Cargar desde SharedPreferences si la cola está vacía
      if (_errorQueue.isEmpty) {
        await _loadErrorQueue();
      }
      
      return List.from(_errorQueue);
    } catch (e) {
      'Error obteniendo todos los errores'.error(error: e);
      return [];
    }
  }

  /// NUEVO: Obtener errores no resueltos
  Future<List<OfflineError>> getUnresolvedErrors() async {
    final allErrors = await getAllErrors();
    return allErrors.where((error) => !error.isResolved).toList();
  }

  /// NUEVO: Obtener errores críticos
  Future<List<OfflineError>> getCriticalErrors() async {
    final allErrors = await getAllErrors();
    return allErrors.where((error) => error.isCritical && !error.isResolved).toList();
  }

  /// NUEVO: Obtener estadísticas de errores
  Future<Map<String, dynamic>> getErrorStats() async {
    try {
      final allErrors = await getAllErrors();
      
      final Map<String, int> errorsByType = {};
      final Map<String, int> errorsByEndpoint = {};
      
      int totalErrors = 0;
      int resolvedErrors = 0;
      int criticalErrors = 0;
      int recentErrors = 0;
      
      for (final error in allErrors) {
        totalErrors++;
        
        if (error.isResolved) {
          resolvedErrors++;
        }
        
        if (error.isCritical) {
          criticalErrors++;
        }
        
        if (error.isRecent) {
          recentErrors++;
        }
        
        // Contar por tipo
        errorsByType[error.type] = (errorsByType[error.type] ?? 0) + 1;
        
        // Contar por endpoint
        if (error.endpoint != null) {
          errorsByEndpoint[error.endpoint!] = (errorsByEndpoint[error.endpoint!] ?? 0) + 1;
        }
      }
      
      return {
        'totalErrors': totalErrors,
        'unresolvedErrors': totalErrors - resolvedErrors,
        'resolvedErrors': resolvedErrors,
        'criticalErrors': criticalErrors,
        'recentErrors': recentErrors,
        'errorsByType': errorsByType,
        'errorsByEndpoint': errorsByEndpoint,
        'isOnline': _isOnline,
        'retryStrategy': _retryStrategy.toString(),
        'maxQueueSize': _maxErrorQueueSize,
      };
    } catch (e) {
      'Error obteniendo estadísticas de errores'.error(error: e);
      return {};
    }
  }

  /// NUEVO: Establecer estrategia de reintento
  void setRetryStrategy(RetryStrategy strategy) {
    _retryStrategy = strategy;
    
    'OfflineErrorService: Estrategia de reintento actualizada'.debug(context: {
      'strategy': strategy.toString(),
    });
  }

  /// NUEVO: Actualizar estado de conectividad
  void setConnectivityStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      
      'OfflineErrorService: Estado de conectividad actualizado'.debug(context: {
        'isOnline': isOnline,
      });
      
      // Si vuelve a estar online, intentar reintentar errores pendientes
      if (isOnline) {
        _retryPendingErrors();
      }
    }
  }

  /// NUEVO: Método privado para agregar error a la cola
  Future<void> _addErrorToQueue(OfflineError error) async {
    // Verificar si ya existe un error similar
    final existingErrorIndex = _errorQueue.indexWhere(
      (e) => e.type == error.type && 
             e.endpoint == error.endpoint && 
             e.method == error.method &&
             !e.isResolved
    );
    
    if (existingErrorIndex != -1) {
      // Actualizar error existente en lugar de agregar uno nuevo
      final existingError = _errorQueue[existingErrorIndex];
      _errorQueue[existingErrorIndex] = existingError.copyWith(
        timestamp: DateTime.now(),
        retryCount: 0,
        nextRetryAt: _calculateNextRetryTime(DateTime.now(), 0, error.type),
      );
      
      'OfflineErrorService: Error existente actualizado'.debug(context: {
        'errorId': existingError.id,
        'type': error.type,
      });
    } else {
      // Mantener el tamaño máximo de la cola
      if (_errorQueue.length >= _maxErrorQueueSize) {
        _errorQueue.removeAt(0); // Eliminar el más antiguo
      }
      
      _errorQueue.add(error);
      'OfflineErrorService: Error agregado a la cola'.debug(context: {
        'errorId': error.id,
        'type': error.type,
        'queueSize': _errorQueue.length,
      });
    }
    
    await _saveErrorQueue();
  }

  /// NUEVO: Método privado para reintentar error
  Future<bool> _retryError(OfflineError error) async {
    if (_activeRetries.containsKey(error.id)) {
      return false;
    }
    
    final completer = Completer<bool>();
    _activeRetries[error.id] = completer;
    
    try {
      'OfflineErrorService: Reintentando error'.debug(context: {
        'errorId': error.id,
        'type': error.type,
        'retryCount': error.retryCount + 1,
        'endpoint': error.endpoint,
        'method': error.method,
      });
      
      // Actualizar contador de reintentos
      final updatedError = error.copyWith(
        retryCount: error.retryCount + 1,
        nextRetryAt: _calculateNextRetryTime(
          DateTime.now(), 
          error.retryCount + 1, 
          error.type
        ),
      );
      
      // Actualizar error en la cola
      final errorIndex = _errorQueue.indexWhere((e) => e.id == error.id);
      if (errorIndex != -1) {
        _errorQueue[errorIndex] = updatedError;
      }
      
      // Emitir evento de reintento
      _eventController.add(OfflineErrorEvent(
        type: OfflineErrorEventType.errorRetried,
        error: updatedError,
        message: 'Reintento ${updatedError.retryCount}/${updatedError.maxRetries}',
      ));
      
      // Ejecutar reintento
      bool success = false;
      
      if (error.requestData != null && error.endpoint != null) {
        // Reintentar la solicitud original
        success = await _retryRequest(
          endpoint: error.endpoint!,
          method: error.method ?? 'GET',
          requestData: error.requestData!,
        );
      } else {
        // Para otros tipos de errores, solo marcamos como resuelto
        success = true;
      }
      
      if (success) {
        // Marcar como resuelto
        await resolveError(error.id);
        
        'OfflineErrorService: Error resuelto exitosamente'.debug(context: {
          'errorId': error.id,
          'type': error.type,
        });
      } else {
        // Verificar si se puede volver a reintentar
        if (updatedError.canRetry) {
          'OfflineErrorService: Reintento fallido, se programará próximo reintento'.debug(context: {
            'errorId': error.id,
            'nextRetryAt': updatedError.nextRetryAt,
          });
          completer.complete(false);
        } else {
          // Marcar como fallido permanentemente
          final failedError = updatedError.copyWith(
            isResolved: true,
            resolvedAt: DateTime.now(),
          );
          
          final failedErrorIndex = _errorQueue.indexWhere((e) => e.id == error.id);
          if (failedErrorIndex != -1) {
            _errorQueue[failedErrorIndex] = failedError;
          }
          
          await _saveErrorQueue();
          
          'OfflineErrorService: Error marcado como fallido permanentemente'.warn(context: {
            'errorId': error.id,
            'type': error.type,
            'retryCount': updatedError.retryCount,
          });
          
          // Emitir evento de error fallido
          _eventController.add(OfflineErrorEvent(
            type: OfflineErrorEventType.errorFailed,
            error: failedError,
          ));
          
          completer.complete(false);
        }
      }
      
      return success;
    } catch (e) {
      'Error en reintento de error'.error(error: e, context: {
        'errorId': error.id,
      });
      
      completer.complete(false);
      return false;
    } finally {
      _activeRetries.remove(error.id);
      await _saveErrorQueue();
    }
  }

  /// NUEVO: Método privado para reintentar solicitud HTTP
  Future<bool> _retryRequest({
    required String endpoint,
    required String method,
    required Map<String, dynamic> requestData,
  }) async {
    if (_apiService == null) {
      'OfflineErrorService: API service no disponible para reintento'.warn();
      return false;
    }
    
    try {
      dynamic response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _apiService!.get(endpoint);
          break;
        case 'POST':
          response = await _apiService!.post(endpoint, data: requestData);
          break;
        case 'PUT':
          response = await _apiService!.put(endpoint, data: requestData);
          break;
        case 'DELETE':
          response = await _apiService!.delete(endpoint);
          break;
        default:
          'OfflineErrorService: Método HTTP no soportado'.warn(context: {
            'method': method,
          });
          return false;
      }
      
      // Verificar si la respuesta fue exitosa
      return response['success'] == true;
    } catch (e) {
      'Error reintentando solicitud HTTP'.error(error: e, context: {
        'endpoint': endpoint,
        'method': method,
      });
      return false;
    }
  }

  /// NUEVO: Método privado para reintentar errores pendientes
  Future<void> _retryPendingErrors() async {
    try {
      final pendingErrors = _errorQueue.where((error) => error.canRetry).toList();
      
      if (pendingErrors.isEmpty) {
        return;
      }
      
      'OfflineErrorService: Reintentando errores pendientes'.debug(context: {
        'pendingCount': pendingErrors.length,
      });
      
      // Retardar un poco para dar tiempo a que la conexión se estabilice
      await Future.delayed(const Duration(seconds: 2));
      
      await retryAllErrors();
    } catch (e) {
      'Error reintentando errores pendientes'.error(error: e);
    }
  }

  /// NUEVO: Método privado para calcular próximo tiempo de reintento
  DateTime _calculateNextRetryTime(DateTime now, int retryCount, String errorType) {
    Duration delay;
    
    switch (_retryStrategy) {
      case RetryStrategy.immediate:
        delay = const Duration(seconds: 1);
        break;
        
      case RetryStrategy.exponential:
        // Backoff exponencial: 2^retryCount segundos, máximo 5 minutos
        final seconds = [1, 2, 4, 8, 16, 32, 64, 128, 256, 300]
            .elementAt(retryCount.clamp(0, 9));
        delay = Duration(seconds: seconds);
        break;
        
      case RetryStrategy.fixed:
        delay = const Duration(seconds: 30);
        break;
        
      case RetryStrategy.linear:
        // Intervalo lineal creciente: 30, 60, 90, 120, 150 segundos
        final seconds = 30 * (retryCount + 1);
        delay = Duration(seconds: seconds.clamp(0, 150));
        break;
    }
    
    // Ajustar delay según el tipo de error
    if (errorType == 'network_timeout' || errorType == 'server_error') {
      delay = Duration(milliseconds: (delay.inMilliseconds * 1.5).round());
    }
    
    return now.add(delay);
  }

  /// NUEVO: Método privado para generar ID de error
  String _generateErrorId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    return 'error_${timestamp}_$random';
  }

  /// NUEVO: Método privado para guardar cola de errores
  Future<void> _saveErrorQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final errorQueueJson = jsonEncode(
        _errorQueue.map((error) => error.toJson()).toList()
      );
      await prefs.setString(_errorQueueKey, errorQueueJson);
    } catch (e) {
      'Error guardando cola de errores'.error(error: e);
    }
  }

  /// NUEVO: Método privado para cargar cola de errores
  Future<void> _loadErrorQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final errorQueueJson = prefs.getString(_errorQueueKey);
      
      if (errorQueueJson != null) {
        final List<dynamic> errorData = jsonDecode(errorQueueJson);
        final errors = errorData
            .map((json) => OfflineError.fromJson(json))
            .where((error) => !error.isResolved && 
                   DateTime.now().difference(error.timestamp).inDays < _maxErrorAge.inDays)
            .toList();
        
        _errorQueue.clear();
        _errorQueue.addAll(errors);
        
        'OfflineErrorService: Cola de errores cargada'.debug(context: {
          'errorCount': errors.length,
        });
      }
    } catch (e) {
      'Error cargando cola de errores'.error(error: e);
    }
  }

  /// NUEVO: Método privado para iniciar timer de sincronización
  void _startSyncTimer() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_isOnline) {
        _retryPendingErrors();
      }
    });
  }

  /// NUEVO: Método privado para inicializar listener de conectividad
  void _initializeConnectivityListener() {
    // En una implementación real, aquí se usaría un paquete como 'connectivity'
    // para escuchar cambios en el estado de la conexión
    
    // Por ahora, simulamos cambios periódicos
    Timer.periodic(const Duration(seconds: 10), (timer) {
      // Simular verificación de conectividad
      _checkConnectivity();
    });
  }

  /// NUEVO: Método privado para verificar conectividad
  Future<void> _checkConnectivity() async {
    try {
      // En una implementación real, aquí se verificaría la conectividad
      // Por ahora, asumimos que siempre estamos online
      
      // Simulación: verificar si hay conexión a internet
      final result = await InternetAddress.lookup('google.com');
      
      final wasOnline = _isOnline;
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (wasOnline != _isOnline) {
        setConnectivityStatus(_isOnline);
      }
    } catch (e) {
      if (_isOnline) {
        setConnectivityStatus(false);
      }
    }
  }

  /// NUEVO: Método privado para limpiar errores antiguos
  Future<void> _cleanupOldErrors() async {
    try {
      final now = DateTime.now();
      final initialLength = _errorQueue.length;
      
      _errorQueue.removeWhere((error) => 
        now.difference(error.timestamp).inDays > _maxErrorAge.inDays
      );
      
      if (_errorQueue.length < initialLength) {
        await _saveErrorQueue();
        
        'OfflineErrorService: Errores antiguos limpiados'.debug(context: {
          'removedCount': initialLength - _errorQueue.length,
        });
      }
    } catch (e) {
      'Error limpiando errores antiguos'.error(error: e);
    }
  }

  /// NUEVO: Liberar recursos
  void dispose() {
    _syncTimer?.cancel();
    _eventController.close();
    _activeRetries.clear();
  }
}

/// NUEVO: Singleton del servicio
final offlineErrorService = OfflineErrorService();