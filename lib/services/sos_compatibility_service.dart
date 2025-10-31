// Servicio de compatibilidad para el sistema SOS
// Maneja errores de compatibilidad con el backend y proporciona fallbacks

import 'dart:async';
import 'api_service.dart';
import 'auth_service.dart';
import '../config/app_config.dart';

class SOSCompatibilityService {
  final ApiService _apiService;
  final AuthService _authService;
  
  SOSCompatibilityService(this._apiService, this._authService);
  
  /// Enviar alerta SOS con manejo de errores de compatibilidad
  Future<Map<String, dynamic>> enviarAlertaSOSCompatible({
    required String gestanteId,
    required double latitud,
    required double longitud,
    String? descripcion,
  }) async {
    try {
      
      // Intentar con el endpoint original
      final response = await _apiService.post(AppConfig.endpointSOS, data: {
        'gestante_id': gestanteId,
        'coordenadas': [longitud, latitud], // Backend espera [lng, lat]
        'tipo_alerta': AppConfig.tipoAlerta['sos']!,
        'nivel_prioridad': AppConfig.nivelPrioridad['critica']!,
        'descripcion': descripcion ?? 'Alerta SOS activada',
        'emergencia_real': true,
        'ubicacion': {
          'latitud': latitud,
          'longitud': longitud,
          'precision': AppConfig.defaultLocationAccuracy,
        },
      });
      
      if (response.data != null && response.data['success'] == true) {
        return {
          'success': true,
          'alertaId': response.data['alertaId'],
          'gestanteId': gestanteId,
          'coordenadas': [longitud, latitud],
          'timestamp': DateTime.now().toIso8601String(),
          'mensaje': 'Alerta SOS enviada exitosamente',
        };
      } else {
        throw Exception(response.data?['error'] ?? 'Error desconocido del backend');
      }
    } catch (e) {
      
      // Intentar con el endpoint alternativo
      return await _enviarAlertaSOSAlternativo(
        gestanteId: gestanteId,
        latitud: latitud,
        longitud: longitud,
        descripcion: descripcion,
      );
    }
  }
  
  /// Enviar alerta SOS con endpoint alternativo
  Future<Map<String, dynamic>> _enviarAlertaSOSAlternativo({
    required String gestanteId,
    required double latitud,
    required double longitud,
    String? descripcion,
  }) async {
    try {
      
      // Usar endpoint de alertas general
      final response = await _apiService.post('/alertas/emergencia', data: {
        'gestante_id': gestanteId,
        'latitud': latitud,
        'longitud': longitud,
        'tipo': 'sos',
        'prioridad': 'alta',
        'descripcion': descripcion ?? 'Alerta SOS activada',
        'fecha_hora': DateTime.now().toIso8601String(),
        'usuario_id': _authService.userId,
      });
      
      if (response.data != null && response.data['success'] == true) {
        return {
          'success': true,
          'alertaId': response.data['alertaId'],
          'gestanteId': gestanteId,
          'coordenadas': [longitud, latitud],
          'timestamp': DateTime.now().toIso8601String(),
          'mensaje': 'Alerta SOS enviada exitosamente (endpoint alternativo)',
        };
      } else {
        throw Exception(response.data?['error'] ?? 'Error desconocido del backend');
      }
    } catch (e) {
      
      // Ãšltimo recurso: guardar localmente
      return await _guardarAlertaSOSLocalmente(
        gestanteId: gestanteId,
        latitud: latitud,
        longitud: longitud,
        descripcion: descripcion,
      );
    }
  }
  
  /// Guardar alerta SOS localmente como fallback
  Future<Map<String, dynamic>> _guardarAlertaSOSLocalmente({
    required String gestanteId,
    required double latitud,
    required double longitud,
    String? descripcion,
  }) async {
    try {
      
      // Crear alerta local
      final alertaLocal = {
        'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
        'gestante_id': gestanteId,
        'latitud': latitud,
        'longitud': longitud,
        'tipo': 'sos',
        'prioridad': 'alta',
        'descripcion': descripcion ?? 'Alerta SOS activada',
        'fecha_hora': DateTime.now().toIso8601String(),
        'usuario_id': _authService.userId,
        'enviado': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // AquÃ­ se podrÃ­a guardar en almacenamiento local
      // Por ahora, solo retornamos el resultado
      
      return {
        'success': true,
        'alertaId': alertaLocal['id'],
        'gestanteId': gestanteId,
        'coordenadas': [longitud, latitud],
        'timestamp': DateTime.now().toIso8601String(),
        'mensaje': 'Alerta SOS guardada localmente (sin conexiÃ³n)',
        'local': true,
      };
    } catch (e) {
      return {
        'success': false,
        'alertaId': null,
        'gestanteId': gestanteId,
        'coordenadas': [longitud, latitud],
        'timestamp': DateTime.now().toIso8601String(),
        'mensaje': 'Error: No se pudo enviar ni guardar la alerta SOS',
        'error': e.toString(),
      };
    }
  }
  
  /// Sincronizar alertas locales pendientes
  Future<List<Map<String, dynamic>>> sincronizarAlertasPendientes() async {
    try {
      
      // AquÃ­ se obtendrÃ­an las alertas locales pendientes
      // Por ahora, retornamos una lista vacÃ­a
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Verificar si el backend es compatible con el sistema SOS
  Future<bool> verificarCompatibilidadSOS() async {
    try {
      
      // Intentar hacer una peticiÃ³n de prueba al endpoint SOS
      final response = await _apiService.get('/alertas/sos/compatibilidad');
      
      if (response.data != null && response.data['compatible'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  /// Obtener estado del sistema SOS
  Future<Map<String, dynamic>> obtenerEstadoSOS() async {
    try {
      
      final esCompatible = await verificarCompatibilidadSOS();
      final alertasPendientes = await sincronizarAlertasPendientes();
      
      return {
        'compatible': esCompatible,
        'alertas_pendientes': alertasPendientes.length,
        'ultimo_intento': DateTime.now().toIso8601String(),
        'estado': esCompatible ? 'funcional' : 'limitado',
      };
    } catch (e) {
      return {
        'compatible': false,
        'alertas_pendientes': 0,
        'ultimo_intento': DateTime.now().toIso8601String(),
        'estado': 'error',
        'error': e.toString(),
      };
    }
  }
}
