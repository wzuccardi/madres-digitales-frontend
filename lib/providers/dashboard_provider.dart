import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/models/dashboard_models.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';
import 'package:madres_digitales_flutter_new/providers/service_providers.dart';

/// Provider para estadísticas generales del dashboard
final estadisticasGeneralesProvider = FutureProvider<DashboardStats>((ref) async {
  print('📊 DashboardProvider: ========== OBTENIENDO ESTADÍSTICAS GENERALES ==========');
  appLogger.debug('DashboardProvider: Obteniendo estadísticas generales');
  
  try {
    print('📊 DashboardProvider: Esperando servicio de dashboard...');
    // Esperar a que el servicio esté disponible
    final dashboardService = await ref.read(dashboardServiceProvider.future);
    print('📊 DashboardProvider: ✅ Servicio de dashboard obtenido');
    
    print('📊 DashboardProvider: Solicitando estadísticas al servicio...');
    final estadisticas = await dashboardService.obtenerEstadisticasGenerales();
    
    print('📊 DashboardProvider: ✅ Estadísticas obtenidas exitosamente:');
    print('   - Total gestantes: ${estadisticas.totalGestantes}');
    print('   - Controles realizados: ${estadisticas.controlesRealizados}');
    print('   - Alertas activas: ${estadisticas.alertasActivas}');
    print('   - Total médicos: ${estadisticas.totalMedicos}');
    print('   - Total IPS: ${estadisticas.totalIps}');
    
    appLogger.debug('DashboardProvider: Estadísticas generales obtenidas exitosamente');
    return estadisticas;
  } catch (e) {
    print('❌ DashboardProvider: Error obteniendo estadísticas generales: $e');
    print('❌ DashboardProvider: Stack trace: ${StackTrace.current}');
    appLogger.error('DashboardProvider: Error obteniendo estadísticas generales', error: e);
    
    // Retornar estadísticas vacías en caso de error
    print('📊 DashboardProvider: Retornando estadísticas vacías por error');
    return DashboardStats.empty();
  }
});

/// Provider para estadísticas por municipio
final estadisticasMunicipioProvider = FutureProvider.family<DashboardStats, String>((ref, municipioId) async {
  appLogger.debug('DashboardProvider: Obteniendo estadísticas del municipio: $municipioId');
  
  try {
    // Esperar a que el servicio esté disponible
    final dashboardService = await ref.read(dashboardServiceProvider.future);
    final estadisticas = await dashboardService.obtenerEstadisticasPorMunicipio(municipioId);
    
    appLogger.debug('DashboardProvider: Estadísticas de municipio obtenidas exitosamente');
    return estadisticas;
  } catch (e) {
    appLogger.error('DashboardProvider: Error obteniendo estadísticas de municipio', error: e);
    
    // Retornar estadísticas vacías en caso de error
    return DashboardStats.empty();
  }
});

/// Provider para estadísticas por período
final estadisticasPeriodoProvider = FutureProvider.family<DashboardStats, Map<String, dynamic>>((ref, params) async {
  final startDate = params['startDate'] as DateTime;
  final endDate = params['endDate'] as DateTime;
  final municipioId = params['municipioId'] as String?;
  
  appLogger.debug('DashboardProvider: Obteniendo estadísticas por período');
  appLogger.debug('DashboardProvider: Período: ${startDate.toIso8601String()} - ${endDate.toIso8601String()}');
  if (municipioId != null) {
    appLogger.debug('DashboardProvider: Municipio: $municipioId');
  }
  
  try {
    // Esperar a que el servicio esté disponible
    final dashboardService = await ref.read(dashboardServiceProvider.future);
    final estadisticas = await dashboardService.obtenerEstadisticasPorPeriodo(
      startDate: startDate,
      endDate: endDate,
      municipioId: municipioId,
    );
    
    appLogger.debug('DashboardProvider: Estadísticas de período obtenidas exitosamente');
    return estadisticas;
  } catch (e) {
    appLogger.error('DashboardProvider: Error obteniendo estadísticas de período', error: e);
    
    // Retornar estadísticas vacías en caso de error
    return DashboardStats.empty();
  }
});

/// Provider para el estado de conexión del dashboard - TEMPORALMENTE DESHABILITADO
// final dashboardConnectionStateProvider = StateNotifierProvider<DashboardConnectionNotifier, DashboardConnectionState>((ref) {
//   return DashboardConnectionNotifier(ref);
// });

/// Notificador para el estado de conexión del dashboard
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
      
      // Esperar a que el servicio esté disponible
      final dashboardService = await ref.read(dashboardServiceProvider.future);
      
      // Probar obtener estadísticas para verificar conexión
      await dashboardService.obtenerEstadisticasGenerales();
      
      state = state.copyWith(
        isLoading: false,
        isConnected: true,
        lastChecked: DateTime.now(),
      );
      
      appLogger.debug('DashboardConnectionNotifier: Conexión verificada exitosamente');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isConnected: false,
        error: e.toString(),
        lastChecked: DateTime.now(),
      );
      
      appLogger.error('DashboardConnectionNotifier: Error verificando conexión', error: e);
    }
  }
  
  /// Forzar verificación de conexión
  Future<void> forzarVerificacion() async {
    appLogger.debug('DashboardConnectionNotifier: Forzando verificación de conexión');
    await _verificarConexion();
  }
  
  /// Refrescar estadísticas
  Future<void> refrescarEstadisticas() async {
    appLogger.debug('DashboardConnectionNotifier: Refrescando estadísticas');
    
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Invalidar providers para forzar recarga
      ref.invalidate(estadisticasGeneralesProvider);
      
      state = state.copyWith(isLoading: false);
      
      appLogger.debug('DashboardConnectionNotifier: Estadísticas refrescadas exitosamente');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      
      appLogger.error('DashboardConnectionNotifier: Error refrescando estadísticas', error: e);
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

/// Estado de conexión del dashboard
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

/// Provider para refrescar estadísticas
final estadisticasRefreshProvider = FutureProvider.family<DashboardStats, void>((ref, _) async {
  appLogger.debug('DashboardProvider: Refrescando estadísticas generales');
  
  try {
    // Esperar a que el servicio esté disponible
    final dashboardService = await ref.read(dashboardServiceProvider.future);
    final estadisticas = await dashboardService.actualizarEstadisticas();
    
    appLogger.debug('DashboardProvider: Estadísticas refrescadas exitosamente');
    return estadisticas;
  } catch (e) {
    appLogger.error('DashboardProvider: Error refrescando estadísticas', error: e);
    
    // Retornar estadísticas vacías en caso de error
    return DashboardStats.empty();
  }
});

/// Provider para estadísticas de tendencias
final estadisticasTendenciaProvider = FutureProvider.family<DashboardTrend, String>((ref, metric) async {
  appLogger.debug('DashboardProvider: Obteniendo estadísticas de tendencia para métrica: $metric');
  
  try {
    // En una implementación real, aquí se obtendrían las tendencias desde el servicio
    // Por ahora, retornamos datos de ejemplo
    final now = DateTime.now();
    final points = <DashboardTrendPoint>[];
    
    // Generar 30 días de datos de ejemplo
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
    
    appLogger.debug('DashboardProvider: Estadísticas de tendencia obtenidas exitosamente');
    return trend;
  } catch (e) {
    appLogger.error('DashboardProvider: Error obteniendo estadísticas de tendencia', error: e);
    
    // Retornar tendencia vacía en caso de error
    return DashboardTrend(
      metric: metric,
      points: [],
      period: '30d',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    );
  }
});

/// Provider para estadísticas de comparación
final estadisticasComparacionProvider = FutureProvider.family<DashboardComparison, String>((ref, metric) async {
  appLogger.debug('DashboardProvider: Obteniendo estadísticas de comparación para métrica: $metric');
  
  try {
    // En una implementación real, aquí se obtendrían las comparaciones desde el servicio
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
    
    appLogger.debug('DashboardProvider: Estadísticas de comparación obtenidas exitosamente');
    return comparison;
  } catch (e) {
    appLogger.error('DashboardProvider: Error obteniendo estadísticas de comparación', error: e);
    
    // Retornar comparación vacía en caso de error
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

/// Generar un valor aleatorio para una métrica específica
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
    // En una implementación real, aquí se obtendrían los datos desde el servicio
    // Por ahora, retornamos datos de ejemplo
    final municipios = <MunicipioData>[];
    
    final municipiosNombres = [
      'Bogotá', 'Medellín', 'Cali', 'Barranquilla', 'Cartagena',
      'Cúcuta', 'Bucaramanga', 'Pereira', 'Ibagué', 'Manizales'
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
    
    // Retornar lista vacía en caso de error
    return [];
  }
});

/// Provider para resumen de alertas
final alertasResumenProvider = FutureProvider<AlertasResumen>((ref) async {
  appLogger.debug('DashboardProvider: Obteniendo resumen de alertas');
  
  try {
    // En una implementación real, aquí se obtendrían los datos desde el servicio
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
    
    // Retornar resumen vacío en caso de error
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