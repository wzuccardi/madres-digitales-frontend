import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de preferencias compartidas
class SharedPreferencesService {
  
  SharedPreferencesService() : _sharedPreferences = null;
  SharedPreferences? _sharedPreferences;
  
  /// Inicializar preferencias compartidas
  Future<void> initialize() async {
    try {
      AppLogger.debug('SharedPreferencesService: Inicializando preferencias compartidas');
      _sharedPreferences = await SharedPreferences.getInstance();
      AppLogger.debug('SharedPreferencesService: Preferencias compartidas inicializadas correctamente');
    } catch (e) {
      AppLogger.error('SharedPreferencesService: Error inicializando preferencias compartidas', error: e);
      rethrow;
    }
  }
  
  /// Guardar valor en preferencias compartidas
  Future<void> saveValue(String key, dynamic value) async {
    try {
      AppLogger.debug('SharedPreferencesService: Guardando valor con clave $key');
      final prefs = await _getPreferences();
      
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      } else {
        await prefs.setString(key, value.toString());
      }
      
      AppLogger.debug('SharedPreferencesService: Valor guardado correctamente');
    } catch (e) {
      AppLogger.error('SharedPreferencesService: Error guardando valor', error: e);
      rethrow;
    }
  }
  
  /// Obtener valor de preferencias compartidas
  Future<T?> getValue<T>(String key) async {
    try {
      AppLogger.debug('SharedPreferencesService: Obteniendo valor con clave $key');
      final prefs = await _getPreferences();
      
      if (T == String) {
        final value = prefs.getString(key);
        AppLogger.debug('SharedPreferencesService: Valor String obtenido correctamente');
        return value as T?;
      } else if (T == int) {
        final value = prefs.getInt(key);
        AppLogger.debug('SharedPreferencesService: Valor int obtenido correctamente');
        return value as T?;
      } else if (T == double) {
        final value = prefs.getDouble(key);
        AppLogger.debug('SharedPreferencesService: Valor double obtenido correctamente');
        return value as T?;
      } else if (T == bool) {
        final value = prefs.getBool(key);
        AppLogger.debug('SharedPreferencesService: Valor bool obtenido correctamente');
        return value as T?;
      } else if (T == List<String>) {
        final value = prefs.getStringList(key);
        AppLogger.debug('SharedPreferencesService: Valor List<String> obtenido correctamente');
        return value as T?;
      } else {
        final value = prefs.getString(key);
        AppLogger.debug('SharedPreferencesService: Valor genérico obtenido correctamente');
        return value as T?;
      }
    } catch (e) {
      AppLogger.error('SharedPreferencesService: Error obteniendo valor', error: e);
      return null;
    }
  }
  
  /// Eliminar valor de preferencias compartidas
  Future<void> removeValue(String key) async {
    try {
      AppLogger.debug('SharedPreferencesService: Eliminando valor con clave $key');
      final prefs = await _getPreferences();
      await prefs.remove(key);
      AppLogger.debug('SharedPreferencesService: Valor eliminado correctamente');
    } catch (e) {
      AppLogger.error('SharedPreferencesService: Error eliminando valor', error: e);
      rethrow;
    }
  }
  
  /// Limpiar todas las preferencias compartidas
  Future<void> clearAll() async {
    try {
      AppLogger.debug('SharedPreferencesService: Limpiando todas las preferencias');
      final prefs = await _getPreferences();
      await prefs.clear();
      AppLogger.debug('SharedPreferencesService: Preferencias limpiadas correctamente');
    } catch (e) {
      AppLogger.error('SharedPreferencesService: Error limpiando preferencias', error: e);
      rethrow;
    }
  }
  
  /// Obtener instancia de SharedPreferences
  Future<SharedPreferences> _getPreferences() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }
}
