import 'package:dio/dio.dart';
import '../models/gestante_model.dart';
import 'api_service.dart';
import 'location_service.dart';
import 'offline_service.dart';
import 'notification_service.dart';

class AlertaService {
  final ApiService _apiService;
  final LocationService _locationService;
  final OfflineService _offlineService;
  final NotificationService _notificationService;
  
  AlertaService({
    required ApiService apiService,
    required LocationService locationService,
    required OfflineService offlineService,
    required NotificationService notificationService,
  }) : _apiService = apiService,
       _locationService = locationService,
       _offlineService = offlineService,
       _notificationService = notificationService;
  
  // Obtener todas las alertas
  Future<List<AlertaModel>> obtenerAlertas({
    int? page,
    int? limit,
    String? gestanteId,
    String? tipoAlerta,
    String? nivelPrioridad,
    bool? resuelta,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (gestanteId != null) queryParams['gestanteId'] = gestanteId;
      if (tipoAlerta != null) queryParams['tipoAlerta'] = tipoAlerta;
      if (nivelPrioridad != null) queryParams['nivelPrioridad'] = nivelPrioridad;
      if (resuelta != null) queryParams['resuelta'] = resuelta;
      if (fechaInicio != null) queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      if (fechaFin != null) queryParams['fechaFin'] = fechaFin.toIso8601String();
      
      final response = await _apiService.get('/alertas', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> alertasData = response.data['data'];
        return alertasData.map((json) => AlertaModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener alertas');
      }
    } catch (e) {
      // Intentar obtener alertas offline
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        return await _offlineService.getOfflineAlertas(
          gestanteId: gestanteId,
          resuelta: resuelta,
        );
      }
      rethrow;
    }
  }
  
  // Obtener alerta por ID
  Future<AlertaModel> obtenerAlertaPorId(String id) async {
    try {
      final response = await _apiService.get('/alertas/$id');
      
      if (response.data['success'] == true) {
        return AlertaModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener alerta');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Crear nueva alerta
  Future<AlertaModel> crearAlerta(AlertaModel alerta) async {
    try {
      final alertaData = alerta.toJson();
      
      // Obtener ubicación actual si no se especificó
      if (alerta.ubicacionLatitud == null || alerta.ubicacionLongitud == null) {
        final ubicacion = await _locationService.getCurrentLocation();
        if (ubicacion != null) {
          alertaData['ubicacionLatitud'] = ubicacion.latitude;
          alertaData['ubicacionLongitud'] = ubicacion.longitude;
        }
      }
      
      final response = await _apiService.post('/alertas', data: alertaData);
      
      if (response.data['success'] == true) {
        final nuevaAlerta = AlertaModel.fromJson(response.data['data']);
        
        // Enviar notificación inmediata para alertas críticas
        if (nuevaAlerta.esUrgente) {
          await _enviarNotificacionAlerta(nuevaAlerta);
        }
        
        return nuevaAlerta;
      } else {
        throw Exception(response.data['message'] ?? 'Error al crear alerta');
      }
    } catch (e) {
      // Si no hay conectividad, guardar offline
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('alertas', alerta.toJson());
        
        // Enviar notificación local
        await _enviarNotificacionLocal(alerta);
        
        return alerta;
      }
      rethrow;
    }
  }
  
  // Actualizar alerta
  Future<AlertaModel> actualizarAlerta(String id, AlertaModel alerta) async {
    try {
      final response = await _apiService.put('/alertas/$id', data: alerta.toJson());
      
      if (response.data['success'] == true) {
        final alertaActualizada = AlertaModel.fromJson(response.data['data']);
        
        // Si se resolvió la alerta, enviar notificación de resolución
        if (alertaActualizada.resuelta && !alerta.resuelta) {
          await _notificationService.showNotification(
            title: 'Alerta Resuelta',
            body: 'La alerta "${alertaActualizada.mensaje}" ha sido resuelta',
          );
        }
        
        return alertaActualizada;
      } else {
        throw Exception(response.data['message'] ?? 'Error al actualizar alerta');
      }
    } catch (e) {
      // Si no hay conectividad, guardar offline
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('alertas_update', {
          'id': id,
          'data': alerta.toJson(),
        });
        return alerta;
      }
      rethrow;
    }
  }
  
  // Resolver alerta
  Future<AlertaModel> resolverAlerta(String id, String comentarios) async {
    try {
      final response = await _apiService.put('/alertas/$id/resolver', data: {
        'resolucionComentarios': comentarios,
        'fechaResolucion': DateTime.now().toIso8601String(),
      });
      
      if (response.data['success'] == true) {
        final alertaResuelta = AlertaModel.fromJson(response.data['data']);
        
        // Enviar notificación de resolución
        await _notificationService.showNotification(
          title: 'Alerta Resuelta',
          body: 'La alerta ha sido marcada como resuelta',
        );
        
        return alertaResuelta;
      } else {
        throw Exception(response.data['message'] ?? 'Error al resolver alerta');
      }
    } catch (e) {
      // Si no hay conectividad, guardar offline
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('alertas_resolver', {
          'id': id,
          'comentarios': comentarios,
          'fechaResolucion': DateTime.now().toIso8601String(),
        });
        return AlertaModel(
          id: id,
          gestanteId: '',
          tipoAlerta: '',
          nivelPrioridad: '',
          mensaje: '',
          resuelta: true,
          fechaResolucion: DateTime.now(),
          resolucionComentarios: comentarios,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      rethrow;
    }
  }
  
  // Obtener alertas por ubicación
  Future<List<AlertaModel>> obtenerAlertasPorUbicacion({
    required double latitud,
    required double longitud,
    required double radioKm,
    String? nivelPrioridad,
    bool? resuelta,
  }) async {
    try {
      final queryParams = {
        'latitud': latitud,
        'longitud': longitud,
        'radio': radioKm,
        if (nivelPrioridad != null) 'nivelPrioridad': nivelPrioridad,
        if (resuelta != null) 'resuelta': resuelta,
      };
      
      final response = await _apiService.get('/alertas/ubicacion', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> alertasData = response.data['data'];
        return alertasData.map((json) => AlertaModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al buscar alertas por ubicación');
      }
    } catch (e) {
      // Búsqueda offline por ubicación
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        final alertasOffline = await _offlineService.getOfflineAlertas();
        return alertasOffline.where((alerta) {
          if (alerta.tieneUbicacion) {
            final distancia = _locationService.calculateDistance(
              latitud,
              longitud,
              alerta.ubicacionLatitud!,
              alerta.ubicacionLongitud!,
            );
            return distancia <= radioKm;
          }
          return false;
        }).toList();
      }
      rethrow;
    }
  }
  
  // Obtener alertas críticas
  Future<List<AlertaModel>> obtenerAlertasCriticas({
    double? latitud,
    double? longitud,
    double? radioKm,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'nivelPrioridad': 'CRITICA',
        'resuelta': false,
      };
      
      if (latitud != null && longitud != null) {
        queryParams['latitud'] = latitud;
        queryParams['longitud'] = longitud;
        if (radioKm != null) queryParams['radio'] = radioKm;
      }
      
      final response = await _apiService.get('/alertas/criticas', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> alertasData = response.data['data'];
        final alertasCriticas = alertasData.map((json) => AlertaModel.fromJson(json)).toList();
        
        // Enviar notificaciones para alertas críticas no notificadas
        for (final alerta in alertasCriticas) {
          await _enviarNotificacionAlerta(alerta);
        }
        
        return alertasCriticas;
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener alertas críticas');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        final alertasOffline = await _offlineService.getOfflineAlertas();
        return alertasOffline.where((a) => a.nivelPrioridad == 'CRITICA' && !a.resuelta).toList();
      }
      rethrow;
    }
  }
  
  // Obtener alertas pendientes por gestante
  Future<List<AlertaModel>> obtenerAlertasPendientes(String gestanteId) async {
    try {
      final response = await _apiService.get('/alertas/pendientes/$gestanteId');
      
      if (response.data['success'] == true) {
        final List<dynamic> alertasData = response.data['data'];
        return alertasData.map((json) => AlertaModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener alertas pendientes');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        final alertasOffline = await _offlineService.getOfflineAlertas(gestanteId: gestanteId);
        return alertasOffline.where((a) => !a.resuelta).toList();
      }
      rethrow;
    }
  }
  
  // Generar alerta automática basada en control prenatal
  Future<AlertaModel?> generarAlertaAutomatica({
    required String gestanteId,
    required String controlId,
    required Map<String, dynamic> signosVitales,
  }) async {
    try {
      AlertaModel? alerta;
      
      // Verificar presión arterial alta
      final presionSistolica = signosVitales['presionSistolica'] as int?;
      final presionDiastolica = signosVitales['presionDiastolica'] as int?;
      
      if (presionSistolica != null && presionDiastolica != null) {
        if (presionSistolica >= 140 || presionDiastolica >= 90) {
          final nivelPrioridad = (presionSistolica >= 160 || presionDiastolica >= 110) ? 'CRITICA' : 'ALTA';
          
          alerta = AlertaModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            gestanteId: gestanteId,
            controlId: controlId,
            tipoAlerta: 'PRESION_ALTA',
            nivelPrioridad: nivelPrioridad,
            mensaje: 'Presión arterial elevada: $presionSistolica/$presionDiastolica mmHg',
            descripcionDetallada: 'Se detectó hipertensión arterial durante el control prenatal. Requiere evaluación médica inmediata.',
            resuelta: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }
      
      // Verificar temperatura
      final temperatura = signosVitales['temperatura'] as double?;
      if (temperatura != null && temperatura >= 37.5) {
        final nivelPrioridad = temperatura >= 39.0 ? 'ALTA' : 'MEDIA';
        
        alerta = AlertaModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          gestanteId: gestanteId,
          controlId: controlId,
          tipoAlerta: 'FIEBRE',
          nivelPrioridad: nivelPrioridad,
          mensaje: 'Temperatura elevada: ${temperatura}°C',
          descripcionDetallada: 'Se detectó fiebre durante el control prenatal. Monitorear evolución.',
          resuelta: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      
      // Si se generó una alerta, crearla
      if (alerta != null) {
        return await crearAlerta(alerta);
      }
      
      return null;
    } catch (e) {
      print('Error generando alerta automática: $e');
      return null;
    }
  }
  
  // Obtener estadísticas de alertas
  Future<Map<String, dynamic>> obtenerEstadisticasAlertas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? departamento,
    String? municipio,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fechaInicio != null) queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      if (fechaFin != null) queryParams['fechaFin'] = fechaFin.toIso8601String();
      if (departamento != null) queryParams['departamento'] = departamento;
      if (municipio != null) queryParams['municipio'] = municipio;
      
      final response = await _apiService.get('/alertas/estadisticas', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener estadísticas');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        // Calcular estadísticas básicas offline
        final alertasOffline = await _offlineService.getOfflineAlertas();
        return {
          'total': alertasOffline.length,
          'criticas': alertasOffline.where((a) => a.nivelPrioridad == 'CRITICA').length,
          'pendientes': alertasOffline.where((a) => !a.resuelta).length,
          'resueltas': alertasOffline.where((a) => a.resuelta).length,
        };
      }
      rethrow;
    }
  }
  
  // Monitorear alertas en tiempo real
  Stream<List<AlertaModel>> monitorearAlertas({
    String? gestanteId,
    String? nivelPrioridad,
  }) async* {
    while (true) {
      try {
        final alertas = await obtenerAlertas(
          gestanteId: gestanteId,
          nivelPrioridad: nivelPrioridad,
          resuelta: false,
        );
        yield alertas;
        
        // Esperar 30 segundos antes de la próxima consulta
        await Future.delayed(const Duration(seconds: 30));
      } catch (e) {
        print('Error monitoreando alertas: $e');
        await Future.delayed(const Duration(minutes: 1));
      }
    }
  }
  
  // Enviar notificación para alerta
  Future<void> _enviarNotificacionAlerta(AlertaModel alerta) async {
    try {
      await _notificationService.showMedicalAlert(
        title: _obtenerTituloAlerta(alerta.tipoAlerta),
        message: alerta.mensaje,
        priority: alerta.nivelPrioridad,
        gestanteId: alerta.gestanteId,
      );
    } catch (e) {
      print('Error enviando notificación de alerta: $e');
    }
  }
  
  // Enviar notificación local (offline)
  Future<void> _enviarNotificacionLocal(AlertaModel alerta) async {
    try {
      await _notificationService.showNotification(
        title: '${_obtenerTituloAlerta(alerta.tipoAlerta)} (Offline)',
        body: alerta.mensaje,
      );
    } catch (e) {
      print('Error enviando notificación local: $e');
    }
  }
  
  // Obtener título de alerta según tipo
  String _obtenerTituloAlerta(String tipoAlerta) {
    switch (tipoAlerta) {
      case 'PRESION_ALTA':
        return 'Hipertensión Arterial';
      case 'PRESION_BAJA':
        return 'Hipotensión Arterial';
      case 'FIEBRE':
        return 'Temperatura Elevada';
      case 'PESO_ANORMAL':
        return 'Peso Anormal';
      case 'FRECUENCIA_CARDIACA_ANORMAL':
        return 'Frecuencia Cardíaca Anormal';
      case 'CONTROL_VENCIDO':
        return 'Control Prenatal Vencido';
      case 'EMBARAZO_ALTO_RIESGO':
        return 'Embarazo de Alto Riesgo';
      default:
        return 'Alerta Médica';
    }
  }
  
  // Sincronizar alertas offline
  Future<void> sincronizarAlertasOffline() async {
    try {
      await _offlineService.syncPendingData();
    } catch (e) {
      print('Error sincronizando alertas offline: $e');
    }
  }
  
  // Eliminar alertas antiguas resueltas
  Future<void> limpiarAlertasAntiguas({int diasAntiguedad = 30}) async {
    try {
      final fechaLimite = DateTime.now().subtract(Duration(days: diasAntiguedad));
      
      final response = await _apiService.delete('/alertas/limpiar', queryParams: {
        'fechaLimite': fechaLimite.toIso8601String(),
        'soloResueltas': true,
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Error al limpiar alertas');
      }
    } catch (e) {
      print('Error limpiando alertas antiguas: $e');
    }
  }
}