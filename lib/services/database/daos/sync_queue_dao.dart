import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../local_database.dart';
import '../../logger_service.dart';

/// Estados de sincronización
enum SyncStatus {
  pending,
  syncing,
  synced,
  failed,
  conflict,
}

/// Operaciones de sincronización
enum SyncOperation {
  create,
  update,
  delete,
}

/// Tipos de entidad
enum SyncEntity {
  gestante,
  control,
  alerta,
  usuario,
  ips,
  medico,
  municipio,
}

/// DAO para cola de sincronización
class SyncQueueDao {
  final LocalDatabase _db = LocalDatabase();
  final _logger = LoggerService();
  final _uuid = const Uuid();

  /// Agregar item a la cola
  Future<String> add({
    required SyncEntity entityType,
    required String entityId,
    required SyncOperation operation,
    required Map<String, dynamic> data,
    int version = 1,
  }) async {
    try {
      final db = await _db.database;
      final id = _uuid.v4();
      final now = DateTime.now().toIso8601String();

      await db.insert('sync_queue', {
        'id': id,
        'entity_type': entityType.name,
        'entity_id': entityId,
        'operation': operation.name,
        'data': jsonEncode(data),
        'status': SyncStatus.pending.name,
        'version': version,
        'retry_count': 0,
        'max_retries': 3,
        'created_at': now,
        'updated_at': now,
      });

      _logger.database('Item agregado a cola de sincronización', data: {
        'id': id,
        'entityType': entityType.name,
        'operation': operation.name,
      });

      return id;
    } catch (e, stackTrace) {
      _logger.error('Error agregando item a cola', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtener items pendientes
  Future<List<Map<String, dynamic>>> getPending({int? limit}) async {
    try {
      final db = await _db.database;

      final results = await db.query(
        'sync_queue',
        where: 'status = ?',
        whereArgs: [SyncStatus.pending.name],
        orderBy: 'created_at ASC',
        limit: limit,
      );

      return results.map((row) => _prepareFromStorage(row)).toList();
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo items pendientes', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtener items fallidos
  Future<List<Map<String, dynamic>>> getFailed() async {
    try {
      final db = await _db.database;

      final results = await db.query(
        'sync_queue',
        where: 'status = ?',
        whereArgs: [SyncStatus.failed.name],
        orderBy: 'created_at DESC',
      );

      return results.map((row) => _prepareFromStorage(row)).toList();
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo items fallidos', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Actualizar estado de item
  Future<void> updateStatus(
    String id,
    SyncStatus status, {
    String? errorMessage,
  }) async {
    try {
      final db = await _db.database;

      final data = {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (errorMessage != null) {
        data['error_message'] = errorMessage;
      }

      if (status == SyncStatus.synced) {
        data['synced_at'] = DateTime.now().toIso8601String();
      }

      await db.update(
        'sync_queue',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );

      _logger.database('Estado de item actualizado', data: {
        'id': id,
        'status': status.name,
      });
    } catch (e, stackTrace) {
      _logger.error('Error actualizando estado', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Incrementar contador de reintentos
  Future<void> incrementRetryCount(String id) async {
    try {
      final db = await _db.database;

      await db.rawUpdate(
        'UPDATE sync_queue SET retry_count = retry_count + 1, updated_at = ? WHERE id = ?',
        [DateTime.now().toIso8601String(), id],
      );

      _logger.database('Contador de reintentos incrementado', data: {'id': id});
    } catch (e, stackTrace) {
      _logger.error('Error incrementando reintentos', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Marcar item como fallido si excede reintentos
  Future<void> checkAndMarkFailed(String id) async {
    try {
      final db = await _db.database;

      final result = await db.query(
        'sync_queue',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) return;

      final item = result.first;
      final retryCount = item['retry_count'] as int;
      final maxRetries = item['max_retries'] as int;

      if (retryCount >= maxRetries) {
        await updateStatus(
          id,
          SyncStatus.failed,
          errorMessage: 'Máximo de reintentos alcanzado',
        );
      }
    } catch (e, stackTrace) {
      _logger.error('Error verificando reintentos', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Eliminar item
  Future<void> delete(String id) async {
    try {
      final db = await _db.database;

      await db.delete(
        'sync_queue',
        where: 'id = ?',
        whereArgs: [id],
      );

      _logger.database('Item eliminado de cola', data: {'id': id});
    } catch (e, stackTrace) {
      _logger.error('Error eliminando item', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Limpiar items sincronizados antiguos
  Future<int> cleanupSynced({int daysOld = 7}) async {
    try {
      final db = await _db.database;
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      final count = await db.delete(
        'sync_queue',
        where: 'status = ? AND synced_at < ?',
        whereArgs: [SyncStatus.synced.name, cutoffDate.toIso8601String()],
      );

      _logger.database('Items sincronizados antiguos eliminados', data: {
        'count': count,
        'daysOld': daysOld,
      });

      return count;
    } catch (e, stackTrace) {
      _logger.error('Error limpiando items', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Contar items por estado
  Future<Map<String, int>> countByStatus() async {
    try {
      final db = await _db.database;

      final pending = Sqflite.firstIntValue(
        await db.rawQuery(
          "SELECT COUNT(*) FROM sync_queue WHERE status = ?",
          [SyncStatus.pending.name],
        ),
      ) ?? 0;

      final syncing = Sqflite.firstIntValue(
        await db.rawQuery(
          "SELECT COUNT(*) FROM sync_queue WHERE status = ?",
          [SyncStatus.syncing.name],
        ),
      ) ?? 0;

      final synced = Sqflite.firstIntValue(
        await db.rawQuery(
          "SELECT COUNT(*) FROM sync_queue WHERE status = ?",
          [SyncStatus.synced.name],
        ),
      ) ?? 0;

      final failed = Sqflite.firstIntValue(
        await db.rawQuery(
          "SELECT COUNT(*) FROM sync_queue WHERE status = ?",
          [SyncStatus.failed.name],
        ),
      ) ?? 0;

      final conflict = Sqflite.firstIntValue(
        await db.rawQuery(
          "SELECT COUNT(*) FROM sync_queue WHERE status = ?",
          [SyncStatus.conflict.name],
        ),
      ) ?? 0;

      return {
        'pending': pending,
        'syncing': syncing,
        'synced': synced,
        'failed': failed,
        'conflict': conflict,
      };
    } catch (e, stackTrace) {
      _logger.error('Error contando items', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Reintentar items fallidos
  Future<void> retryFailed() async {
    try {
      final db = await _db.database;

      await db.update(
        'sync_queue',
        {
          'status': SyncStatus.pending.name,
          'retry_count': 0,
          'error_message': null,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'status = ?',
        whereArgs: [SyncStatus.failed.name],
      );

      _logger.database('Items fallidos marcados para reintentar');
    } catch (e, stackTrace) {
      _logger.error('Error reintentando items fallidos', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Preparar datos desde almacenamiento
  Map<String, dynamic> _prepareFromStorage(Map<String, dynamic> row) {
    final prepared = Map<String, dynamic>.from(row);

    // Decodificar JSON data
    if (prepared['data'] is String) {
      try {
        prepared['data'] = jsonDecode(prepared['data']);
      } catch (e) {
        _logger.error('Error decodificando data', error: e);
        prepared['data'] = {};
      }
    }

    return prepared;
  }
}

