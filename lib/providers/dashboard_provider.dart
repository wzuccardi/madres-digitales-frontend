import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

// Service provider
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

// Statistics providers
final estadisticasGeneralesProvider = StateNotifierProvider<EstadisticasGeneralesNotifier, AsyncValue<EstadisticasGeneralesModel?>>((ref) {
  return EstadisticasGeneralesNotifier(ref.read(dashboardServiceProvider));
});

final estadisticasPorPeriodoProvider = StateNotifierProvider.family<EstadisticasPorPeriodoNotifier, AsyncValue<List<EstadisticasPorPeriodoModel>>, DateRange>((ref, dateRange) {
  return EstadisticasPorPeriodoNotifier(ref.read(dashboardServiceProvider), dateRange);
});

final estadisticasGeograficasProvider = StateNotifierProvider<EstadisticasGeograficasNotifier, AsyncValue<List<EstadisticasGeograficasModel>>>((ref) {
  return EstadisticasGeograficasNotifier(ref.read(dashboardServiceProvider));
});

// Reports providers
final reportesProvider = StateNotifierProvider<ReportesNotifier, AsyncValue<List<ReporteModel>>>((ref) {
  return ReportesNotifier(ref.read(dashboardServiceProvider));
});

final reporteDetailProvider = StateNotifierProvider.family<ReporteDetailNotifier, AsyncValue<ReporteModel?>, String>((ref, reporteId) {
  return ReporteDetailNotifier(ref.read(dashboardServiceProvider), reporteId);
});

// Filter providers
final dashboardFilterProvider = StateProvider<DashboardFilter>((ref) => DashboardFilter());

final filteredEstadisticasProvider = Provider<AsyncValue<EstadisticasGeneralesModel?>>((ref) {
  final estadisticas = ref.watch(estadisticasGeneralesProvider);
  final filter = ref.watch(dashboardFilterProvider);
  
  return estadisticas.when(
    data: (stats) {
      if (stats == null) return const AsyncValue.data(null);
      
      // Apply filters to statistics if needed
      // For now, return as is, but you can implement filtering logic here
      return AsyncValue.data(stats);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Date range class
class DateRange {
  final DateTime inicio;
  final DateTime fin;
  
  DateRange({
    required this.inicio,
    required this.fin,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange &&
        other.inicio == inicio &&
        other.fin == fin;
  }
  
  @override
  int get hashCode => inicio.hashCode ^ fin.hashCode;
}

// Filter class
class DashboardFilter {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String? region;
  final String? ips;
  final bool soloAltoRiesgo;
  
  DashboardFilter({
    this.fechaInicio,
    this.fechaFin,
    this.region,
    this.ips,
    this.soloAltoRiesgo = false,
  });
  
  DashboardFilter copyWith({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? region,
    String? ips,
    bool? soloAltoRiesgo,
  }) {
    return DashboardFilter(
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      region: region ?? this.region,
      ips: ips ?? this.ips,
      soloAltoRiesgo: soloAltoRiesgo ?? this.soloAltoRiesgo,
    );
  }
}

// State Notifiers
class EstadisticasGeneralesNotifier extends StateNotifier<AsyncValue<EstadisticasGeneralesModel?>> {
  final DashboardService _service;
  
  EstadisticasGeneralesNotifier(this._service) : super(const AsyncValue.loading()) {
    loadEstadisticasGenerales();
  }
  
  Future<void> loadEstadisticasGenerales() async {
    state = const AsyncValue.loading();
    try {
      final estadisticas = await _service.obtenerEstadisticasGenerales();
      state = AsyncValue.data(estadisticas);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadEstadisticasGenerales();
  }
}

class EstadisticasPorPeriodoNotifier extends StateNotifier<AsyncValue<List<EstadisticasPorPeriodoModel>>> {
  final DashboardService _service;
  final DateRange _dateRange;
  
  EstadisticasPorPeriodoNotifier(this._service, this._dateRange) : super(const AsyncValue.loading()) {
    loadEstadisticasPorPeriodo();
  }
  
  Future<void> loadEstadisticasPorPeriodo() async {
    state = const AsyncValue.loading();
    try {
      final estadisticas = await _service.obtenerEstadisticasPorPeriodo(
        _dateRange.inicio,
        _dateRange.fin,
      );
      state = AsyncValue.data(estadisticas);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadEstadisticasPorPeriodo();
  }
}

class EstadisticasGeograficasNotifier extends StateNotifier<AsyncValue<List<EstadisticasGeograficasModel>>> {
  final DashboardService _service;
  
  EstadisticasGeograficasNotifier(this._service) : super(const AsyncValue.loading()) {
    loadEstadisticasGeograficas();
  }
  
  Future<void> loadEstadisticasGeograficas() async {
    state = const AsyncValue.loading();
    try {
      final estadisticas = await _service.obtenerEstadisticasGeograficas();
      state = AsyncValue.data(estadisticas);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadEstadisticasGeograficas();
  }
}

class ReportesNotifier extends StateNotifier<AsyncValue<List<ReporteModel>>> {
  final DashboardService _service;
  
  ReportesNotifier(this._service) : super(const AsyncValue.loading()) {
    loadReportes();
  }
  
  Future<void> loadReportes() async {
    state = const AsyncValue.loading();
    try {
      final reportes = await _service.obtenerReportes();
      state = AsyncValue.data(reportes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> generateReporte(TipoReporte tipo, Map<String, dynamic> parametros) async {
    try {
      await _service.generarReporte(tipo, parametros);
      await loadReportes(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> deleteReporte(String reporteId) async {
    try {
      await _service.eliminarReporte(reporteId);
      await loadReportes(); // Reload the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadReportes();
  }
}

class ReporteDetailNotifier extends StateNotifier<AsyncValue<ReporteModel?>> {
  final DashboardService _service;
  final String _reporteId;
  
  ReporteDetailNotifier(this._service, this._reporteId) : super(const AsyncValue.loading()) {
    loadReporte();
  }
  
  Future<void> loadReporte() async {
    state = const AsyncValue.loading();
    try {
      final reporte = await _service.obtenerReportePorId(_reporteId);
      state = AsyncValue.data(reporte);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> downloadReporte() async {
    try {
      final reporte = state.value;
      if (reporte != null) {
        await _service.descargarReporte(_reporteId);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void refresh() {
    loadReporte();
  }
}