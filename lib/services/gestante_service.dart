import 'package:dio/dio.dart';
import '../models/gestante_model.dart';
import '../models/usuario_model.dart';
import 'api_service.dart';
import 'location_service.dart';
import 'offline_service.dart';
import 'notification_service.dart';

class GestanteService {
  final ApiService _apiService;
  final LocationService _locationService;
  final OfflineService _offlineService;
  final NotificationService _notificationService;
  
  GestanteService({
    required ApiService apiService,
    required LocationService locationService,
    required OfflineService offlineService,
    required NotificationService notificationService,
  }) : _apiService = apiService,
       _locationService = locationService,
       _offlineService = offlineService,
       _notificationService = notificationService;
  
  // Obtener todas las gestantes
  Future<List<GestanteModel>> obtenerGestantes({
    int? page,
    int? limit,
    String? search,
    bool? altoRiesgo,
    String? departamento,
    String? municipio,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (altoRiesgo != null) queryParams['altoRiesgo'] = altoRiesgo;
      if (departamento != null) queryParams['departamento'] = departamento;
      if (municipio != null) queryParams['municipio'] = municipio;
      
      final response = await _apiService.get('/gestantes', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> gestantesData = response.data['data'];
        final gestantes = gestantesData.map((json) => GestanteModel.fromJson(json)).toList();
        
        // Cachear gestantes para uso offline
        await _offlineService.cacheGestantes(gestantes);
        
        return gestantes;
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener gestantes');
      }
    } catch (e) {
      // Si hay error de conectividad, intentar obtener datos offline
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        return await _offlineService.getOfflineGestantes();
      }
      rethrow;
    }
  }
  
  // Obtener gestante por ID
  Future<GestanteModel> obtenerGestantePorId(String id) async {
    try {
      final response = await _apiService.get('/gestantes/$id');
      
      if (response.data['success'] == true) {
        return GestanteModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener gestante');
      }
    } catch (e) {
      // Intentar obtener de cache offline
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        final gestantesOffline = await _offlineService.getOfflineGestantes();
        final gestante = gestantesOffline.where((g) => g.id == id).firstOrNull;
        if (gestante != null) return gestante;
      }
      rethrow;
    }
  }
  
  // Crear nueva gestante
  Future<GestanteModel> crearGestante(GestanteModel gestante) async {
    try {
      final gestanteData = gestante.toJson();
      
      // Obtener ubicación actual si está disponible
      final ubicacion = await _locationService.getCurrentLocation();
      if (ubicacion != null) {
        gestanteData['ubicacionRegistro'] = {
          'latitud': ubicacion.latitude,
          'longitud': ubicacion.longitude,
        };
      }
      
      final response = await _apiService.post('/gestantes', data: gestanteData);
      
      if (response.data['success'] == true) {
        final nuevaGestante = GestanteModel.fromJson(response.data['data']);
        
        // Programar recordatorios de controles prenatales
        await _programarRecordatoriosControles(nuevaGestante);
        
        return nuevaGestante;
      } else {
        throw Exception(response.data['message'] ?? 'Error al crear gestante');
      }
    } catch (e) {
      // Si no hay conectividad, guardar offline
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('gestantes', gestante.toJson());
        return gestante;
      }
      rethrow;
    }
  }
  
  // Actualizar gestante
  Future<GestanteModel> actualizarGestante(String id, GestanteModel gestante) async {
    try {
      final response = await _apiService.put('/gestantes/$id', data: gestante.toJson());
      
      if (response.data['success'] == true) {
        final gestanteActualizada = GestanteModel.fromJson(response.data['data']);
        
        // Actualizar recordatorios si cambió información relevante
        await _programarRecordatoriosControles(gestanteActualizada);
        
        return gestanteActualizada;
      } else {
        throw Exception(response.data['message'] ?? 'Error al actualizar gestante');
      }
    } catch (e) {
      // Si no hay conectividad, guardar offline
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('gestantes_update', {
          'id': id,
          'data': gestante.toJson(),
        });
        return gestante;
      }
      rethrow;
    }
  }
  
  // Eliminar gestante
  Future<bool> eliminarGestante(String id) async {
    try {
      final response = await _apiService.delete('/gestantes/$id');
      
      if (response.data['success'] == true) {
        // Cancelar recordatorios programados
        await _notificationService.cancelNotification(id.hashCode);
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Error al eliminar gestante');
      }
    } catch (e) {
      // Si no hay conectividad, marcar para eliminación offline
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('gestantes_delete', {'id': id});
        return true;
      }
      rethrow;
    }
  }
  
  // Buscar gestantes por ubicación
  Future<List<GestanteModel>> buscarGestantesPorUbicacion({
    required double latitud,
    required double longitud,
    required double radioKm,
    bool? altoRiesgo,
  }) async {
    try {
      final queryParams = {
        'latitud': latitud,
        'longitud': longitud,
        'radio': radioKm,
        if (altoRiesgo != null) 'altoRiesgo': altoRiesgo,
      };
      
      final response = await _apiService.get('/gestantes/ubicacion', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> gestantesData = response.data['data'];
        return gestantesData.map((json) => GestanteModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al buscar gestantes por ubicación');
      }
    } catch (e) {
      // Búsqueda offline por ubicación
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        final gestantesOffline = await _offlineService.getOfflineGestantes();
        return gestantesOffline.where((gestante) {
          if (gestante.usuario?.latitud != null && gestante.usuario?.longitud != null) {
            final distancia = _locationService.calculateDistance(
              latitud,
              longitud,
              gestante.usuario!.latitud!,
              gestante.usuario!.longitud!,
            );
            return distancia <= radioKm;
          }
          return false;
        }).toList();
      }
      rethrow;
    }
  }
  
  // Obtener gestantes de alto riesgo
  Future<List<GestanteModel>> obtenerGestantesAltoRiesgo({
    double? latitud,
    double? longitud,
    double? radioKm,
  }) async {
    try {
      final queryParams = <String, dynamic>{'altoRiesgo': true};
      
      if (latitud != null && longitud != null) {
        queryParams['latitud'] = latitud;
        queryParams['longitud'] = longitud;
        if (radioKm != null) queryParams['radio'] = radioKm;
      }
      
      final response = await _apiService.get('/gestantes/alto-riesgo', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> gestantesData = response.data['data'];
        return gestantesData.map((json) => GestanteModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener gestantes de alto riesgo');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        final gestantesOffline = await _offlineService.getOfflineGestantes();
        return gestantesOffline.where((g) => g.embarazoAltoRiesgo).toList();
      }
      rethrow;
    }
  }
  
  // Obtener estadísticas de gestantes
  Future<Map<String, dynamic>> obtenerEstadisticasGestantes({
    String? departamento,
    String? municipio,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (departamento != null) queryParams['departamento'] = departamento;
      if (municipio != null) queryParams['municipio'] = municipio;
      if (fechaInicio != null) queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      if (fechaFin != null) queryParams['fechaFin'] = fechaFin.toIso8601String();
      
      final response = await _apiService.get('/gestantes/estadisticas', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener estadísticas');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        // Calcular estadísticas básicas offline
        final gestantesOffline = await _offlineService.getOfflineGestantes();
        return {
          'total': gestantesOffline.length,
          'altoRiesgo': gestantesOffline.where((g) => g.embarazoAltoRiesgo).length,
          'activas': gestantesOffline.where((g) => g.activo).length,
        };
      }
      rethrow;
    }
  }
  
  // Programar recordatorios de controles prenatales
  Future<void> _programarRecordatoriosControles(GestanteModel gestante) async {
    try {
      // Calcular fechas de controles según semanas de gestación
      final semanasGestacion = gestante.semanasGestacion;
      final proximosControles = _calcularProximosControles(semanasGestacion, gestante.fechaUltimaMenstruacion);
      
      for (int i = 0; i < proximosControles.length; i++) {
        final fechaControl = proximosControles[i];
        final notificationId = '${gestante.id}_control_$i'.hashCode;
        
        await _notificationService.scheduleNotification(
          id: notificationId,
          title: 'Recordatorio de Control Prenatal',
          body: 'Es hora de tu control prenatal. Semana ${semanasGestacion + (i + 1) * 4}',
          scheduledDate: fechaControl.subtract(const Duration(days: 1)), // Recordar 1 día antes
          payload: {
            'type': 'control_prenatal',
            'gestanteId': gestante.id,
            'fechaControl': fechaControl.toIso8601String(),
          },
        );
      }
    } catch (e) {
      print('Error programando recordatorios: $e');
    }
  }
  
  // Calcular próximos controles prenatales
  List<DateTime> _calcularProximosControles(int semanasActuales, DateTime fechaUltimaMenstruacion) {
    final controles = <DateTime>[];
    final controlesRecomendados = [8, 12, 16, 20, 24, 28, 32, 36, 38, 40]; // Semanas recomendadas
    
    for (final semana in controlesRecomendados) {
      if (semana > semanasActuales) {
        final fechaControl = fechaUltimaMenstruacion.add(Duration(days: semana * 7));
        if (fechaControl.isAfter(DateTime.now())) {
          controles.add(fechaControl);
        }
      }
    }
    
    return controles;
  }
  
  // Sincronizar datos offline
  Future<void> sincronizarDatosOffline() async {
    try {
      await _offlineService.syncPendingData();
    } catch (e) {
      print('Error sincronizando datos offline: $e');
    }
  }
  
  // Verificar gestantes que requieren atención
  Future<List<GestanteModel>> verificarGestantesAtencion() async {
    try {
      final response = await _apiService.get('/gestantes/requieren-atencion');
      
      if (response.data['success'] == true) {
        final List<dynamic> gestantesData = response.data['data'];
        final gestantes = gestantesData.map((json) => GestanteModel.fromJson(json)).toList();
        
        // Enviar notificaciones para gestantes que requieren atención urgente
        for (final gestante in gestantes) {
          if (gestante.embarazoAltoRiesgo) {
            await _notificationService.showMedicalAlert(
              title: 'Atención Requerida',
              message: 'La gestante ${gestante.nombreCompleto} requiere atención médica',
              priority: 'ALTA',
              gestanteId: gestante.id,
            );
          }
        }
        
        return gestantes;
      } else {
        throw Exception(response.data['message'] ?? 'Error al verificar gestantes');
      }
    } catch (e) {
      rethrow;
    }
  }
}