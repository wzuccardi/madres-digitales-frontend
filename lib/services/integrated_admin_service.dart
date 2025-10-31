import 'dart:convert';
import '../models/integrated_models.dart';
import 'auth_service.dart';

class IntegratedAdminService {
  final String baseUrl = 'http://localhost:54112/api';
  final AuthService _authService;
  
  IntegratedAdminService({AuthService? authService})
      : _authService = authService ?? AuthService() {
    if (authService == null) {
    } else {
    }
  }

  // ==================== MUNICIPIOS ====================
  
  /// Obtener todos los municipios con estadÃ­sticas integradas
  Future<List<MunicipioIntegrado>> getMunicipiosIntegrados() async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/municipios/integrados',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] as List;
        return data.map((json) => MunicipioIntegrado.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener municipios integrados: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Activar o desactivar un municipio
  Future<void> toggleMunicipioEstado(String municipioId, bool nuevoEstado) async {
    try {
      final endpoint = nuevoEstado 
          ? '/municipios/$municipioId/activar' 
          : '/municipios/$municipioId/desactivar';
      
      final response = await _authService.authenticatedRequest(
        'POST',
        endpoint,
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cambiar estado del municipio: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener municipio especÃ­fico con detalles completos
  Future<MunicipioIntegrado> getMunicipioDetallado(String municipioId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/municipios/$municipioId/detallado',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return MunicipioIntegrado.fromJson(decoded['data']);
      } else {
        throw Exception('Error al obtener municipio detallado: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== IPS ====================
  
  /// Obtener IPS por municipio con informaciÃ³n integrada
  Future<List<IPSIntegrada>> getIPSByMunicipio(String municipioId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/ips-crud/municipio/$municipioId/integradas',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] as List;
        return data.map((json) => IPSIntegrada.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener IPS integradas: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener todas las IPS integradas
  Future<List<IPSIntegrada>> getAllIPSIntegradas() async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/ips-crud/integradas',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] as List;
        return data.map((json) => IPSIntegrada.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener todas las IPS integradas: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Activar o desactivar una IPS
  Future<void> toggleIPSEstado(String ipsId, bool nuevoEstado) async {
    try {
      final response = await _authService.authenticatedRequest(
        'PUT',
        '/ips-crud/$ipsId',
        body: {'activa': nuevoEstado},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cambiar estado de la IPS: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Crear nueva IPS
  Future<IPSIntegrada> createIPS(Map<String, dynamic> ipsData) async {
    try {
      final response = await _authService.authenticatedRequest(
        'POST',
        '/ips-crud',
        body: ipsData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return IPSIntegrada.fromJson(decoded['data']);
      } else {
        throw Exception('Error al crear IPS: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar IPS
  Future<IPSIntegrada> updateIPS(String ipsId, Map<String, dynamic> ipsData) async {
    try {
      final response = await _authService.authenticatedRequest(
        'PUT',
        '/ips-crud/$ipsId',
        body: ipsData,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return IPSIntegrada.fromJson(decoded['data']);
      } else {
        throw Exception('Error al actualizar IPS: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== MÃ‰DICOS ====================
  
  /// Obtener mÃ©dicos por municipio con informaciÃ³n integrada
  Future<List<MedicoIntegrado>> getMedicosByMunicipio(String municipioId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/medicos-crud/municipio/$municipioId/integrados',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] as List;
        return data.map((json) => MedicoIntegrado.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener mÃ©dicos integrados: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener mÃ©dicos por IPS
  Future<List<MedicoIntegrado>> getMedicosByIPS(String ipsId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/medicos-crud/ips/$ipsId/integrados',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] as List;
        return data.map((json) => MedicoIntegrado.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener mÃ©dicos por IPS: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener todos los mÃ©dicos integrados
  Future<List<MedicoIntegrado>> getAllMedicosIntegrados() async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/medicos-crud/integrados',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] as List;
        return data.map((json) => MedicoIntegrado.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener todos los mÃ©dicos integrados: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Activar o desactivar un mÃ©dico
  Future<void> toggleMedicoEstado(String medicoId, bool nuevoEstado) async {
    try {
      final response = await _authService.authenticatedRequest(
        'PUT',
        '/medicos-crud/$medicoId',
        body: {'activo': nuevoEstado},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cambiar estado del mÃ©dico: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Crear nuevo mÃ©dico
  Future<MedicoIntegrado> createMedico(Map<String, dynamic> medicoData) async {
    try {
      final response = await _authService.authenticatedRequest(
        'POST',
        '/medicos-crud',
        body: medicoData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return MedicoIntegrado.fromJson(decoded['data']);
      } else {
        throw Exception('Error al crear mÃ©dico: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar mÃ©dico
  Future<MedicoIntegrado> updateMedico(String medicoId, Map<String, dynamic> medicoData) async {
    try {
      final response = await _authService.authenticatedRequest(
        'PUT',
        '/medicos-crud/$medicoId',
        body: medicoData,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return MedicoIntegrado.fromJson(decoded['data']);
      } else {
        throw Exception('Error al actualizar mÃ©dico: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Asignar mÃ©dico a IPS
  Future<void> asignarMedicoAIPS(String medicoId, String ipsId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'POST',
        '/medicos-crud/$medicoId/asignar-ips',
        body: {'ips_id': ipsId},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al asignar mÃ©dico a IPS: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== RESUMEN Y ESTADÃSTICAS ====================
  
  /// Obtener resumen integrado con todas las estadÃ­sticas
  Future<ResumenIntegrado> getResumenIntegrado() async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/admin/resumen-integrado',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return ResumenIntegrado.fromJson(decoded['data']);
      } else {
        throw Exception('Error al obtener resumen integrado: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener estadÃ­sticas por municipio
  Future<Map<String, dynamic>> getEstadisticasMunicipio(String municipioId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/admin/estadisticas/municipio/$municipioId',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener estadÃ­sticas del municipio: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener estadÃ­sticas por IPS
  Future<Map<String, dynamic>> getEstadisticasIPS(String ipsId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/admin/estadisticas/ips/$ipsId',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener estadÃ­sticas de la IPS: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener estadÃ­sticas por mÃ©dico
  Future<Map<String, dynamic>> getEstadisticasMedico(String medicoId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/admin/estadisticas/medico/$medicoId',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener estadÃ­sticas del mÃ©dico: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== BÃšSQUEDAS Y FILTROS ====================
  
  /// Buscar en todos los mÃ³dulos
  Future<Map<String, dynamic>> buscarIntegrado(String query) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/admin/buscar?q=$query',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return {
          'municipios': (decoded['data']['municipios'] as List)
              .map((json) => MunicipioIntegrado.fromJson(json))
              .toList(),
          'ips': (decoded['data']['ips'] as List)
              .map((json) => IPSIntegrada.fromJson(json))
              .toList(),
          'medicos': (decoded['data']['medicos'] as List)
              .map((json) => MedicoIntegrado.fromJson(json))
              .toList(),
        };
      } else {
        throw Exception('Error en bÃºsqueda integrada: ${response.statusCode}');
      }
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

      final response = await _authService.authenticatedRequest(
        'GET',
        '/municipios/integrados/filtros?$queryString',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] as List;
        return data.map((json) => MunicipioIntegrado.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener municipios con filtros: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== OPERACIONES MASIVAS ====================
  
  /// Activar/desactivar mÃºltiples municipios
  Future<void> toggleMultiplesMunicipios(List<String> municipioIds, bool nuevoEstado) async {
    try {
      final response = await _authService.authenticatedRequest(
        'POST',
        '/municipios/toggle-multiple',
        body: {
          'municipio_ids': municipioIds,
          'activo': nuevoEstado,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cambiar estado de mÃºltiples municipios: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Sincronizar datos entre mÃ³dulos
  Future<void> sincronizarDatos() async {
    try {
      final response = await _authService.authenticatedRequest(
        'POST',
        '/admin/sincronizar-datos',
      );

      if (response.statusCode != 200) {
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

      final response = await _authService.authenticatedRequest(
        'POST',
        '/admin/reporte-integrado',
        body: body,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Error al generar reporte integrado: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
