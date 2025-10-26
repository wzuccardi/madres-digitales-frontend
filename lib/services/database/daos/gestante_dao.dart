import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import '../local_database.dart';
import '../../logger_service.dart';

/// DAO para gestantes en base de datos local
class GestanteDao {
  final LocalDatabase _db = LocalDatabase();
  final _logger = LoggerService();

  /// Insertar gestante
  Future<void> insert(Map<String, dynamic> gestante) async {
    try {
      final db = await _db.database;
      
      // Convertir datos complejos a JSON string
      final data = _prepareForStorage(gestante);
      
      await db.insert(
        'gestantes',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      _logger.database('Gestante insertada', data: {'id': gestante['id']});
    } catch (e, stackTrace) {
      _logger.error('Error insertando gestante', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Insertar múltiples gestantes
  Future<void> insertBatch(List<Map<String, dynamic>> gestantes) async {
    try {
      final db = await _db.database;
      final batch = db.batch();
      
      for (final gestante in gestantes) {
        final data = _prepareForStorage(gestante);
        batch.insert(
          'gestantes',
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      await batch.commit(noResult: true);
      
      _logger.database('Gestantes insertadas en batch', data: {'count': gestantes.length});
    } catch (e, stackTrace) {
      _logger.error('Error insertando gestantes en batch', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Actualizar gestante
  Future<void> update(String id, Map<String, dynamic> gestante) async {
    try {
      final db = await _db.database;
      
      final data = _prepareForStorage(gestante);
      data['updated_at'] = DateTime.now().toIso8601String();
      data['synced'] = 0; // Marcar como no sincronizado
      
      await db.update(
        'gestantes',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      _logger.database('Gestante actualizada', data: {'id': id});
    } catch (e, stackTrace) {
      _logger.error('Error actualizando gestante', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Eliminar gestante
  Future<void> delete(String id) async {
    try {
      final db = await _db.database;
      
      await db.delete(
        'gestantes',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      _logger.database('Gestante eliminada', data: {'id': id});
    } catch (e, stackTrace) {
      _logger.error('Error eliminando gestante', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtener gestante por ID
  Future<Map<String, dynamic>?> getById(String id) async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        'gestantes',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (results.isEmpty) return null;
      
      return _prepareFromStorage(results.first);
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo gestante', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtener todas las gestantes
  Future<List<Map<String, dynamic>>> getAll({
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        'gestantes',
        where: 'activo = ?',
        whereArgs: [1],
        orderBy: orderBy ?? 'nombre ASC',
        limit: limit,
        offset: offset,
      );
      
      return results.map((row) => _prepareFromStorage(row)).toList();
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo gestantes', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtener gestantes por madrina
  Future<List<Map<String, dynamic>>> getByMadrina(String madrinaId) async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        'gestantes',
        where: 'madrina_id = ? AND activo = ?',
        whereArgs: [madrinaId, 1],
        orderBy: 'nombre ASC',
      );
      
      return results.map((row) => _prepareFromStorage(row)).toList();
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo gestantes por madrina', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtener gestantes por municipio
  Future<List<Map<String, dynamic>>> getByMunicipio(String municipioId) async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        'gestantes',
        where: 'municipio_id = ? AND activo = ?',
        whereArgs: [municipioId, 1],
        orderBy: 'nombre ASC',
      );
      
      return results.map((row) => _prepareFromStorage(row)).toList();
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo gestantes por municipio', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Buscar gestantes
  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        'gestantes',
        where: '(nombre LIKE ? OR documento LIKE ?) AND activo = ?',
        whereArgs: ['%$query%', '%$query%', 1],
        orderBy: 'nombre ASC',
      );
      
      return results.map((row) => _prepareFromStorage(row)).toList();
    } catch (e, stackTrace) {
      _logger.error('Error buscando gestantes', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtener gestantes no sincronizadas
  Future<List<Map<String, dynamic>>> getUnsyncedgestantes() async {
    try {
      final db = await _db.database;
      
      final results = await db.query(
        'gestantes',
        where: 'synced = ?',
        whereArgs: [0],
      );
      
      return results.map((row) => _prepareFromStorage(row)).toList();
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo gestantes no sincronizadas', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Marcar gestante como sincronizada
  Future<void> markAsSynced(String id, int version) async {
    try {
      final db = await _db.database;
      
      await db.update(
        'gestantes',
        {
          'synced': 1,
          'version': version,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      
      _logger.database('Gestante marcada como sincronizada', data: {'id': id, 'version': version});
    } catch (e, stackTrace) {
      _logger.error('Error marcando gestante como sincronizada', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Contar gestantes
  Future<int> count() async {
    try {
      final db = await _db.database;
      
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM gestantes WHERE activo = ?',
        [1],
      );
      
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e, stackTrace) {
      _logger.error('Error contando gestantes', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Preparar datos para almacenamiento
  Map<String, dynamic> _prepareForStorage(Map<String, dynamic> data) {
    final prepared = Map<String, dynamic>.from(data);
    
    // Convertir objetos complejos a JSON string
    if (prepared['coordenadas'] != null && prepared['coordenadas'] is Map) {
      prepared['coordenadas'] = jsonEncode(prepared['coordenadas']);
    }
    
    // Convertir booleanos a enteros
    if (prepared['activo'] is bool) {
      prepared['activo'] = prepared['activo'] ? 1 : 0;
    }
    
    // Asegurar que synced sea entero
    if (prepared['synced'] is bool) {
      prepared['synced'] = prepared['synced'] ? 1 : 0;
    }
    
    // Asegurar timestamps
    prepared['created_at'] ??= DateTime.now().toIso8601String();
    prepared['updated_at'] ??= DateTime.now().toIso8601String();
    
    return prepared;
  }

  /// Preparar datos desde almacenamiento
  Map<String, dynamic> _prepareFromStorage(Map<String, dynamic> data) {
    final prepared = Map<String, dynamic>.from(data);
    
    // Convertir JSON string a objetos
    if (prepared['coordenadas'] != null && prepared['coordenadas'] is String) {
      try {
        prepared['coordenadas'] = jsonDecode(prepared['coordenadas']);
      } catch (e) {
        prepared['coordenadas'] = null;
      }
    }
    
    // Convertir enteros a booleanos
    if (prepared['activo'] is int) {
      prepared['activo'] = prepared['activo'] == 1;
    }
    
    if (prepared['synced'] is int) {
      prepared['synced'] = prepared['synced'] == 1;
    }
    
    return prepared;
  }
}

