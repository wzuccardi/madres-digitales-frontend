import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:madres_digitales_flutter_new/domain/entities/user.dart';
import 'package:madres_digitales_flutter_new/domain/entities/alerta.dart';
import 'package:madres_digitales_flutter_new/domain/entities/contenido_unificado.dart';

class CacheService {
  CacheService();

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  // User change notifications
  final StreamController<User?> _userChangesController = StreamController<User?>.broadcast();
  Stream<User?> get userChanges => _userChangesController.stream;

  // Token helpers
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // User helpers
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_userKey, jsonString);
    _userChangesController.add(user);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userKey);
    if (jsonString == null) return null;
    final data = jsonDecode(jsonString);
    return data is Map<String, dynamic> ? data : null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    _userChangesController.add(null);
  }
  Future<List<dynamic>?> getList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    final data = jsonDecode(jsonString);
    if (data is List) return data;
    return null;
  }

  Future<bool> setList(String key, List<dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(value);
    return await prefs.setString(key, jsonString);
  }

  Future<Map<String, dynamic>?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    final data = jsonDecode(jsonString);
    if (data is Map<String, dynamic>) return data;
    return null;
  }

  Future<bool> set(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(value);
    return await prefs.setString(key, jsonString);
  }

  void dispose() {
    _userChangesController.close();
  }

  // Alertas cache
  static const String _alertasKey = 'cache_alertas';
  Future<List<Alerta>?> getCachedAlertas() async {
    final list = await getList(_alertasKey);
    if (list == null) return null;
    return list.map((e) => Alerta.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<void> cacheAlertas(List<Alerta> alertas) async {
    await setList(_alertasKey, alertas.map((a) => a.toJson()).toList());
  }
  Future<void> cacheAlerta(Alerta alerta) async {
    final existing = await getList(_alertasKey) ?? [];
    existing.removeWhere((e) => (e as Map<String, dynamic>)['id'] == alerta.id);
    existing.add(alerta.toJson());
    await setList(_alertasKey, existing);
  }
  Future<void> updateAlertaStatus(String id, AlertaEstado estado) async {
    final existing = await getList(_alertasKey) ?? [];
    final updated = existing.map((e) {
      final m = e as Map<String, dynamic>;
      if (m['id'] == id) {
        m['estado'] = estado.toString().split('.').last;
      }
      return m;
    }).toList();
    await setList(_alertasKey, updated);
  }
  Future<void> updateAlertaMadrina(String alertaId, String madrinaId) async {
    final existing = await getList(_alertasKey) ?? [];
    final updated = existing.map((e) {
      final m = e as Map<String, dynamic>;
      if (m['id'] == alertaId) {
        m['madrinaId'] = madrinaId;
      }
      return m;
    }).toList();
    await setList(_alertasKey, updated);
  }
  Future<void> deleteCachedAlerta(String id) async {
    final existing = await getList(_alertasKey) ?? [];
    existing.removeWhere((e) => (e as Map<String, dynamic>)['id'] == id);
    await setList(_alertasKey, existing);
  }

  // Contenidos cache
  static const String _contenidosKey = 'cache_contenidos';
  Future<List<ContenidoUnificado>?> getCachedContenidos() async {
    final list = await getList(_contenidosKey);
    if (list == null) return null;
    return list.map((e) => ContenidoUnificado.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<void> cacheContenidos(List<ContenidoUnificado> contenidos) async {
    await setList(_contenidosKey, contenidos.map((c) => c.toJson()).toList());
  }
  Future<ContenidoUnificado?> getCachedContenidoById(String id) async {
    final list = await getList(_contenidosKey) ?? [];
    for (final e in list) {
      final m = e as Map<String, dynamic>;
      if (m['id']?.toString() == id) {
        return ContenidoUnificado.fromJson(m);
      }
    }
    return null;
  }
  Future<void> cacheContenido(ContenidoUnificado contenido) async {
    final existing = await getList(_contenidosKey) ?? [];
    existing.removeWhere((e) => (e as Map<String, dynamic>)['id']?.toString() == contenido.id.toString());
    existing.add(contenido.toJson());
    await setList(_contenidosKey, existing);
  }
  Future<void> deleteCachedContenido(String id) async {
    final existing = await getList(_contenidosKey) ?? [];
    existing.removeWhere((e) => (e as Map<String, dynamic>)['id']?.toString() == id);
    await setList(_contenidosKey, existing);
  }
  Future<void> cacheSearchResults(String query, List<ContenidoUnificado> resultados) async {
    await setList('cache_search_$query', resultados.map((c) => c.toJson()).toList());
  }
  
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Video cache
  static const String _videoCacheMapKey = 'video_cache_map';
  Future<String?> getCachedVideoPath(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_videoCacheMapKey);
    if (jsonString == null) return null;
    final Map<String, dynamic> map = jsonDecode(jsonString) as Map<String, dynamic>;
    final path = map[url] as String?;
    if (path == null) return null;
    if (await File(path).exists()) {
      return path;
    } else {
      // limpiar entrada obsoleta
      map.remove(url);
      await prefs.setString(_videoCacheMapKey, jsonEncode(map));
      return null;
    }
  }

  Future<void> cacheVideo(String url, {void Function(double)? onProgress}) async {
    final directory = await getTemporaryDirectory();
    final filename = _sanitizeFileName(Uri.parse(url).pathSegments.isNotEmpty
        ? Uri.parse(url).pathSegments.last
        : 'video_${DateTime.now().millisecondsSinceEpoch}.mp4');
    final savePath = '${directory.path}/$filename';

    final dio = Dio();
    await dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress?.call(received / total);
        }
      },
      options: Options(responseType: ResponseType.bytes),
    );

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_videoCacheMapKey);
    final Map<String, dynamic> map = jsonString != null
        ? (jsonDecode(jsonString) as Map<String, dynamic>)
        : <String, dynamic>{};
    map[url] = savePath;
    await prefs.setString(_videoCacheMapKey, jsonEncode(map));
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }
}