import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gestante_model.dart';
import '../services/gestante_service.dart';

// Service provider
final gestanteServiceProvider = Provider<GestanteService>((ref) {
  return GestanteService();
});

// State providers for gestantes
final gestantesProvider = StateNotifierProvider<GestantesNotifier, AsyncValue<List<GestanteModel>>>((ref) {
  return GestantesNotifier(ref.read(gestanteServiceProvider));
});

final gestantesAltoRiesgoProvider = StateNotifierProvider<GestantesAltoRiesgoNotifier, AsyncValue<List<GestanteModel>>>((ref) {
  return GestantesAltoRiesgoNotifier(ref.read(gestanteServiceProvider));
});

final gestantesCercanasProvider = StateNotifierProvider<GestantesCercanasNotifier, AsyncValue<List<GestanteModel>>>((ref) {
  return GestantesCercanasNotifier(ref.read(gestanteServiceProvider));
});

final gestanteDetailProvider = StateNotifierProvider.family<GestanteDetailNotifier, AsyncValue<GestanteModel?>, String>((ref, gestanteId) {
  return GestanteDetailNotifier(ref.read(gestanteServiceProvider), gestanteId);
});

// Search provider
final gestanteSearchProvider = StateProvider<String>((ref) => '');

final filteredGestantesProvider = Provider<AsyncValue<List<GestanteModel>>>((ref) {
  final gestantes = ref.watch(gestantesProvider);
  final searchQuery = ref.watch(gestanteSearchProvider);
  
  return gestantes.when(
    data: (gestantesList) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(gestantesList);
      }
      
      final filtered = gestantesList.where((gestante) {
        return gestante.nombres.toLowerCase().contains(searchQuery.toLowerCase()) ||
               gestante.apellidos.toLowerCase().contains(searchQuery.toLowerCase()) ||
               gestante.numeroDocumento.contains(searchQuery);
      }).toList();
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Statistics provider
final gestanteStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.read(gestanteServiceProvider);
  return await service.obtenerEstadisticas();
});

// State Notifiers
class GestantesNotifier extends StateNotifier<AsyncValue<List<GestanteModel>>> {
  final GestanteService _service;
  
  GestantesNotifier(this._service) : super(const AsyncValue.loading()) {
    loadGestantes();
  }
  
  Future<void> loadGestantes() async {
    state = const AsyncValue.loading();
    try {
      final gestantes = await _service.obtenerGestantes();
      state = AsyncValue.data(gestantes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> addGestante(GestanteModel gestante) async {
    try {
      await _service.crearGestante(gestante);
      await loadGestantes(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> updateGestante(GestanteModel gestante) async {
    try {
      await _service.actualizarGestante(gestante);
      await loadGestantes(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> deleteGestante(String gestanteId) async {
    try {
      await _service.eliminarGestante(gestanteId);
      await loadGestantes(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadGestantes();
  }
}

class GestantesAltoRiesgoNotifier extends StateNotifier<AsyncValue<List<GestanteModel>>> {
  final GestanteService _service;
  
  GestantesAltoRiesgoNotifier(this._service) : super(const AsyncValue.loading()) {
    loadGestantesAltoRiesgo();
  }
  
  Future<void> loadGestantesAltoRiesgo() async {
    state = const AsyncValue.loading();
    try {
      final gestantes = await _service.obtenerGestantesAltoRiesgo();
      state = AsyncValue.data(gestantes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadGestantesAltoRiesgo();
  }
}

class GestantesCercanasNotifier extends StateNotifier<AsyncValue<List<GestanteModel>>> {
  final GestanteService _service;
  
  GestantesCercanasNotifier(this._service) : super(const AsyncValue.loading()) {
    loadGestantesCercanas();
  }
  
  Future<void> loadGestantesCercanas() async {
    state = const AsyncValue.loading();
    try {
      // Using a default location for now - in real app, get from location service
      final gestantes = await _service.buscarPorUbicacion(4.6097, -74.0817, 10.0);
      state = AsyncValue.data(gestantes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadGestantesCercanas();
  }
}

class GestanteDetailNotifier extends StateNotifier<AsyncValue<GestanteModel?>> {
  final GestanteService _service;
  final String _gestanteId;
  
  GestanteDetailNotifier(this._service, this._gestanteId) : super(const AsyncValue.loading()) {
    loadGestante();
  }
  
  Future<void> loadGestante() async {
    state = const AsyncValue.loading();
    try {
      final gestante = await _service.obtenerGestantePorId(_gestanteId);
      state = AsyncValue.data(gestante);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadGestante();
  }
}