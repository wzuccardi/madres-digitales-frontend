import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gestante_model.dart';
import '../services/alerta_service.dart';

// Service provider
final alertaServiceProvider = Provider<AlertaService>((ref) {
  return AlertaService();
});

// State providers for alerts
final alertasProvider = StateNotifierProvider<AlertasNotifier, AsyncValue<List<AlertaModel>>>((ref) {
  return AlertasNotifier(ref.read(alertaServiceProvider));
});

final alertasCriticasProvider = StateNotifierProvider<AlertasCriticasNotifier, AsyncValue<List<AlertaModel>>>((ref) {
  return AlertasCriticasNotifier(ref.read(alertaServiceProvider));
});

final alertasResueltasProvider = StateNotifierProvider<AlertasResueltasNotifier, AsyncValue<List<AlertaModel>>>((ref) {
  return AlertasResueltasNotifier(ref.read(alertaServiceProvider));
});

final alertaDetailProvider = StateNotifierProvider.family<AlertaDetailNotifier, AsyncValue<AlertaModel?>, String>((ref, alertaId) {
  return AlertaDetailNotifier(ref.read(alertaServiceProvider), alertaId);
});

final alertasPorGestanteProvider = StateNotifierProvider.family<AlertasPorGestanteNotifier, AsyncValue<List<AlertaModel>>, String>((ref, gestanteId) {
  return AlertasPorGestanteNotifier(ref.read(alertaServiceProvider), gestanteId);
});

// Filter providers
final alertaFilterProvider = StateProvider<AlertaFilter>((ref) => AlertaFilter());

final alertaSearchProvider = StateProvider<String>((ref) => '');

final filteredAlertasProvider = Provider<AsyncValue<List<AlertaModel>>>((ref) {
  final alertas = ref.watch(alertasProvider);
  final searchQuery = ref.watch(alertaSearchProvider);
  final filter = ref.watch(alertaFilterProvider);
  
  return alertas.when(
    data: (alertasList) {
      var filtered = alertasList.asMap().entries.map((entry) => entry.value).toList();
      
      // Apply search filter
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((alerta) {
          return alerta.titulo.toLowerCase().contains(searchQuery.toLowerCase()) ||
                 alerta.descripcion.toLowerCase().contains(searchQuery.toLowerCase()) ||
                 alerta.gestanteId.contains(searchQuery);
        }).toList();
      }
      
      // Apply type filter
      if (filter.tipo != null) {
        filtered = filtered.where((alerta) => alerta.tipo == filter.tipo).toList();
      }
      
      // Apply priority filter
      if (filter.prioridad != null) {
        filtered = filtered.where((alerta) => alerta.prioridad == filter.prioridad).toList();
      }
      
      // Apply date range filter
      if (filter.fechaInicio != null) {
        filtered = filtered.where((alerta) => 
          alerta.fechaCreacion.isAfter(filter.fechaInicio!) ||
          alerta.fechaCreacion.isAtSameMomentAs(filter.fechaInicio!)
        ).toList();
      }
      
      if (filter.fechaFin != null) {
        filtered = filtered.where((alerta) => 
          alerta.fechaCreacion.isBefore(filter.fechaFin!) ||
          alerta.fechaCreacion.isAtSameMomentAs(filter.fechaFin!)
        ).toList();
      }
      
      // Apply status filter
      if (filter.soloActivas) {
        filtered = filtered.where((alerta) => alerta.fechaResolucion == null).toList();
      }
      
      if (filter.soloResueltas) {
        filtered = filtered.where((alerta) => alerta.fechaResolucion != null).toList();
      }
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Statistics provider
final alertaStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.read(alertaServiceProvider);
  return await service.obtenerEstadisticas();
});

// Real-time monitoring provider
final alertaMonitoringProvider = StreamProvider<List<AlertaModel>>((ref) {
  final service = ref.read(alertaServiceProvider);
  return service.monitorearAlertas();
});

// Filter class
class AlertaFilter {
  final TipoAlerta? tipo;
  final NivelPrioridad? prioridad;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final bool soloActivas;
  final bool soloResueltas;
  
  AlertaFilter({
    this.tipo,
    this.prioridad,
    this.fechaInicio,
    this.fechaFin,
    this.soloActivas = false,
    this.soloResueltas = false,
  });
  
  AlertaFilter copyWith({
    TipoAlerta? tipo,
    NivelPrioridad? prioridad,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? soloActivas,
    bool? soloResueltas,
  }) {
    return AlertaFilter(
      tipo: tipo ?? this.tipo,
      prioridad: prioridad ?? this.prioridad,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      soloActivas: soloActivas ?? this.soloActivas,
      soloResueltas: soloResueltas ?? this.soloResueltas,
    );
  }
}

// State Notifiers
class AlertasNotifier extends StateNotifier<AsyncValue<List<AlertaModel>>> {
  final AlertaService _service;
  
  AlertasNotifier(this._service) : super(const AsyncValue.loading()) {
    loadAlertas();
  }
  
  Future<void> loadAlertas() async {
    state = const AsyncValue.loading();
    try {
      final alertas = await _service.obtenerAlertas();
      state = AsyncValue.data(alertas);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> addAlerta(AlertaModel alerta) async {
    try {
      await _service.crearAlerta(alerta);
      await loadAlertas(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> updateAlerta(AlertaModel alerta) async {
    try {
      await _service.actualizarAlerta(alerta);
      await loadAlertas(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> resolveAlerta(String alertaId, String observaciones) async {
    try {
      await _service.resolverAlerta(alertaId, observaciones);
      await loadAlertas(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> deleteAlerta(String alertaId) async {
    try {
      await _service.eliminarAlerta(alertaId);
      await loadAlertas(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadAlertas();
  }
}

class AlertasCriticasNotifier extends StateNotifier<AsyncValue<List<AlertaModel>>> {
  final AlertaService _service;
  
  AlertasCriticasNotifier(this._service) : super(const AsyncValue.loading()) {
    loadAlertasCriticas();
  }
  
  Future<void> loadAlertasCriticas() async {
    state = const AsyncValue.loading();
    try {
      final alertas = await _service.obtenerAlertasCriticas();
      state = AsyncValue.data(alertas);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadAlertasCriticas();
  }
}

class AlertasResueltasNotifier extends StateNotifier<AsyncValue<List<AlertaModel>>> {
  final AlertaService _service;
  
  AlertasResueltasNotifier(this._service) : super(const AsyncValue.loading()) {
    loadAlertasResueltas();
  }
  
  Future<void> loadAlertasResueltas() async {
    state = const AsyncValue.loading();
    try {
      final alertas = await _service.obtenerAlertas();
      final resueltas = alertas.where((alerta) => alerta.fechaResolucion != null).toList();
      state = AsyncValue.data(resueltas);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadAlertasResueltas();
  }
}

class AlertaDetailNotifier extends StateNotifier<AsyncValue<AlertaModel?>> {
  final AlertaService _service;
  final String _alertaId;
  
  AlertaDetailNotifier(this._service, this._alertaId) : super(const AsyncValue.loading()) {
    loadAlerta();
  }
  
  Future<void> loadAlerta() async {
    state = const AsyncValue.loading();
    try {
      final alerta = await _service.obtenerAlertaPorId(_alertaId);
      state = AsyncValue.data(alerta);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadAlerta();
  }
}

class AlertasPorGestanteNotifier extends StateNotifier<AsyncValue<List<AlertaModel>>> {
  final AlertaService _service;
  final String _gestanteId;
  
  AlertasPorGestanteNotifier(this._service, this._gestanteId) : super(const AsyncValue.loading()) {
    loadAlertasPorGestante();
  }
  
  Future<void> loadAlertasPorGestante() async {
    state = const AsyncValue.loading();
    try {
      final alertas = await _service.obtenerAlertasPorGestante(_gestanteId);
      state = AsyncValue.data(alertas);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadAlertasPorGestante();
  }
}