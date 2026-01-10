import '../../core/network/websocket_service.dart';
import '../services/cache_service.dart';
import '../../core/network/api_service.dart';

import '../../domain/entities/sos_alert.dart';
import '../../domain/entities/sos_location.dart';
import '../../domain/entities/sos_statistics.dart';
import '../../domain/repositories/sos_repository.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/utils/app_logger.dart';

class SOSRepositoryImpl implements SOSRepository {

  SOSRepositoryImpl(
    this._apiService,
    this._webSocketService,
    this._cacheService,
  );
  final ApiService _apiService;
  final WebSocketService _webSocketService;
  final CacheService _cacheService;

  @override
  Future<SOSAlert> enviarAlertaSOS(EnviarSOSParams params) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/alertas/sos',
        data: {
          'gestanteId': params.gestanteId,
          'gestanteNombre': params.gestanteNombre,
          'madrinaId': params.madrinaId,
          'madrinaNombre': params.madrinaNombre,
          'latitud': params.latitud,
          'longitud': params.longitud,
          'descripcion': params.descripcion,
          'fechaHora': DateTime.now().toIso8601String(),
          'estado': SOSAlertStatus.activa.toString(),
          'nivelPrioridad': params.nivelPrioridad.toString(),
          'metadata': params.metadata,
        },
      );

      if (!response.success || response.data == null) {
        throw const ServerError('Error enviando alerta SOS');
      }

      final sosAlert = SOSAlert.fromJson(response.data as Map<String, dynamic>);
      
      // Guardar en caché
      await _cacheService.set('sos_alert_${sosAlert.id}', sosAlert.toJson());
      
      // Notificar via WebSocket para actualización en tiempo real
      await _webSocketService.emit('nueva_alerta_sos', sosAlert.toJson());
      
      AppLogger.info('Alerta SOS enviada: ${sosAlert.id}');
      
      return sosAlert;
    } catch (e) {
      AppLogger.error('Error enviando alerta SOS: $e');
      throw SOSFailure('Error enviando alerta SOS: $e');
    }
  }

  @override
  Future<List<SOSAlert>> obtenerAlertasActivas() async {
    try {
      final cachedAlerts = await _getCachedActiveAlerts();
      if (cachedAlerts.isNotEmpty) {
        AppLogger.info('Alertas activas obtenidas desde caché: ${cachedAlerts.length}');
        return cachedAlerts;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        '/alertas/sos/activas',
      );

      if (!response.success || response.data == null) {
        throw const ServerError('Error obteniendo alertas activas');
      }

      final root = response.data as Map<String, dynamic>;
      final List<dynamic> data = root['alertas'] ?? [];
      final alerts = data.map((json) => SOSAlert.fromJson(json as Map<String, dynamic>)).toList();
      await _cacheService.set('active_sos_alerts', {
        'alerts': alerts.map((a) => a.toJson()).toList(),
      });
      
      AppLogger.info('Alertas activas obtenidas desde API: ${alerts.length}');
      
      return alerts;
    } catch (e) {
      AppLogger.error('Error obteniendo alertas activas: $e');
      final cachedAlerts = await _getCachedActiveAlerts();
      if (cachedAlerts.isNotEmpty) {
        AppLogger.info('Alertas activas obtenidas desde caché offline tras error: ${cachedAlerts.length}');
        return cachedAlerts;
      }
      throw SOSFailure('Error obteniendo alertas activas: $e');
    }
  }

  @override
  Future<List<SOSAlert>> obtenerHistorialAlertas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? gestanteId,
    String? madrinaId,
    SOSAlertStatus? estado,
    SOSPriority? prioridad,
    int? limite,
    int? pagina,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (fechaInicio != null) {
        queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      }
      
      if (fechaFin != null) {
        queryParams['fechaFin'] = fechaFin.toIso8601String();
      }
      
      if (gestanteId != null) {
        queryParams['gestanteId'] = gestanteId;
      }
      
      if (madrinaId != null) {
        queryParams['madrinaId'] = madrinaId;
      }
      
      if (estado != null) {
        queryParams['estado'] = estado.toString();
      }
      
      if (prioridad != null) {
        queryParams['prioridad'] = prioridad.toString();
      }
      
      if (limite != null) {
        queryParams['limite'] = limite;
      }
      
      if (pagina != null) {
        queryParams['pagina'] = pagina;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        '/alertas/sos/historial',
        queryParameters: queryParams,
      );

      if (!response.success || response.data == null) {
        throw const ServerError('Error obteniendo historial de alertas');
      }

      final root = response.data as Map<String, dynamic>;
      final List<dynamic> data = root['alertas'] ?? [];
      final alerts = data.map((json) => SOSAlert.fromJson(json as Map<String, dynamic>)).toList();
      
      AppLogger.info('Historial de alertas obtenido: ${alerts.length}');
      
      return alerts;
    } catch (e) {
      AppLogger.error('Error obteniendo historial de alertas: $e');
      throw SOSFailure('Error obteniendo historial de alertas: $e');
    }
  }

  @override
  Future<SOSAlert?> obtenerAlertaPorId(String alertaId) async {
    try {
      // Intentar obtener desde caché primero
      final cachedAlert = await _getCachedAlertById(alertaId);
      if (cachedAlert != null) {
        AppLogger.info('Alerta obtenida desde caché: $alertaId');
        return cachedAlert;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        '/alertas/sos/$alertaId',
      );

      if (!response.success || response.data == null) {
        throw const ServerError('Error obteniendo alerta por ID');
      }

      final alert = SOSAlert.fromJson(response.data as Map<String, dynamic>);
      
      // Actualizar caché
      await _cacheService.set('sos_alert_$alertaId', alert.toJson());
      
      AppLogger.info('Alerta obtenida desde API: $alertaId');
      
      return alert;
    } catch (e) {
      AppLogger.error('Error obteniendo alerta por ID: $e');
      throw SOSFailure('Error obteniendo alerta por ID: $e');
    }
  }

  @override
  Future<SOSAlert> actualizarEstadoAlerta(
    String alertaId,
    SOSAlertStatus nuevoEstado, {
    String? atendidoPor,
    String? motivoCancelacion,
  }) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/alertas/sos/$alertaId/estado',
        data: {
          'estado': nuevoEstado.toString(),
          if (atendidoPor != null) 'atendidoPor': atendidoPor,
          if (motivoCancelacion != null) 'motivoCancelacion': motivoCancelacion,
          'fechaActualizacion': DateTime.now().toIso8601String(),
        },
      );

      if (!response.success || response.data == null) {
        throw const ServerError('Error actualizando estado de alerta');
      }

      final alert = SOSAlert.fromJson(response.data as Map<String, dynamic>);
      
      // Actualizar caché
      await _cacheService.set('sos_alert_$alertaId', alert.toJson());
      
      // Notificar via WebSocket para actualización en tiempo real
      await _webSocketService.emit('actualizacion_alerta_sos', {
        'alertaId': alertaId,
        'nuevoEstado': nuevoEstado.toString(),
        'alerta': alert.toJson(),
      });
      
      AppLogger.info('Estado de alerta actualizado: $alertaId -> $nuevoEstado');
      
      return alert;
    } catch (e) {
      AppLogger.error('Error actualizando estado de alerta: $e');
      throw SOSFailure('Error actualizando estado de alerta: $e');
    }
  }

  @override
  Future<void> cancelarAlerta(String alertaId, String motivo) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/alertas/sos/$alertaId/cancelar',
        data: {
          'motivo': motivo,
          'fechaCancelacion': DateTime.now().toIso8601String(),
        },
      );

      if (!response.success) {
        throw const ServerError('Error cancelando alerta');
      }

      // Actualizar caché
      final cachedAlert = await _getCachedAlertById(alertaId);
      if (cachedAlert != null) {
        final updatedAlert = cachedAlert.copyWith(
          estado: SOSAlertStatus.cancelada,
        );
        await _cacheService.set('sos_alert_$alertaId', updatedAlert.toJson());
      }
      
      // Notificar via WebSocket para actualización en tiempo real
      await _webSocketService.emit('alerta_cancelada_sos', {
        'alertaId': alertaId,
        'motivo': motivo,
      });
      
      AppLogger.info('Alerta cancelada: $alertaId');
    } catch (e) {
      AppLogger.error('Error cancelando alerta: $e');
      throw SOSFailure('Error cancelando alerta: $e');
    }
  }

  @override
  Future<SOSAlert> marcarAlertaComoAtendida(String alertaId, String atendidoPor) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/alertas/sos/$alertaId/atender',
        data: {
          'atendidoPor': atendidoPor,
          'fechaAtencion': DateTime.now().toIso8601String(),
        },
      );

      if (!response.success || response.data == null) {
        throw const ServerError('Error marcando alerta como atendida');
      }

      final alert = SOSAlert.fromJson(response.data as Map<String, dynamic>);
      
      // Actualizar caché
      final cachedAlert = await _getCachedAlertById(alertaId);
      if (cachedAlert != null) {
        final updatedAlert = cachedAlert.copyWith(
          estado: SOSAlertStatus.atendida,
        );
        await _cacheService.set('sos_alert_$alertaId', updatedAlert.toJson());
      }
      
      // Notificar via WebSocket para actualización en tiempo real
      await _webSocketService.emit('alerta_atendida_sos', {
        'alertaId': alertaId,
        'atendidoPor': atendidoPor,
        'alerta': alert.toJson(),
      });
      
      AppLogger.info('Alerta marcada como atendida: $alertaId');
      
      return alert;
    } catch (e) {
      AppLogger.error('Error marcando alerta como atendida: $e');
      throw SOSFailure('Error marcando alerta como atendida: $e');
    }
  }

  @override
  Future<SOSAlert> marcarAlertaComoFalsaAlarma(String alertaId, String motivo) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/alertas/sos/$alertaId/falsa_alarma',
        data: {
          'motivo': motivo,
          'fechaCancelacion': DateTime.now().toIso8601String(),
        },
      );

      if (!response.success || response.data == null) {
        throw const ServerError('Error marcando alerta como falsa alarma');
      }

      final alert = SOSAlert.fromJson(response.data as Map<String, dynamic>);
      
      // Actualizar caché
      final cachedAlert = await _getCachedAlertById(alertaId);
      if (cachedAlert != null) {
        final updatedAlert = cachedAlert.copyWith(
          estado: SOSAlertStatus.falsaAlarma,
        );
        await _cacheService.set('sos_alert_$alertaId', updatedAlert.toJson());
      }
      
      // Notificar via WebSocket para actualización en tiempo real
      await _webSocketService.emit('alerta_falsa_alarma_sos', {
        'alertaId': alertaId,
        'motivo': motivo,
        'alerta': alert.toJson(),
      });
      
      AppLogger.info('Alerta marcada como falsa alarma: $alertaId');
      
      return alert;
    } catch (e) {
      AppLogger.error('Error marcando alerta como falsa alarma: $e');
      throw SOSFailure('Error marcando alerta como falsa alarma: $e');
    }
  }

  @override
  Future<List<SOSLocation>> obtenerUbicacionesAlertas({
    String? alertaId,
    String? gestanteId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? limite,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (alertaId != null) {
        queryParams['alertaId'] = alertaId;
      }
      
      if (gestanteId != null) {
        queryParams['gestanteId'] = gestanteId;
      }
      
      if (fechaInicio != null) {
        queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      }
      
      if (fechaFin != null) {
        queryParams['fechaFin'] = fechaFin.toIso8601String();
      }
      
      if (limite != null) {
        queryParams['limite'] = limite;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        '/alertas/sos/ubicaciones',
        queryParameters: queryParams,
      );

      if (!response.success || response.data == null) {
        throw const ServerError('Error obteniendo ubicaciones de alertas');
      }

      final root = response.data as Map<String, dynamic>;
      final List<dynamic> data = root['ubicaciones'] ?? [];
      final locations = data.map((json) => SOSLocation.fromJson(json as Map<String, dynamic>)).toList();
      
      AppLogger.info('Ubicaciones de alertas obtenidas: ${locations.length}');
      
      return locations;
    } catch (e) {
      AppLogger.error('Error obteniendo ubicaciones de alertas: $e');
      throw SOSFailure('Error obteniendo ubicaciones de alertas: $e');
    }
  }

  @override
  Future<SOSStatistics> obtenerEstadisticasSOS({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? municipioId,
    String? madrinaId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (fechaInicio != null) {
        queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      }
      
      if (fechaFin != null) {
        queryParams['fechaFin'] = fechaFin.toIso8601String();
      }
      
      if (municipioId != null) {
        queryParams['municipioId'] = municipioId;
      }
      
      if (madrinaId != null) {
        queryParams['madrinaId'] = madrinaId;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/alertas/sos/estadisticas',
        queryParameters: queryParams,
      );

      if (!response.success || response.data == null) {
        throw const ServerError('Error obteniendo estadísticas de SOS');
      }

      final statistics = SOSStatistics.fromJson(response.data as Map<String, dynamic>);
      
      AppLogger.info('Estadísticas de SOS obtenidas');
      
      return statistics;
    } catch (e) {
      AppLogger.error('Error obteniendo estadísticas de SOS: $e');
      throw SOSFailure('Error obteniendo estadísticas de SOS: $e');
    }
  }

  @override
  Stream<List<SOSAlert>> observarAlertasActivas() {
    return _webSocketService.stream('alertas_sos_activas').map(
      (data) => (data as List).map((json) => SOSAlert.fromJson(json as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Stream<SOSAlert> observarAlerta(String alertaId) {
    return _webSocketService.stream('alerta_sos_$alertaId').map(
      (data) => SOSAlert.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Stream<SOSStatistics> observarEstadisticasSOS() {
    return _webSocketService.stream('estadisticas_sos').map(
      (data) => SOSStatistics.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<List<SOSAlert>> buscarAlertas({
    String? query,
    String? gestanteId,
    String? madrinaId,
    SOSAlertStatus? estado,
    SOSPriority? prioridad,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? limite,
    int? pagina,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }
      
      if (gestanteId != null) {
        queryParams['gestanteId'] = gestanteId;
      }
      
      if (madrinaId != null) {
        queryParams['madrinaId'] = madrinaId;
      }
      
      if (estado != null) {
        queryParams['estado'] = estado.toString();
      }
      
      if (prioridad != null) {
        queryParams['prioridad'] = prioridad.toString();
      }
      
      if (fechaInicio != null) {
        queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      }
      
      if (fechaFin != null) {
        queryParams['fechaFin'] = fechaFin.toIso8601String();
      }
      
      if (limite != null) {
        queryParams['limite'] = limite;
      }
      
      if (pagina != null) {
        queryParams['pagina'] = pagina;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        '/alertas/sos/buscar',
        queryParameters: queryParams,
      );

      if (!response.success || response.data == null) {
        throw const ServerError('Error buscando alertas');
      }

      final root = response.data as Map<String, dynamic>;
      final List<dynamic> data = root['alertas'] ?? [];
      final alerts = data.map((json) => SOSAlert.fromJson(json as Map<String, dynamic>)).toList();
      
      AppLogger.info('Alertas encontradas: ${alerts.length}');
      
      return alerts;
    } catch (e) {
      AppLogger.error('Error buscando alertas: $e');
      throw SOSFailure('Error buscando alertas: $e');
    }
  }

  @override
  Future<List<SOSAlert>> obtenerAlertasCercanas({
    required double latitud,
    required double longitud,
    double radioKm = 5.0,
    int? limite,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'latitud': latitud,
        'longitud': longitud,
        'radioKm': radioKm,
      };
      
      if (limite != null) {
        queryParams['limite'] = limite;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        '/alertas/sos/cercanas',
        queryParameters: queryParams,
      );

      if (!response.success || response.data == null) {
        throw const ServerError('Error obteniendo alertas cercanas');
      }

      final root = response.data as Map<String, dynamic>;
      final List<dynamic> data = root['alertas'] ?? [];
      final alerts = data.map((json) => SOSAlert.fromJson(json as Map<String, dynamic>)).toList();
      
      AppLogger.info('Alertas cercanas obtenidas: ${alerts.length}');
      
      return alerts;
    } catch (e) {
      AppLogger.error('Error obteniendo alertas cercanas: $e');
      throw SOSFailure('Error obteniendo alertas cercanas: $e');
    }
  }

  @override
  Future<String> exportarAlertas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? formato = 'csv',
    List<String>? campos,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'formato': formato,
      };
      
      if (fechaInicio != null) {
        queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      }
      
      if (fechaFin != null) {
        queryParams['fechaFin'] = fechaFin.toIso8601String();
      }
      
      if (campos != null && campos.isNotEmpty) {
        queryParams['campos'] = campos.join(',');
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        '/alertas/sos/exportar',
        queryParameters: queryParams,
      );

      if (!response.success || response.data == null) {
        throw const ServerError('Error exportando alertas');
      }

      final root = response.data as Map<String, dynamic>;
      final exportData = root['datos'] as String;
      
      AppLogger.info('Alertas exportadas en formato $formato');
      
      return exportData;
    } catch (e) {
      AppLogger.error('Error exportando alertas: $e');
      throw SOSFailure('Error exportando alertas: $e');
    }
  }

  // Métodos auxiliares para manejo de caché
  Future<List<SOSAlert>> _getCachedActiveAlerts() async {
    try {
      final cachedData = await _cacheService.get('active_sos_alerts');
      if (cachedData == null) return [];
      
      final List<dynamic> data = cachedData['alerts'] ?? [];
      return data.map((json) => SOSAlert.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.error('Error obteniendo alertas activas desde caché: $e');
      return [];
    }
  }

  Future<SOSAlert?> _getCachedAlertById(String alertaId) async {
    try {
      final cachedData = await _cacheService.get('sos_alert_$alertaId');
      if (cachedData == null) return null;
      
      return SOSAlert.fromJson(cachedData);
    } catch (e) {
      AppLogger.error('Error obteniendo alerta desde caché: $e');
      return null;
    }
  }
}

// Excepción específica para errores de SOS
class SOSFailure extends AppError {
  const SOSFailure(super.message, {super.code});
  
  @override
  String toString() => 'SOSFailure: $message';
}
