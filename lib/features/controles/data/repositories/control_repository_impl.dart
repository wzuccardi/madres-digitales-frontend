import '../models/control_model.dart';
import 'package:dio/dio.dart';
import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import 'package:madres_digitales_flutter_new/data/services/cache_service.dart';
import 'package:madres_digitales_flutter_new/config/app_config.dart';

class ControlRepositoryImpl {
  ControlRepositoryImpl(this.dio)
      : _api = null,
        _cache = CacheService();
  ControlRepositoryImpl.fromApiService(ApiService api)
      : _api = api,
        dio = api.dioInstance,
        _cache = CacheService();
  final Dio dio;
  final ApiService? _api;
  final CacheService _cache;

  Future<List<ControlModel>> fetchControles() async {
    List<dynamic> controlesData = [];
    if (_api != null) {
      final resp = await _api!.get<dynamic>('/api/controles');
      final fromList = _api!.extractList(resp.data);
      if (fromList.isNotEmpty) {
        controlesData = fromList;
      } else {
        final root = _api!.extractObject(resp.data);
        if (root['controles'] is List) {
          controlesData = List<dynamic>.from(root['controles']);
        }
      }
      await _cache.setList('controles_list', controlesData);
      await _cache.set('controles_list_meta', {'ts': DateTime.now().toIso8601String()});
    } else {
      final response = await dio.get('/api/controles');
      if (response.data is Map && response.data['data'] != null) {
        final dataMap = response.data['data'];
        if (dataMap is Map && dataMap['controles'] != null) {
          final controlesValue = dataMap['controles'];
          if (controlesValue is List) {
            controlesData = controlesValue;
          }
        }
      } else if (response.data is List) {
        controlesData = response.data;
      }
    }
    if (controlesData.isEmpty) {
      final meta = await _cache.get('controles_list_meta');
      final tsString = meta?['ts'] as String?;
      final ts = tsString != null ? DateTime.tryParse(tsString) : null;
      final isFresh = ts != null && DateTime.now().difference(ts) <= AppConfig.getCacheDuration();
      final cached = await _cache.getList('controles_list') ?? const [];
      if (cached.isNotEmpty && isFresh) {
        controlesData = cached;
      }
    }
    return controlesData.map((json) => ControlModel.fromJson(json)).toList();
  }

  Future<ControlModel> createControl(Map<String, dynamic> data) async {
    if (_api != null) {
      final resp = await _api!.post<Map<String, dynamic>>('/api/controles', data: data);
      final obj = _api!.extractObject(resp.data);
      return ControlModel.fromJson(obj);
    }
    final response = await dio.post('/api/controles', data: data);
    return ControlModel.fromJson(response.data);
  }
}
