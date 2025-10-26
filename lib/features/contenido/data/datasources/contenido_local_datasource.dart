import '../../domain/entities/contenido.dart';
import '../models/contenido_model.dart';
import '../models/categoria_model.dart';

abstract class ContenidoLocalDataSource {
  // Métodos de caché
  Future<void> cacheContenidos(List<ContenidoModel> contenidos);
  Future<List<ContenidoModel>> getCachedContenidos({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
  });

  Future<void> cacheContenido(ContenidoModel contenido);
  Future<ContenidoModel?> getCachedContenidoById(String id);
  Future<void> deleteCachedContenido(String id);

  // Métodos de búsqueda
  Future<void> cacheSearchResults(String query, List<ContenidoModel> contenidos);
  Future<List<ContenidoModel>> getCachedSearchResults(String query);

  // Métodos de favoritos
  Future<void> cacheFavoritos(String usuarioId, List<ContenidoModel> contenidos);
  Future<List<ContenidoModel>> getCachedFavoritos(String usuarioId);
  Future<void> queueToggleFavorito(String contenidoId);
  Future<List<String>> getQueuedToggleFavoritos();
  Future<void> clearQueuedToggleFavoritos();

  // Métodos de progreso
  Future<void> cacheContenidosConProgreso(String usuarioId, List<ContenidoModel> contenidos);
  Future<List<ContenidoModel>> getCachedContenidosConProgreso(String usuarioId);
  Future<void> queueRegistrarVista(String contenidoId);
  Future<List<String>> getQueuedRegistrarVista();
  Future<void> clearQueuedRegistrarVista();
  Future<void> queueActualizarProgreso(
    String contenidoId, {
    int? tiempoVisualizado,
    double? porcentaje,
    bool? completado,
  });
  Future<Map<String, dynamic>> getQueuedActualizarProgreso();
  Future<void> clearQueuedActualizarProgreso();

  // Métodos de categorías
  Future<void> cacheCategorias(List<CategoriaModel> categorias);
  Future<List<CategoriaModel>> getCachedCategorias();

  // Métodos de sincronización
  Future<Map<String, dynamic>> getPendingSyncActions();
  Future<void> clearPendingSyncAction(String actionId);
  Future<void> clearAllSyncActions();

  // Métodos de gestión de caché
  Future<void> clearCache({CategoriaContenido? categoria});
  Future<bool> isCacheValid({CategoriaContenido? categoria});
  Future<void> setCacheTimestamp({CategoriaContenido? categoria});
}

class ContenidoLocalDataSourceImpl implements ContenidoLocalDataSource {
  // Para una implementación completa, esto usaría Hive, SQLite o similar
  // Por ahora, una implementación simulada con memoria
  final Map<String, List<ContenidoModel>> _cachedContenidosByCategory = {};
  final Map<String, ContenidoModel> _cachedContenidosById = {};
  final Map<String, List<ContenidoModel>> _searchResults = {};
  final Map<String, List<ContenidoModel>> _favoritosByUser = {};
  final Map<String, List<ContenidoModel>> _contenidosWithProgresoByUser = {};
  final List<String> _queuedToggleFavoritos = [];
  final List<String> _queuedRegistrarVista = [];
  final Map<String, Map<String, dynamic>> _queuedActualizarProgreso = {};
  final List<CategoriaModel> _cachedCategorias = [];
  final Map<String, DateTime> _cacheTimestamps = {};

  @override
  Future<void> cacheContenidos(List<ContenidoModel> contenidos) async {
    for (final contenido in contenidos) {
      _cachedContenidosById[contenido.id] = contenido;
    }
    
    // Agrupar por categoría para acceso rápido
    final contenidosByCategory = <String, List<ContenidoModel>>{};
    for (final contenido in contenidos) {
      final categoria = contenido.categoria;
      if (!contenidosByCategory.containsKey(categoria)) {
        contenidosByCategory[categoria] = [];
      }
      contenidosByCategory[categoria]!.add(contenido);
    }
    
    for (final entry in contenidosByCategory.entries) {
      _cachedContenidosByCategory[entry.key] = entry.value;
    }
    
    // Marcar timestamp de caché
    await setCacheTimestamp();
  }

  @override
  Future<List<ContenidoModel>> getCachedContenidos({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
  }) async {
    if (categoria != null) {
      final contenidos = _cachedContenidosByCategory[categoria.value] ?? [];
      
      // Aplicar filtros adicionales
      List<ContenidoModel> filteredContenidos = contenidos;
      
      if (tipo != null) {
        filteredContenidos = filteredContenidos
            .where((c) => c.tipo == tipo.value)
            .toList();
      }
      
      if (nivel != null) {
        filteredContenidos = filteredContenidos
            .where((c) => c.nivel == nivel.value)
            .toList();
      }
      
      return filteredContenidos;
    }
    
    // Si no hay categoría, devolver todos los contenidos
    return _cachedContenidosById.values.toList();
  }

  @override
  Future<void> cacheContenido(ContenidoModel contenido) async {
    _cachedContenidosById[contenido.id] = contenido;
    
    // Actualizar caché por categoría
    final categoria = contenido.categoria;
    if (!_cachedContenidosByCategory.containsKey(categoria)) {
      _cachedContenidosByCategory[categoria] = [];
    }
    
    // Verificar si ya existe en la lista
    final existingIndex = _cachedContenidosByCategory[categoria]!
        .indexWhere((c) => c.id == contenido.id);
    
    if (existingIndex >= 0) {
      _cachedContenidosByCategory[categoria]![existingIndex] = contenido;
    } else {
      _cachedContenidosByCategory[categoria]!.add(contenido);
    }
  }

  @override
  Future<ContenidoModel?> getCachedContenidoById(String id) async {
    return _cachedContenidosById[id];
  }

  @override
  Future<void> deleteCachedContenido(String id) async {
    _cachedContenidosById.remove(id);
    
    // Eliminar de las listas por categoría
    for (final categoryList in _cachedContenidosByCategory.values) {
      categoryList.removeWhere((c) => c.id == id);
    }
  }

  @override
  Future<void> cacheSearchResults(String query, List<ContenidoModel> contenidos) async {
    _searchResults[query] = contenidos;
  }

  @override
  Future<List<ContenidoModel>> getCachedSearchResults(String query) async {
    return _searchResults[query] ?? [];
  }

  @override
  Future<void> cacheFavoritos(String usuarioId, List<ContenidoModel> contenidos) async {
    _favoritosByUser[usuarioId] = contenidos;
  }

  @override
  Future<List<ContenidoModel>> getCachedFavoritos(String usuarioId) async {
    return _favoritosByUser[usuarioId] ?? [];
  }

  @override
  Future<void> queueToggleFavorito(String contenidoId) async {
    if (!_queuedToggleFavoritos.contains(contenidoId)) {
      _queuedToggleFavoritos.add(contenidoId);
    }
  }

  @override
  Future<List<String>> getQueuedToggleFavoritos() async {
    return List.from(_queuedToggleFavoritos);
  }

  @override
  Future<void> clearQueuedToggleFavoritos() async {
    _queuedToggleFavoritos.clear();
  }

  @override
  Future<void> cacheContenidosConProgreso(String usuarioId, List<ContenidoModel> contenidos) async {
    _contenidosWithProgresoByUser[usuarioId] = contenidos;
  }

  @override
  Future<List<ContenidoModel>> getCachedContenidosConProgreso(String usuarioId) async {
    return _contenidosWithProgresoByUser[usuarioId] ?? [];
  }

  @override
  Future<void> queueRegistrarVista(String contenidoId) async {
    if (!_queuedRegistrarVista.contains(contenidoId)) {
      _queuedRegistrarVista.add(contenidoId);
    }
  }

  @override
  Future<List<String>> getQueuedRegistrarVista() async {
    return List.from(_queuedRegistrarVista);
  }

  @override
  Future<void> clearQueuedRegistrarVista() async {
    _queuedRegistrarVista.clear();
  }

  @override
  Future<void> queueActualizarProgreso(
    String contenidoId, {
    int? tiempoVisualizado,
    double? porcentaje,
    bool? completado,
  }) async {
    _queuedActualizarProgreso[contenidoId] = {
      'tiempoVisualizado': tiempoVisualizado,
      'porcentaje': porcentaje,
      'completado': completado,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> getQueuedActualizarProgreso() async {
    return Map.from(_queuedActualizarProgreso);
  }

  @override
  Future<void> clearQueuedActualizarProgreso() async {
    _queuedActualizarProgreso.clear();
  }

  @override
  Future<void> cacheCategorias(List<CategoriaModel> categorias) async {
    _cachedCategorias.clear();
    _cachedCategorias.addAll(categorias);
  }

  @override
  Future<List<CategoriaModel>> getCachedCategorias() async {
    return List.from(_cachedCategorias);
  }

  @override
  Future<Map<String, dynamic>> getPendingSyncActions() async {
    final actions = <String, dynamic>{};
    
    if (_queuedToggleFavoritos.isNotEmpty) {
      actions['toggleFavoritos'] = _queuedToggleFavoritos;
    }
    
    if (_queuedRegistrarVista.isNotEmpty) {
      actions['registrarVista'] = _queuedRegistrarVista;
    }
    
    if (_queuedActualizarProgreso.isNotEmpty) {
      actions['actualizarProgreso'] = _queuedActualizarProgreso;
    }
    
    return actions;
  }

  @override
  Future<void> clearPendingSyncAction(String actionId) async {
    switch (actionId) {
      case 'toggleFavoritos':
        await clearQueuedToggleFavoritos();
        break;
      case 'registrarVista':
        await clearQueuedRegistrarVista();
        break;
      case 'actualizarProgreso':
        await clearQueuedActualizarProgreso();
        break;
    }
  }

  @override
  Future<void> clearAllSyncActions() async {
    await clearQueuedToggleFavoritos();
    await clearQueuedRegistrarVista();
    await clearQueuedActualizarProgreso();
  }

  @override
  Future<void> clearCache({CategoriaContenido? categoria}) async {
    if (categoria != null) {
      _cachedContenidosByCategory.remove(categoria.value);
      _cacheTimestamps.remove(categoria.value);
    } else {
      _cachedContenidosByCategory.clear();
      _cachedContenidosById.clear();
      _searchResults.clear();
      _favoritosByUser.clear();
      _contenidosWithProgresoByUser.clear();
      _cachedCategorias.clear();
      _cacheTimestamps.clear();
    }
  }

  @override
  Future<bool> isCacheValid({CategoriaContenido? categoria}) async {
    final key = categoria?.value ?? 'all';
    final timestamp = _cacheTimestamps[key];
    
    if (timestamp == null) return false;
    
    // Considerar válido si tiene menos de 1 hora
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    return difference.inMinutes < 60;
  }

  @override
  Future<void> setCacheTimestamp({CategoriaContenido? categoria}) async {
    final key = categoria?.value ?? 'all';
    _cacheTimestamps[key] = DateTime.now();
  }
}

// Excepciones personalizadas
class CacheException implements Exception {
  final String message;
  
  const CacheException(this.message);
}