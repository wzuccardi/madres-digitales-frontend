// Servicio simple para obtener datos reales del backend
// Basado en el patrÃ³n exitoso del DashboardService
// Integrado con el sistema de permisos de madrina

import '../services/api_service.dart';
import '../models/simple_models.dart';
import 'permission_service.dart';

class SimpleDataService {
  final ApiService _apiService;
  final PermissionService? _permissionService;

  SimpleDataService(this._apiService, [this._permissionService]);

  // Obtener gestantes - con soporte para formato paginado
  Future<List<SimpleGestante>> obtenerGestantes() async {

    try {
      final response = await _apiService.get('/gestantes');

      // Manejar formato paginado: { success: true, data: { gestantes: [...], total: ... } }
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

        // Estructura: { data: { gestantes: [...] } }
        if (responseData['data'] is Map && responseData['data']['gestantes'] != null) {
          final List<dynamic> data = responseData['data']['gestantes'] as List<dynamic>;
          final gestantes = data
              .map((json) => SimpleGestante.fromJson(json as Map<String, dynamic>))
              .toList();
          return gestantes;
        }
        // Estructura: { data: [...] }
        else if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'] as List<dynamic>;
          final gestantes = data
              .map((json) => SimpleGestante.fromJson(json as Map<String, dynamic>))
              .toList();
          return gestantes;
        }
      }

      // Manejar formato array simple (legacy)
      if (response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;

        final gestantes = data
            .map((json) => SimpleGestante.fromJson(json as Map<String, dynamic>))
            .toList();

        return gestantes;
      }

      throw Exception('Formato de respuesta inválido para gestantes');
    } catch (e) {
      rethrow;
    }
  }

  // Obtener controles - igual que el dashboard
  Future<List<SimpleControl>> obtenerControles() async {
    try {
      final response = await _apiService.get('/controles');

      List<dynamic> controlesData;
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data;

        // Estructura: { success: true, data: { controles: [...], pagination: {...} } }
        if (responseData['data'] is Map && responseData['data']['controles'] != null) {
          controlesData = responseData['data']['controles'] as List<dynamic>;
        }
        // Estructura: { data: [...] }
        else if (responseData['data'] is List) {
          controlesData = responseData['data'] as List<dynamic>;
        } else {
          controlesData = [];
        }
      } else if (response.data is List) {
        controlesData = response.data as List<dynamic>;
      } else {
        throw Exception('Formato de respuesta inválido para controles');
      }

      final controles = controlesData
          .map((json) => SimpleControl.fromJson(json as Map<String, dynamic>))
          .toList();

      return controles;
    } catch (e) {
      rethrow;
    }
  }

  // Obtener alertas - igual que el dashboard
  Future<List<SimpleAlerta>> obtenerAlertas() async {
    try {
      final response = await _apiService.get('/alertas');

      List<dynamic> alertasData;
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data;

        // Estructura: { success: true, data: { alertas: [...], pagination: {...} } }
        if (responseData['data'] is Map && responseData['data']['alertas'] != null) {
          alertasData = responseData['data']['alertas'] as List<dynamic>;
        }
        // Estructura: { data: [...] }
        else if (responseData['data'] is List) {
          alertasData = responseData['data'] as List<dynamic>;
        } else {
          alertasData = [];
        }
      } else if (response.data is List) {
        alertasData = response.data as List<dynamic>;
      } else {
        throw Exception('Formato de respuesta inválido para alertas');
      }

      final alertas = alertasData
          .map((json) => SimpleAlerta.fromJson(json as Map<String, dynamic>))
          .toList();

      return alertas;
    } catch (e) {
      rethrow;
    }
  }

  // Obtener gestante por ID
  Future<SimpleGestante?> obtenerGestantePorId(String id) async {
    try {
      final response = await _apiService.get('/gestantes/$id');
      
      if (response.data != null) {
        final gestante = SimpleGestante.fromJson(response.data as Map<String, dynamic>);
        return gestante;
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Filtrar controles por estado
  List<SimpleControl> filtrarControlesPorEstado(List<SimpleControl> controles, String estado) {
    final ahora = DateTime.now();
    
    switch (estado) {
      case 'vencidos':
        return controles.where((control) {
          // Considerar vencidos los controles de hace mÃ¡s de 30 dÃ­as
          return ahora.difference(control.fecha_control).inDays > 30;
        }).toList();
      
      case 'pendientes':
        return controles.where((control) {
          // Considerar pendientes los controles recientes (Ãºltimos 7 dÃ­as)
          return ahora.difference(control.fecha_control).inDays <= 7;
        }).toList();
      
      default: // 'todos'
        return controles;
    }
  }

  // Filtrar alertas por estado
  List<SimpleAlerta> filtrarAlertasPorEstado(List<SimpleAlerta> alertas, {bool? resuelta}) {
    if (resuelta == null) return alertas;
    return alertas.where((alerta) => alerta.resuelta == resuelta).toList();
  }

  // MÃ©todo para enviar alerta SOS
  Future<Map<String, dynamic>> enviarAlertaSOS({
    required String gestanteId,
    required double latitud,
    required double longitud,
  }) async {
    try {

      final response = await _apiService.post('/alertas/emergencia', data: {
        'gestanteId': gestanteId,
        'coordenadas': [longitud, latitud], // Backend espera [lng, lat]
      });


      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // MÃ©todo para obtener alertas por gestante
  Future<List<SimpleAlerta>> obtenerAlertasPorGestante(String gestanteId) async {
    try {
      final response = await _apiService.get('/alertas/gestante/$gestanteId');

      if (response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        final alertas = data
            .map((json) => SimpleAlerta.fromJson(json as Map<String, dynamic>))
            .toList();

        return alertas;
      } else {
        throw Exception('Formato de respuesta invÃ¡lido para alertas de gestante');
      }
    } catch (e) {
      rethrow;
    }
  }

  // MÃ©todo para resolver una alerta
  Future<Map<String, dynamic>> resolverAlerta(String alertaId, {String? observaciones}) async {
    try {
      final response = await _apiService.put('/alertas/$alertaId/resolver', data: {
        if (observaciones != null) 'observaciones': observaciones,
      });

      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // MÃ©todo para obtener IPS cercanas
  Future<List<SimpleIPS>> obtenerIPSCercanas({
    required double latitud,
    required double longitud,
    double radioKm = 10.0,
  }) async {
    try {

      // Usar el endpoint correcto del backend: /ips-crud/nearby
      final response = await _apiService.get('/ips-crud/nearby', queryParameters: {
        'lat': latitud.toString(),
        'lng': longitud.toString(),
        'radius': radioKm.toString(),
      });

      // El backend devuelve directamente un array de IPS
      if (response.data is List) {
        final List<dynamic> ipsData = response.data as List<dynamic>;

        final ips = ipsData
            .map((json) => SimpleIPS.fromJson(json as Map<String, dynamic>))
            .toList();

        return ips;
      } else {
        throw Exception('Formato de respuesta invÃ¡lido para IPS cercanas');
      }
    } catch (e) {
      rethrow;
    }
  }

  // MÃ©todo para obtener todas las IPS
  Future<List<SimpleIPS>> obtenerTodasLasIPS() async {
    try {
      final response = await _apiService.get('/ips');

      if (response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        final ips = data
            .map((json) => SimpleIPS.fromJson(json as Map<String, dynamic>))
            .toList();

        return ips;
      } else {
        throw Exception('Formato de respuesta invÃ¡lido para IPS');
      }
    } catch (e) {
      rethrow;
    }
  }

  // MÃ©todo para obtener IPS por municipio
  Future<List<SimpleIPS>> obtenerIPSPorMunicipio(String municipioId) async {
    try {
      final response = await _apiService.get('/ips/municipio/$municipioId');

      if (response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        final ips = data
            .map((json) => SimpleIPS.fromJson(json as Map<String, dynamic>))
            .toList();

        return ips;
      } else {
        throw Exception('Formato de respuesta invÃ¡lido para IPS por municipio');
      }
    } catch (e) {
      rethrow;
    }
  }

  // MÃ©todo para crear gestante
  Future<SimpleGestante> crearGestante({
    required String documento,
    required String nombre,
    String? telefono,
    String? direccion,
    String? eps,
    bool activa = true,
    bool riesgoAlto = false,
    DateTime? fechaNacimiento,
    DateTime? fechaProbableParto,
    // Nuevo campo: registrar madrina creadora
    String? creadaPor,
  }) async {
    try {

      final data = {
        'documento': documento,
        'nombre': nombre,
        'telefono': telefono,
        'direccion': direccion,
        'eps': eps,
        'activa': activa,
        'riesgo_alto': riesgoAlto,
        'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
        'fecha_probable_parto': fechaProbableParto?.toIso8601String(),
      };
      
      // Agregar madrina creadora si se proporciona
      if (creadaPor != null) {
        data['creada_por'] = creadaPor;
      }
      
      final response = await _apiService.post('/gestantes', data: data);

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final gestanteData = data['gestante'] as Map<String, dynamic>;
        final gestante = SimpleGestante.fromJson(gestanteData);

        return gestante;
      } else {
        throw Exception('Formato de respuesta invÃ¡lido al crear gestante');
      }
    } catch (e) {
      rethrow;
    }
  }

  // MÃ©todo para actualizar gestante
  Future<SimpleGestante> actualizarGestante({
    required String id,
    String? documento,
    String? nombre,
    String? telefono,
    String? direccion,
    String? eps,
    bool? activa,
    bool? riesgoAlto,
    DateTime? fechaNacimiento,
    DateTime? fechaProbableParto,
  }) async {
    try {

      final updateData = <String, dynamic>{};
      if (documento != null) updateData['documento'] = documento;
      if (nombre != null) updateData['nombre'] = nombre;
      if (telefono != null) updateData['telefono'] = telefono;
      if (direccion != null) updateData['direccion'] = direccion;
      if (eps != null) updateData['eps'] = eps;
      if (activa != null) updateData['activa'] = activa;
      if (riesgoAlto != null) updateData['riesgo_alto'] = riesgoAlto;
      if (fechaNacimiento != null) updateData['fecha_nacimiento'] = fechaNacimiento.toIso8601String();
      if (fechaProbableParto != null) updateData['fecha_probable_parto'] = fechaProbableParto.toIso8601String();

      final response = await _apiService.put('/gestantes/$id', data: updateData);

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final gestanteData = data['gestante'] as Map<String, dynamic>;
        final gestante = SimpleGestante.fromJson(gestanteData);

        return gestante;
      } else {
        throw Exception('Formato de respuesta invÃ¡lido al actualizar gestante');
      }
    } catch (e) {
      rethrow;
    }
  }

  // MÃ©todo para crear control prenatal
  Future<SimpleControl> crearControl({
    required String gestanteId,
    required DateTime fechaControl,
    int? semanasGestacion,
    double? peso,
    int? presionSistolica,
    int? presionDiastolica,
    String? observaciones,
  }) async {
    try {

      final response = await _apiService.post('/controles', data: {
        'gestante_id': gestanteId,
        'fecha_control': fechaControl.toIso8601String(),
        'semanas_gestacion': semanasGestacion,
        'peso': peso,
        'presion_sistolica': presionSistolica,
        'presion_diastolica': presionDiastolica,
        'observaciones': observaciones,
      });

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final controlData = data['control'] as Map<String, dynamic>;
        final control = SimpleControl.fromJson(controlData);

        return control;
      } else {
        throw Exception('Formato de respuesta invÃ¡lido al crear control');
      }
    } catch (e) {
      rethrow;
    }
  }

  // MÃ©todo para actualizar control prenatal
  Future<SimpleControl> actualizarControl({
    required String id,
    String? gestanteId,
    DateTime? fechaControl,
    int? semanasGestacion,
    double? peso,
    int? presionSistolica,
    int? presionDiastolica,
    String? observaciones,
  }) async {
    try {

      final updateData = <String, dynamic>{};
      if (gestanteId != null) updateData['gestante_id'] = gestanteId;
      if (fechaControl != null) updateData['fecha_control'] = fechaControl.toIso8601String();
      if (semanasGestacion != null) updateData['semanas_gestacion'] = semanasGestacion;
      if (peso != null) updateData['peso'] = peso;
      if (presionSistolica != null) updateData['presion_sistolica'] = presionSistolica;
      if (presionDiastolica != null) updateData['presion_diastolica'] = presionDiastolica;
      if (observaciones != null) updateData['observaciones'] = observaciones;

      final response = await _apiService.put('/controles/$id', data: updateData);

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final controlData = data['control'] as Map<String, dynamic>;
        final control = SimpleControl.fromJson(controlData);

        return control;
      } else {
        throw Exception('Formato de respuesta invÃ¡lido al actualizar control');
      }
    } catch (e) {
      rethrow;
    }
  }

  // MÃ©todo para crear alerta
  Future<SimpleAlerta> crearAlerta({
    required String gestanteId,
    required TipoAlerta tipoAlerta,
    required NivelPrioridad nivelPrioridad,
    String? descripcion,
    DateTime? fechaAlerta,
    double? latitud,
    double? longitud,
  }) async {
    try {

      final response = await _apiService.post('/alertas', data: {
        'gestante_id': gestanteId,
        'tipo_alerta': tipoAlerta.backendValue,
        'nivel_prioridad': nivelPrioridad.backendValue,
        'descripcion': descripcion,
        'fecha_alerta': fechaAlerta?.toIso8601String(),
        'latitud': latitud,
        'longitud': longitud,
      });

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final alertaData = data['alerta'] as Map<String, dynamic>;
        final alerta = SimpleAlerta.fromJson(alertaData);

        return alerta;
      } else {
        throw Exception('Formato de respuesta invÃ¡lido al crear alerta');
      }
    } catch (e) {
      rethrow;
    }
  }

  // MÃ©todo para actualizar alerta
  Future<SimpleAlerta> actualizarAlerta({
    required String id,
    String? gestanteId,
    TipoAlerta? tipoAlerta,
    NivelPrioridad? nivelPrioridad,
    String? descripcion,
    DateTime? fechaAlerta,
    bool? resuelta,
    double? latitud,
    double? longitud,
  }) async {
    try {

      final updateData = <String, dynamic>{};
      if (gestanteId != null) updateData['gestante_id'] = gestanteId;
      if (tipoAlerta != null) updateData['tipo_alerta'] = tipoAlerta.backendValue;
      if (nivelPrioridad != null) updateData['nivel_prioridad'] = nivelPrioridad.backendValue;
      if (descripcion != null) updateData['descripcion'] = descripcion;
      if (fechaAlerta != null) updateData['fecha_alerta'] = fechaAlerta.toIso8601String();
      if (resuelta != null) updateData['resuelta'] = resuelta;
      if (latitud != null) updateData['latitud'] = latitud;
      if (longitud != null) updateData['longitud'] = longitud;

      final response = await _apiService.put('/alertas/$id', data: updateData);

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final alertaData = data['alerta'] as Map<String, dynamic>;
        final alerta = SimpleAlerta.fromJson(alertaData);
        return alerta;
      } else {
        throw Exception('Formato de respuesta inválido al actualizar alerta');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Método auxiliar para parsear respuesta de gestantes
  List<SimpleGestante> parseGestantesResponse(dynamic response) {
          if (response.data is List) {
            final List<dynamic> data = response.data as List<dynamic>;
            return data
                .map((json) => SimpleGestante.fromJson(json as Map<String, dynamic>))
                .toList();
          } else if (response.data is Map<String, dynamic> && response.data['data'] is List) {
            final List<dynamic> data = response.data['data'] as List<dynamic>;
            return data
                .map((json) => SimpleGestante.fromJson(json as Map<String, dynamic>))
                .toList();
          }
          return [];
        }
      
        /// MÃ©todo para obtener gestantes con filtrado por madrina
        Future<List<SimpleGestante>> obtenerGestantesPorMadrina(String madrinaId) async {
          try {
            
            // Intentar endpoint especÃ­fico de madrina
            try {
              final response = await _apiService.get('/gestantes/madrina/$madrinaId');
              final gestantes = parseGestantesResponse(response);
              return gestantes;
            } catch (e) {
              
              // MÃ©todo alternativo: obtener todas y filtrar
              final response = await _apiService.get('/gestantes');
              final todasGestantes = parseGestantesResponse(response);
              
              // Filtrar manualmente por las relaciones
              final gestantesMadrina = todasGestantes
                  .where((g) => g.tieneAccesoMadrina(madrinaId))
                  .toList();
                  
              return gestantesMadrina;
            }
          } catch (e) {
            rethrow;
          }
        }
      
        /// MÃ©todo para verificar si una madrina tiene acceso a una gestante
        Future<bool> verificarAccesoMadrina(String gestanteId, String madrinaId) async {
          try {
            // Verificación local
            final response = await _apiService.get('/gestantes/$gestanteId');
            if (response.data != null) {
              final gestante = SimpleGestante.fromJson(response.data as Map<String, dynamic>);
              final tieneAcceso = gestante.tieneAccesoMadrina(madrinaId);
              return tieneAcceso;
            }
            
            return false;
          } catch (e) {
            return false;
          }
        }
      
        /// MÃ©todo para asignar una gestante a una madrina
        Future<bool> asignarGestanteAMadrina({
          required String gestanteId,
          required String madrinaId,
          String? asignadoPor,
        }) async {
          try {
            // Asignación directa a través de la API
            final response = await _apiService.post('/gestantes/$gestanteId/asignar', data: {
              'madrina_id': madrinaId,
              'asignado_por': asignadoPor,
            });

            if (response.data != null && response.data['success'] == true) {
              return true;
            } else {
              return false;
            }
          } catch (e) {
            return false;
          }
        }
}

