import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ReportesService {
  final Dio _dio;

  ReportesService(this._dio);

  // Obtener resumen general
  Future<Map<String, dynamic>> getResumenGeneral() async {
    try {
      final response = await _dio.get(
        '${AppConfig.getApiUrl()}/reportes/resumen-general',
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Error al obtener resumen general: $e');
    }
  }

  // Obtener estadísticas de gestantes
  Future<Map<String, dynamic>> getEstadisticasGestantes({
    String? municipioId,
    String? riesgo,
    String? madrinaId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (municipioId != null) params['municipio_id'] = municipioId;
      if (riesgo != null) params['riesgo'] = riesgo;
      if (madrinaId != null) params['madrina_id'] = madrinaId;

      final response = await _dio.get(
        '${AppConfig.getApiUrl()}/reportes/estadisticas-gestantes',
        queryParameters: params,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Error al obtener estadísticas de gestantes: $e');
    }
  }

  // Obtener reporte mensual consolidado
  Future<Map<String, dynamic>> getReporteMensual({
    int? mes,
    int? anio,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (mes != null) params['mes'] = mes;
      if (anio != null) params['anio'] = anio;

      final response = await _dio.get(
        '${AppConfig.getApiUrl()}/reportes/consolidados/mensual',
        queryParameters: params,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Error al obtener reporte mensual: $e');
    }
  }

  // Obtener reporte anual consolidado
  Future<Map<String, dynamic>> getReporteAnual({
    int? anio,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (anio != null) params['anio'] = anio;

      final response = await _dio.get(
        '${AppConfig.getApiUrl()}/reportes/consolidados/anual',
        queryParameters: params,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Error al obtener reporte anual: $e');
    }
  }

  // Obtener reporte por municipio
  Future<Map<String, dynamic>> getReportePorMunicipio({
    required String municipioId,
    int? mes,
    int? anio,
  }) async {
    try {
      final params = <String, dynamic>{
        'municipio_id': municipioId,
      };
      if (mes != null) params['mes'] = mes;
      if (anio != null) params['anio'] = anio;

      final response = await _dio.get(
        '${AppConfig.getApiUrl()}/reportes/consolidados/municipio',
        queryParameters: params,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Error al obtener reporte por municipio: $e');
    }
  }

  // Obtener comparativa entre períodos
  Future<Map<String, dynamic>> getComparativa({
    required int mes1,
    required int anio1,
    required int mes2,
    required int anio2,
  }) async {
    try {
      final params = {
        'mes1': mes1,
        'anio1': anio1,
        'mes2': mes2,
        'anio2': anio2,
      };

      final response = await _dio.get(
        '${AppConfig.getApiUrl()}/reportes/consolidados/comparativa',
        queryParameters: params,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Error al obtener comparativa: $e');
    }
  }

  // Descargar reporte como PDF
  Future<void> descargarPDF(String endpoint) async {
    try {
      final response = await _dio.get(
        '${AppConfig.getApiUrl()}/reportes/$endpoint',
        options: Options(responseType: ResponseType.bytes),
      );
      // La descarga se maneja en la UI
      return response.data;
    } catch (e) {
      throw Exception('Error al descargar PDF: $e');
    }
  }

  // Descargar reporte como Excel
  Future<void> descargarExcel(String endpoint) async {
    try {
      final response = await _dio.get(
        '${AppConfig.getApiUrl()}/reportes/$endpoint',
        options: Options(responseType: ResponseType.bytes),
      );
      // La descarga se maneja en la UI
      return response.data;
    } catch (e) {
      throw Exception('Error al descargar Excel: $e');
    }
  }

  // Obtener estadísticas de caché
  Future<Map<String, dynamic>> getCacheEstadisticas() async {
    try {
      final response = await _dio.get(
        '${AppConfig.getApiUrl()}/reportes/cache/estadisticas',
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Error al obtener estadísticas de caché: $e');
    }
  }

  // Limpiar caché expirado
  Future<void> limpiarCacheExpirado() async {
    try {
      await _dio.post(
        '${AppConfig.getApiUrl()}/reportes/cache/limpiar-expirado',
      );
    } catch (e) {
      throw Exception('Error al limpiar caché expirado: $e');
    }
  }

  // Limpiar todo el caché
  Future<void> limpiarTodoCache() async {
    try {
      await _dio.post(
        '${AppConfig.getApiUrl()}/reportes/cache/limpiar-todo',
      );
    } catch (e) {
      throw Exception('Error al limpiar caché: $e');
    }
  }
}

