import 'package:sqflite/sqflite.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import '../../models/gestante_model.dart';
import 'database_helper.dart';

/// Implementación de la fuente de datos local para gestantes
class GestanteLocalDataSource {

  GestanteLocalDataSource();

  /// Obtiene todas las gestantes
  Future<List<GestanteModel>> getAllGestantes([Map<String, dynamic>? filters]) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      if (filters != null) {
        filters.forEach((key, value) {
          if (whereClause.isNotEmpty) {
            whereClause += ' AND ';
          }
          
          whereClause += '$key = ?';
          whereArgs.add(value);
        });
      }
      
      final List<Map<String, dynamic>> maps = await db.query(
        'gestantes',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'name ASC',
      );
      
      await DatabaseHelper.closeDatabase(db);
      
      return maps.map((map) => GestanteModel.fromJson(map)).toList();
    } catch (e) {
      AppLogger.error('Error getting gestantes from local database: $e');
      rethrow;
    }
  }

  /// Obtiene una gestante por su ID
  Future<GestanteModel?> getGestanteById(String id) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      final List<Map<String, dynamic>> maps = await db.query(
        'gestantes',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      await DatabaseHelper.closeDatabase(db);
      
      if (maps.isEmpty) return null;
      
      return GestanteModel.fromJson(maps.first);
    } catch (e) {
      AppLogger.error('Error getting gestante by ID from local database: $e');
      rethrow;
    }
  }

  /// Guarda una gestante en la base de datos local
  Future<GestanteModel> saveGestante(GestanteModel gestante) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      await db.insert(
        'gestantes',
        gestante.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      await DatabaseHelper.closeDatabase(db);
      
      return gestante;
    } catch (e) {
      AppLogger.error('Error saving gestante to local database: $e');
      rethrow;
    }
  }

  /// Actualiza una gestante en la base de datos local
  Future<GestanteModel> updateGestante(GestanteModel gestante) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      await db.update(
        'gestantes',
        gestante.toJson(),
        where: 'id = ?',
        whereArgs: [gestante.id],
      );
      
      await DatabaseHelper.closeDatabase(db);
      
      return gestante;
    } catch (e) {
      AppLogger.error('Error updating gestante in local database: $e');
      rethrow;
    }
  }

  /// Elimina una gestante de la base de datos local
  Future<void> deleteGestante(String id) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      await db.delete(
        'gestantes',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      await DatabaseHelper.closeDatabase(db);
    } catch (e) {
      AppLogger.error('Error deleting gestante from local database: $e');
      rethrow;
    }
  }

  /// Busca gestantes por criterios
  Future<List<GestanteModel>> searchGestantes(Map<String, dynamic> criteria) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      criteria.forEach((key, value) {
        if (whereClause.isNotEmpty) {
          whereClause += ' AND ';
        }
        whereClause += '$key = ?';
        whereArgs.add(value);
      });
      
      final List<Map<String, dynamic>> maps = await db.query(
        'gestantes',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'name ASC',
      );
      
      await DatabaseHelper.closeDatabase(db);
      
      return maps.map((map) => GestanteModel.fromJson(map)).toList();
    } catch (e) {
      AppLogger.error('Error searching gestantes in local database: $e');
      rethrow;
    }
  }

  /// Obtiene gestantes por página (paginación)
  Future<List<GestanteModel>> getGestantesPage({
    required int page,
    required int limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      if (filters != null) {
        filters.forEach((key, value) {
          if (whereClause.isNotEmpty) {
            whereClause += ' AND ';
          }
          
          whereClause += '$key = ?';
          whereArgs.add(value);
        });
      }
      
      final List<Map<String, dynamic>> maps = await db.query(
        'gestantes',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'name ASC',
        limit: limit,
        offset: (page - 1) * limit,
      );
      
      await DatabaseHelper.closeDatabase(db);
      
      return maps.map((map) => GestanteModel.fromJson(map)).toList();
    } catch (e) {
      AppLogger.error('Error getting gestantes page from local database: $e');
      rethrow;
    }
  }

  /// Obtiene el conteo total de gestantes
  Future<int> getGestantesCount([Map<String, dynamic>? filters]) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      if (filters != null) {
        filters.forEach((key, value) {
          if (whereClause.isNotEmpty) {
            whereClause += ' AND ';
          }
          
          whereClause += '$key = ?';
          whereArgs.add(value);
        });
      }
      
      final countResult = await db.rawQuery(
        'SELECT COUNT(*) FROM gestantes${whereClause.isNotEmpty ? ' WHERE $whereClause' : ''}',
        whereArgs.isNotEmpty ? whereArgs : null,
      );
      await DatabaseHelper.closeDatabase(db);
      return (countResult.first.values.first as num).toInt();
    } catch (e) {
      AppLogger.error('Error getting gestantes count from local database: $e');
      rethrow;
    }
  }
}
