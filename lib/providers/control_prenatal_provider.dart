import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gestante_model.dart';
import '../services/control_prenatal_service.dart';

// Service provider
final controlPrenatalServiceProvider = Provider<ControlPrenatalService>((ref) {
  return ControlPrenatalService();
});

// State providers for controls
final controlesProvider = StateNotifierProvider<ControlesNotifier, AsyncValue<List<ControlPrenatalModel>>>((ref) {
  return ControlesNotifier(ref.read(controlPrenatalServiceProvider));
});

final controlesVencidosProvider = StateNotifierProvider<ControlesVencidosNotifier, AsyncValue<List<ControlPrenatalModel>>>((ref) {
  return ControlesVencidosNotifier(ref.read(controlPrenatalServiceProvider));
});

final controlesPendientesProvider = StateNotifierProvider<ControlesPendientesNotifier, AsyncValue<List<ControlPrenatalModel>>>((ref) {
  return ControlesPendientesNotifier(ref.read(controlPrenatalServiceProvider));
});

final controlDetailProvider = StateNotifierProvider.family<ControlDetailNotifier, AsyncValue<ControlPrenatalModel?>, String>((ref, controlId) {
  return ControlDetailNotifier(ref.read(controlPrenatalServiceProvider), controlId);
});

final controlesPorGestanteProvider = StateNotifierProvider.family<ControlesPorGestanteNotifier, AsyncValue<List<ControlPrenatalModel>>, String>((ref, gestanteId) {
  return ControlesPorGestanteNotifier(ref.read(controlPrenatalServiceProvider), gestanteId);
});

// Search and filter providers
final controlSearchProvider = StateProvider<String>((ref) => '');

final filteredControlesProvider = Provider<AsyncValue<List<ControlPrenatalModel>>>((ref) {
  final controles = ref.watch(controlesProvider);
  final searchQuery = ref.watch(controlSearchProvider);
  
  return controles.when(
    data: (controlesList) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(controlesList);
      }
      
      final filtered = controlesList.where((control) {
        return control.gestanteId.contains(searchQuery) ||
               control.observaciones?.toLowerCase().contains(searchQuery.toLowerCase()) == true;
      }).toList();
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Statistics provider
final controlStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.read(controlPrenatalServiceProvider);
  return await service.obtenerEstadisticas();
});

// State Notifiers
class ControlesNotifier extends StateNotifier<AsyncValue<List<ControlPrenatalModel>>> {
  final ControlPrenatalService _service;
  
  ControlesNotifier(this._service) : super(const AsyncValue.loading()) {
    loadControles();
  }
  
  Future<void> loadControles() async {
    state = const AsyncValue.loading();
    try {
      final controles = await _service.obtenerControles();
      state = AsyncValue.data(controles);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> addControl(ControlPrenatalModel control) async {
    try {
      await _service.crearControl(control);
      await loadControles(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> updateControl(ControlPrenatalModel control) async {
    try {
      await _service.actualizarControl(control);
      await loadControles(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> deleteControl(String controlId) async {
    try {
      await _service.eliminarControl(controlId);
      await loadControles(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadControles();
  }
}

class ControlesVencidosNotifier extends StateNotifier<AsyncValue<List<ControlPrenatalModel>>> {
  final ControlPrenatalService _service;
  
  ControlesVencidosNotifier(this._service) : super(const AsyncValue.loading()) {
    loadControlesVencidos();
  }
  
  Future<void> loadControlesVencidos() async {
    state = const AsyncValue.loading();
    try {
      final controles = await _service.verificarControlesVencidos();
      state = AsyncValue.data(controles);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadControlesVencidos();
  }
}

class ControlesPendientesNotifier extends StateNotifier<AsyncValue<List<ControlPrenatalModel>>> {
  final ControlPrenatalService _service;
  
  ControlesPendientesNotifier(this._service) : super(const AsyncValue.loading()) {
    loadControlesPendientes();
  }
  
  Future<void> loadControlesPendientes() async {
    state = const AsyncValue.loading();
    try {
      final controles = await _service.obtenerControles();
      // Filter for pending controls (you might want to add a status field to the model)
      final pendientes = controles.where((control) => 
        control.fechaProximoControl != null && 
        control.fechaProximoControl!.isAfter(DateTime.now())
      ).toList();
      state = AsyncValue.data(pendientes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadControlesPendientes();
  }
}

class ControlDetailNotifier extends StateNotifier<AsyncValue<ControlPrenatalModel?>> {
  final ControlPrenatalService _service;
  final String _controlId;
  
  ControlDetailNotifier(this._service, this._controlId) : super(const AsyncValue.loading()) {
    loadControl();
  }
  
  Future<void> loadControl() async {
    state = const AsyncValue.loading();
    try {
      final control = await _service.obtenerControlPorId(_controlId);
      state = AsyncValue.data(control);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadControl();
  }
}

class ControlesPorGestanteNotifier extends StateNotifier<AsyncValue<List<ControlPrenatalModel>>> {
  final ControlPrenatalService _service;
  final String _gestanteId;
  
  ControlesPorGestanteNotifier(this._service, this._gestanteId) : super(const AsyncValue.loading()) {
    loadControlesPorGestante();
  }
  
  Future<void> loadControlesPorGestante() async {
    state = const AsyncValue.loading();
    try {
      final controles = await _service.obtenerControlesPorGestante(_gestanteId);
      state = AsyncValue.data(controles);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadControlesPorGestante();
  }
}