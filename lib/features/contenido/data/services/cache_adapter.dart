import 'package:flutter/foundation.dart' show kIsWeb;
import 'cache_service.dart';
import 'web_cache_service.dart';

abstract class CacheAdapter {
  Future<void> init();
  Future<void> cacheContenidos(dynamic contenidos);
  Future<dynamic> getCachedContenidos();
  Future<void> cacheContenido(dynamic contenido);
  Future<dynamic> getCachedContenidoById(String id);
  Future<void> cacheSearchResults(String query, dynamic resultados);
  Future<dynamic> getCachedSearchResults(String query);
  Future<void> cacheFavoritos(String usuarioId, dynamic favoritos);
  Future<dynamic> getCachedFavoritos(String usuarioId);
  Future<void> cacheProgreso(String contenidoId, String usuarioId, Map<String, dynamic> progreso);
  Future<Map<String, dynamic>?> getCachedProgreso(String contenidoId, String usuarioId);
  Future<void> clearCache();
  Future<bool> isCacheValid({String? key});
}

class CacheAdapterFactory {
  static CacheAdapter create() {
    if (kIsWeb) {
      return WebCacheAdapter();
    } else {
      return MobileCacheAdapter();
    }
  }
}

// Adaptador para Flutter Web
class WebCacheAdapter implements CacheAdapter {
  final WebCacheService _webCacheService;
  
  WebCacheAdapter() : _webCacheService = WebCacheService();
  
  @override
  Future<void> init() async {
    await _webCacheService.init();
  }
  
  @override
  Future<void> cacheContenidos(dynamic contenidos) async {
    await _webCacheService.cacheContenidos(contenidos);
  }
  
  @override
  Future<dynamic> getCachedContenidos() async {
    return await _webCacheService.getCachedContenidos();
  }
  
  @override
  Future<void> cacheContenido(dynamic contenido) async {
    await _webCacheService.cacheContenido(contenido);
  }
  
  @override
  Future<dynamic> getCachedContenidoById(String id) async {
    return await _webCacheService.getCachedContenidoById(id);
  }
  
  @override
  Future<void> cacheSearchResults(String query, dynamic resultados) async {
    await _webCacheService.cacheSearchResults(query, resultados);
  }
  
  @override
  Future<dynamic> getCachedSearchResults(String query) async {
    return await _webCacheService.getCachedSearchResults(query);
  }
  
  @override
  Future<void> cacheFavoritos(String usuarioId, dynamic favoritos) async {
    await _webCacheService.cacheFavoritos(usuarioId, favoritos);
  }
  
  @override
  Future<dynamic> getCachedFavoritos(String usuarioId) async {
    return await _webCacheService.getCachedFavoritos(usuarioId);
  }
  
  @override
  Future<void> cacheProgreso(String contenidoId, String usuarioId, Map<String, dynamic> progreso) async {
    await _webCacheService.cacheProgreso(contenidoId, usuarioId, progreso);
  }
  
  @override
  Future<Map<String, dynamic>?> getCachedProgreso(String contenidoId, String usuarioId) async {
    return await _webCacheService.getCachedProgreso(contenidoId, usuarioId);
  }
  
  @override
  Future<void> clearCache() async {
    await _webCacheService.clearCache();
  }
  
  @override
  Future<bool> isCacheValid({String? key}) async {
    return await _webCacheService.isCacheValid(key: key);
  }
}

// Adaptador para móviles (Android/iOS)
class MobileCacheAdapter implements CacheAdapter {
  final CacheService _cacheService;
  
  MobileCacheAdapter() : _cacheService = CacheService();
  
  @override
  Future<void> init() async {
    await _cacheService.init();
  }
  
  @override
  Future<void> cacheContenidos(dynamic contenidos) async {
    await _cacheService.cacheContenidos(contenidos);
  }
  
  @override
  Future<dynamic> getCachedContenidos() async {
    return await _cacheService.getCachedContenidos();
  }
  
  @override
  Future<void> cacheContenido(dynamic contenido) async {
    await _cacheService.cacheContenido(contenido);
  }
  
  @override
  Future<dynamic> getCachedContenidoById(String id) async {
    return await _cacheService.getCachedContenidoById(id);
  }
  
  @override
  Future<void> cacheSearchResults(String query, dynamic resultados) async {
    await _cacheService.cacheSearchResults(query, resultados);
  }
  
  @override
  Future<dynamic> getCachedSearchResults(String query) async {
    return await _cacheService.getCachedSearchResults(query);
  }
  
  @override
  Future<void> cacheFavoritos(String usuarioId, dynamic favoritos) async {
    await _cacheService.cacheFavoritos(usuarioId, favoritos);
  }
  
  @override
  Future<dynamic> getCachedFavoritos(String usuarioId) async {
    return await _cacheService.getCachedFavoritos(usuarioId);
  }
  
  @override
  Future<void> cacheProgreso(String contenidoId, String usuarioId, Map<String, dynamic> progreso) async {
    await _cacheService.cacheProgreso(contenidoId, usuarioId, progreso);
  }
  
  @override
  Future<Map<String, dynamic>?> getCachedProgreso(String contenidoId, String usuarioId) async {
    return await _cacheService.getCachedProgreso(contenidoId, usuarioId);
  }
  
  @override
  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }
  
  @override
  Future<bool> isCacheValid({String? key}) async {
    return await _cacheService.isCacheValid(key: key);
  }
}