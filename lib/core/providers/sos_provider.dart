import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/domain/entities/sos_alert.dart';
import 'package:madres_digitales_flutter_new/domain/entities/sos_statistics.dart';

// Estado del SOS provider
class SOSState {

  const SOSState({
    this.alertasActivas,
    this.historialAlertas,
    this.estadisticas,
    this.isLoading = false,
    this.isLoadingHistorial = false,
    this.isLoadingEstadisticas = false,
    this.isRefreshing = false,
    this.error,
    this.alertasSeleccionadas = const [],
    this.alertasExpandidas = const [],
  });
  final List<SOSAlert>? alertasActivas;
  final List<SOSAlert>? historialAlertas;
  final SOSStatistics? estadisticas;
  final bool isLoading;
  final bool isLoadingHistorial;
  final bool isLoadingEstadisticas;
  final bool isRefreshing;
  final String? error;
  final List<SOSAlert> alertasSeleccionadas;
  final List<SOSAlert> alertasExpandidas;

  SOSState copyWith({
    List<SOSAlert>? alertasActivas,
    List<SOSAlert>? historialAlertas,
    SOSStatistics? estadisticas,
    bool? isLoading,
    bool? isLoadingHistorial,
    bool? isLoadingEstadisticas,
    bool? isRefreshing,
    String? error,
    List<SOSAlert>? alertasSeleccionadas,
    List<SOSAlert>? alertasExpandidas,
  }) {
    return SOSState(
      alertasActivas: alertasActivas ?? this.alertasActivas,
      historialAlertas: historialAlertas ?? this.historialAlertas,
      estadisticas: estadisticas ?? this.estadisticas,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistorial: isLoadingHistorial ?? this.isLoadingHistorial,
      isLoadingEstadisticas: isLoadingEstadisticas ?? this.isLoadingEstadisticas,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error ?? this.error,
      alertasSeleccionadas: alertasSeleccionadas ?? this.alertasSeleccionadas,
      alertasExpandidas: alertasExpandidas ?? this.alertasExpandidas,
    );
  }
}

// Notifier para gestión de alertas SOS
class SOSNotifier extends StateNotifier<SOSState> {
  SOSNotifier() : super(const SOSState());

  // Refrescar alertas activas
  Future<void> refrescarAlertasActivas() async {
    state = state.copyWith(isRefreshing: true);
    
    try {
      // Simulación de refresco
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(
        isRefreshing: false,
        alertasActivas: state.alertasActivas,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  // Actualizar alertas activas
  void actualizarAlertasActivas(List<SOSAlert> alertas) {
    state = state.copyWith(alertasActivas: alertas);
  }

  // Actualizar estadísticas
  void actualizarEstadisticas(SOSStatistics estadisticas) {
    state = state.copyWith(estadisticas: estadisticas);
  }

  // Actualizar alerta seleccionada
  void actualizarAlertaSeleccionada(SOSAlert alerta) {
    final seleccionadas = [...state.alertasSeleccionadas];
    final index = seleccionadas.indexWhere((a) => a.id == alerta.id);
    
    if (index >= 0) {
      seleccionadas[index] = alerta;
    } else {
      seleccionadas.add(alerta);
    }
    
    state = state.copyWith(alertasSeleccionadas: seleccionadas);
  }

  // Limpiar errores
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final sosProvider = StateNotifierProvider<SOSNotifier, SOSState>((ref) {
  return SOSNotifier();
});

final activeSOSAlertsProvider = Provider<List<SOSAlert>?>((ref) {
  return ref.watch(sosProvider).alertasActivas;
});

final sosStatisticsProvider = Provider<SOSStatistics?>((ref) {
  return ref.watch(sosProvider).estadisticas;
});