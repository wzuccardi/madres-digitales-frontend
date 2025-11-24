import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:madres_digitales_flutter_new/domain/entities/sos_alert.dart';
import 'package:madres_digitales_flutter_new/domain/entities/sos_statistics.dart';

/// Estado del provider de SOS
class SOSState {

  const SOSState({
    this.alertasActivas = const [],
    this.historialAlertas = const [],
    this.estadisticas,
    this.isLoading = false,
    this.isLoadingHistorial = false,
    this.isLoadingEstadisticas = false,
    this.error,
    this.isRefreshing = false,
    this.alertasSeleccionadas = const {},
    this.alertasExpandidas = const {},
  });
  final List<SOSAlert> alertasActivas;
  final List<SOSAlert> historialAlertas;
  final SOSStatistics? estadisticas;
  final bool isLoading;
  final bool isLoadingHistorial;
  final bool isLoadingEstadisticas;
  final String? error;
  final bool isRefreshing;
  final Map<String, bool> alertasSeleccionadas;
  final Map<String, bool> alertasExpandidas;

  SOSState copyWith({
    List<SOSAlert>? alertasActivas,
    List<SOSAlert>? historialAlertas,
    SOSStatistics? estadisticas,
    bool? isLoading,
    bool? isLoadingHistorial,
    bool? isLoadingEstadisticas,
    String? error,
    bool? isRefreshing,
    Map<String, bool>? alertasSeleccionadas,
    Map<String, bool>? alertasExpandidas,
  }) {
    return SOSState(
      alertasActivas: alertasActivas ?? this.alertasActivas,
      historialAlertas: historialAlertas ?? this.historialAlertas,
      estadisticas: estadisticas ?? this.estadisticas,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistorial: isLoadingHistorial ?? this.isLoadingHistorial,
      isLoadingEstadisticas: isLoadingEstadisticas ?? this.isLoadingEstadisticas,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      alertasSeleccionadas: alertasSeleccionadas ?? this.alertasSeleccionadas,
      alertasExpandidas: alertasExpandidas ?? this.alertasExpandidas,
    );
  }

  SOSState loading() {
    return copyWith(isLoading: true);
  }

  SOSState loadingHistorial() {
    return copyWith(isLoadingHistorial: true);
  }

  SOSState loadingEstadisticas() {
    return copyWith(isLoadingEstadisticas: true);
  }

  SOSState refreshing() {
    return copyWith(isRefreshing: true);
  }

  SOSState withError(String mensaje) {
    return copyWith(error: mensaje);
  }

  SOSState alertasActualizadas(List<SOSAlert> nuevasAlertas) {
    final alertasMap = { for (final a in alertasActivas) a.id: a };
    for (final alerta in nuevasAlertas) {
      alertasMap[alerta.id] = alerta;
    }
    return copyWith(
      alertasActivas: alertasMap.values.toList(),
      isRefreshing: false,
    );
  }

  SOSState estadisticasActualizadas(SOSStatistics nuevasEstadisticas) {
    return copyWith(
      estadisticas: nuevasEstadisticas,
      isLoadingEstadisticas: false,
    );
  }

  SOSState alertaSeleccionada(String alertaId, bool seleccionada) {
    final seleccionadas = Map<String, bool>.from(alertasSeleccionadas);
    seleccionadas[alertaId] = seleccionada;
    return copyWith(alertasSeleccionadas: seleccionadas);
  }

  SOSState alertaExpandida(String alertaId, bool expandida) {
    final expandidas = Map<String, bool>.from(alertasExpandidas);
    expandidas[alertaId] = expandida;
    return copyWith(alertasExpandidas: expandidas);
  }
}

/// Provider para gestión de alertas SOS
class SOSNotifier extends StateNotifier<SOSState> {
  SOSNotifier() : super(const SOSState());

  void setAlertasActivas(List<SOSAlert> alertas) {
    state = state.copyWith(alertasActivas: alertas, isLoading: false, isRefreshing: false);
  }

  void setEstadisticas(SOSStatistics estadisticas) {
    state = state.estadisticasActualizadas(estadisticas);
  }

  void seleccionarAlerta(String alertaId, bool seleccionada) {
    final seleccionadas = Map<String, bool>.from(state.alertasSeleccionadas);
    seleccionadas[alertaId] = seleccionada;
    state = state.copyWith(alertasSeleccionadas: seleccionadas);
  }

  void expandirAlerta(String alertaId) {
    final expandidas = Map<String, bool>.from(state.alertasExpandidas);
    final current = expandidas[alertaId] ?? false;
    expandidas[alertaId] = !current;
    state = state.copyWith(alertasExpandidas: expandidas);
  }
}

/// Provider para el provider de SOS completo
final sosProvider = StateNotifierProvider<SOSNotifier, SOSState>((ref) => SOSNotifier());
