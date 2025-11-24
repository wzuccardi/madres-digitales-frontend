import 'package:madres_digitales_flutter_new/domain/entities/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/data/models/user_model.dart';


/// Interfaz abstracta para el data source local de autenticación
abstract class AuthLocalDataSource {
  /// Guarda los datos de autenticación (usuario, token, refresh token)
  Future<void> saveAuthData({
    required User user,
    required String token,
    required String refreshToken,
  });

  /// Guarda solo el token de acceso
  Future<void> saveToken(String token);

  /// Obtiene el usuario actual almacenado
  Future<User?> getCurrentUser();

  /// Obtiene el token de acceso almacenado
  Future<String?> getToken();

  /// Obtiene el refresh token almacenado
  Future<String?> getRefreshToken();

  /// Limpia todos los datos de autenticación
  Future<void> clearAuthData();

  /// Verifica si hay datos de autenticación almacenados
  Future<bool> hasAuthData();
}

/// Implementación del data source local de autenticación
/// 
/// Usa FlutterSecureStorage para tokens (seguro)
/// Usa SharedPreferences para datos del usuario (rápido)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {

  AuthLocalDataSourceImpl({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'current_user';

  @override
  Future<void> saveAuthData({
    required User user,
    required String token,
    required String refreshToken,
  }) async {
    try {
      // Guardar tokens en secure storage (encriptado)
      await Future.wait([
        _secureStorage.write(key: _tokenKey, value: token),
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      ]);

      // Convertir User entity a UserModel y luego a JSON
      final userModel = UserModel.fromDomainEntity(user);
      final userJson = jsonEncode(userModel.toJson());

      // Guardar usuario en SharedPreferences (más rápido para lectura)
      await _prefs.setString(_userKey, userJson);

      AppLogger.info('Auth data saved successfully');
    } catch (e) {
      AppLogger.error('Error saving auth data: $e');
      throw CacheException('Failed to save auth data: ${e.toString()}');
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      AppLogger.info('Token saved successfully');
    } catch (e) {
      AppLogger.error('Error saving token: $e');
      throw CacheException('Failed to save token: ${e.toString()}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userJson = _prefs.getString(_userKey);
      
      if (userJson == null) {
        AppLogger.info('No user found in local storage');
        return null;
      }

      // Parsear JSON a Map
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      
      // Convertir Map a UserModel y luego a User entity
      final userModel = UserModel.fromJson(userMap);
      final user = userModel.toDomainEntity();

      AppLogger.info('User retrieved from local storage: ${user.email}');
      return user;
    } catch (e) {
      AppLogger.error('Error getting current user: $e');
      throw CacheException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      
      if (token == null) {
        AppLogger.info('No token found in secure storage');
      }
      
      return token;
    } catch (e) {
      AppLogger.error('Error getting token: $e');
      throw CacheException('Failed to get token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      
      if (refreshToken == null) {
        AppLogger.info('No refresh token found in secure storage');
      }
      
      return refreshToken;
    } catch (e) {
      AppLogger.error('Error getting refresh token: $e');
      throw CacheException('Failed to get refresh token: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      // Limpiar tokens de secure storage
      await Future.wait([
        _secureStorage.delete(key: _tokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
      ]);

      // Limpiar usuario de SharedPreferences
      await _prefs.remove(_userKey);

      AppLogger.info('Auth data cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing auth data: $e');
      throw CacheException('Failed to clear auth data: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasAuthData() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      final userJson = _prefs.getString(_userKey);
      
      final hasData = token != null && userJson != null;
      
      AppLogger.info('Has auth data: $hasData');
      return hasData;
    } catch (e) {
      AppLogger.error('Error checking auth data: $e');
      return false;
    }
  }
}

/// Excepción para errores de caché
class CacheException implements Exception {
  
  CacheException(this.message);
  final String message;
  
  @override
  String toString() => 'CacheException: $message';
}
