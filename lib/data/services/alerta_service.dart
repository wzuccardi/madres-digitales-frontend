import 'package:madres_digitales_flutter_new/domain/entities/alerta.dart';
import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import 'package:madres_digitales_flutter_new/core/exceptions/exceptions.dart';
import 'package:madres_digitales_flutter_new/core/network/websocket_service.dart';
import 'package:madres_digitales_flutter_new/data/services/cache_service.dart';

class AlertaException extends AppException {
  const AlertaException(super.message, {super.code});
}

class AlertaService {
  AlertaService(this._apiService, [CacheService? cacheService, WebSocketService? webSocketService])
      : _cacheService = cacheService ?? CacheService(),
        _webSocketService = webSocketService ?? WebSocketService();
  final ApiService _apiService;
  final CacheService _cacheService;
  final WebSocketService _webSocketService;
  
  static const List<String> tiposAlerta = [
    'sintomas_criticos',
    'emergencia_obstetrica',
    'hipertension',
    'preeclampsia',
    'sepsis',
    'hemorragia',
    'parto_prematuro',
    'control_vencido',
  ];
  
  static const List<String> nivelesPrioridad = [
    'critica', 'alta', 'media', 'baja',
  ];
  
  static const List<String> sintomasComunes = [
    'dolor_abdominal',
    'sangrado',
    'presion_alta',
    'mareo',
    'desmayo',
    'fiebre',
    'vomito',
    'cefalea',
  ];
  
  
  Future<List<Alerta>> getActiveAlertas() async {
    try {
      // Primero intentar obtener desde caché
      final cachedAlertas = await _cacheService.getCachedAlertas();
      if (cachedAlertas != null && cachedAlertas.isNotEmpty) {
        return cachedAlertas;
      }
      
      // Si no hay en caché, obtener del servidor
      final response = await _apiService.get<Map<String, dynamic>>('/api/alertas');
      if (response.success) {
        final list = _apiService.extractList(response.data);
        final alertas = list.map((json) => Alerta.fromJson(json)).toList();
        
        // Guardar en caché para futuras consultas
        await _cacheService.cacheAlertas(alertas);
        return alertas;
      } else {
        throw const AlertaException('Failed to load alertas');
      }
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (e) {
      throw const AlertaException('Failed to load alertas');
    }
  }

  Future<List<Alerta>> _getAlertasByPath(String path) async {
    final response = await _apiService.get<Map<String, dynamic>>(path);
    if (!response.success || response.data == null) {
      throw const AlertaException('Failed to load alertas');
    }
    final list = _apiService.extractList(response.data);
    return list.map((json) => Alerta.fromJson(json)).toList();
  }
  
  Future<Alerta> crearAlertaConEvaluacion({
    required String gestanteId,
    required String tipoAlerta,
    required String nivelPrioridad,
    required String mensaje,
    List<String>? sintomas,
    double? latitud,
    double? longitud,
    Map<String, num>? signos,
    bool evaluarAutomaticamente = true,
    bool sobrescribirConAutomatica = true,
  }) async {
    try {
      final payload = {
        'gestante_id': gestanteId,
        'tipo_alerta': tipoAlerta,
        'nivel_prioridad': nivelPrioridad,
        'mensaje': mensaje,
        if (sintomas != null) 'sintomas': sintomas,
        if (latitud != null && longitud != null) 'coordenadas_alerta': [longitud, latitud],
        if (signos != null) ...{
          if (signos['presion_sistolica'] != null) 'presion_sistolica': signos['presion_sistolica'],
          if (signos['presion_diastolica'] != null) 'presion_diastolica': signos['presion_diastolica'],
          if (signos['frecuencia_cardiaca'] != null) 'frecuencia_cardiaca': signos['frecuencia_cardiaca'],
          if (signos['temperatura'] != null) 'temperatura': signos['temperatura'],
          if (signos['frecuencia_respiratoria'] != null) 'frecuencia_respiratoria': signos['frecuencia_respiratoria'],
          if (signos['semanas_gestacion'] != null) 'semanas_gestacion': signos['semanas_gestacion'],
        },
        'evaluar_automaticamente': evaluarAutomaticamente,
        'sobrescribir_con_automatica': sobrescribirConAutomatica,
      };
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/alertas-automaticas/alertas/con-evaluacion',
        data: payload,
      );
      if (response.success && response.data != null) {
        final data = (response.data!['data'] as Map<String, dynamic>);
        final alertaJson = (data['alerta_manual'] ?? data['resultado'] ?? data);
        final alerta = Alerta.fromJson((alertaJson as Map<String, dynamic>).cast<String, dynamic>());
        await _cacheService.cacheAlerta(alerta);
        await _webSocketService.emit('alerta:created', alerta.toJson());
        return alerta;
      }
      throw const AlertaException('Failed to create alerta con evaluación');
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (_) {
      throw const AlertaException('Failed to create alerta con evaluación');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerGestantesDisponibles() async {
    try {
      final resp = await _apiService.get<Map<String, dynamic>>('/api/gestantes');
      if (!resp.success || resp.data == null) return [];
      final root = resp.data!;
      final list = (root['data'] is List)
          ? (root['data'] as List)
          : (root['gestantes'] as List?) ?? [];
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        return {
          'id': (m['id'] ?? '').toString(),
          'nombre': ('${m['nombre'] ?? ''} ${m['apellido'] ?? ''}').trim(),
          'documento': (m['documento'] ?? '').toString(),
        };
      }).toList();
    } catch (e) {
      throw const AlertaException('Failed to load gestantes');
    }
  }

  Future<Alerta> crearAlerta({
    required String gestanteId,
    required String tipoAlerta,
    required String nivelPrioridad,
    required String mensaje,
    List<String>? sintomas,
    String? descripcionDetallada,
    double? latitud,
    double? longitud,
  }) async {
    try {
      final payload = {
        'gestante_id': gestanteId,
        'tipo_alerta': tipoAlerta,
        'nivel_prioridad': nivelPrioridad,
        'mensaje': descripcionDetallada != null && descripcionDetallada.isNotEmpty
            ? '$mensaje\n\n$descripcionDetallada'
            : mensaje,
        if (sintomas != null) 'sintomas': sintomas,
        if (latitud != null && longitud != null) 'coordenadas_alerta': [longitud, latitud],
      };
      final response = await _apiService.post<Map<String, dynamic>>('/api/alertas', data: payload);
      if (response.success && response.data != null) {
        final alerta = Alerta.fromJson((response.data!['data'] as Map<String, dynamic>)
            .cast<String, dynamic>());
        await _cacheService.cacheAlerta(alerta);
        await _webSocketService.emit('alerta:created', alerta.toJson());
        return alerta;
      }
      throw const AlertaException('Failed to create alerta');
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (_) {
      throw const AlertaException('Failed to create alerta');
    }
  }
  
  Future<List<Alerta>> getAlertasByGestante(String gestanteId) async {
    try {
      return await _getAlertasByPath('/api/alertas/gestante/$gestanteId');
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (_) {
      throw const AlertaException('Failed to load alertas by gestante');
    }
  }
  
  Future<List<Alerta>> getAlertasByMadrina(String madrinaId) async {
    try {
      return await _getAlertasByPath('/api/alertas/madrina/$madrinaId');
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (_) {
      throw const AlertaException('Failed to load alertas by madrina');
    }
  }
  
  Future<Alerta> createAlerta(Alerta alerta) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>('/api/alertas', data: alerta.toJson());
      if (response.success) {
        final createdAlerta = Alerta.fromJson(response.data!['data']);
        
        // Guardar en caché
        await _cacheService.cacheAlerta(createdAlerta);
        
        // Enviar notificación vía WebSocket
        await _webSocketService.emit('alerta:created', createdAlerta.toJson());
        
        return createdAlerta;
      } else {
        throw const AlertaException('Failed to create alerta');
      }
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (e) {
      throw const AlertaException('Failed to create alerta');
    }
  }
  
  Future<Alerta> updateAlertaStatus(String id, AlertaEstado estado) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>('/api/alertas/$id/status', data: {
        'estado': estado.toString().split('.').last,
      });
      if (response.success) {
        final updatedAlerta = Alerta.fromJson(response.data!['data']);
        
        // Actualizar caché
        await _cacheService.updateAlertaStatus(id, estado);
        
        // Enviar notificación vía WebSocket
        await _webSocketService.emit('alerta:status', updatedAlerta.toJson());
        
        return updatedAlerta;
      } else {
        throw const AlertaException('Failed to update alerta status');
      }
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (e) {
      throw const AlertaException('Failed to update alerta status');
    }
  }
  
  Future<void> deleteAlerta(String id) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>('/api/alertas/$id');
      if (response.success) {
        // Eliminar de caché
        await _cacheService.deleteCachedAlerta(id);
        
        // Enviar notificación vía WebSocket
        await _webSocketService.emit('alerta:deleted', {'id': id});
      } else {
        throw const AlertaException('Failed to delete alerta');
      }
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (e) {
      throw const AlertaException('Failed to delete alerta');
    }
  }

  Future<void> eliminarAlerta(String id) async {
    await deleteAlerta(id);
  }

  Future<void> enviarAlertaSOS({
    required String gestanteId,
    String mensaje = '',
    String? nivel,
    double? latitude,
    double? longitude,
    double? accuracy,
  }) async {
    try {
      final payload = {
        'gestante_id': gestanteId,
        if (mensaje.isNotEmpty) 'mensaje': mensaje,
        if (nivel != null) 'nivel': nivel,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (accuracy != null) 'accuracy': accuracy,
      };
      final response = await _apiService.post<Map<String, dynamic>>('/api/alertas/emergencia', data: payload);
      if (!response.success) {
        throw const AlertaException('Failed to send SOS alert');
      }
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (_) {
      throw const AlertaException('Failed to send SOS alert');
    }
  }
  
  Future<List<Alerta>> getAlertasByTipo(AlertaTipo tipo) async {
    try {
      final p = '/api/alertas/tipo/${tipo.toString().split('.').last}';
      return await _getAlertasByPath(p);
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (_) {
      throw const AlertaException('Failed to load alertas by tipo');
    }
  }
  
  Future<List<Alerta>> getAlertasByNivel(AlertaNivel nivel) async {
    try {
      final p = '/api/alertas/nivel/${nivel.toString().split('.').last}';
      return await _getAlertasByPath(p);
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (_) {
      throw const AlertaException('Failed to load alertas by nivel');
    }
  }
  
  Future<List<Alerta>> getAlertasByEstado(AlertaEstado estado) async {
    try {
      final p = '/api/alertas/estado/${estado.toString().split('.').last}';
      return await _getAlertasByPath(p);
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (_) {
      throw const AlertaException('Failed to load alertas by estado');
    }
  }
  
  Future<List<Alerta>> getAlertasByRangoFecha(DateTime inicio, DateTime fin) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/api/alertas/rango', queryParameters: {
        'inicio': inicio.toIso8601String(),
        'fin': fin.toIso8601String(),
      });
      if (!response.success || response.data == null) {
        throw const AlertaException('Failed to load alertas by date range');
      }
      final list = _apiService.extractList(response.data);
      return list.map((json) => Alerta.fromJson(json)).toList();
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (_) {
      throw const AlertaException('Failed to load alertas by date range');
    }
  }
  
  Future<Map<String, dynamic>> getEstadisticasAlertas() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/api/alertas/estadisticas');
      if (response.success) {
        return response.data!['data'] as Map<String, dynamic>;
      } else {
        throw const AlertaException('Failed to load alertas estadisticas');
      }
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (e) {
      throw const AlertaException('Failed to load alertas estadisticas');
    }
  }
  
  Future<void> asignarAlertaMadrina(String alertaId, String madrinaId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>('/api/alertas/$alertaId/asignar', data: {
        'madrinaId': madrinaId,
      });
      if (response.success) {
        final updatedAlerta = Alerta.fromJson(response.data!['data']);
        
        // Actualizar caché
        await _cacheService.updateAlertaMadrina(alertaId, madrinaId);
        
        // Enviar notificación vía WebSocket
        await _webSocketService.emit('alerta:assigned', updatedAlerta.toJson());
      } else {
        throw const AlertaException('Failed to assign alerta to madrina');
      }
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (e) {
      throw const AlertaException('Failed to assign alerta to madrina');
    }
  }
  
  Future<void> marcarAlertaComoLeida(String alertaId) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>('/api/alertas/$alertaId/leida');
      if (response.success) {
        final updatedAlerta = Alerta.fromJson(response.data!['data']);
        
        // Actualizar caché
        await _cacheService.updateAlertaStatus(alertaId, AlertaEstado.resuelta);
        
        // Enviar notificación vía WebSocket
        await _webSocketService.emit('alerta:read', updatedAlerta.toJson());
      } else {
        throw const AlertaException('Failed to mark alerta as read');
      }
    } on NetworkException catch (e) {
      throw AlertaException(e.message);
    } catch (e) {
      throw const AlertaException('Failed to mark alerta as read');
    }
  }
  
  // Stream para observar cambios en tiempo real
  Stream<List<Alerta>> get alertasStream => _webSocketService.stream<List<Alerta>>('alertas');
  
  // Métodos utilitarios
  Future<bool> hasUnreadAlertas(String userId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/api/alertas/$userId/unread/count');
      if (response.success) {
        return (response.data?['count'] as int? ?? 0) > 0;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  Future<int> getUnreadAlertasCount(String userId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/api/alertas/$userId/unread/count');
      if (response.success) {
        return response.data?['count'] as int? ?? 0;
      } else {
        throw AlertaException(response.message ?? 'Failed to get unread alertas count');
      }
    } on NetworkException catch (e) {
      throw AlertaException('Network error: ${e.message}');
    } catch (e) {
      throw AlertaException('Failed to get unread alertas count: ${e.toString()}');
    }
  }
}
