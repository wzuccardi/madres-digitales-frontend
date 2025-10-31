import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/models/dashboard_models.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';
import 'package:madres_digitales_flutter_new/providers/service_providers.dart';

/// Provider para estadÃ­sticas generales del dashboard
final estadisticasGeneralesProvider = FutureProvider<DashboardStats>((ref) async {
  appLogger.debug('DashboardProvider: Obteniendo estadÃ­sticas generales');
  
  try {
    // Esperar a que el servicio estÃ© disponible
    final dashboardService = await ref.read(dashboardServiceProvider.future);
    
    final estadisticas = await dashboardService.obtenerEstadisticasGenerales();
    
    
    appLogger.debug('DashboardProvider: EstadÃ­sticas generales obtenidas exitosamente');
    return estadisticas;
  } catch (e) {
    appLogger.error('DashboardProvider: Error obteniendo estadÃ­sticas generales', error: e);
    
    // Retornar estadÃ­sticas vacÃ­as en caso de error
    return DashboardStats.empty();
  }
});

/// Provider para estadÃ­sticas por municipio
final estadisticasMunicipioProvider = FutureProvider.family<DashboardStats, String>((ref, municipioId) async {
  appLogger.debug('DashboardProvider: Obteniendo estadÃ­sticas del municipio: $municipioId');
  
  try {
    // Esperar a que el servicio estÃ© disponible
    final dashboardService = await ref.read(dashboardServiceProvider.future);
    final estadisticas = await dashboardService.obtenerEstadisticasPorMunicipio(municipioId);
    
    appLogger.debug('DashboardProvider: EstadÃ­sticas de municipio obtenidas exitosamente');
    return estadisticas;
  } catch (e) {
    appLogger.error('DashboardProvider: Error obteniendo estadÃ­sticas de municipio', error: e);
    
    // Retornar estadÃ­sticas vacÃ­as en caso de error
    return DashboardStats.empty();
  }
});

/// Provider para estadÃ­sticas por perÃ­odo
final estadisticasPeriodoProvider = FutureProvider.family<DashboardStats, Map<String, dynamic>>((ref, params) async {
  final startDate = params['startDate'] as DateTime;
  final endDate = params['endDate'] as DateTime;
  final municipioId = params['municipioId'] as String?;
  
  appLogger.debug('DashboardProvider: Obteniendo estadÃ­sticas por perÃ­odo');
  appLogger.debug('DashboardProvider: PerÃ­odo: ${startDate.toIso8601String()} - ${endDate.toIso8601String()}');
  if (municipioId != null) {
    appLogger.debug('DashboardProvider: Municipio: $municipioId');
  }
  
  try {
    // Esperar a que el servicio estÃ© disponible
    final dashboardService = await ref.read(dashboardServiceProvider.future);
    final estadisticas = await dashboardService.obtenerEstadisticasPorPeriodo(
      startDate: startDate,
      endDate: endDate,
      municipioId: municipioId,
    );
    
    appLogger.debug('DashboardProvider: EstadÃ­sticas de perÃ­odo obtenidas exitosamente');
    return estadisticas;
  } catch (e) {
    appLogger.error('DashboardProvider: Error obteniendo estadÃ­sticas de perÃ­odo', error: e);
    
    // Retornar estadÃ­sticas vacÃ­as en caso de error
    return DashboardStats.empty();
  }
});

/// Provider para el estado de conexiÃ³n del dashboard - TEMPORALMENTE DESHABILITADO
// final dashboardConnectionStateProvider = StateNotifierProvider<DashboardConnectionNotifier, DashboardConnectionState>((ref) {
//   return DashboardConnectionNotifier(ref);
// });

/// Notificador para el estado de conexiÃ³n del dashboard
class DashboardConnectionNotifier extends StateNotifier<DashboardConnectionState> {
  final Ref ref;
  
  DashboardConnectionNotifier(this.ref) : super(const DashboardConnectionState()) {
    _verificarConexion();
    // TEMPORALMENTE DESHABILITADO - CAUSABA PROBLEMAS DE setState
    // Stream.periodic(const Duration(seconds: 30), (_) => _verificarConexion());
  }
  
  Future<void> _verificarConexion() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Esperar a que el servicio estÃ© disponible
      final dashboardService = await ref.read(dashboardServiceProvider.future);
      
      // Probar obtener estadÃ­sticas para verificar conexiÃ³n
      await dashboardService.obtenerEstadisticasGenerales();
      
      state = state.copyWith(
        isLoading: false,
        isConnected: true,
        lastChecked: DateTime.now(),
      );
      
      appLogger.debug('DashboardConnectionNotifier: ConexiÃ³n verificada exitosamente');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isConnected: false,
        error: e.toString(),
        lastChecked: DateTime.now(),
      );
      
      appLogger.error('DashboardConnectionNotifier: Error verificando conexiÃ³n', error: e);
    }
  }
  
  /// Forzar verificaciÃ³n de conexiÃ³n
  Future<void> forzarVerificacion() async {
    appLogger.debug('DashboardConnectionNotifier: Forzando verificaciÃ³n de conexiÃ³n');
    await _verificarConexion();
  }
  
  /// Refrescar estadÃ­sticas
  Future<void> refrescarEstadisticas() async {
    appLogger.debug('DashboardConnectionNotifier: Refrescando estadÃ­sticas');
    
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Invalidar providers para forzar recarga
      ref.invalidate(estadisticasGeneralesProvider);
      
      state = state.copyWith(isLoading: false);
      
      appLogger.debug('DashboardConnectionNotifier: EstadÃ­sticas refrescadas exitosamente');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      
      appLogger.error('DashboardConnectionNotifier: Error refrescando estadÃ­sticas', error: e);
    }
  }
  
  /// Limpiar errores
  void limpiarErrores() {
    if (state.error != null) {
      state = state.copyWith(error: null);
      appLogger.debug('DashboardConnectionNotifier: Errores limpiados');
    }
  }
}

/// Estado de conexiÃ³n del dashboard
class DashboardConnectionState {
  final bool isLoading;
  final bool isConnected;
  final String? error;
  final DateTime? lastChecked;
  
  const DashboardConnectionState({
    this.isLoading = false,
    this.isConnected = false,
    this.error,
    this.lastChecked,
  });
  
  DashboardConnectionState copyWith({
    bool? isLoading,
    bool? isConnected,
    String? error,
    DateTime? lastChecked,
  }) {
    return DashboardConnectionState(
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      error: error ?? this.error,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
  
  @override
  String toString() {
    return 'DashboardConnectionState(isLoading: $isLoading, isConnected: $isConnected, error: $error, lastChecked: $lastChecked)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DashboardConnectionState &&
      other.isLoading == isLoading &&
      other.isConnected == isConnected &&
      other.error == error &&
      other.lastChecked == lastChecked;
  }
  
  @override
  int get hashCode {
    return isLoading.hashCode ^
      isConnected.hashCode ^
      error.hashCode ^
      lastChecked.hashCode;
  }
}

/// Provider para refrescar estadÃ­sticas
final estadisticasRefreshProvider = FutureProvider.family<DashboardStats, void>((ref, _) async {
  appLogger.debug('DashboardProvider: Refrescando estadÃ­sticas generales');
  
  try {
    // Esperar a que el servicio estÃ© disponible
    final dashboardService = await ref.read(dashboardServiceProvider.future);
    final estadisticas = await dashboardService.actualizarEstadisticas();
    
    appLogger.debug('DashboardProvider: EstadÃ­sticas refrescadas exitosamente');
    return estadisticas;
  } catch (e) {
    appLogger.error('DashboardProvider: Error refrescando estadÃ­sticas', error: e);
    
    // Retornar estadÃ­sticas vacÃ­as en caso de error
    return DashboardStats.empty();
  }
});

/// Provider para estadÃ­sticas de tendencias
final estadisticasTendenciaProvider = FutureProvider.family<DashboardTrend, String>((ref, metric) async {
  appLogger.debug('DashboardProvider: Obteniendo estadÃ­sticas de tendencia para mÃ©trica: $metric');
  
  try {
    // En una implementaciÃ³n real, aquÃ­ se obtendrÃ­an las tendencias desde el servicio
    // Por ahora, retornamos datos de ejemplo
    final now = DateTime.now();
    final points = <DashboardTrendPoint>[];
    
    // Generar 30 dÃ­as de datos de ejemplo
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final value = _generateRandomValueForMetric(metric);
      
      points.add(DashboardTrendPoint(
        date: date,
        value: value,
      ));
    }
    
    final trend = DashboardTrend(
      metric: metric,
      points: points,
      period: '30d',
      startDate: now.subtract(const Duration(days: 29)),
      endDate: now,
    );
    
    appLogger.debug('DashboardProvider: EstadÃ­sticas de tendencia obtenidas exitosamente');
    return trend;
  } catch (e) {
    appLogger.error('DashboardProvider: Error obteniendo estadÃ­sticas de tendencia', error: e);
    
    // Retornar tendencia vacÃ­a en caso de error
    return DashboardTrend(
      metric: metric,
      points: [],
      period: '30d',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    );
  }
});

/// Provider para estadÃ­sticas de comparaciÃ³n
final estadisticasComparacionProvider = FutureProvider.family<DashboardComparison, String>((ref, metric) async {
  appLogger.debug('DashboardProvider: Obteniendo estadÃ­sticas de comparaciÃ³n para mÃ©trica: $metric');
  
  try {
    // En una implementaciÃ³n real, aquÃ­ se obtendrÃ­an las comparaciones desde el servicio
    // Por ahora, retornamos datos de ejemplo
    final currentValue = _generateRandomValueForMetric(metric);
    final previousValue = _generateRandomValueForMetric(metric);
    final percentageChange = ((currentValue - previousValue) / previousValue) * 100;
    
    final comparison = DashboardComparison(
      metric: metric,
      currentValue: currentValue,
      previousValue: previousValue,
      percentageChange: percentageChange,
      period: '30d',
      isPositive: percentageChange >= 0,
    );
    
    appLogger.debug('DashboardProvider: EstadÃ­sticas de comparaciÃ³n obtenidas exitosamente');
    return comparison;
  } catch (e) {
    appLogger.error('DashboardProvider: Error obteniendo estadÃ­sticas de comparaciÃ³n', error: e);
    
    // Retornar comparaciÃ³n vacÃ­a en caso de error
    return DashboardComparison(
      metric: metric,
      currentValue: 0,
      previousValue: 0,
      percentageChange: 0,
      period: '30d',
      isPositive: true,
    );
  }
});

/// Generar un valor aleatorio para una mÃ©trica especÃ­fica
double _generateRandomValueForMetric(String metric) {
  switch (metric.toLowerCase()) {
    case 'total_gestantes':
      return 1000 + (DateTime.now().millisecond % 500);
    case 'controles_realizados':
      return 2000 + (DateTime.now().millisecond % 1000);
    case 'alertas_activas':
      return 20 + (DateTime.now().millisecond % 30);
    case 'contenidos_vistos':
      return 500 + (DateTime.now().millisecond % 500);
    case 'proximos_controles':
      return 100 + (DateTime.now().millisecond % 100);
    case 'tasa_cumplimiento':
      return 0.7 + (DateTime.now().millisecond % 30) / 100.0;
    default:
      return 100 + (DateTime.now().millisecond % 100);
  }
}

/// Provider para datos de municipios
final municipiosDataProvider = FutureProvider<List<MunicipioData>>((ref) async {
  appLogger.debug('DashboardProvider: Obteniendo datos de municipios');
  
  try {
    // En una implementaciÃ³n real, aquÃ­ se obtendrÃ­an los datos desde el servicio
    // Por ahora, retornamos datos de ejemplo
    final municipios = <MunicipioData>[];
    
    final municipiosNombres = [
      'BogotÃ¡', 'MedellÃ­n', 'Cali', 'Barranquilla', 'Cartagena',
      'CÃºcuta', 'Bucaramanga', 'Pereira', 'IbaguÃ©', 'Manizales'
    ];
    
    for (int i = 0; i < municipiosNombres.length; i++) {
      final stats = DashboardStats(
        totalGestantes: 100 + (i * 50),
        controlesRealizados: 200 + (i * 100),
        alertasActivas: 2 + (i % 5),
        contenidosVistos: 50 + (i * 25),
        proximosControles: 10 + (i * 5),
        tasaCumplimiento: 0.7 + (i * 0.02),
        totalMedicos: 5 + (i * 2),
        totalIps: 3 + (i % 4),
      );
      
      municipios.add(MunicipioData(
        id: 'municipio_$i',
        nombre: municipiosNombres[i],
        stats: stats,
        latitud: 4.0 + (i * 0.5),
        longitud: -74.0 + (i * 0.5),
      ));
    }
    
    appLogger.debug('DashboardProvider: Datos de municipios obtenidos exitosamente');
    return municipios;
  } catch (e) {
    appLogger.error('DashboardProvider: Error obteniendo datos de municipios', error: e);
    
    // Retornar lista vacÃ­a en caso de error
    return [];
  }
});

/// Provider para resumen de alertas
final alertasResumenProvider = FutureProvider<AlertasResumen>((ref) async {
  appLogger.debug('DashboardProvider: Obteniendo resumen de alertas');
  
  try {
    // En una implementaciÃ³n real, aquÃ­ se obtendrÃ­an los datos desde el servicio
    // Por ahora, retornamos datos de ejemplo
    final resumen = AlertasResumen(
      total: 25,
      criticas: 3,
      altas: 7,
      medias: 10,
      bajas: 5,
      porTipo: {
        'Roja': 3,
        'Amarilla': 7,
        'Azul': 15,
      },
    );
    
    appLogger.debug('DashboardProvider: Resumen de alertas obtenido exitosamente');
    return resumen;
  } catch (e) {
    appLogger.error('DashboardProvider: Error obteniendo resumen de alertas', error: e);
    
    // Retornar resumen vacÃ­o en caso de error
    return AlertasResumen(
      total: 0,
      criticas: 0,
      altas: 0,
      medias: 0,
      bajas: 0,
      porTipo: {},
    );
  }
});
