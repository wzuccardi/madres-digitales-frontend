import 'package:madres_digitales_flutter_new/core/network/api_service.dart';

class DashboardService {
  DashboardService([ApiService? api]) : _api = api ?? ApiService();
  final ApiService _api;

  Future<Map<String, dynamic>> getDashboardData() async {
    final resp = await _api.get<Map<String, dynamic>>('/dashboard');
    if (!resp.success || resp.data == null) return <String, dynamic>{};
    final root = resp.data as Map<String, dynamic>;
    return root['data'] is Map<String, dynamic> ? root['data'] as Map<String, dynamic> : root;
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final resp = await _api.get<Map<String, dynamic>>('/dashboard/statistics');
    if (!resp.success || resp.data == null) return <String, dynamic>{};
    final root = resp.data as Map<String, dynamic>;
    return root['data'] is Map<String, dynamic> ? root['data'] as Map<String, dynamic> : root;
  }
}