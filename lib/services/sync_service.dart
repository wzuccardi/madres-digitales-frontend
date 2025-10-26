import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/daos/sync_queue_dao.dart';
import 'database/daos/gestante_dao.dart';
import 'logger_service.dart';

/// Servicio de sincronización offline
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _logger = LoggerService();
  final _syncQueueDao = SyncQueueDao();
  final _gestanteDao = GestanteDao();
  final _connectivity = Connectivity();
  
  Dio? _dio;
  Timer? _autoSyncTimer;
  bool _isSyncing = false;
  
  // Stream controllers para notificar cambios
  final _syncStatusController = StreamController<SyncStatusData>.broadcast();
  final _connectivityController = StreamController<bool>.broadcast();
  
  Stream<SyncStatusData> get syncStatusStream => _syncStatusController.stream;
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Inicializar servicio de sincronización
  Future<void> initialize(Dio dio) async {
    _dio = dio;
    
    // Escuchar cambios de conectividad
    _connectivity.onConnectivityChanged.listen((result) {
      final isConnected = !result.contains(ConnectivityResult.none);
      _connectivityController.add(isConnected);
      
      _logger.info('Conectividad cambió', data: {
        'connected': isConnected,
        'type': result.toString(),
      });
      
      // Si recuperamos conectividad, sincronizar automáticamente
      if (isConnected && !_isSyncing) {
        syncAll();
      }
    });
    
    // Iniciar sincronización automática cada 5 minutos
    _autoSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncAll(),
    );
    
    _logger.info('Servicio de sincronización inicializado');
  }

  /// Verificar si hay conectividad
  Future<bool> hasConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      _logger.error('Error verificando conectividad', error: e);
      return false;
    }
  }

  /// Sincronizar todo (PUSH + PULL)
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      _logger.warning('Sincronización ya en progreso');
      return SyncResult(
        success: false,
        message: 'Sincronización ya en progreso',
      );
    }

    if (!await hasConnectivity()) {
      _logger.warning('Sin conectividad para sincronizar');
      return SyncResult(
        success: false,
        message: 'Sin conexión a internet',
      );
    }

    _isSyncing = true;
    _updateSyncStatus(isSyncing: true);

    try {
      _logger.info('Iniciando sincronización completa');
      final startTime = DateTime.now();

      // 1. PUSH: Enviar cambios locales al servidor
      final pushResult = await _pushChanges();
      
      // 2. PULL: Descargar cambios del servidor
      final pullResult = await _pullChanges();

      final duration = DateTime.now().difference(startTime);

      _logger.info('Sincronización completa finalizada', data: {
        'durationMs': duration.inMilliseconds,
        'pushSuccess': pushResult.success,
        'pullSuccess': pullResult.success,
      });

      final success = pushResult.success && pullResult.success;
      
      _updateSyncStatus(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        success: success,
      );

      return SyncResult(
        success: success,
        message: success
            ? 'Sincronización completada'
            : 'Sincronización completada con errores',
        pushResult: pushResult,
        pullResult: pullResult,
      );
    } catch (e, stackTrace) {
      _logger.error('Error en sincronización', error: e, stackTrace: stackTrace);
      
      _updateSyncStatus(isSyncing: false, success: false);
      
      return SyncResult(
        success: false,
        message: 'Error en sincronización: ${e.toString()}',
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// PUSH: Enviar cambios locales al servidor
  Future<PushResult> _pushChanges() async {
    try {
      _logger.info('Iniciando PUSH de cambios locales');

      // Obtener items pendientes de la cola
      final pendingItems = await _syncQueueDao.getPending(limit: 50);

      if (pendingItems.isEmpty) {
        _logger.info('No hay cambios pendientes para enviar');
        return PushResult(
          success: true,
          totalItems: 0,
          syncedItems: 0,
          failedItems: 0,
          conflicts: 0,
        );
      }

      _logger.info('Enviando cambios al servidor', data: {
        'count': pendingItems.length,
      });

      // Preparar items para enviar
      final items = pendingItems.map((item) => {
        'entityType': item['entity_type'],
        'entityId': item['entity_id'],
        'operation': item['operation'],
        'data': item['data'],
        'version': item['version'],
        'localTimestamp': item['created_at'],
      }).toList();

      // Enviar al servidor
      final response = await _dio!.post(
        '/sync/push',
        data: {'items': items},
      );

      final result = response.data['data'];
      
      // Procesar resultados
      for (var i = 0; i < pendingItems.length; i++) {
        final item = pendingItems[i];
        final itemResult = result['items'][i];
        
        if (itemResult['status'] == 'synced') {
          await _syncQueueDao.updateStatus(item['id'], SyncStatus.synced);
          
          // Marcar entidad como sincronizada
          await _markEntityAsSynced(
            item['entity_type'],
            item['entity_id'],
            item['version'] + 1,
          );
        } else if (itemResult['status'] == 'conflict') {
          await _syncQueueDao.updateStatus(item['id'], SyncStatus.conflict);
          // TODO: Guardar conflicto en tabla de conflictos
        } else if (itemResult['status'] == 'failed') {
          await _syncQueueDao.incrementRetryCount(item['id']);
          await _syncQueueDao.checkAndMarkFailed(item['id']);
          await _syncQueueDao.updateStatus(
            item['id'],
            SyncStatus.failed,
            errorMessage: itemResult['errorMessage'],
          );
        }
      }

      _logger.info('PUSH completado', data: result);

      return PushResult(
        success: result['success'],
        totalItems: result['totalItems'],
        syncedItems: result['syncedItems'],
        failedItems: result['failedItems'],
        conflicts: result['conflicts'],
      );
    } catch (e, stackTrace) {
      _logger.error('Error en PUSH', error: e, stackTrace: stackTrace);
      return PushResult(
        success: false,
        totalItems: 0,
        syncedItems: 0,
        failedItems: 0,
        conflicts: 0,
      );
    }
  }

  /// PULL: Descargar cambios del servidor
  Future<PullResult> _pullChanges() async {
    try {
      _logger.info('Iniciando PULL de cambios del servidor');

      // Obtener timestamp de última sincronización
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString('last_sync_timestamp');

      // Solicitar cambios al servidor
      final response = await _dio!.post(
        '/sync/pull',
        data: {
          'lastSyncTimestamp': lastSync,
          'entityTypes': ['gestante', 'control', 'alerta', 'ips', 'medico', 'municipio'],
        },
      );

      final result = response.data['data'];
      final changes = result['changes'];
      int totalApplied = 0;

      // Aplicar cambios de gestantes
      if (changes['gestantes'] != null) {
        final gestantes = List<Map<String, dynamic>>.from(changes['gestantes']);
        await _gestanteDao.insertBatch(gestantes);
        totalApplied += gestantes.length;
      }

      // TODO: Aplicar cambios de otras entidades (controles, alertas, etc.)

      // Guardar timestamp de sincronización
      await prefs.setString(
        'last_sync_timestamp',
        result['lastSyncTimestamp'],
      );

      _logger.info('PULL completado', data: {
        'totalChanges': result['totalChanges'],
        'totalApplied': totalApplied,
      });

      return PullResult(
        success: true,
        totalChanges: result['totalChanges'],
        appliedChanges: totalApplied,
      );
    } catch (e, stackTrace) {
      _logger.error('Error en PULL', error: e, stackTrace: stackTrace);
      return PullResult(
        success: false,
        totalChanges: 0,
        appliedChanges: 0,
      );
    }
  }

  /// Marcar entidad como sincronizada
  Future<void> _markEntityAsSynced(
    String entityType,
    String entityId,
    int version,
  ) async {
    try {
      switch (entityType) {
        case 'gestante':
          await _gestanteDao.markAsSynced(entityId, version);
          break;
        // TODO: Agregar otros tipos de entidad
      }
    } catch (e) {
      _logger.error('Error marcando entidad como sincronizada', error: e);
    }
  }

  /// Actualizar estado de sincronización
  void _updateSyncStatus({
    bool? isSyncing,
    DateTime? lastSyncTime,
    bool? success,
  }) {
    _syncStatusController.add(SyncStatusData(
      isSyncing: isSyncing ?? _isSyncing,
      lastSyncTime: lastSyncTime,
      success: success,
    ));
  }

  /// Obtener estado de sincronización
  Future<Map<String, dynamic>> getStatus() async {
    final counts = await _syncQueueDao.countByStatus();
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString('last_sync_timestamp');

    return {
      'pendingItems': counts['pending'],
      'syncingItems': counts['syncing'],
      'failedItems': counts['failed'],
      'conflicts': counts['conflict'],
      'lastSyncTimestamp': lastSync,
      'isSyncing': _isSyncing,
    };
  }

  /// Limpiar recursos
  void dispose() {
    _autoSyncTimer?.cancel();
    _syncStatusController.close();
    _connectivityController.close();
  }
}

/// Datos de estado de sincronización
class SyncStatusData {
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final bool? success;

  SyncStatusData({
    required this.isSyncing,
    this.lastSyncTime,
    this.success,
  });
}

/// Resultado de sincronización completa
class SyncResult {
  final bool success;
  final String message;
  final PushResult? pushResult;
  final PullResult? pullResult;

  SyncResult({
    required this.success,
    required this.message,
    this.pushResult,
    this.pullResult,
  });
}

/// Resultado de PUSH
class PushResult {
  final bool success;
  final int totalItems;
  final int syncedItems;
  final int failedItems;
  final int conflicts;

  PushResult({
    required this.success,
    required this.totalItems,
    required this.syncedItems,
    required this.failedItems,
    required this.conflicts,
  });
}

/// Resultado de PULL
class PullResult {
  final bool success;
  final int totalChanges;
  final int appliedChanges;

  PullResult({
    required this.success,
    required this.totalChanges,
    required this.appliedChanges,
  });
}

