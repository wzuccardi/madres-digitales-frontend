import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:js' as js;
import '../../models/reporte_model.dart';
import '../../core/constants/app_constants.dart';

class ReportesService {
  static String get baseUrl => AppConstants.apiBaseUrl;

  Future<ReporteCompleto> generarReporte({
    String? municipioId,
    String? madrinaId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (municipioId != null) queryParams['municipioId'] = municipioId;
      if (madrinaId != null) queryParams['madrinaId'] = madrinaId;
      if (fechaInicio != null) queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      if (fechaFin != null) queryParams['fechaFin'] = fechaFin.toIso8601String();

      final uri = Uri.parse('$baseUrl/reportes/generar')
          .replace(queryParameters: queryParams);

      print('🔍 Generando reporte: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      print('📊 Respuesta reporte: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        if (data['success'] == true) {
          return ReporteCompleto.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Error desconocido');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error generando reporte: $e');
      throw Exception('Error generando reporte: $e');
    }
  }

  Future<List<Municipio>> obtenerMunicipios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reportes/municipios'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((m) => Municipio.fromJson(m))
              .toList();
        } else {
          throw Exception(data['error'] ?? 'Error desconocido');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo municipios: $e');
      throw Exception('Error obteniendo municipios: $e');
    }
  }

  Future<List<Madrina>> obtenerMadrinas(String? municipioId) async {
    try {
      final queryParams = <String, String>{};
      if (municipioId != null) queryParams['municipioId'] = municipioId;

      final uri = Uri.parse('$baseUrl/reportes/madrinas')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((m) => Madrina.fromJson(m))
              .toList();
        } else {
          throw Exception(data['error'] ?? 'Error desconocido');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo madrinas: $e');
      throw Exception('Error obteniendo madrinas: $e');
    }
  }

  Future<void> descargarReporte({
    required String formato,
    String? municipioId,
    String? madrinaId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (municipioId != null) queryParams['municipioId'] = municipioId;
      if (madrinaId != null) queryParams['madrinaId'] = madrinaId;
      if (fechaInicio != null) queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      if (fechaFin != null) queryParams['fechaFin'] = fechaFin.toIso8601String();
      queryParams['formato'] = formato;

      final uri = Uri.parse('$baseUrl/reportes/dashboard/descargar')
          .replace(queryParameters: queryParams);

      print('📥 Descargando reporte: $uri');

      // En Flutter web, abrimos la URL en una nueva pestaña para descargar
      if (kIsWeb) {
        _abrirEnlaceDescarga(uri.toString());
      } else {
        // Para móvil, usaríamos un método diferente
        throw UnimplementedError('Descarga en móvil no implementada aún');
      }
    } catch (e) {
      print('❌ Error descargando reporte: $e');
      throw Exception('Error descargando reporte: $e');
    }
  }

  void _abrirEnlaceDescarga(String url) {
    if (kIsWeb) {
      // ignore: avoid_web_libraries_in_flutter
      // ignore: undefined_prefixed_name
      js.context.callMethod('open', [url, '_blank']);
    }
  }
}