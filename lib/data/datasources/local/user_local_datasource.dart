import 'package:sqflite/sqflite.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/data/models/user_model.dart';
import 'package:madres_digitales_flutter_new/data/datasources/local/database_helper.dart';

/// Implementación de la fuente de datos local para usuarios
class UserLocalDataSource {

  UserLocalDataSource();

  /// Obtiene todos los usuarios
  Future<List<UserModel>> getAllUsers([Map<String, dynamic>? filters]) async {
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
        'users',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'name ASC',
      );
      
      await DatabaseHelper.closeDatabase(db);
      
      return maps.map((map) => UserModel.fromJson(map)).toList();
    } catch (e) {
      AppLogger.error('Error getting users from local database: $e');
      rethrow;
    }
  }

  /// Obtiene un usuario por su ID
  Future<UserModel?> getUserById(String id) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      await DatabaseHelper.closeDatabase(db);
      
      if (maps.isEmpty) return null;
      
      return UserModel.fromJson(maps.first);
    } catch (e) {
      AppLogger.error('Error getting user by ID from local database: $e');
      rethrow;
    }
  }

  /// Obtiene un usuario por su email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      await DatabaseHelper.closeDatabase(db);
      
      if (maps.isEmpty) return null;
      
      return UserModel.fromJson(maps.first);
    } catch (e) {
      AppLogger.error('Error getting user by email from local database: $e');
      rethrow;
    }
  }

  /// Guarda un usuario en la base de datos local
  Future<UserModel> saveUser(UserModel user) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      await db.insert(
        'users',
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      await DatabaseHelper.closeDatabase(db);
      
      return user;
    } catch (e) {
      AppLogger.error('Error saving user to local database: $e');
      rethrow;
    }
  }

  /// Actualiza un usuario en la base de datos local
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      await db.update(
        'users',
        user.toJson(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      
      await DatabaseHelper.closeDatabase(db);
      
      return user;
    } catch (e) {
      AppLogger.error('Error updating user in local database: $e');
      rethrow;
    }
  }

  /// Elimina un usuario de la base de datos local
  Future<void> deleteUser(String id) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      await DatabaseHelper.closeDatabase(db);
    } catch (e) {
      AppLogger.error('Error deleting user from local database: $e');
      rethrow;
    }
  }

  /// Verifica si un email ya está registrado
  Future<bool> isEmailRegistered(String email) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      await DatabaseHelper.closeDatabase(db);
      
      return maps.isNotEmpty;
    } catch (e) {
      AppLogger.error('Error checking if email is registered in local database: $e');
      rethrow;
    }
  }

  /// Verifica si un documento ya está registrado
  Future<bool> isDocumentRegistered(String document, String documentType) async {
    try {
      final db = await DatabaseHelper.openDatabase();
      
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'document = ? AND documentType = ?',
        whereArgs: [document, documentType],
      );
      
      await DatabaseHelper.closeDatabase(db);
      
      return maps.isNotEmpty;
    } catch (e) {
      AppLogger.error('Error checking if document is registered in local database: $e');
      rethrow;
    }
  }
}
