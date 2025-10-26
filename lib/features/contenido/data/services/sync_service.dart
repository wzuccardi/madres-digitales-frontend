import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../datasources/contenido_remote_datasource.dart';
import 'cache_service.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/errors/exceptions.dart' as core_exceptions;

class SyncService {
  static const String _syncQueueBoxName = 'sync_queue';
  static const String _syncLogBoxName = 'sync_log';
  
  late Box<Map> _syncQueueBox;
  late Box<String> _syncLogBox;
  
  final ContenidoRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;
  final NetworkInfo _networkInfo;
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  SyncService({
    required ContenidoRemoteDataSource remoteDataSource,
    required CacheService cacheService,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _cacheService = cacheService,
        _networkInfo = networkInfo;
  
  Future<void> init() async {
    try {
      // Abrir cajas de Hive
      if (!Hive.isBoxOpen(_syncQueueBoxName)) {
        _syncQueueBox = await Hive.openBox<Map>(_syncQueueBoxName);
      } else {
        _syncQueueBox = Hive.box<Map>(_syncQueueBoxName);
      }
      
      if (!Hive.isBoxOpen(_syncLogBoxName)) {
        _syncLogBox = await Hive.openBox<String>(_syncLogBoxName);
      } else {
        _syncLogBox = Hive.box<String>(_syncLogBoxName);
      }
      
      // Configurar listener de conectividad
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
        if (results.isNotEmpty && results.last != ConnectivityResult.none) {
          // Hay conexión, intentar sincronizar
          _attemptSync();
        }
      });
      
      // Configurar temporizador de sincronización periódica
      _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
        _attemptSync();
      });
      
      // Intentar sincronizar al iniciar
      _attemptSync();
    } catch (e) {
      throw core_exceptions.CacheException('Error inicializando servicio de sincronización: $e');
    }
  }
  
  Future<void> dispose() async {
    _syncTimer?.cancel();
    await _connectivitySubscription?.cancel();
  }
  
  // Métodos para agregar acciones a la cola de sincronización
  Future<void> queueToggleFavorito(String contenidoId) async {
    try {
      final action = {
        'type': 'toggle_favorito',
        'contenidoId': contenidoId,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _syncQueueBox.add(action);
      await _logSyncAction('toggle_favorito', contenidoId, 'queued');
      
      // Intentar sincronizar inmediatamente si hay conexión
      _attemptSync();
    } catch (e) {
      throw core_exceptions.CacheException('Error agregando toggle_favorito a la cola: $e');
    }
  }
  
  Future<void> queueRegistrarVista(String contenidoId) async {
    try {
      final action = {
        'type': 'registrar_vista',
        'contenidoId': contenidoId,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _syncQueueBox.add(action);
      await _logSyncAction('registrar_vista', contenidoId, 'queued');
      
      // Intentar sincronizar inmediatamente si hay conexión
      _attemptSync();
    } catch (e) {
      throw core_exceptions.CacheException('Error agregando registrar_vista a la cola: $e');
    }
  }
  
  Future<void> queueActualizarProgreso(
    String contenidoId, {
    int? tiempoVisualizado,
    double? porcentaje,
    bool? completado,
  }) async {
    try {
      final action = {
        'type': 'actualizar_progreso',
        'contenidoId': contenidoId,
        'tiempoVisualizado': tiempoVisualizado,
        'porcentaje': porcentaje,
        'completado': completado,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _syncQueueBox.add(action);
      await _logSyncAction('actualizar_progreso', contenidoId, 'queued');
      
      // Intentar sincronizar inmediatamente si hay conexión
      _attemptSync();
    } catch (e) {
      throw core_exceptions.CacheException('Error agregando actualizar_progreso a la cola: $e');
    }
  }
  
  // Métodos para obtener información de sincronización
  Future<int> getPendingSyncActionsCount() async {
    return _syncQueueBox.length;
  }
  
  Future<List<Map<String, dynamic>>> getPendingSyncActions() async {
    final actions = <Map<String, dynamic>>[];
    
    for (final key in _syncQueueBox.keys) {
      final action = _syncQueueBox.get(key);
      if (action != null) {
        actions.add(Map<String, dynamic>.from(action));
      }
    }
    
    return actions;
  }
  
  Future<List<String>> getSyncLog({int limit = 50}) async {
    final logs = <String>[];
    final keys = _syncLogBox.keys.toList();
    
    // Obtener los logs más recientes
    keys.sort((a, b) => b.compareTo(a));
    
    for (int i = 0; i < keys.length && i < limit; i++) {
      final log = _syncLogBox.get(keys[i]);
      if (log != null) {
        logs.add(log);
      }
    }
    
    return logs;
  }
  
  Future<bool> get isSyncing async => _isSyncing;
  
  // Métodos de sincronización
  Future<void> syncNow() async {
    await _attemptSync();
  }
  
  Future<void> _attemptSync() async {
    if (_isSyncing) return;
    
    try {
      // Verificar si hay conexión
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        await _logSyncAction('system', '', 'sync_skipped_no_connection');
        return;
      }
      
      // Verificar si hay acciones pendientes
      if (_syncQueueBox.isEmpty) {
        await _logSyncAction('system', '', 'sync_skipped_no_actions');
        return;
      }
      
      _isSyncing = true;
      await _logSyncAction('system', '', 'sync_started');
      
      // Procesar acciones pendientes
      final keys = _syncQueueBox.keys.toList();
      int successCount = 0;
      int errorCount = 0;
      
      for (final key in keys) {
        try {
          final action = _syncQueueBox.get(key);
          if (action == null) continue;
          
          final success = await _processSyncAction(Map<String, dynamic>.from(action));
          if (success) {
            // Eliminar acción de la cola
            await _syncQueueBox.delete(key);
            successCount++;
          } else {
            errorCount++;
          }
        } catch (e) {
          errorCount++;
          await _logSyncAction('system', '', 'sync_action_error: $e');
        }
      }
      
      await _logSyncAction('system', '', 'sync_completed: $successCount success, $errorCount errors');
    } catch (e) {
      await _logSyncAction('system', '', 'sync_failed: $e');
    } finally {
      _isSyncing = false;
    }
  }
  
  Future<bool> _processSyncAction(Map<String, dynamic> action) async {
    try {
      final type = action['type'] as String;
      
      switch (type) {
        case 'toggle_favorito':
          await _remoteDataSource.toggleFavorito(action['contenidoId'] as String);
          await _logSyncAction('toggle_favorito', action['contenidoId'], 'synced');
          return true;
          
        case 'registrar_vista':
          await _remoteDataSource.registrarVista(action['contenidoId'] as String);
          await _logSyncAction('registrar_vista', action['contenidoId'], 'synced');
          return true;
          
        case 'actualizar_progreso':
          await _remoteDataSource.actualizarProgreso(
            action['contenidoId'] as String,
            tiempoVisualizado: action['tiempoVisualizado'] as int?,
            porcentaje: action['porcentaje'] as double?,
            completado: action['completado'] as bool?,
          );
          await _logSyncAction('actualizar_progreso', action['contenidoId'], 'synced');
          return true;
          
        default:
          await _logSyncAction('system', '', 'unknown_action_type: $type');
          return false;
      }
    } catch (e) {
      await _logSyncAction('system', '', 'sync_action_failed: $e');
      return false;
    }
  }
  
  // Métodos para sincronización completa de datos
  Future<SyncResult> syncAllData({bool forceRefresh = false}) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return const SyncResult(
          success: false,
          message: 'No hay conexión a internet',
        );
      }
      
      await _logSyncAction('system', '', 'full_data_sync_started');
      
      // Sincronizar categorías
      try {
        final remoteCategorias = await _remoteDataSource.getCategorias();
        await _cacheService.cacheCategorias(remoteCategorias.map((c) => c.toJson()).toList());
        await _logSyncAction('system', '', 'categorias_synced');
      } catch (e) {
        await _logSyncAction('system', '', 'categorias_sync_error: $e');
      }
      
      // Sincronizar contenidos principales
      try {
        final remoteContenidos = await _remoteDataSource.getContenidos(
          categoria: null,
          tipo: null,
          nivel: null,
          page: 1,
          limit: 20,
        );
        await _cacheService.cacheContenidos(remoteContenidos);
        await _logSyncAction('system', '', 'contenidos_synced');
      } catch (e) {
        await _logSyncAction('system', '', 'contenidos_sync_error: $e');
      }
      
      // Procesar cola de sincronización
      await _attemptSync();
      
      await _logSyncAction('system', '', 'full_data_sync_completed');
      
      return const SyncResult(
        success: true,
        message: 'Datos sincronizados correctamente',
      );
    } catch (e) {
      await _logSyncAction('system', '', 'full_data_sync_error: $e');
      return SyncResult(
        success: false,
        message: 'Error al sincronizar datos: $e',
      );
    }
  }
  
  // Métodos privados
  Future<void> _logSyncAction(String action, String target, String status) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final log = '$timestamp|$action|$target|$status';
      await _syncLogBox.add(log);
      
      // Limitar el tamaño del log
      if (_syncLogBox.length > 500) {
        final keys = _syncLogBox.keys.toList();
        keys.sort();
        
        // Eliminar los logs más antiguos
        for (int i = 0; i < 100 && i < keys.length; i++) {
          await _syncLogBox.delete(keys[i]);
        }
      }
    } catch (e) {
      // Ignorar errores de logging para no afectar la funcionalidad principal
    }
  }
}

class SyncResult {
  final bool success;
  final String message;
  
  const SyncResult({
    required this.success,
    required this.message,
  });
}