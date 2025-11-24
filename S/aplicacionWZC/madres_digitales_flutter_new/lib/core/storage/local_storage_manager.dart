import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// Manejador centralizado de almacenamiento local
class LocalStorageManager {
  
  LocalStorageManager(this._prefs, this._documentsPath);
  final SharedPreferences _prefs;
  final String _documentsPath;
  
  /// Guardar un string
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }
  
  /// Obtener un string
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }
  
  /// Guardar un objeto JSON (Map)
  Future<void> setModel(String key, Map<String, dynamic> model) async {
    final json = jsonEncode(model);
    await _prefs.setString(key, json);
  }
  
  /// Obtener un objeto JSON
  Future<T?> getModel<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    final json = _prefs.getString(key);
    if (json == null) return null;
    return fromJson(jsonDecode(json));
  }
  
  /// Eliminar una clave
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
  
  /// Limpiar todo el almacenamiento
  Future<void> clear() async {
    await _prefs.clear();
  }
  
  /// Obtener ruta de documentos
  String get documentsPath => _documentsPath;
}

/// Factory para crear LocalStorageManager
class LocalStorageManagerFactory {
  static Future<LocalStorageManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    final documentsPath = (await getApplicationDocumentsDirectory()).path;
    return LocalStorageManager(prefs, documentsPath);
  }
}
