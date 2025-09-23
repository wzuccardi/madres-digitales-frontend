import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/dashboard_model.dart';
import '../models/gestante_model.dart';
import '../models/usuario_model.dart';
import 'api_service.dart';
import 'offline_service.dart';
import 'location_service.dart';

class DashboardService {
  final ApiService _apiService;
  final OfflineService _offlineService;
  final LocationService _locationService;

  DashboardService({
    required ApiService apiService,
    required OfflineService offlineService,
    required LocationService locationService,
  })  : _apiService = apiService,
        _offlineService = offlineService,
        _locationService = locationService;

  // Obtener estadísticas generales
  Future<EstadisticasGeneralesModel> obtenerEstadisticasGenerales() async {
    try {
      final response = await _apiService.get('/dashboard/estadisticas-generales');
      return EstadisticasGeneralesModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Error obteniendo estadísticas generales: $e');
      // Intentar obtener datos offline
      return await _obtenerEstadisticasOffline();
    }
  }

  // Obtener estadísticas por período
  Future<EstadisticasPorPeriodoModel> obtenerEstadisticasPorPeriodo({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? ipsId,
    String? medicoId,
  }) async {
    try {
      final queryParams = {
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        if (ipsId != null) 'ips_id': ipsId,
        if (medicoId != null) 'medico_id': medicoId,
      };

      final response = await _apiService.get(
        '/dashboard/estadisticas-periodo',
        queryParameters: queryParams,
      );

      return EstadisticasPorPeriodoModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Error obteniendo estadísticas por período: $e');
      rethrow;
    }
  }

  // Obtener estadísticas geográficas
  Future<EstadisticasGeograficasModel> obtenerEstadisticasGeograficas({
    double? latitud,
    double? longitud,
    double? radio,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (latitud != null && longitud != null) {
        queryParams['latitud'] = latitud.toString();
        queryParams['longitud'] = longitud.toString();
        queryParams['radio'] = (radio ?? 10.0).toString();
      }

      final response = await _apiService.get(
        '/dashboard/estadisticas-geograficas',
        queryParameters: queryParams,
      );

      return EstadisticasGeograficasModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Error obteniendo estadísticas geográficas: $e');
      rethrow;
    }
  }

  // Obtener estadísticas por ubicación actual
  Future<EstadisticasGeograficasModel> obtenerEstadisticasPorUbicacionActual({
    double radio = 10.0,
  }) async {
    try {
      final ubicacion = await _locationService.getCurrentLocation();
      return await obtenerEstadisticasGeograficas(
        latitud: ubicacion.latitude,
        longitud: ubicacion.longitude,
        radio: radio,
      );
    } catch (e) {
      debugPrint('Error obteniendo estadísticas por ubicación actual: $e');
      rethrow;
    }
  }

  // Generar reporte
  Future<ReporteModel> generarReporte({
    required TipoReporte tipo,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required FormatoArchivo formato,
    String? ipsId,
    String? medicoId,
    Map<String, dynamic>? parametrosAdicionales,
  }) async {
    try {
      final body = {
        'tipo': tipo.name,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        'formato': formato.name,
        if (ipsId != null) 'ips_id': ipsId,
        if (medicoId != null) 'medico_id': medicoId,
        if (parametrosAdicionales != null) ...parametrosAdicionales,
      };

      final response = await _apiService.post('/reportes/generar', data: body);
      return ReporteModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Error generando reporte: $e');
      rethrow;
    }
  }

  // Obtener estado del reporte
  Future<ReporteModel> obtenerEstadoReporte(String reporteId) async {
    try {
      final response = await _apiService.get('/reportes/$reporteId');
      return ReporteModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Error obteniendo estado del reporte: $e');
      rethrow;
    }
  }

  // Descargar reporte
  Future<String> descargarReporte(String reporteId) async {
    try {
      final response = await _apiService.get(
        '/reportes/$reporteId/descargar',
        options: {'responseType': 'bytes'},
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reporte_$reporteId.pdf');
      await file.writeAsBytes(response.data);

      return file.path;
    } catch (e) {
      debugPrint('Error descargando reporte: $e');
      rethrow;
    }
  }

  // Compartir reporte
  Future<void> compartirReporte(String reporteId) async {
    try {
      final rutaArchivo = await descargarReporte(reporteId);
      await Share.shareXFiles([XFile(rutaArchivo)]);
    } catch (e) {
      debugPrint('Error compartiendo reporte: $e');
      rethrow;
    }
  }

  // Obtener lista de reportes
  Future<List<ReporteModel>> obtenerReportes({
    int page = 1,
    int limit = 20,
    TipoReporte? tipo,
    EstadoReporte? estado,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (tipo != null) 'tipo': tipo.name,
        if (estado != null) 'estado': estado.name,
      };

      final response = await _apiService.get(
        '/reportes',
        queryParameters: queryParams,
      );

      return (response.data['reportes'] as List)
          .map((json) => ReporteModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo lista de reportes: $e');
      rethrow;
    }
  }

  // Eliminar reporte
  Future<void> eliminarReporte(String reporteId) async {
    try {
      await _apiService.delete('/reportes/$reporteId');
    } catch (e) {
      debugPrint('Error eliminando reporte: $e');
      rethrow;
    }
  }

  // Obtener estadísticas en tiempo real
  Stream<EstadisticasGeneralesModel> obtenerEstadisticasEnTiempoReal() async* {
    while (true) {
      try {
        final estadisticas = await obtenerEstadisticasGenerales();
        yield estadisticas;
        await Future.delayed(const Duration(minutes: 5));
      } catch (e) {
        debugPrint('Error en estadísticas en tiempo real: $e');
        await Future.delayed(const Duration(minutes: 1));
      }
    }
  }

  // Obtener estadísticas offline
  Future<EstadisticasGeneralesModel> _obtenerEstadisticasOffline() async {
    try {
      // Obtener datos de la base de datos local
      final db = await _offlineService.database;
      
      // Contar gestantes
      final gestantesResult = await db.rawQuery('SELECT COUNT(*) as count FROM gestantes_cache');
      final totalGestantes = gestantesResult.first['count'] as int;
      
      // Contar controles
      final controlesResult = await db.rawQuery('SELECT COUNT(*) as count FROM offline_prenatal_controls');
      final totalControles = controlesResult.first['count'] as int;
      
      // Contar alertas
      final alertasResult = await db.rawQuery('SELECT COUNT(*) as count FROM offline_alerts');
      final totalAlertas = alertasResult.first['count'] as int;
      
      // Contar alertas críticas
      final alertasCriticasResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM offline_alerts WHERE nivel_prioridad = ?',
        ['critica']
      );
      final alertasCriticas = alertasCriticasResult.first['count'] as int;

      return EstadisticasGeneralesModel(
        totalGestantes: totalGestantes,
        gestantesActivas: totalGestantes,
        totalControles: totalControles,
        controlesPendientes: 0,
        totalAlertas: totalAlertas,
        alertasCriticas: alertasCriticas,
        alertasResueltas: 0,
        promedioControlesPorGestante: totalGestantes > 0 ? totalControles / totalGestantes : 0,
        porcentajeGestantesRiesgo: 0,
        fechaActualizacion: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error obteniendo estadísticas offline: $e');
      // Retornar estadísticas vacías
      return EstadisticasGeneralesModel(
        totalGestantes: 0,
        gestantesActivas: 0,
        totalControles: 0,
        controlesPendientes: 0,
        totalAlertas: 0,
        alertasCriticas: 0,
        alertasResueltas: 0,
        promedioControlesPorGestante: 0,
        porcentajeGestantesRiesgo: 0,
        fechaActualizacion: DateTime.now(),
      );
    }
  }

  // Exportar datos para análisis
  Future<String> exportarDatosAnalisis({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? ipsId,
  }) async {
    try {
      final body = {
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        if (ipsId != null) 'ips_id': ipsId,
      };

      final response = await _apiService.post('/dashboard/exportar-datos', data: body);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/datos_analisis_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(response.data);

      return file.path;
    } catch (e) {
      debugPrint('Error exportando datos para análisis: $e');
      rethrow;
    }
  }

  // Obtener métricas de rendimiento
  Future<Map<String, dynamic>> obtenerMetricasRendimiento() async {
    try {
      final response = await _apiService.get('/dashboard/metricas-rendimiento');
      return response.data;
    } catch (e) {
      debugPrint('Error obteniendo métricas de rendimiento: $e');
      rethrow;
    }
  }
}