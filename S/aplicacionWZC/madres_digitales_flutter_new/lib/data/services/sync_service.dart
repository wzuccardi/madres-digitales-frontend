import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';


/// Estado de sincronización
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  offline,
}

/// Resultado de sincronización
class SyncResult {
  
  SyncResult({
    required this.success,
    this.error,
    this.syncedItems = 0,
    this.failedItems = 0,
    required this.duration,
  });
  final bool success;
  final String? error;
  final int syncedItems;
  final int failedItems;
  final Duration duration;
  
  @override
  String toString() {
    if (success) {
      return 'Sincronización exitosa: $syncedItems elementos sincronizados en ${duration.inSeconds}s';
    } else {
      return 'Error de sincronización: $error ($failedItems elementos fallidos)';
    }
  }
}

/// Servicio de sincronización de datos
class SyncService {
  
  SyncService({
    ApiService? apiService,
    Connectivity? connectivity,
  }) : _apiService = apiService ?? ApiService(),
        _connectivity = connectivity ?? Connectivity();
  final ApiService _apiService;
  final Connectivity _connectivity;
  
  SyncStatus _status = SyncStatus.idle;
  StreamController<SyncStatus>? _statusController;
  Timer? _syncTimer;
  
  /// Obtener estado actual de sincronización
  SyncStatus get status => _status;
  
  /// Stream de cambios de estado
  Stream<SyncStatus> get statusStream {
    _statusController ??= StreamController<SyncStatus>.broadcast();
    return _statusController!.stream;
  }

  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((result) => result != ConnectivityResult.none);
  }

  Stream<SyncStatus> get syncStatusStream => statusStream;
  
  /// Cambiar estado de sincronización
  void _setStatus(SyncStatus newStatus) {
    _status = newStatus;
    _statusController?.add(newStatus);
    AppLogger.debug('SyncService: Estado cambiado a $newStatus');
  }
  
  /// Verificar si hay conexión a internet
  Future<bool> _isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      // checkConnectivity() retorna ConnectivityResult (versión antigua)
      return result != ConnectivityResult.none;
    } catch (e) {
      AppLogger.error('SyncService: Error verificando conectividad', error: e);
      return false;
    }
  }
  
  /// Iniciar sincronización automática periódica
  void startAutoSync({Duration interval = const Duration(minutes: 5)}) {
    AppLogger.info('SyncService: Iniciando sincronización automática cada ${interval.inMinutes} minutos');
    
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) => sync());
  }
  
  /// Detener sincronización automática
  void stopAutoSync() {
    AppLogger.info('SyncService: Deteniendo sincronización automática');
    _syncTimer?.cancel();
    _syncTimer = null;
  }
  
  /// Sincronizar todos los datos
  Future<SyncResult> sync() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      if (_status == SyncStatus.syncing) {
        AppLogger.warning('SyncService: Sincronización ya en progreso');
        return SyncResult(
          success: false,
          error: 'Sincronización ya en progreso',
          duration: stopwatch.elapsed,
        );
      }
      
      _setStatus(SyncStatus.syncing);
      
      // Verificar conectividad
      if (!await _isConnected()) {
        _setStatus(SyncStatus.offline);
        return SyncResult(
          success: false,
          error: 'Sin conexión a internet',
          duration: stopwatch.elapsed,
        );
      }
      
      int syncedItems = 0;
      int failedItems = 0;
      
      // Sincronizar diferentes tipos de datos
      try {
        final result1 = await _syncGestantes();
        syncedItems += result1.syncedItems;
        failedItems += result1.failedItems;
      } catch (e) {
        AppLogger.error('SyncService: Error sincronizando gestantes', error: e);
        failedItems++;
      }
      
      try {
        final result2 = await _syncControles();
        syncedItems += result2.syncedItems;
        failedItems += result2.failedItems;
      } catch (e) {
        AppLogger.error('SyncService: Error sincronizando controles', error: e);
        failedItems++;
      }
      
      try {
        final result3 = await _syncContenido();
        syncedItems += result3.syncedItems;
        failedItems += result3.failedItems;
      } catch (e) {
        AppLogger.error('SyncService: Error sincronizando contenido', error: e);
        failedItems++;
      }

      try {
        final result4 = await _syncQueuedOps();
        syncedItems += result4.syncedItems;
        failedItems += result4.failedItems;
      } catch (e) {
        AppLogger.error('SyncService: Error sincronizando cola general', error: e);
        failedItems++;
      }
      
      stopwatch.stop();
      
      if (failedItems == 0) {
        _setStatus(SyncStatus.success);
        AppLogger.info('SyncService: Sincronización completada exitosamente');
      } else {
        _setStatus(SyncStatus.error);
        AppLogger.warning('SyncService: Sincronización completada con $failedItems errores');
      }
      
      return SyncResult(
        success: failedItems == 0,
        syncedItems: syncedItems,
        failedItems: failedItems,
        duration: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      _setStatus(SyncStatus.error);
      AppLogger.error('SyncService: Error en sincronización', error: e);
      
      return SyncResult(
        success: false,
        error: e.toString(),
        syncedItems: 0,
        failedItems: 0,
        duration: stopwatch.elapsed,
      );
    }
  }

  Future<SyncResult> syncAll() async {
    return await sync();
  }
  
  /// Sincronizar gestantes
  Future<SyncResult> _syncGestantes() async {
    try {
      AppLogger.debug('SyncService: Sincronizando gestantes');
      
      // Obtener datos locales pendientes de sincronización
      final localGestantes = await _apiService.getList('gestantes_pending_sync') ?? [];
      
      int syncedItems = 0;
      int failedItems = 0;
      
      for (final gestanteData in localGestantes) {
        try {
          final response = await _apiService.post('/gestantes/sync', data: gestanteData);
          
          if (response.success) {
            final pending = await _apiService.getList('gestantes_pending_sync') ?? [];
            pending.removeWhere((item) => item['id'] == gestanteData['id']);
            await _apiService.setList('gestantes_pending_sync', pending);
            
            syncedItems++;
          } else {
            failedItems++;
          }
        } catch (e) {
          AppLogger.error('SyncService: Error sincronizando gestante ${gestanteData['id']}', error: e);
          failedItems++;
        }
      }
      
      // Obtener datos del servidor
      final response = await _apiService.get('/gestantes');
      if (response.success && response.data != null) {
        final serverGestantes = response.data as List<dynamic>;
        await _apiService.setList('gestantes', serverGestantes);
      }
      
      return SyncResult(
        success: failedItems == 0,
        syncedItems: syncedItems,
        failedItems: failedItems,
        duration: Duration.zero,
      );
    } catch (e) {
      AppLogger.error('SyncService: Error en sincronización de gestantes', error: e);
      return SyncResult(
        success: false,
        error: e.toString(),
        syncedItems: 0,
        failedItems: 0,
        duration: Duration.zero,
      );
    }
  }
  
  /// Sincronizar controles
  Future<SyncResult> _syncControles() async {
    try {
      AppLogger.debug('SyncService: Sincronizando controles');
      
      // Obtener datos locales pendientes de sincronización
      final localControles = await _apiService.getList('controles_pending_sync') ?? [];
      
      int syncedItems = 0;
      int failedItems = 0;
      
      for (final controlData in localControles) {
        try {
          final response = await _apiService.post('/controles/sync', data: controlData);
          
          if (response.success) {
            final pending = await _apiService.getList('controles_pending_sync') ?? [];
            pending.removeWhere((item) => item['id'] == controlData['id']);
            await _apiService.setList('controles_pending_sync', pending);
            
            syncedItems++;
          } else {
            failedItems++;
          }
        } catch (e) {
          AppLogger.error('SyncService: Error sincronizando control ${controlData['id']}', error: e);
          failedItems++;
        }
      }
      
      // Obtener datos del servidor
      final response = await _apiService.get('/controles');
      if (response.success && response.data != null) {
        final serverControles = response.data as List<dynamic>;
        await _apiService.setList('controles', serverControles);
      }
      
      return SyncResult(
        success: failedItems == 0,
        syncedItems: syncedItems,
        failedItems: failedItems,
        duration: Duration.zero,
      );
    } catch (e) {
      AppLogger.error('SyncService: Error en sincronización de controles', error: e);
      return SyncResult(
        success: false,
        error: e.toString(),
        syncedItems: 0,
        failedItems: 0,
        duration: Duration.zero,
      );
    }
  }
  
  /// Sincronizar contenido
  Future<SyncResult> _syncContenido() async {
    try {
      AppLogger.debug('SyncService: Sincronizando contenido');
      
      // Obtener datos del servidor
      final response = await _apiService.get('/contenido');
      if (response.success && response.data != null) {
        final serverContenido = response.data as List<dynamic>;
        await _apiService.setList('contenido', serverContenido);
      }
      
      return SyncResult(
        success: true,
        syncedItems: 1,
        failedItems: 0,
        duration: Duration.zero,
      );
    } catch (e) {
      AppLogger.error('SyncService: Error en sincronización de contenido', error: e);
      return SyncResult(
        success: false,
        error: e.toString(),
        syncedItems: 0,
        failedItems: 0,
        duration: Duration.zero,
      );
    }
  }
  
  /// Marcar elemento para sincronización
  Future<void> markForSync(String type, Map<String, dynamic> data) async {
    try {
      AppLogger.debug('SyncService: Marcando $type para sincronización');
      
      final pendingKey = '${type}_pending_sync';
      final pending = await _apiService.getList(pendingKey) ?? [];
      
      // Verificar si ya está pendiente
      final exists = pending.any((item) => item['id'] == data['id']);
      if (!exists) {
        pending.add(data);
        await _apiService.setList(pendingKey, pending);
      }
    } catch (e) {
      AppLogger.error('SyncService: Error marcando para sincronización', error: e);
      rethrow;
    }
  }
  
  /// Forzar sincronización inmediata
  Future<SyncResult> forceSync() async {
    AppLogger.info('SyncService: Forzando sincronización inmediata');
    return await sync();
  }
  
  /// Obtener estado detallado de sincronización
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final gestantesPending = await _apiService.getList('gestantes_pending_sync') ?? [];
      final controlesPending = await _apiService.getList('controles_pending_sync') ?? [];
      
      return {
        'status': _status.toString(),
        'isConnected': await _isConnected(),
        'pendingGestantes': gestantesPending.length,
        'pendingControles': controlesPending.length,
        'totalPending': gestantesPending.length + controlesPending.length,
        'lastSync': null,
      };
    } catch (e) {
      AppLogger.error('SyncService: Error obteniendo estado de sincronización', error: e);
      return {
        'status': _status.toString(),
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getStatus() async {
    return await getSyncStatus();
  }
  Future<bool> _performQueuedOp(String type, Map<String, dynamic> data) async {
    if (type == 'alertas_create') {
      final r = await _apiService.post('/alertas', data: data);
      return r.success;
    } else if (type == 'alertas_resolver') {
      final id = data['id']?.toString() ?? '';
      final r = await _apiService.put('/alertas/$id/resolver');
      return r.success;
    } else if (type == 'alertas_leida') {
      final id = data['id']?.toString() ?? '';
      final r = await _apiService.post('/alertas/$id/leida');
      return r.success;
    } else if (type == 'controles_create') {
      final r = await _apiService.post('/controles', data: data);
      return r.success;
    } else if (type == 'controles_create_eval') {
      final r = await _apiService.post('/alertas-automaticas/controles/con-evaluacion', data: data);
      return r.success;
    } else if (type == 'controles_update') {
      final id = data['id']?.toString() ?? '';
      final r = await _apiService.put('/controles/$id', data: data);
      return r.success;
    } else if (type == 'controles_delete') {
      final id = data['id']?.toString() ?? '';
      final r = await _apiService.delete('/controles/$id');
      return r.success;
    } else if (type == 'medicos_create') {
      final r = await _apiService.post('/medicos', data: data);
      return r.success;
    } else if (type == 'medicos_update') {
      final id = data['id']?.toString() ?? '';
      final r = await _apiService.put('/medicos/$id', data: data);
      return r.success;
    } else if (type == 'medicos_delete') {
      final id = data['id']?.toString() ?? '';
      final r = await _apiService.delete('/medicos/$id');
      return r.success;
    } else if (type == 'medicos_toggle') {
      final id = data['id']?.toString() ?? '';
      final r = await _apiService.put('/medicos/$id', data: {'activo': data['activo']});
      return r.success;
    }
    return false;
  }

  Future<SyncResult> _syncQueuedOps() async {
    int synced = 0;
    int failed = 0;
    final types = [
      'alertas_create',
      'alertas_resolver',
      'alertas_leida',
      'controles_create',
      'controles_create_eval',
      'controles_update',
      'controles_delete',
      'medicos_create',
      'medicos_update',
      'medicos_delete',
      'medicos_toggle',
    ];
    for (final t in types) {
      final key = '${t}_pending_sync';
      final pending = await _apiService.getList(key) ?? [];
      if (pending.isEmpty) continue;
      final remaining = <dynamic>[];
      for (final item in pending) {
        final ok = await _performQueuedOp(t, Map<String, dynamic>.from(item as Map));
        if (ok) {
          synced++;
        } else {
          failed++;
          remaining.add(item);
        }
      }
      await _apiService.setList(key, remaining);
    }
    return SyncResult(success: failed == 0, syncedItems: synced, failedItems: failed, duration: Duration.zero);
  }
  
  /// Liberar recursos
  void dispose() {
    stopAutoSync();
    _statusController?.close();
    _statusController = null;
  }
}
