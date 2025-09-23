import 'package:dio/dio.dart';
import '../models/gestante_model.dart';
import 'api_service.dart';
import 'location_service.dart';
import 'offline_service.dart';
import 'notification_service.dart';

class ControlPrenatalService {
  final ApiService _apiService;
  final LocationService _locationService;
  final OfflineService _offlineService;
  final NotificationService _notificationService;
  
  ControlPrenatalService({
    required ApiService apiService,
    required LocationService locationService,
    required OfflineService offlineService,
    required NotificationService notificationService,
  }) : _apiService = apiService,
       _locationService = locationService,
       _offlineService = offlineService,
       _notificationService = notificationService;
  
  // Obtener controles prenatales
  Future<List<ControlPrenatalModel>> obtenerControles({
    String? gestanteId,
    String? medicoId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (gestanteId != null) queryParams['gestanteId'] = gestanteId;
      if (medicoId != null) queryParams['medicoId'] = medicoId;
      if (fechaInicio != null) queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      if (fechaFin != null) queryParams['fechaFin'] = fechaFin.toIso8601String();
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      
      final response = await _apiService.get('/controles-prenatales', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> controlesData = response.data['data'];
        return controlesData.map((json) => ControlPrenatalModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener controles');
      }
    } catch (e) {
      // Intentar obtener datos offline
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        return await _offlineService.getOfflineControles(gestanteId: gestanteId);
      }
      rethrow;
    }
  }
  
  // Obtener control por ID
  Future<ControlPrenatalModel> obtenerControlPorId(String id) async {
    try {
      final response = await _apiService.get('/controles-prenatales/$id');
      
      if (response.data['success'] == true) {
        return ControlPrenatalModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener control');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Crear nuevo control prenatal
  Future<ControlPrenatalModel> crearControl(ControlPrenatalModel control) async {
    try {
      final controlData = control.toJson();
      
      // Obtener ubicación actual automáticamente
      final ubicacion = await _locationService.getCurrentLocation();
      if (ubicacion != null) {
        controlData['ubicacionLatitud'] = ubicacion.latitude;
        controlData['ubicacionLongitud'] = ubicacion.longitude;
      }
      
      final response = await _apiService.post('/controles-prenatales', data: controlData);
      
      if (response.data['success'] == true) {
        final nuevoControl = ControlPrenatalModel.fromJson(response.data['data']);
        
        // Verificar si se generaron alertas automáticamente
        await _verificarAlertas(nuevoControl);
        
        // Programar próximo control si se especificó
        if (nuevoControl.proximoControl != null) {
          await _programarRecordatorioProximoControl(nuevoControl);
        }
        
        return nuevoControl;
      } else {
        throw Exception(response.data['message'] ?? 'Error al crear control');
      }
    } catch (e) {
      // Si no hay conectividad, guardar offline
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineControl(control);
        
        // Verificar alertas offline
        await _verificarAlertasOffline(control);
        
        return control;
      }
      rethrow;
    }
  }
  
  // Actualizar control prenatal
  Future<ControlPrenatalModel> actualizarControl(String id, ControlPrenatalModel control) async {
    try {
      final response = await _apiService.put('/controles-prenatales/$id', data: control.toJson());
      
      if (response.data['success'] == true) {
        final controlActualizado = ControlPrenatalModel.fromJson(response.data['data']);
        
        // Verificar alertas después de la actualización
        await _verificarAlertas(controlActualizado);
        
        return controlActualizado;
      } else {
        throw Exception(response.data['message'] ?? 'Error al actualizar control');
      }
    } catch (e) {
      // Si no hay conectividad, guardar offline
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('controles_update', {
          'id': id,
          'data': control.toJson(),
        });
        return control;
      }
      rethrow;
    }
  }
  
  // Eliminar control prenatal
  Future<bool> eliminarControl(String id) async {
    try {
      final response = await _apiService.delete('/controles-prenatales/$id');
      
      if (response.data['success'] == true) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Error al eliminar control');
      }
    } catch (e) {
      // Si no hay conectividad, marcar para eliminación offline
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('controles_delete', {'id': id});
        return true;
      }
      rethrow;
    }
  }
  
  // Obtener controles por ubicación
  Future<List<ControlPrenatalModel>> obtenerControlesPorUbicacion({
    required double latitud,
    required double longitud,
    required double radioKm,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      final queryParams = {
        'latitud': latitud,
        'longitud': longitud,
        'radio': radioKm,
        if (fechaInicio != null) 'fechaInicio': fechaInicio.toIso8601String(),
        if (fechaFin != null) 'fechaFin': fechaFin.toIso8601String(),
      };
      
      final response = await _apiService.get('/controles-prenatales/ubicacion', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> controlesData = response.data['data'];
        return controlesData.map((json) => ControlPrenatalModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al buscar controles por ubicación');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Obtener estadísticas de controles
  Future<Map<String, dynamic>> obtenerEstadisticasControles({
    String? gestanteId,
    String? medicoId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (gestanteId != null) queryParams['gestanteId'] = gestanteId;
      if (medicoId != null) queryParams['medicoId'] = medicoId;
      if (fechaInicio != null) queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      if (fechaFin != null) queryParams['fechaFin'] = fechaFin.toIso8601String();
      
      final response = await _apiService.get('/controles-prenatales/estadisticas', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener estadísticas');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Verificar controles vencidos
  Future<List<Map<String, dynamic>>> verificarControlesVencidos() async {
    try {
      final response = await _apiService.get('/controles-prenatales/vencidos');
      
      if (response.data['success'] == true) {
        final List<dynamic> controlesVencidos = response.data['data'];
        
        // Enviar notificaciones para controles vencidos
        for (final control in controlesVencidos) {
          await _notificationService.showMedicalAlert(
            title: 'Control Prenatal Vencido',
            message: 'La gestante ${control['gestante']['nombre']} tiene un control vencido',
            priority: 'MEDIA',
            gestanteId: control['gestanteId'],
          );
        }
        
        return List<Map<String, dynamic>>.from(controlesVencidos);
      } else {
        throw Exception(response.data['message'] ?? 'Error al verificar controles vencidos');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Generar reporte de controles
  Future<Map<String, dynamic>> generarReporteControles({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? formato = 'PDF',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'formato': formato,
      };
      if (fechaInicio != null) queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      if (fechaFin != null) queryParams['fechaFin'] = fechaFin.toIso8601String();
      
      final response = await _apiService.get('/controles-prenatales/reporte', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Error al generar reporte');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Verificar alertas automáticamente después de crear/actualizar control
  Future<void> _verificarAlertas(ControlPrenatalModel control) async {
    try {
      final alertas = <Map<String, dynamic>>[];
      
      // Verificar presión arterial alta
      if (control.tienePresionAlta) {
        alertas.add({
          'gestanteId': control.gestanteId,
          'controlId': control.id,
          'tipoAlerta': 'PRESION_ALTA',
          'nivelPrioridad': control.presionSistolica! >= 160 || control.presionDiastolica! >= 110 ? 'CRITICA' : 'ALTA',
          'mensaje': 'Presión arterial elevada: ${control.presionSistolica}/${control.presionDiastolica} mmHg',
          'ubicacionLatitud': control.ubicacionLatitud,
          'ubicacionLongitud': control.ubicacionLongitud,
        });
      }
      
      // Verificar presión arterial baja
      if (control.tienePresionBaja) {
        alertas.add({
          'gestanteId': control.gestanteId,
          'controlId': control.id,
          'tipoAlerta': 'PRESION_BAJA',
          'nivelPrioridad': 'MEDIA',
          'mensaje': 'Presión arterial baja: ${control.presionSistolica}/${control.presionDiastolica} mmHg',
          'ubicacionLatitud': control.ubicacionLatitud,
          'ubicacionLongitud': control.ubicacionLongitud,
        });
      }
      
      // Verificar fiebre
      if (control.tieneFiebre) {
        alertas.add({
          'gestanteId': control.gestanteId,
          'controlId': control.id,
          'tipoAlerta': 'FIEBRE',
          'nivelPrioridad': control.temperatura! >= 39.0 ? 'ALTA' : 'MEDIA',
          'mensaje': 'Temperatura elevada: ${control.temperatura}°C',
          'ubicacionLatitud': control.ubicacionLatitud,
          'ubicacionLongitud': control.ubicacionLongitud,
        });
      }
      
      // Crear alertas en el backend
      for (final alerta in alertas) {
        await _apiService.post('/alertas', data: alerta);
        
        // Enviar notificación inmediata para alertas críticas
        if (alerta['nivelPrioridad'] == 'CRITICA') {
          await _notificationService.showMedicalAlert(
            title: 'Alerta Médica Crítica',
            message: alerta['mensaje'],
            priority: 'CRITICA',
            gestanteId: alerta['gestanteId'],
          );
        }
      }
    } catch (e) {
      print('Error verificando alertas: $e');
    }
  }
  
  // Verificar alertas offline
  Future<void> _verificarAlertasOffline(ControlPrenatalModel control) async {
    try {
      final alertas = <Map<String, dynamic>>[];
      
      if (control.tienePresionAlta) {
        alertas.add({
          'gestanteId': control.gestanteId,
          'controlId': control.id,
          'tipoAlerta': 'PRESION_ALTA',
          'nivelPrioridad': 'ALTA',
          'mensaje': 'Presión arterial elevada (offline)',
          'offline': true,
        });
      }
      
      if (control.tieneFiebre) {
        alertas.add({
          'gestanteId': control.gestanteId,
          'controlId': control.id,
          'tipoAlerta': 'FIEBRE',
          'nivelPrioridad': 'MEDIA',
          'mensaje': 'Temperatura elevada (offline)',
          'offline': true,
        });
      }
      
      // Guardar alertas offline para sincronizar después
      for (final alerta in alertas) {
        await _offlineService.saveOfflineData('alertas', alerta);
        
        // Mostrar notificación local
        await _notificationService.showNotification(
          title: 'Alerta Médica (Offline)',
          body: alerta['mensaje'],
        );
      }
    } catch (e) {
      print('Error verificando alertas offline: $e');
    }
  }
  
  // Programar recordatorio para próximo control
  Future<void> _programarRecordatorioProximoControl(ControlPrenatalModel control) async {
    try {
      if (control.proximoControl != null) {
        final notificationId = '${control.gestanteId}_proximo_control'.hashCode;
        
        await _notificationService.scheduleNotification(
          id: notificationId,
          title: 'Próximo Control Prenatal',
          body: 'Tienes un control prenatal programado para mañana',
          scheduledDate: control.proximoControl!.subtract(const Duration(days: 1)),
          payload: {
            'type': 'proximo_control',
            'gestanteId': control.gestanteId,
            'fechaControl': control.proximoControl!.toIso8601String(),
          },
        );
      }
    } catch (e) {
      print('Error programando recordatorio: $e');
    }
  }
  
  // Sincronizar controles offline
  Future<void> sincronizarControlesOffline() async {
    try {
      await _offlineService.syncPendingData();
    } catch (e) {
      print('Error sincronizando controles offline: $e');
    }
  }
  
  // Validar datos del control antes de enviar
  bool validarControl(ControlPrenatalModel control) {
    // Validaciones básicas
    if (control.gestanteId.isEmpty) return false;
    if (control.semanasGestacion < 0 || control.semanasGestacion > 42) return false;
    
    // Validar rangos de signos vitales
    if (control.presionSistolica != null && 
        (control.presionSistolica! < 70 || control.presionSistolica! > 250)) return false;
    
    if (control.presionDiastolica != null && 
        (control.presionDiastolica! < 40 || control.presionDiastolica! > 150)) return false;
    
    if (control.frecuenciaCardiaca != null && 
        (control.frecuenciaCardiaca! < 40 || control.frecuenciaCardiaca! > 200)) return false;
    
    if (control.temperatura != null && 
        (control.temperatura! < 35.0 || control.temperatura! > 45.0)) return false;
    
    if (control.peso != null && 
        (control.peso! < 30.0 || control.peso! > 200.0)) return false;
    
    return true;
  }
}