// Servicio para reportes y estadísticas
import 'dart:convert';
import 'auth_service.dart';

class ReporteService {

  // Obtener resumen general
  Future<Map<String, dynamic>> getResumenGeneral() async {
    try {
      final response = await AuthService().authenticatedRequest(
        'GET',
        '/reportes/resumen-general',
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener resumen general: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error en getResumenGeneral: $e');
      rethrow;
    }
  }

  // Obtener estadísticas de gestantes
  Future<List<dynamic>> getEstadisticasGestantes() async {
    try {
      final response = await AuthService().authenticatedRequest(
        'GET',
        '/reportes/estadisticas-gestantes',
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener estadísticas de gestantes: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error en getEstadisticasGestantes: $e');
      rethrow;
    }
  }

  // Obtener estadísticas de controles
  Future<Map<String, dynamic>> getEstadisticasControles({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      String endpoint = '/reportes/estadisticas-controles';
      if (fechaInicio != null || fechaFin != null) {
        endpoint += '?';
        if (fechaInicio != null) {
          endpoint += 'fecha_inicio=${fechaInicio.toIso8601String()}&';
        }
        if (fechaFin != null) {
          endpoint += 'fecha_fin=${fechaFin.toIso8601String()}';
        }
      }

      final response = await AuthService().authenticatedRequest(
        'GET',
        endpoint,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener estadísticas de controles: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error en getEstadisticasControles: $e');
      rethrow;
    }
  }

  // Obtener estadísticas de alertas
  Future<Map<String, dynamic>> getEstadisticasAlertas() async {
    try {
      final response = await AuthService().authenticatedRequest(
        'GET',
        '/reportes/estadisticas-alertas',
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener estadísticas de alertas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en getEstadisticasAlertas: $e');
      rethrow;
    }
  }

  // Obtener estadísticas de riesgo
  Future<Map<String, dynamic>> getEstadisticasRiesgo() async {
    try {
      final response = await AuthService().authenticatedRequest(
        'GET',
        '/reportes/estadisticas-riesgo',
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener estadísticas de riesgo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error en getEstadisticasRiesgo: $e');
      rethrow;
    }
  }

  // Obtener tendencias
  Future<List<dynamic>> getTendencias({int meses = 6}) async {
    try {
      final response = await AuthService().authenticatedRequest(
        'GET',
        '/reportes/tendencias?meses=$meses',
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener tendencias: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error en getTendencias: $e');
      rethrow;
    }
  }
}

