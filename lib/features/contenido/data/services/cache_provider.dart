import 'cache_adapter.dart';

class CacheProvider {
  static CacheAdapter? _instance;
  static bool _isInitialized = false;
  
  // Obtener la instancia del caché
  static CacheAdapter getInstance() {
    _instance ??= CacheAdapterFactory.create();
    return _instance!;
  }
  
  // Inicializar el caché
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final cache = getInstance();
      await cache.init();
      _isInitialized = true;
    } catch (e) {
      // En caso de error, crear una instancia nula para evitar fallos
      _instance = NullCacheService();
      _isInitialized = true;
    }
  }
  
  // Reinicializar el caché
  static Future<void> reinitialize() async {
    _instance = null;
    _isInitialized = false;
    await initialize();
  }
  
  // Verificar si está inicializado
  static bool get isInitialized => _isInitialized;
}

// Implementación nula para evitar errores cuando el caché no está disponible
class NullCacheService implements CacheAdapter {
  @override
  Future<void> init() async {}
  
  @override
  Future<void> cacheContenidos(dynamic contenidos) async {}
  
  @override
  Future<dynamic> getCachedContenidos() async => null;
  
  @override
  Future<void> cacheContenido(dynamic contenido) async {}
  
  @override
  Future<dynamic> getCachedContenidoById(String id) async => null;
  
  @override
  Future<void> cacheSearchResults(String query, dynamic resultados) async {}
  
  @override
  Future<dynamic> getCachedSearchResults(String query) async => null;
  
  @override
  Future<void> cacheFavoritos(String usuarioId, dynamic favoritos) async {}
  
  @override
  Future<dynamic> getCachedFavoritos(String usuarioId) async => null;
  
  @override
  Future<void> cacheProgreso(String contenidoId, String usuarioId, Map<String, dynamic> progreso) async {}
  
  @override
  Future<Map<String, dynamic>?> getCachedProgreso(String contenidoId, String usuarioId) async => null;
  
  @override
  Future<void> clearCache() async {}
  
  @override
  Future<bool> isCacheValid({String? key}) async => false;
}