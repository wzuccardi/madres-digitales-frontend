// Servicio simple para obtener datos reales del backend
// Basado en el patrón exitoso del DashboardService
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
    print('🤰 SimpleDataService: Fetching gestantes...');

    try {
      final response = await _apiService.get('/gestantes');
      print('🔍 DEBUG: Response received');
      print('🔍 DEBUG: Response type: ${response.data.runtimeType}');

      // Manejar formato paginado (nuevo)
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        print('🔍 DEBUG: Response is Map, keys: ${responseData.keys.toList()}');

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'] as List<dynamic>;
          print('🔍 DEBUG: Found data array with ${data.length} items');

          final gestantes = data
              .map((json) => SimpleGestante.fromJson(json as Map<String, dynamic>))
              .toList();

          print('✅ SimpleDataService: Successfully loaded ${gestantes.length} gestantes (paginated)');
          return gestantes;
        } else {
          print('❌ DEBUG: Map does not contain data array');
          print('❌ DEBUG: Keys: ${responseData.keys.toList()}');
        }
      }

      // Manejar formato array simple (legacy)
      if (response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        print('🔍 DEBUG: Response is List with ${data.length} items');

        final gestantes = data
            .map((json) => SimpleGestante.fromJson(json as Map<String, dynamic>))
            .toList();

        print('✅ SimpleDataService: Successfully loaded ${gestantes.length} gestantes (legacy)');
        return gestantes;
      }

      print('❌ DEBUG: Response format not recognized');
      print('❌ DEBUG: Type: ${response.data.runtimeType}');
      throw Exception('Formato de respuesta inválido para gestantes');
    } catch (e, stackTrace) {
      print('❌ SimpleDataService: Error loading gestantes: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Obtener controles - igual que el dashboard
  Future<List<SimpleControl>> obtenerControles() async {
    try {
      print('🏥 SimpleDataService: Fetching controles...');
      final response = await _apiService.get('/controles');
      
      if (response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        final controles = data
            .map((json) => SimpleControl.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('🏥 SimpleDataService: Successfully loaded ${controles.length} controles');
        return controles;
      } else {
        throw Exception('Formato de respuesta inválido para controles');
      }
    } catch (e) {
      print('❌ SimpleDataService: Error loading controles: $e');
      rethrow;
    }
  }

  // Obtener alertas - igual que el dashboard
  Future<List<SimpleAlerta>> obtenerAlertas() async {
    try {
      print('🚨 SimpleDataService: Fetching alertas...');
      final response = await _apiService.get('/alertas');
      
      if (response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        final alertas = data
            .map((json) => SimpleAlerta.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('🚨 SimpleDataService: Successfully loaded ${alertas.length} alertas');
        return alertas;
      } else {
        throw Exception('Formato de respuesta inválido para alertas');
      }
    } catch (e) {
      print('❌ SimpleDataService: Error loading alertas: $e');
      rethrow;
    }
  }

  // Obtener gestante por ID
  Future<SimpleGestante?> obtenerGestantePorId(String id) async {
    try {
      print('🤰 SimpleDataService: Fetching gestante $id...');
      final response = await _apiService.get('/gestantes/$id');
      
      if (response.data != null) {
        final gestante = SimpleGestante.fromJson(response.data as Map<String, dynamic>);
        print('🤰 SimpleDataService: Successfully loaded gestante ${gestante.nombre}');
        return gestante;
      } else {
        return null;
      }
    } catch (e) {
      print('❌ SimpleDataService: Error loading gestante $id: $e');
      rethrow;
    }
  }

  // Filtrar controles por estado
  List<SimpleControl> filtrarControlesPorEstado(List<SimpleControl> controles, String estado) {
    final ahora = DateTime.now();
    
    switch (estado) {
      case 'vencidos':
        return controles.where((control) {
          // Considerar vencidos los controles de hace más de 30 días
          return ahora.difference(control.fecha_control).inDays > 30;
        }).toList();
      
      case 'pendientes':
        return controles.where((control) {
          // Considerar pendientes los controles recientes (últimos 7 días)
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

  // Método para enviar alerta SOS
  Future<Map<String, dynamic>> enviarAlertaSOS({
    required String gestanteId,
    required double latitud,
    required double longitud,
  }) async {
    try {
      print('🚨 SimpleDataService: Sending SOS alert...');
      print('   Gestante ID: $gestanteId');
      print('   Coordinates: [$longitud, $latitud]');

      final response = await _apiService.post('/alertas/emergencia', data: {
        'gestanteId': gestanteId,
        'coordenadas': [longitud, latitud], // Backend espera [lng, lat]
      });

      print('✅ SimpleDataService: SOS alert sent successfully');
      print('   Alert ID: ${response.data['alertaId']}');

      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ SimpleDataService: Error sending SOS alert: $e');
      rethrow;
    }
  }

  // Método para obtener alertas por gestante
  Future<List<SimpleAlerta>> obtenerAlertasPorGestante(String gestanteId) async {
    try {
      print('🚨 SimpleDataService: Fetching alerts for gestante $gestanteId...');
      final response = await _apiService.get('/alertas/gestante/$gestanteId');

      if (response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        final alertas = data
            .map((json) => SimpleAlerta.fromJson(json as Map<String, dynamic>))
            .toList();

        print('🚨 SimpleDataService: Successfully loaded ${alertas.length} alerts for gestante');
        return alertas;
      } else {
        throw Exception('Formato de respuesta inválido para alertas de gestante');
      }
    } catch (e) {
      print('❌ SimpleDataService: Error loading alerts for gestante: $e');
      rethrow;
    }
  }

  // Método para resolver una alerta
  Future<Map<String, dynamic>> resolverAlerta(String alertaId, {String? observaciones}) async {
    try {
      print('🚨 SimpleDataService: Resolving alert $alertaId...');
      final response = await _apiService.put('/alertas/$alertaId/resolver', data: {
        if (observaciones != null) 'observaciones': observaciones,
      });

      print('✅ SimpleDataService: Alert resolved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ SimpleDataService: Error resolving alert: $e');
      rethrow;
    }
  }

  // Método para obtener IPS cercanas
  Future<List<SimpleIPS>> obtenerIPSCercanas({
    required double latitud,
    required double longitud,
    double radioKm = 10.0,
  }) async {
    try {
      print('🏥 SimpleDataService: Fetching nearby IPS...');
      print('   Center: [$latitud, $longitud]');
      print('   Radius: ${radioKm}km');

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

        print('🏥 SimpleDataService: Successfully loaded ${ips.length} nearby IPS');
        return ips;
      } else {
        throw Exception('Formato de respuesta inválido para IPS cercanas');
      }
    } catch (e) {
      print('❌ SimpleDataService: Error loading nearby IPS: $e');
      rethrow;
    }
  }

  // Método para obtener todas las IPS
  Future<List<SimpleIPS>> obtenerTodasLasIPS() async {
    try {
      print('🏥 SimpleDataService: Fetching all IPS...');
      final response = await _apiService.get('/ips');

      if (response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        final ips = data
            .map((json) => SimpleIPS.fromJson(json as Map<String, dynamic>))
            .toList();

        print('🏥 SimpleDataService: Successfully loaded ${ips.length} IPS');
        return ips;
      } else {
        throw Exception('Formato de respuesta inválido para IPS');
      }
    } catch (e) {
      print('❌ SimpleDataService: Error loading IPS: $e');
      rethrow;
    }
  }

  // Método para obtener IPS por municipio
  Future<List<SimpleIPS>> obtenerIPSPorMunicipio(String municipioId) async {
    try {
      print('🏥 SimpleDataService: Fetching IPS for municipio $municipioId...');
      final response = await _apiService.get('/ips/municipio/$municipioId');

      if (response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        final ips = data
            .map((json) => SimpleIPS.fromJson(json as Map<String, dynamic>))
            .toList();

        print('🏥 SimpleDataService: Successfully loaded ${ips.length} IPS for municipio');
        return ips;
      } else {
        throw Exception('Formato de respuesta inválido para IPS por municipio');
      }
    } catch (e) {
      print('❌ SimpleDataService: Error loading IPS by municipio: $e');
      rethrow;
    }
  }

  // Método para crear gestante
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
      print('🤰 SimpleDataService: Creating new gestante...');
      print('   Documento: $documento');
      print('   Nombre: $nombre');

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

        print('✅ SimpleDataService: Gestante created successfully with ID: ${gestante.id}');
        return gestante;
      } else {
        throw Exception('Formato de respuesta inválido al crear gestante');
      }
    } catch (e) {
      print('❌ SimpleDataService: Error creating gestante: $e');
      rethrow;
    }
  }

  // Método para actualizar gestante
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
      print('🤰 SimpleDataService: Updating gestante $id...');

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

        print('✅ SimpleDataService: Gestante updated successfully');
        return gestante;
      } else {
        throw Exception('Formato de respuesta inválido al actualizar gestante');
      }
    } catch (e) {
      print('❌ SimpleDataService: Error updating gestante: $e');
      rethrow;
    }
  }

  // Método para crear control prenatal
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
      print('🏥 SimpleDataService: Creating new control...');
      print('   Gestante ID: $gestanteId');
      print('   Fecha: $fechaControl');

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

        print('✅ SimpleDataService: Control created successfully with ID: ${control.id}');
        return control;
      } else {
        throw Exception('Formato de respuesta inválido al crear control');
      }
    } catch (e) {
      print('❌ SimpleDataService: Error creating control: $e');
      rethrow;
    }
  }

  // Método para actualizar control prenatal
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
      print('🏥 SimpleDataService: Updating control $id...');

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

        print('✅ SimpleDataService: Control updated successfully');
        return control;
      } else {
        throw Exception('Formato de respuesta inválido al actualizar control');
      }
    } catch (e) {
      print('❌ SimpleDataService: Error updating control: $e');
      rethrow;
    }
  }

  // Método para crear alerta
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
      print('🚨 SimpleDataService: Creating new alert...');
      print('   Gestante ID: $gestanteId');
      print('   Tipo: ${tipoAlerta.backendValue}');

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

        print('✅ SimpleDataService: Alert created successfully with ID: ${alerta.id}');
        return alerta;
      } else {
        throw Exception('Formato de respuesta inválido al crear alerta');
      }
    } catch (e) {
      print('❌ SimpleDataService: Error creating alert: $e');
      rethrow;
    }
  }

  // Método para actualizar alerta
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
      print('🚨 SimpleDataService: Updating alert $id...');

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

        print('✅ SimpleDataService: Alert updated successfully');
        return alerta;
      } else {
        throw Exception('Formato de respuesta inválido al actualizar alerta');
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
      
        /// Método para obtener gestantes con filtrado por madrina
        Future<List<SimpleGestante>> obtenerGestantesPorMadrina(String madrinaId) async {
          try {
            print('🤰 SimpleDataService: Obteniendo gestantes de la madrina $madrinaId...');
            
            // Intentar endpoint específico de madrina
            try {
              final response = await _apiService.get('/gestantes/madrina/$madrinaId');
              final gestantes = parseGestantesResponse(response);
              print('✅ SimpleDataService: ${gestantes.length} gestantes de la madrina cargadas (endpoint específico)');
              return gestantes;
            } catch (e) {
              print('⚠️ SimpleDataService: Endpoint específico falló, intentando método alternativo: $e');
              
              // Método alternativo: obtener todas y filtrar
              final response = await _apiService.get('/gestantes');
              final todasGestantes = parseGestantesResponse(response);
              
              // Filtrar manualmente por las relaciones
              final gestantesMadrina = todasGestantes
                  .where((g) => g.tieneAccesoMadrina(madrinaId))
                  .toList();
                  
              print('✅ SimpleDataService: ${gestantesMadrina.length} gestantes de la madrina cargadas (filtrado manual)');
              return gestantesMadrina;
            }
          } catch (e) {
            print('❌ SimpleDataService: Error obteniendo gestantes de la madrina: $e');
            rethrow;
          }
        }
      
        /// Método para verificar si una madrina tiene acceso a una gestante
        Future<bool> verificarAccesoMadrina(String gestanteId, String madrinaId) async {
          try {
            print('🔐 SimpleDataService: Verificando acceso de la madrina $madrinaId a la gestante $gestanteId...');
            
            // Usar el servicio de permisos si está disponible
            if (_permissionService != null) {
              return await _permissionService!.tienePermisoSobreGestante(gestanteId, 'ver');
            }
            
            // Verificación local si no hay servicio de permisos
            final response = await _apiService.get('/gestantes/$gestanteId');
            if (response.data != null) {
              final gestante = SimpleGestante.fromJson(response.data as Map<String, dynamic>);
              final tieneAcceso = gestante.tieneAccesoMadrina(madrinaId);
              print('🔐 SimpleDataService: Acceso verificado localmente: $tieneAcceso');
              return tieneAcceso;
            }
            
            return false;
          } catch (e) {
            print('❌ SimpleDataService: Error verificando acceso: $e');
            return false;
          }
        }
      
        /// Método para asignar una gestante a una madrina
        Future<bool> asignarGestanteAMadrina({
          required String gestanteId,
          required String madrinaId,
          String? asignadoPor,
        }) async {
          try {
            print('🔐 SimpleDataService: Asignando gestante $gestanteId a la madrina $madrinaId...');
            
            // Usar el servicio de permisos si está disponible
            if (_permissionService != null) {
              return await _permissionService!.asignarGestanteAMadrina(
                gestanteId: gestanteId,
                madrinaId: madrinaId,
                asignadoPor: asignadoPor,
              );
            }
            
            // Asignación directa si no hay servicio de permisos
            final response = await _apiService.post('/gestantes/$gestanteId/asignar', data: {
              'madrina_id': madrinaId,
              'asignado_por': asignadoPor,
            });
            
            if (response.data != null && response.data['success'] == true) {
              print('✅ SimpleDataService: Gestante asignada exitosamente');
              return true;
            } else {
              print('❌ SimpleDataService: Error en respuesta del backend');
              return false;
            }
          } catch (e) {
            print('❌ SimpleDataService: Error asignando gestante: $e');
            return false;
          }
        }
      
      }
    } catch (e) {
      print('❌ SimpleDataService: Error updating alert: $e');
      rethrow;
    }
  }

}
