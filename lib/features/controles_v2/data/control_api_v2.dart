import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import '../domain/control_dto.dart';
import 'control_mapper_v2.dart';
import 'package:uuid/uuid.dart';

class ControlApiV2 {
  ControlApiV2({ApiService? api}) : _api = api ?? ApiService();
  final ApiService _api;

  Future<List<ControlDto>> fetchControles() async {
    final resp = await _api.get<Map<String, dynamic>>('/api/controles');
    final data = _api.extractData(resp.data);
    List<dynamic> list = [];
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      final inner = data['controles'];
      if (inner is List) list = inner;
    }
    return list
        .whereType<Map<String, dynamic>>()
        .map((j) => mapJsonToDto(j))
        .toList();
  }

  Future<bool> createControl(Map<String, dynamic> payload, {bool evaluar = false}) async {
    if (!payload.containsKey('id') || (payload['id']?.toString().isEmpty ?? true)) {
      payload['id'] = const Uuid().v4();
    }
    final path = evaluar
        ? '/api/alertas-automaticas/controles/con-evaluacion'
        : '/api/controles';
    final resp = await _api.post<Map<String, dynamic>>(path, data: payload);
    return resp.success;
  }
}
