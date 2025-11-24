import 'package:dio/dio.dart';
import 'package:madres_digitales_flutter_new/core/network/api_service.dart';

class ReportesService {
  ReportesService(this._dio) : _api = null;
  ReportesService.fromApiService(ApiService api)
      : _api = api,
        _dio = api.dioInstance;
  final Dio _dio;
  final ApiService? _api;

  // Obtener resumen general
  Future<Map<String, dynamic>> getResumenGeneral() async {
    try {
      if (_api != null) {
        final resp = await _api!.get<Map<String, dynamic>>('/reportes/resumen-general');
        if (!resp.success) {
          throw Exception(resp.message ?? 'No autorizado');
        }
        return _api!.extractObject(resp.data);
      }
      final response = await _dio.get('/reportes/resumen-general');
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

      if (_api != null) {
        final resp = await _api!.get<Map<String, dynamic>>('/reportes/estadisticas-gestantes', queryParameters: params);
        if (!resp.success) {
          throw Exception(resp.message ?? 'No autorizado');
        }
        return _api!.extractObject(resp.data);
      }
      final response = await _dio.get('/reportes/estadisticas-gestantes', queryParameters: params);
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Error al obtener estadísticas de gestantes: $e');
    }
  }

  // Obtener estadísticas de controles
  Future<Map<String, dynamic>> getEstadisticasControles({
    String? municipioId,
    String? medicoId,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (municipioId != null) params['municipio_id'] = municipioId;
      if (medicoId != null) params['medico_id'] = medicoId;
      if (fechaInicio != null && fechaFin != null) {
        params['fecha_inicio'] = fechaInicio;
        params['fecha_fin'] = fechaFin;
      }

      if (_api != null) {
        final resp = await _api!.get<Map<String, dynamic>>('/reportes/estadisticas-controles', queryParameters: params);
        if (!resp.success) {
          throw Exception(resp.message ?? 'No autorizado');
        }
        return _api!.extractObject(resp.data);
      }
      final response = await _dio.get('/reportes/estadisticas-controles', queryParameters: params);
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Error al obtener estadísticas de controles: $e');
    }
  }

  // Obtener estadísticas de alertas
  Future<Map<String, dynamic>> getEstadisticasAlertas({
    String? municipioId,
    String? tipoAlerta,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (municipioId != null) params['municipio_id'] = municipioId;
      if (tipoAlerta != null) params['tipo_alerta'] = tipoAlerta;
      if (fechaInicio != null && fechaFin != null) {
        params['fecha_inicio'] = fechaInicio;
        params['fecha_fin'] = fechaFin;
      }

      if (_api != null) {
        final resp = await _api!.get<Map<String, dynamic>>('/reportes/estadisticas-alertas', queryParameters: params);
        if (!resp.success) {
          throw Exception(resp.message ?? 'No autorizado');
        }
        return _api!.extractObject(resp.data);
      }
      final response = await _dio.get('/reportes/estadisticas-alertas', queryParameters: params);
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Error al obtener estadísticas de alertas: $e');
    }
  }

  // Descargar CSV
  Future<dynamic> descargarCSV(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get('/reportes/$endpoint', queryParameters: params, options: Options(responseType: ResponseType.bytes));
      return response.data;
    } catch (e) {
      throw Exception('Error al descargar CSV: $e');
    }
  }

  // Descargar TXT
  Future<dynamic> descargarTXT(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get('/reportes/$endpoint', queryParameters: params, options: Options(responseType: ResponseType.bytes));
      return response.data;
    } catch (e) {
      throw Exception('Error al descargar TXT: $e');
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

      if (_api != null) {
        final resp = await _api!.get<Map<String, dynamic>>('/reportes/consolidados/mensual', queryParameters: params);
        if (!resp.success) {
          throw Exception(resp.message ?? 'No autorizado');
        }
        return _api!.extractObject(resp.data);
      }
      final response = await _dio.get('/reportes/consolidados/mensual', queryParameters: params);
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

      if (_api != null) {
        final resp = await _api!.get<Map<String, dynamic>>('/reportes/consolidados/anual', queryParameters: params);
        if (!resp.success) {
          throw Exception(resp.message ?? 'No autorizado');
        }
        return _api!.extractObject(resp.data);
      }
      final response = await _dio.get('/reportes/consolidados/anual', queryParameters: params);
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

      if (_api != null) {
        final resp = await _api!.get<Map<String, dynamic>>('/reportes/consolidados/municipio', queryParameters: params);
        if (!resp.success) {
          throw Exception(resp.message ?? 'No autorizado');
        }
        return _api!.extractObject(resp.data);
      }
      final response = await _dio.get('/reportes/consolidados/municipio', queryParameters: params);
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

      if (_api != null) {
        final resp = await _api!.get<Map<String, dynamic>>('/reportes/consolidados/comparativa', queryParameters: params);
        if (!resp.success) {
          throw Exception(resp.message ?? 'No autorizado');
        }
        return _api!.extractObject(resp.data);
      }
      final response = await _dio.get('/reportes/consolidados/comparativa', queryParameters: params);
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Error al obtener comparativa: $e');
    }
  }

  // Descargar reporte como PDF
  Future<List<int>> descargarPDF(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(
        '/reportes/descargar/$endpoint/pdf',
        queryParameters: params,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data as List<int>;
    } catch (e) {
      throw Exception('Error al descargar PDF: $e');
    }
  }

  // Descargar reporte como Excel/CSV
  Future<List<int>> descargarExcel(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(
        '/reportes/descargar/$endpoint/excel',
        queryParameters: params,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data as List<int>;
    } catch (e) {
      throw Exception('Error al descargar Excel: $e');
    }
  }

  // Obtener estadísticas de caché
  Future<Map<String, dynamic>> getCacheEstadisticas() async {
    try {
      if (_api != null) {
        final resp = await _api!.get<Map<String, dynamic>>('/reportes/cache/estadisticas');
        if (!resp.success) {
          throw Exception(resp.message ?? 'No autorizado');
        }
        return _api!.extractObject(resp.data);
      }
      final response = await _dio.get('/reportes/cache/estadisticas');
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Error al obtener estadísticas de caché: $e');
    }
  }

  // Limpiar caché expirado
  Future<void> limpiarCacheExpirado() async {
    try {
      await _dio.post('/reportes/cache/limpiar-expirado');
    } catch (e) {
      throw Exception('Error al limpiar caché expirado: $e');
    }
  }

  // Limpiar todo el caché
  Future<void> limpiarTodoCache() async {
    try {
      await _dio.post('/reportes/cache/limpiar-todo');
    } catch (e) {
      throw Exception('Error al limpiar caché: $e');
    }
  }
}

