import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';
import 'package:madres_digitales_flutter_new/models/contenido_unificado.dart';

/// Servicio para almacenamiento local
class LocalStorageService {
  final SharedPreferences _prefs;
  static const _secureStorage = FlutterSecureStorage();

  LocalStorageService(this._prefs);

  // Métodos seguros para tokens y credenciales
  Future<void> saveAuthToken(String token) async {
    try {
      await _secureStorage.write(key: 'auth_token', value: token);
      appLogger.debug('Token guardado de forma segura');
    } catch (e) {
      appLogger.error('Error guardando token de forma segura', error: e);
      rethrow;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      appLogger.error('Error obteniendo token de forma segura', error: e);
      return null;
    }
  }

  Future<void> clearAuthData() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      appLogger.debug('Datos de autenticación eliminados de forma segura');
    } catch (e) {
      appLogger.error('Error eliminando datos de autenticación', error: e);
      rethrow;
    }
  }

  // Métodos para otros datos sensibles
  Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: 'refresh_token', value: token);
      appLogger.debug('Refresh token guardado de forma segura');
    } catch (e) {
      appLogger.error('Error guardando refresh token', error: e);
      rethrow;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: 'refresh_token');
    } catch (e) {
      appLogger.error('Error obteniendo refresh token', error: e);
      return null;
    }
  }

  /// Guardar un objeto como JSON
  Future<void> saveObject(String key, dynamic object) async {
    try {
      final jsonString = jsonEncode(object);
      await _prefs.setString(key, jsonString);
      appLogger.debug('LocalStorageService: Objeto guardado con clave: $key');
    } catch (e) {
      appLogger.error('Error guardando objeto', error: e, context: {
        'key': key,
      });
      rethrow;
    }
  }

  /// Obtener un objeto desde JSON
  Future<dynamic> getObject(String key) async {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;

      final object = jsonDecode(jsonString);
      appLogger.debug('LocalStorageService: Objeto obtenido con clave: $key');
      return object;
    } catch (e) {
      appLogger.error('Error obteniendo objeto', error: e, context: {
        'key': key,
      });
      return null;
    }
  }

  /// Guardar una cadena de texto
  Future<void> saveString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
      appLogger.debug('LocalStorageService: Cadena guardada con clave: $key');
    } catch (e) {
      appLogger.error('Error guardando cadena', error: e, context: {
        'key': key,
      });
      rethrow;
    }
  }

  /// Obtener una cadena de texto
  Future<String?> getString(String key) async {
    try {
      final value = _prefs.getString(key);
      appLogger.debug('LocalStorageService: Cadena obtenida con clave: $key');
      return value;
    } catch (e) {
      appLogger.error('Error obteniendo cadena', error: e, context: {
        'key': key,
      });
      return null;
    }
  }

  /// Guardar un entero
  Future<void> saveInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
      appLogger.debug('LocalStorageService: Entero guardado con clave: $key');
    } catch (e) {
      appLogger.error('Error guardando entero', error: e, context: {
        'key': key,
      });
      rethrow;
    }
  }

  /// Obtener un entero
  Future<int?> getInt(String key) async {
    try {
      final value = _prefs.getInt(key);
      appLogger.debug('LocalStorageService: Entero obtenido con clave: $key');
      return value;
    } catch (e) {
      appLogger.error('Error obteniendo entero', error: e, context: {
        'key': key,
      });
      return null;
    }
  }

  /// Guardar un booleano
  Future<void> saveBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
      appLogger.debug('LocalStorageService: Booleano guardado con clave: $key');
    } catch (e) {
      appLogger.error('Error guardando booleano', error: e, context: {
        'key': key,
      });
      rethrow;
    }
  }

  /// Obtener un booleano
  Future<bool?> getBool(String key) async {
    try {
      final value = _prefs.getBool(key);
      appLogger.debug('LocalStorageService: Booleano obtenido con clave: $key');
      return value;
    } catch (e) {
      appLogger.error('Error obteniendo booleano', error: e, context: {
        'key': key,
      });
      return null;
    }
  }

  /// Eliminar una clave
  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
      appLogger.debug('LocalStorageService: Clave eliminada: $key');
    } catch (e) {
      appLogger.error('Error eliminando clave', error: e, context: {
        'key': key,
      });
      rethrow;
    }
  }

  /// Limpiar todos los datos
  Future<void> clear() async {
    try {
      await _prefs.clear();
      appLogger.debug('LocalStorageService: Todos los datos eliminados');
    } catch (e) {
      appLogger.error('Error limpiando datos', error: e);
      rethrow;
    }
  }

  /// Guardar contenidos
  Future<void> saveContenidos(List<ContenidoUnificado> contenidos) async {
    try {
      final contenidosJson = contenidos.map((c) => c.toJson()).toList();
      await saveObject('contenidos', {
        'data': contenidosJson,
        'timestamp': DateTime.now().toIso8601String(),
      });
      appLogger.debug('LocalStorageService: ${contenidos.length} contenidos guardados');
    } catch (e) {
      appLogger.error('Error guardando contenidos', error: e);
      rethrow;
    }
  }

  /// Obtener contenidos
  Future<List<ContenidoUnificado>?> getContenidos() async {
    try {
      final contenidosData = await getObject('contenidos');
      if (contenidosData == null) return null;

      final List<dynamic>? contenidosList = contenidosData['data'];
      if (contenidosList == null) return null;

      // Convertir directamente a ContenidoUnificado
      return contenidosList.map((c) => ContenidoUnificado.fromJson(c)).toList();
    } catch (e) {
      appLogger.error('Error obteniendo contenidos', error: e);
      return null;
    }
  }

  /// Guardar un contenido individual
  Future<void> saveContenido(ContenidoUnificado contenido) async {
    try {
      // Serializar el contenido a un Map<String, dynamic>
      final contenidoJson = contenido.toJson();

      await saveObject('contenido_${contenido.id}', contenidoJson);
      appLogger.debug('LocalStorageService: Contenido guardado con ID: ${contenido.id}');
    } catch (e) {
      appLogger.error('Error guardando contenido', error: e, context: {
        'contenidoId': contenido.id,
      });
      rethrow;
    }
  }

  /// Obtener un contenido individual
  Future<ContenidoUnificado?> getContenido(String id) async {
    try {
      final contenidoJson = await getObject('contenido_$id');
      if (contenidoJson == null) return null;

      // Convertir directamente a ContenidoUnificado
      return ContenidoUnificado.fromJson(contenidoJson);
    } catch (e) {
      appLogger.error('Error obteniendo contenido', error: e, context: {
        'contenidoId': id,
      });
      return null;
    }
  }
}
