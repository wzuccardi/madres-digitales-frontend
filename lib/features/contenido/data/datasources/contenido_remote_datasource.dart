import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/models/contenido_model.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/models/categoria_model.dart';

abstract class ContenidoRemoteDataSource {
  Future<List<ContenidoModel>> getContenidos({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
  });

  Future<ContenidoModel> getContenidoById(String id);

  Future<ContenidoModel> createContenido({
    required String titulo,
    required String descripcion,
    required CategoriaContenido categoria,
    required TipoContenido tipo,
    String? url,
    String? thumbnailUrl,
    int? duracion,
    NivelDificultad nivel = NivelDificultad.basico,
    List<String> etiquetas = const [],
    int? semanaGestacionInicio,
    int? semanaGestacionFin,
  });

  Future<ContenidoModel> updateContenido(
    String id, {
    String? titulo,
    String? descripcion,
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    String? url,
    String? thumbnailUrl,
    int? duracion,
    NivelDificultad? nivel,
    List<String>? etiquetas,
    int? semanaGestacionInicio,
    int? semanaGestacionFin,
  });

  Future<void> deleteContenido(String id);

  Future<List<ContenidoModel>> searchContenidos(
    String query, {
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
  });

  Future<void> toggleFavorito(String contenidoId);

  Future<void> registrarVista(String contenidoId);

  Future<void> actualizarProgreso(
    String contenidoId, {
    int? tiempoVisualizado,
    double? porcentaje,
    bool? completado,
  });

  Future<List<ContenidoModel>> getFavoritos(String usuarioId);

  Future<List<ContenidoModel>> getContenidosConProgreso(String usuarioId);

  Future<List<CategoriaModel>> getCategorias();
}

class ContenidoRemoteDataSourceImpl implements ContenidoRemoteDataSource {

  ContenidoRemoteDataSourceImpl({required this.apiService});
  final ApiService apiService;

  @override
  Future<List<ContenidoModel>> getContenidos({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (categoria != null) {
      queryParams['categoria'] = categoria.value;
    }
    
    if (tipo != null) {
      queryParams['tipo'] = tipo.value;
    }
    
    if (nivel != null) {
      queryParams['nivel'] = nivel.value;
    }
    
    queryParams['page'] = page;
    queryParams['limit'] = limit;

    final response = await apiService.get<Map<String, dynamic>>(
      '/api/contenido-crud',
      queryParameters: queryParams,
    );
    if (response.success && response.data != null) {
      final payload = response.data!;
      final List<dynamic> contenidosJson = (payload['contenidos'] as List?) ?? (payload['data'] as List?) ?? [];
      return contenidosJson.map((json) => ContenidoModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw ServerException(response.message ?? 'Error al obtener contenidos');
  }

  @override
  Future<ContenidoModel> getContenidoById(String id) async {
    final response = await apiService.get<Map<String, dynamic>>('/api/contenido-crud/$id');
    if (response.success && response.data != null) {
      final payload = response.data!;
      final data = payload.containsKey('data') ? payload['data'] as Map<String, dynamic> : payload;
      return ContenidoModel.fromJson(data);
    }
    throw ServerException(response.message ?? 'Error al obtener contenido');
  }

  @override
  Future<ContenidoModel> createContenido({
    required String titulo,
    required String descripcion,
    required CategoriaContenido categoria,
    required TipoContenido tipo,
    String? url,
    String? thumbnailUrl,
    int? duracion,
    NivelDificultad nivel = NivelDificultad.basico,
    List<String> etiquetas = const [],
    int? semanaGestacionInicio,
    int? semanaGestacionFin,
  }) async {
    final data = {
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria.value,
      'tipo': tipo.value,
      'nivel': nivel.value,
      'tags': etiquetas,
    };
    
    if (url != null) {
      data['url_contenido'] = url;
    }
    
    if (thumbnailUrl != null) {
      data['url_imagen'] = thumbnailUrl;
    }
    
    if (duracion != null) {
      data['duracion_minutos'] = duracion;
    }
    
    if (semanaGestacionInicio != null) {
      data['semana_gestacion_inicio'] = semanaGestacionInicio;
    }
    
    if (semanaGestacionFin != null) {
      data['semana_gestacion_fin'] = semanaGestacionFin;
    }

    final response = await apiService.post<Map<String, dynamic>>('/api/contenido-crud', data: data);
    if (response.success && response.data != null) {
      final payload = response.data!;
      final map = (payload['contenido'] as Map<String, dynamic>?) ?? (payload['data'] as Map<String, dynamic>?);
      if (map != null) {
        return ContenidoModel.fromJson(map);
      }
    }
    throw ServerException(response.message ?? 'Error al crear contenido');
  }

  @override
  Future<ContenidoModel> updateContenido(
    String id, {
    String? titulo,
    String? descripcion,
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    String? url,
    String? thumbnailUrl,
    int? duracion,
    NivelDificultad? nivel,
    List<String>? etiquetas,
    int? semanaGestacionInicio,
    int? semanaGestacionFin,
  }) async {
    final data = <String, dynamic>{};
    
    if (titulo != null) {
      data['titulo'] = titulo;
    }
    
    if (descripcion != null) {
      data['descripcion'] = descripcion;
    }
    
    if (categoria != null) {
      data['categoria'] = categoria.value;
    }
    
    if (tipo != null) {
      data['tipo'] = tipo.value;
    }
    
    if (nivel != null) {
      data['nivel'] = nivel.value;
    }
    
    if (etiquetas != null) {
      data['tags'] = etiquetas;
    }
    
    if (url != null) {
      data['url_contenido'] = url;
    }
    
    if (thumbnailUrl != null) {
      data['url_imagen'] = thumbnailUrl;
    }
    
    if (duracion != null) {
      data['duracion_minutos'] = duracion;
    }
    
    if (semanaGestacionInicio != null) {
      data['semana_gestacion_inicio'] = semanaGestacionInicio;
    }
    
    if (semanaGestacionFin != null) {
      data['semana_gestacion_fin'] = semanaGestacionFin;
    }

    final response = await apiService.put<Map<String, dynamic>>('/api/contenido-crud/$id', data: data);
    if (response.success && response.data != null) {
      final payload = response.data!;
      final map = (payload['contenido'] as Map<String, dynamic>?) ?? (payload['data'] as Map<String, dynamic>?);
      if (map != null) {
        return ContenidoModel.fromJson(map);
      }
    }
    throw ServerException(response.message ?? 'Error al actualizar contenido');
  }

  @override
  Future<void> deleteContenido(String id) async {
    final response = await apiService.delete<dynamic>('/api/contenido-crud/$id');
    if (!response.success) {
      throw ServerException(response.message ?? 'Error al eliminar contenido');
    }
  }

  @override
  Future<List<ContenidoModel>> searchContenidos(
    String query, {
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'q': query,
      'page': page,
      'limit': limit,
    };
    
    if (categoria != null) {
      queryParams['categoria'] = categoria.value;
    }
    
    if (tipo != null) {
      queryParams['tipo'] = tipo.value;
    }
    
    if (nivel != null) {
      queryParams['nivel'] = nivel.value;
    }

    final response = await apiService.get<Map<String, dynamic>>(
      '/api/contenido-crud',
      queryParameters: queryParams,
    );
    if (response.success && response.data != null) {
      final payload = response.data!;
      final List<dynamic> contenidosJson = (payload['contenidos'] as List?) ?? (payload['data'] as List?) ?? [];
      return contenidosJson.map((json) => ContenidoModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw ServerException(response.message ?? 'Error al buscar contenidos');
  }

  @override
  Future<void> toggleFavorito(String contenidoId) async {
    final response = await apiService.post<dynamic>('/api/contenido/$contenidoId/favorito');
    if (!response.success) {
      throw ServerException(response.message ?? 'Error al alternar favorito');
    }
  }

  @override
  Future<void> registrarVista(String contenidoId) async {
    final response = await apiService.post<dynamic>('/api/contenido/$contenidoId/vista');
    if (!response.success) {
      throw ServerException(response.message ?? 'Error al registrar vista');
    }
  }

  @override
  Future<void> actualizarProgreso(
    String contenidoId, {
    int? tiempoVisualizado,
    double? porcentaje,
    bool? completado,
  }) async {
    final data = <String, dynamic>{};
    
    if (tiempoVisualizado != null) {
      data['tiempoVisualizado'] = tiempoVisualizado;
    }
    
    if (porcentaje != null) {
      data['porcentaje'] = porcentaje;
    }
    
    if (completado != null) {
      data['completado'] = completado;
    }

    final response = await apiService.post<dynamic>('/api/contenido/$contenidoId/progreso', data: data);
    if (!response.success) {
      throw ServerException(response.message ?? 'Error al actualizar progreso');
    }
  }

  @override
  Future<List<ContenidoModel>> getFavoritos(String usuarioId) async {
    final response = await apiService.get<Map<String, dynamic>>('/api/usuarios/$usuarioId/favoritos');
    if (response.success && response.data != null) {
      final payload = response.data!;
      final List<dynamic> contenidosJson = (payload['data'] as List?) ?? [];
      return contenidosJson.map((json) => ContenidoModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw ServerException(response.message ?? 'Error al obtener favoritos');
  }

  @override
  Future<List<ContenidoModel>> getContenidosConProgreso(String usuarioId) async {
    final response = await apiService.get<Map<String, dynamic>>('/api/usuarios/$usuarioId/progreso');
    if (response.success && response.data != null) {
      final payload = response.data!;
      final List<dynamic> contenidosJson = (payload['data'] as List?) ?? [];
      return contenidosJson.map((json) => ContenidoModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw ServerException(response.message ?? 'Error al obtener contenidos con progreso');
  }

  @override
  Future<List<CategoriaModel>> getCategorias() async {
    final response = await apiService.get<Map<String, dynamic>>('/api/categorias');
    if (response.success && response.data != null) {
      final payload = response.data!;
      final List<dynamic> categoriasJson = (payload['data'] as List?) ?? [];
      return categoriasJson.map((json) => CategoriaModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw ServerException(response.message ?? 'Error al obtener categorías');
  }
}

// Excepciones personalizadas
class ServerException implements Exception {
  
  const ServerException(this.message);
  final String message;
}
