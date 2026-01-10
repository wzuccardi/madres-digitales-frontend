import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import 'package:madres_digitales_flutter_new/models/integrated_models.dart';

class IntegratedAdminService {

  IntegratedAdminService();
  final ApiService _api = ApiService();

  // ==================== MUNICIPIOS ====================
  
  /// Obtener todos los municipios con estadísticas integradas
  Future<List<MunicipioIntegrado>> getMunicipiosIntegrados() async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'GET',
        '/api/municipios/integrados',
      );
      if (response.success) {
        final list = response.data as List<dynamic>;
        return list.map((j) => MunicipioIntegrado.fromJson(j as Map<String, dynamic>)).toList();
      }
      throw Exception('Error al obtener municipios integrados: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Activar o desactivar un municipio
  Future<void> toggleMunicipioEstado(String municipioId, bool nuevoEstado) async {
    try {
      final endpoint = nuevoEstado
          ? '/api/municipios/$municipioId/activar'
          : '/api/municipios/$municipioId/desactivar';
      final response = await _api.authenticatedRequestApiResponse(
        'POST',
        endpoint,
      );
      if (!response.success) {
        throw Exception('Error al cambiar estado del municipio: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener municipio específico con detalles completos
  Future<MunicipioIntegrado> getMunicipioDetallado(String municipioId) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'GET',
        '/api/municipios/$municipioId/detallado',
      );
      if (response.success) {
        final map = response.data as Map<String, dynamic>;
        return MunicipioIntegrado.fromJson(map);
      }
      throw Exception('Error al obtener municipio detallado: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // ==================== IPS ====================
  
  /// Obtener IPS por municipio con información integrada
  Future<List<IPSIntegrada>> getIPSByMunicipio(String municipioId) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'GET',
        '/ips-crud/municipio/$municipioId/integradas',
      );
      if (response.success) {
        final list = response.data as List<dynamic>;
        return list.map((j) => IPSIntegrada.fromJson(j as Map<String, dynamic>)).toList();
      }
      throw Exception('Error al obtener IPS integradas: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener todas las IPS integradas
  Future<List<IPSIntegrada>> getAllIPSIntegradas() async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'GET',
        '/ips-crud/integradas',
      );
      if (response.success) {
        final list = response.data as List<dynamic>;
        return list.map((j) => IPSIntegrada.fromJson(j as Map<String, dynamic>)).toList();
      }
      throw Exception('Error al obtener todas las IPS integradas: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Activar o desactivar una IPS
  Future<void> toggleIPSEstado(String ipsId, bool nuevoEstado) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'PUT',
        '/ips-crud/$ipsId',
        body: {'activa': nuevoEstado},
      );
      if (!response.success) {
        throw Exception('Error al cambiar estado de la IPS: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Crear nueva IPS
  Future<IPSIntegrada> createIPS(Map<String, dynamic> ipsData) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'POST',
        '/ips-crud',
        body: ipsData,
      );
      if (response.success) {
        final map = response.data as Map<String, dynamic>;
        return IPSIntegrada.fromJson(map);
      }
      throw Exception('Error al crear IPS: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar IPS
  Future<IPSIntegrada> updateIPS(String ipsId, Map<String, dynamic> ipsData) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'PUT',
        '/ips-crud/$ipsId',
        body: ipsData,
      );
      if (response.success) {
        final map = response.data as Map<String, dynamic>;
        return IPSIntegrada.fromJson(map);
      }
      throw Exception('Error al actualizar IPS: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // ==================== MÉDICOS ====================
  
  /// Obtener médicos por municipio con información integrada
  Future<List<MedicoIntegrado>> getMedicosByMunicipio(String municipioId) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'GET',
        '/medicos-crud/municipio/$municipioId/integrados',
      );
      if (response.success) {
        final list = response.data as List<dynamic>;
        return list.map((json) => MedicoIntegrado.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Error al obtener médicos integrados: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener médicos por IPS
  Future<List<MedicoIntegrado>> getMedicosByIPS(String ipsId) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'GET',
        '/medicos-crud/ips/$ipsId/integrados',
      );
      if (response.success) {
        final list = response.data as List<dynamic>;
        return list.map((json) => MedicoIntegrado.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Error al obtener médicos por IPS: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener todos los médicos integrados
  Future<List<MedicoIntegrado>> getAllMedicosIntegrados() async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'GET',
        '/medicos-crud/integrados',
      );
      if (response.success) {
        final list = response.data as List<dynamic>;
        return list.map((json) => MedicoIntegrado.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Error al obtener todos los médicos integrados: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Activar o desactivar un médico
  Future<void> toggleMedicoEstado(String medicoId, bool nuevoEstado) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'PUT',
        '/medicos-crud/$medicoId',
        body: {'activo': nuevoEstado},
      );
      if (!response.success) {
        throw Exception('Error al cambiar estado del médico: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Crear nuevo médico
  Future<MedicoIntegrado> createMedico(Map<String, dynamic> medicoData) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'POST',
        '/medicos-crud',
        body: medicoData,
      );
      if (response.success) {
        final map = response.data as Map<String, dynamic>;
        return MedicoIntegrado.fromJson(map);
      } else {
        throw Exception('Error al crear médico: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar médico
  Future<MedicoIntegrado> updateMedico(String medicoId, Map<String, dynamic> medicoData) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'PUT',
        '/medicos-crud/$medicoId',
        body: medicoData,
      );
      if (response.success) {
        final map = response.data as Map<String, dynamic>;
        return MedicoIntegrado.fromJson(map);
      } else {
        throw Exception('Error al actualizar médico: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Asignar médico a IPS
  Future<void> asignarMedicoAIPS(String medicoId, String ipsId) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'POST',
        '/medicos-crud/$medicoId/asignar-ips',
        body: {'ips_id': ipsId},
      );
      if (!response.success) {
        throw Exception('Error al asignar médico a IPS: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== RESUMEN Y ESTADÍSTICAS ====================
  
  /// Obtener resumen integrado con todas las estadísticas
  Future<ResumenIntegrado> getResumenIntegrado() async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'GET',
        '/admin/resumen-integrado',
      );
      if (response.success) {
        final map = response.data as Map<String, dynamic>;
        return ResumenIntegrado.fromJson(map);
      }
      throw Exception('Error al obtener resumen integrado: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener estadísticas por municipio
  Future<Map<String, dynamic>> getEstadisticasMunicipio(String municipioId) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'GET',
        '/api/admin/estadisticas/municipio/$municipioId',
      );
      if (response.success) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener estadísticas del municipio: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener estadísticas por IPS
  Future<Map<String, dynamic>> getEstadisticasIPS(String ipsId) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'GET',
        '/api/admin/estadisticas/ips/$ipsId',
      );
      if (response.success) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener estadísticas de la IPS: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener estadísticas por médico
  Future<Map<String, dynamic>> getEstadisticasMedico(String medicoId) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'GET',
        '/api/admin/estadisticas/medico/$medicoId',
      );
      if (response.success) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener estadísticas del médico: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== BÚSQUEDAS Y FILTROS ====================
  
  /// Buscar en todos los módulos
  Future<Map<String, dynamic>> buscarIntegrado(String query) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'GET',
        '/admin/buscar',
        queryParams: {'q': query},
      );
      if (response.success) {
        final data = response.data as Map<String, dynamic>;
        return {
          'municipios': (data['municipios'] as List)
              .map((json) => MunicipioIntegrado.fromJson(json as Map<String, dynamic>))
              .toList(),
          'ips': (data['ips'] as List)
              .map((json) => IPSIntegrada.fromJson(json as Map<String, dynamic>))
              .toList(),
          'medicos': (data['medicos'] as List)
              .map((json) => MedicoIntegrado.fromJson(json as Map<String, dynamic>))
              .toList(),
        };
      }
      throw Exception('Error en búsqueda integrada: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener municipios con filtros avanzados
  Future<List<MunicipioIntegrado>> getMunicipiosConFiltros({
    bool? activo,
    String? departamento,
    int? minGestantes,
    int? maxGestantes,
    bool? tieneIPS,
    bool? tieneMedicos,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (activo != null) queryParams['activo'] = activo;
      if (departamento != null) queryParams['departamento'] = departamento;
      if (minGestantes != null) queryParams['min_gestantes'] = minGestantes;
      if (maxGestantes != null) queryParams['max_gestantes'] = maxGestantes;
      if (tieneIPS != null) queryParams['tiene_ips'] = tieneIPS;
      if (tieneMedicos != null) queryParams['tiene_medicos'] = tieneMedicos;

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _api.authenticatedRequestApiResponse(
        'GET',
        '/api/municipios/integrados/filtros?$queryString',
      );
      if (response.success) {
        final list = response.data as List<dynamic>;
        return list.map((json) => MunicipioIntegrado.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Error al obtener municipios con filtros: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== OPERACIONES MASIVAS ====================
  
  /// Activar/desactivar múltiples municipios
  Future<void> toggleMultiplesMunicipios(List<String> municipioIds, bool nuevoEstado) async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'POST',
        '/api/municipios/toggle-multiple',
        body: {
          'municipio_ids': municipioIds,
          'activo': nuevoEstado,
        },
      );
      if (!response.success) {
        throw Exception('Error al cambiar estado de múltiples municipios: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Sincronizar datos entre módulos
  Future<void> sincronizarDatos() async {
    try {
      final response = await _api.authenticatedRequestApiResponse(
        'POST',
        '/admin/sincronizar-datos',
      );
      if (!response.success) {
        throw Exception('Error al sincronizar datos: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Generar reporte integrado
  Future<Map<String, dynamic>> generarReporteIntegrado({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    List<String>? municipioIds,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fechaInicio != null) body['fecha_inicio'] = fechaInicio.toIso8601String();
      if (fechaFin != null) body['fecha_fin'] = fechaFin.toIso8601String();
      if (municipioIds != null) body['municipio_ids'] = municipioIds;

      final response = await _api.authenticatedRequestApiResponse(
        'POST',
        '/admin/reporte-integrado',
        body: body,
      );
      if (response.success) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Error al generar reporte integrado: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
