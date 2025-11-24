import 'package:madres_digitales_flutter_new/core/network/api_service.dart';

class ReporteService {
  ReporteService({ApiService? apiService}) : _api = apiService ?? ApiService();
  final ApiService _api;

  Future<List<dynamic>> getReportes() async {
    final resp = await _api.get<dynamic>('/reportes');
    if (!resp.success) return const [];
    if (resp.data is List) return resp.data as List<dynamic>;
    final root = _api.extractObject(resp.data);
    if (root['reportes'] is List) return List<dynamic>.from(root['reportes'] as List);
    if (root['data'] is List) return List<dynamic>.from(root['data'] as List);
    return const [];
  }

  Future<bool> createReporte(Map<String, dynamic> reporte) async {
    final resp = await _api.post<Map<String, dynamic>>('/reportes', data: reporte);
    return resp.success;
  }

  Future<bool> updateReporte(String id, Map<String, dynamic> reporte) async {
    final resp = await _api.put<Map<String, dynamic>>('/reportes/$id', data: reporte);
    return resp.success;
  }

  Future<bool> deleteReporte(String id) async {
    final resp = await _api.delete<Map<String, dynamic>>('/reportes/$id');
    return resp.success;
  }
}