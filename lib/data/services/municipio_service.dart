import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import 'package:madres_digitales_flutter_new/models/integrated_models.dart';
import 'cache_service.dart';

class MunicipioService {
  MunicipioService([ApiService? api, CacheService? cache])
      : _api = api ?? ApiService(),
        _cache = cache ?? CacheService();
  final ApiService _api;
  final CacheService _cache;

  Future<List<MunicipioIntegrado>> getAllMunicipios() async {
    final resp = await _api.get<dynamic>('/municipios');
    List<dynamic> list = const [];
    if (resp.success && resp.data != null) {
      final payload = resp.data;
      if (payload is List) {
        list = payload;
      } else if (payload is Map<String, dynamic>) {
        list = (payload['data'] is List)
            ? (payload['data'] as List)
            : (payload['municipios'] as List?) ?? [];
      }
    }
    if (list.isEmpty) {
      final retry = await _api.get<dynamic>('/municipios', queryParameters: {'ts': DateTime.now().millisecondsSinceEpoch});
      if (retry.success && retry.data != null) {
        final payload = retry.data;
        if (payload is List) {
          list = payload;
        } else if (payload is Map<String, dynamic>) {
          list = (payload['data'] is List)
              ? (payload['data'] as List)
              : (payload['municipios'] as List?) ?? [];
        }
      }
    }
    if (list.isNotEmpty) {
      final parsed = list.map((j) => _toMunicipio(j as Map<String, dynamic>)).toList();
      await _cache.setList('municipios_list', parsed.map((m) => m.toJson()).toList());
      await _cache.set('municipios_list_meta', {'ts': DateTime.now().toIso8601String()});
      return parsed;
    }
    final cached = await _cache.getList('municipios_list') ?? const [];
    if (cached.isNotEmpty) {
      return cached.map((m) => _toMunicipio(m as Map<String, dynamic>)).toList();
    }
    return const <MunicipioIntegrado>[];
  }

  Future<Map<String, dynamic>> getStats() async {
    final resp = await _api.get<Map<String, dynamic>>('/municipios/stats');
    if (!resp.success || resp.data == null) return <String, dynamic>{};
    final root = resp.data as Map<String, dynamic>;
    return root['data'] is Map<String, dynamic> ? root['data'] as Map<String, dynamic> : root;
  }

  Future<List<MunicipioIntegrado>> getMunicipios({
    int page = 1,
    int limit = 20,
    String? search,
    String? departamento,
    bool? activo,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (departamento != null && departamento.isNotEmpty) 'departamento': departamento,
      if (activo != null) 'activo': activo,
    };
    final resp = await _api.get<dynamic>('/municipios', queryParameters: query);
    List<dynamic> list = const [];
    if (resp.success && resp.data != null) {
      final payload = resp.data;
      if (payload is List) {
        list = payload;
      } else if (payload is Map<String, dynamic>) {
        list = (payload['data'] is List)
            ? (payload['data'] as List)
            : (payload['municipios'] as List?) ?? [];
      }
    }
    if (list.isEmpty) {
      final retryQuery = Map<String, dynamic>.from(query)..['ts'] = DateTime.now().millisecondsSinceEpoch;
      final retry = await _api.get<dynamic>('/municipios', queryParameters: retryQuery);
      if (retry.success && retry.data != null) {
        final payload = retry.data;
        if (payload is List) {
          list = payload;
        } else if (payload is Map<String, dynamic>) {
          list = (payload['data'] is List)
              ? (payload['data'] as List)
              : (payload['municipios'] as List?) ?? [];
        }
      }
    }
    if (list.isNotEmpty) {
      final parsed = list.map((j) => _toMunicipio(j as Map<String, dynamic>)).toList();
      await _cache.setList('municipios_list', parsed.map((m) => m.toJson()).toList());
      await _cache.set('municipios_list_meta', {'ts': DateTime.now().toIso8601String()});
      return parsed;
    }
    final cached = await _cache.getList('municipios_list') ?? const [];
    if (cached.isNotEmpty) {
      return cached.map((m) => _toMunicipio(m as Map<String, dynamic>)).toList();
    }
    return const <MunicipioIntegrado>[];
  }

  Future<bool> setEstado(String municipioId, bool activo) async {
    final endpoint = activo ? '/municipios/$municipioId/activar' : '/municipios/$municipioId/desactivar';
    final resp = await _api.post<Map<String, dynamic>>(endpoint);
    return resp.success;
  }

  MunicipioIntegrado _toMunicipio(Map<String, dynamic> m) {
    return MunicipioIntegrado(
      id: (m['id'] ?? '').toString(),
      nombre: (m['nombre'] ?? m['name'] ?? '').toString(),
      codigo: (m['codigo'] ?? m['codigo_dane'] ?? m['code'] ?? '').toString(),
      departamento: (m['departamento'] ?? m['department'] ?? '').toString(),
      activo: (m['activo'] is bool) ? (m['activo'] as bool) : true,
      totalGestantes: (m['totalGestantes'] as int?) ?? 0,
      totalIPS: (m['totalIPS'] as int?) ?? 0,
      totalMedicos: (m['totalMedicos'] as int?) ?? 0,
      alertasActivas: (m['alertasActivas'] as int?) ?? 0,
      gestantesRiesgoAlto: (m['gestantesRiesgoAlto'] as int?) ?? 0,
      nivelCobertura: (m['nivelCobertura'] ?? 'Baja').toString(),
    );
  }
}


