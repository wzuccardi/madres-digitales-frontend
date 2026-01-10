// Placeholder para ControlService
import 'package:madres_digitales_flutter_new/domain/entities/control.dart';
import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import 'sync_service.dart';
import 'package:madres_digitales_flutter_new/core/network/websocket_service.dart';

class ControlService {
  ControlService({ApiService? apiService, SyncService? syncService, WebSocketService? webSocketService})
      : _api = apiService ?? ApiService(),
        _sync = syncService ?? SyncService(),
        _ws = webSocketService ?? WebSocketService();
  final ApiService _api;
  final SyncService _sync;
  final WebSocketService _ws;

  Future<List<Control>> getControles() async {
    final resp = await _api.get<Map<String, dynamic>>('/api/controles');
    if (!resp.success || resp.data == null) return [];
    final data = resp.data as dynamic;
    List<dynamic> controlesData = [];
    if (data is Map && data['data'] != null && data['data'] is Map) {
      final inner = data['data'] as Map<String, dynamic>;
      final list = inner['controles'];
      if (list is List) controlesData = list;
    } else if (data is Map && data['controles'] is List) {
      controlesData = data['controles'] as List<dynamic>;
    } else if (data is List) {
      controlesData = data;
    }
    return controlesData.map((j) => _toEntity(j as Map<String, dynamic>)).toList();
  }

  Future<List<Control>> obtenerControles() async => getControles();
  Future<List<Control>> obtenerControlesVencidos() async => [];
  Future<List<Control>> obtenerControlesPendientes() async => [];

  Future<bool> createControl(Map<String, dynamic> control) async {
    try {
      final resp = await _api.post<Map<String, dynamic>>('/api/controles', data: control);
      if (resp.success) {
        await _ws.emit('control:created', control);
      }
      return resp.success;
    } catch (e) {
      await _sync.markForSync('controles_create', control);
      return false;
    }
  }
  Future<bool> createControlWithEvaluation(Map<String, dynamic> control) async {
    try {
      final resp = await _api.post<Map<String, dynamic>>(
        '/alertas-automaticas/controles/con-evaluacion',
        data: control,
      );
      if (resp.success) {
        await _ws.emit('control:created', control);
      }
      return resp.success;
    } catch (e) {
      await _sync.markForSync('controles_create_eval', control);
      return false;
    }
  }
  Future<bool> updateControl(String id, Map<String, dynamic> control) async {
    try {
      final resp = await _api.put<Map<String, dynamic>>('/api/controles/$id', data: control);
      if (resp.success) {
        await _ws.emit('control:updated', {'id': id, ...control});
      }
      return resp.success;
    } catch (e) {
      await _sync.markForSync('controles_update', {'id': id, ...control});
      return false;
    }
  }
  Future<bool> deleteControl(String id) async {
    try {
      final resp = await _api.delete<Map<String, dynamic>>('/api/controles/$id');
      if (resp.success) {
        await _ws.emit('control:deleted', {'id': id});
      }
      return resp.success;
    } catch (e) {
      await _sync.markForSync('controles_delete', {'id': id});
      return false;
    }
  }
  Future<bool> crearControl(Map<String, dynamic> control) async => createControl(control);
  Future<bool> crearControlConEvaluacion(Map<String, dynamic> control) async => createControlWithEvaluation(control);
  Future<bool> actualizarControl(String id, Map<String, dynamic> control) async => updateControl(id, control);

  Control _toEntity(Map<String, dynamic> json) {
    return Control(
      id: (json['id'] ?? '').toString(),
      gestanteId: json['gestante_id']?.toString(),
      fecha: _parseDate(json['fecha_control']),
      tipo: json['tipo']?.toString(),
      estado: json['estado']?.toString(),
      semanasGestacion: _parseInt(json['semanas_gestacion']),
      peso: _parseDouble(json['peso']),
      presionSistolica: _parseInt(json['presion_sistolica']),
      presionDiastolica: _parseInt(json['presion_diastolica']),
      alturaUterina: _parseDouble(json['altura_uterina']),
      frecuenciaCardiaca: _parseInt(json['frecuencia_cardiaca']),
      temperatura: _parseDouble(json['temperatura']),
      observaciones: json['observaciones']?.toString(),
      recomendaciones: json['recomendaciones']?.toString(),
      fechaProgramada: _parseDate(json['fecha_programada']),
      gestanteNombre: json['gestante_nombre']?.toString(),
    );
  }
  DateTime? _parseDate(dynamic v) {
    if (v is String) {
      try { return DateTime.parse(v); } catch (_) { return null; }
    }
    return null;
  }
  int? _parseInt(dynamic v) => v is int ? v : (v is String ? int.tryParse(v) : null);
  double? _parseDouble(dynamic v) => v is double ? v : (v is num ? v.toDouble() : (v is String ? double.tryParse(v) : null));
}
