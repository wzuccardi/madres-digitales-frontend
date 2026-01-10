import 'package:dio/dio.dart';
import '../../core/network/api_service.dart';
import '../../domain/entities/alerta.dart';
import '../../core/utils/logger.dart';

class AlertaServiceSimple {
  AlertaServiceSimple(this._api);
  final ApiService _api;

  Future<List<Alerta>> getAlertas() async {
    AppLogger.debug('AlertaServiceSimple: Iniciando petición GET /alertas');
    // Obtener el token actual para debugging
    final token = await _api.getCurrentToken();
    AppLogger.debug('AlertaServiceSimple: Token actual', context: {'present': token != null});
    if (token != null) {
      AppLogger.debug('AlertaServiceSimple: Token preview', context: {'preview': token.substring(0, token.length > 20 ? 20 : token.length)});
    }
    
    final resp = await _api.get<dynamic>('/api/alertas', 
      options: Options(
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      ),
    );
    AppLogger.debug('AlertaServiceSimple: Respuesta recibida', context: {'status': resp.statusCode, 'success': resp.success});
    AppLogger.debug('AlertaServiceSimple: Data cruda', context: {'data': resp.data});
    
    final data = _api.extractData(resp.data);
    AppLogger.debug('AlertaServiceSimple: Data extraída', context: {'data': data});
    
    // Intentar diferentes estructuras de datos que el backend podría devolver
    List<dynamic> raw = [];
    
    if (data is Map<String, dynamic>) {
      if (data['alertas'] is List) {
        raw = List<dynamic>.from(data['alertas'] as List);
      } else if (data['data'] is Map<String, dynamic> && data['data']['alertas'] is List) {
        raw = List<dynamic>.from(data['data']['alertas'] as List);
      } else if (data['data'] is List) {
        raw = List<dynamic>.from(data['data'] as List);
      }
    } else if (data is List) {
      raw = data;
    }
    
    AppLogger.debug('AlertaServiceSimple: Lista cruda de alertas', context: {'raw': raw});
    
    final List<Alerta> list = [];
    for (var i = 0; i < raw.length; i++) {
      try {
        final alerta = Alerta.fromJson(raw[i] as Map<String, dynamic>);
        list.add(alerta);
      } catch (e) {
        AppLogger.warning('AlertaServiceSimple: Error parseando alerta', context: {'index': i, 'error': e.toString()});
        // Skip invalid alertas
        continue;
      }
    }
    
    AppLogger.debug('AlertaServiceSimple: Alertas parseadas exitosamente', context: {'count': list.length});
    return list;
  }

  Future<Alerta> getAlertaById(String id) async {
    final resp = await _api.get<dynamic>('/api/alertas/$id');
    final body = _api.extractObject(resp.data);
    return Alerta.fromJson(body);
  }

  Future<Alerta> createAlerta(Alerta alerta) async {
    final payload = {
      'gestante_id': alerta.gestanteId,
      'tipo_alerta': alerta.tipoAlerta.toString().split('.').last,
      'nivel_prioridad': alerta.nivelPrioridad.toString().split('.').last,
      'mensaje': alerta.descripcion,
    };
    final resp = await _api.post<dynamic>('/api/alertas', data: payload);
    final body = _api.extractObject(resp.data);
    return Alerta.fromJson(body);
  }

  Future<Alerta> updateAlerta(String id, Alerta alerta) async {
    final payload = {
      'gestante_id': alerta.gestanteId,
      'tipo_alerta': alerta.tipoAlerta.toString().split('.').last,
      'nivel_prioridad': alerta.nivelPrioridad.toString().split('.').last,
      'mensaje': alerta.descripcion,
    };
    final resp = await _api.put<dynamic>('/api/alertas/$id', data: payload);
    final body = _api.extractObject(resp.data);
    return Alerta.fromJson(body);
  }

  Future<bool> deleteAlerta(String id) async {
    final resp = await _api.delete<dynamic>('/api/alertas/$id');
    final code = resp.statusCode ?? 0;
    if (code == 200 || code == 204 || resp.success) return true;
    return false;
  }

  Future<Alerta> resolverAlerta(String id) async {
    final resp = await _api.put<dynamic>('/api/alertas/$id/resolver');
    final body = _api.extractObject(resp.data);
    return Alerta.fromJson(body);
  }

  Future<Alerta> marcarComoLeida(String id) async {
    final resp = await _api.put<dynamic>('/api/alertas/$id/leida');
    final body = _api.extractObject(resp.data);
    return Alerta.fromJson(body);
  }

  // Alias methods for consistency with existing codebase
  Future<List<Alerta>> obtenerAlertas() => getAlertas();
  Future<Alerta> obtenerAlertaPorId(String id) => getAlertaById(id);
  Future<Alerta> crearAlerta(Alerta a) => createAlerta(a);
  Future<Alerta> actualizarAlerta(String id, Alerta a) => updateAlerta(id, a);
  Future<bool> eliminarAlerta(String id) => deleteAlerta(id);
}
