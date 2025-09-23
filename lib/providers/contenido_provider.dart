import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contenido_model.dart';
import '../services/contenido_service.dart';

// Service provider
final contenidoServiceProvider = Provider<ContenidoService>((ref) {
  return ContenidoService();
});

// State providers for content
final contenidosProvider = StateNotifierProvider<ContenidosNotifier, AsyncValue<List<ContenidoModel>>>((ref) {
  return ContenidosNotifier(ref.read(contenidoServiceProvider));
});

final contenidosPorCategoriaProvider = StateNotifierProvider.family<ContenidosPorCategoriaNotifier, AsyncValue<List<ContenidoModel>>, CategoriaContenido>((ref, categoria) {
  return ContenidosPorCategoriaNotifier(ref.read(contenidoServiceProvider), categoria);
});

final contenidosRecomendadosProvider = StateNotifierProvider.family<ContenidosRecomendadosNotifier, AsyncValue<List<ContenidoModel>>, String>((ref, gestanteId) {
  return ContenidosRecomendadosNotifier(ref.read(contenidoServiceProvider), gestanteId);
});

final contenidoDetailProvider = StateNotifierProvider.family<ContenidoDetailNotifier, AsyncValue<ContenidoModel?>, String>((ref, contenidoId) {
  return ContenidoDetailNotifier(ref.read(contenidoServiceProvider), contenidoId);
});

final progresoContenidoProvider = StateNotifierProvider.family<ProgresoContenidoNotifier, AsyncValue<ProgresoContenidoModel?>, ContenidoProgressParams>((ref, params) {
  return ProgresoContenidoNotifier(ref.read(contenidoServiceProvider), params);
});

// Search and filter providers
final contenidoSearchProvider = StateProvider<String>((ref) => '');

final contenidoFilterProvider = StateProvider<ContenidoFilter>((ref) => ContenidoFilter());

final filteredContenidosProvider = Provider<AsyncValue<List<ContenidoModel>>>((ref) {
  final contenidos = ref.watch(contenidosProvider);
  final searchQuery = ref.watch(contenidoSearchProvider);
  final filter = ref.watch(contenidoFilterProvider);
  
  return contenidos.when(
    data: (contenidosList) {
      var filtered = contenidosList.asMap().entries.map((entry) => entry.value).toList();
      
      // Apply search filter
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((contenido) {
          return contenido.titulo.toLowerCase().contains(searchQuery.toLowerCase()) ||
                 contenido.descripcion.toLowerCase().contains(searchQuery.toLowerCase()) ||
                 contenido.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()));
        }).toList();
      }
      
      // Apply category filter
      if (filter.categoria != null) {
        filtered = filtered.where((contenido) => contenido.categoria == filter.categoria).toList();
      }
      
      // Apply type filter
      if (filter.tipo != null) {
        filtered = filtered.where((contenido) => contenido.tipo == filter.tipo).toList();
      }
      
      // Apply difficulty filter
      if (filter.dificultad != null) {
        filtered = filtered.where((contenido) => contenido.nivelDificultad == filter.dificultad).toList();
      }
      
      // Apply duration filter
      if (filter.duracionMaxima != null) {
        filtered = filtered.where((contenido) => 
          contenido.duracionMinutos != null && 
          contenido.duracionMinutos! <= filter.duracionMaxima!
        ).toList();
      }
      
      // Apply favorites filter
      if (filter.soloFavoritos) {
        filtered = filtered.where((contenido) => contenido.esFavorito).toList();
      }
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Parameters class for progress
class ContenidoProgressParams {
  final String gestanteId;
  final String contenidoId;
  
  ContenidoProgressParams({
    required this.gestanteId,
    required this.contenidoId,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContenidoProgressParams &&
        other.gestanteId == gestanteId &&
        other.contenidoId == contenidoId;
  }
  
  @override
  int get hashCode => gestanteId.hashCode ^ contenidoId.hashCode;
}

// Filter class
class ContenidoFilter {
  final CategoriaContenido? categoria;
  final TipoContenido? tipo;
  final NivelDificultad? dificultad;
  final int? duracionMaxima;
  final bool soloFavoritos;
  final bool soloDescargados;
  
  ContenidoFilter({
    this.categoria,
    this.tipo,
    this.dificultad,
    this.duracionMaxima,
    this.soloFavoritos = false,
    this.soloDescargados = false,
  });
  
  ContenidoFilter copyWith({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? dificultad,
    int? duracionMaxima,
    bool? soloFavoritos,
    bool? soloDescargados,
  }) {
    return ContenidoFilter(
      categoria: categoria ?? this.categoria,
      tipo: tipo ?? this.tipo,
      dificultad: dificultad ?? this.dificultad,
      duracionMaxima: duracionMaxima ?? this.duracionMaxima,
      soloFavoritos: soloFavoritos ?? this.soloFavoritos,
      soloDescargados: soloDescargados ?? this.soloDescargados,
    );
  }
}

// State Notifiers
class ContenidosNotifier extends StateNotifier<AsyncValue<List<ContenidoModel>>> {
  final ContenidoService _service;
  
  ContenidosNotifier(this._service) : super(const AsyncValue.loading()) {
    loadContenidos();
  }
  
  Future<void> loadContenidos() async {
    state = const AsyncValue.loading();
    try {
      final contenidos = await _service.obtenerContenidos();
      state = AsyncValue.data(contenidos);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> toggleFavorito(String contenidoId) async {
    try {
      await _service.marcarComoFavorito(contenidoId);
      await loadContenidos(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> downloadContenido(String contenidoId) async {
    try {
      await _service.descargarContenido(contenidoId);
      await loadContenidos(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadContenidos();
  }
}

class ContenidosPorCategoriaNotifier extends StateNotifier<AsyncValue<List<ContenidoModel>>> {
  final ContenidoService _service;
  final CategoriaContenido _categoria;
  
  ContenidosPorCategoriaNotifier(this._service, this._categoria) : super(const AsyncValue.loading()) {
    loadContenidosPorCategoria();
  }
  
  Future<void> loadContenidosPorCategoria() async {
    state = const AsyncValue.loading();
    try {
      final contenidos = await _service.obtenerContenidosPorCategoria(_categoria);
      state = AsyncValue.data(contenidos);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadContenidosPorCategoria();
  }
}

class ContenidosRecomendadosNotifier extends StateNotifier<AsyncValue<List<ContenidoModel>>> {
  final ContenidoService _service;
  final String _gestanteId;
  
  ContenidosRecomendadosNotifier(this._service, this._gestanteId) : super(const AsyncValue.loading()) {
    loadContenidosRecomendados();
  }
  
  Future<void> loadContenidosRecomendados() async {
    state = const AsyncValue.loading();
    try {
      final contenidos = await _service.obtenerContenidosRecomendados(_gestanteId);
      state = AsyncValue.data(contenidos);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadContenidosRecomendados();
  }
}

class ContenidoDetailNotifier extends StateNotifier<AsyncValue<ContenidoModel?>> {
  final ContenidoService _service;
  final String _contenidoId;
  
  ContenidoDetailNotifier(this._service, this._contenidoId) : super(const AsyncValue.loading()) {
    loadContenido();
  }
  
  Future<void> loadContenido() async {
    state = const AsyncValue.loading();
    try {
      final contenido = await _service.obtenerContenidoPorId(_contenidoId);
      state = AsyncValue.data(contenido);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> marcarComoVisto(String gestanteId) async {
    try {
      await _service.marcarComoVisto(_contenidoId, gestanteId);
      await loadContenido(); // Reload to get updated view count
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadContenido();
  }
}

class ProgresoContenidoNotifier extends StateNotifier<AsyncValue<ProgresoContenidoModel?>> {
  final ContenidoService _service;
  final ContenidoProgressParams _params;
  
  ProgresoContenidoNotifier(this._service, this._params) : super(const AsyncValue.loading()) {
    loadProgreso();
  }
  
  Future<void> loadProgreso() async {
    state = const AsyncValue.loading();
    try {
      final progreso = await _service.obtenerProgresoContenido(_params.gestanteId, _params.contenidoId);
      state = AsyncValue.data(progreso);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> actualizarProgreso(double porcentaje, int tiempoVisto) async {
    try {
      await _service.actualizarProgresoContenido(
        _params.gestanteId,
        _params.contenidoId,
        porcentaje,
        tiempoVisto,
      );
      await loadProgreso(); // Reload to get updated progress
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadProgreso();
  }
}