import '../../core/network/api_service.dart';
import '../../domain/entities/gestante.dart';
import '../../core/converters/gestante_converter.dart';

class GestanteService {
  GestanteService(this._api);
  final ApiService _api;

  Future<List<Gestante>> getGestantes({int page = 1, int limit = 20, String? search}) async {
    final resp = await _api.get<dynamic>(
      '/api/gestantes',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = _api.extractData(resp.data);
    final raw = (data is Map<String, dynamic> && data['gestantes'] is List)
        ? List<dynamic>.from(data['gestantes'] as List)
        : (data is List ? data : const []);
    return raw.map((e) => GestanteConverter.apiToGestante(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<Gestante>> obtenerGestantes({int page = 1, int limit = 20, String? search}) => getGestantes(page: page, limit: limit, search: search);
  Future<Gestante> obtenerGestantePorId(String id) => getGestanteById(id);
  Future<Gestante> crearGestante(Gestante g) => createGestante(g);
  Future<Gestante> actualizarGestante(String id, Gestante g) => updateGestante(id, g);
  Future<bool> eliminarGestante(String id) => deleteGestante(id);

  Future<Gestante> getGestanteById(String id) async {
    final resp = await _api.get<dynamic>('/api/gestantes/$id');
    final body = _api.extractObject(resp.data);
    return GestanteConverter.apiToGestante(body);
  }

  Future<Gestante> createGestante(Gestante gestante) async {
    final payload = GestanteConverter.gestanteToApi(gestante);
    final resp = await _api.post<dynamic>('/api/gestantes', data: payload);
    final raw = resp.data;
    Map<String, dynamic> body;
    if (raw is Map<String, dynamic> && raw['gestante'] is Map<String, dynamic>) {
      body = Map<String, dynamic>.from(raw['gestante'] as Map<String, dynamic>);
    } else {
      body = _api.extractObject(raw);
    }
    return GestanteConverter.apiToGestante(body);
  }

  Future<Gestante> updateGestante(String id, Gestante gestante) async {
    final payload = GestanteConverter.gestanteToApi(gestante);
    final resp = await _api.put<dynamic>('/api/gestantes/$id', data: payload);
    final raw = resp.data;
    Map<String, dynamic> body;
    if (raw is Map<String, dynamic> && raw['gestante'] is Map<String, dynamic>) {
      body = Map<String, dynamic>.from(raw['gestante'] as Map<String, dynamic>);
    } else {
      body = _api.extractObject(raw);
    }
    return GestanteConverter.apiToGestante(body);
  }

  Future<bool> deleteGestante(String id) async {
    final resp = await _api.delete<dynamic>('/api/gestantes/$id');
    final code = resp.statusCode ?? 0;
    if (code == 200 || code == 204 || resp.success) return true;
    return false;
  }
}