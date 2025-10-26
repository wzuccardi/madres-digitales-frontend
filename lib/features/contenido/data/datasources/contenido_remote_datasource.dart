import '../../domain/entities/contenido.dart';
import '../models/contenido_model.dart';
import '../models/categoria_model.dart';
import '../../../../services/api_service.dart';

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
  final ApiService apiService;

  ContenidoRemoteDataSourceImpl({required this.apiService});

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

    String queryParamsStr = queryParams.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');
    
    final response = await apiService.get('/contenido-crud?$queryParamsStr');
    
    if (response.statusCode == 200 && response.data != null) {
      final List<dynamic> contenidosJson = response.data['contenidos'] ?? [];
      return contenidosJson.map((json) => ContenidoModel.fromJson(json)).toList();
    } else {
      throw ServerException(response.data?['message'] ?? 'Error al obtener contenidos');
    }
  }

  @override
  Future<ContenidoModel> getContenidoById(String id) async {
    final response = await apiService.get('/contenido-crud/$id');
    
    if (response.statusCode == 200 && response.data != null) {
      return ContenidoModel.fromJson(response.data);
    } else {
      throw ServerException(response.data?['message'] ?? 'Error al obtener contenido');
    }
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

    final response = await apiService.post('/contenido-crud', data: data);
    
    if (response.statusCode == 201 && response.data != null) {
      return ContenidoModel.fromJson(response.data['contenido']);
    } else {
      throw ServerException(response.data?['message'] ?? 'Error al crear contenido');
    }
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

    final response = await apiService.put('/contenido-crud/$id', data: data);
    
    if (response.statusCode == 200 && response.data != null) {
      return ContenidoModel.fromJson(response.data['contenido']);
    } else {
      throw ServerException(response.data?['message'] ?? 'Error al actualizar contenido');
    }
  }

  @override
  Future<void> deleteContenido(String id) async {
    final response = await apiService.delete('/contenido-crud/$id');
    
    if (response.statusCode != 200) {
      throw ServerException(response.data?['message'] ?? 'Error al eliminar contenido');
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
      'query': query,
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

    String queryParamsStr = queryParams.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');
    
    final response = await apiService.get('/contenido-crud?q=$query');
    
    if (response.statusCode == 200 && response.data != null) {
      final List<dynamic> contenidosJson = response.data['contenidos'] ?? [];
      return contenidosJson.map((json) => ContenidoModel.fromJson(json)).toList();
    } else {
      throw ServerException(response.data?['message'] ?? 'Error al buscar contenidos');
    }
  }

  @override
  Future<void> toggleFavorito(String contenidoId) async {
    final response = await apiService.post('/contenido/$contenidoId/favorito');
    
    if (response.statusCode != 200) {
      throw ServerException(response.data?['message'] ?? 'Error al alternar favorito');
    }
  }

  @override
  Future<void> registrarVista(String contenidoId) async {
    final response = await apiService.post('/contenido/$contenidoId/vista');
    
    if (response.statusCode != 200) {
      throw ServerException(response.data?['message'] ?? 'Error al registrar vista');
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

    final response = await apiService.post('/contenido/$contenidoId/progreso', data: data);
    
    if (response.statusCode != 200) {
      throw ServerException(response.data?['message'] ?? 'Error al actualizar progreso');
    }
  }

  @override
  Future<List<ContenidoModel>> getFavoritos(String usuarioId) async {
    final response = await apiService.get('/usuarios/$usuarioId/favoritos');
    
    if (response.statusCode == 200 && response.data != null) {
      final List<dynamic> contenidosJson = response.data['data'] ?? [];
      return contenidosJson.map((json) => ContenidoModel.fromJson(json)).toList();
    } else {
      throw ServerException(response.data?['message'] ?? 'Error al obtener favoritos');
    }
  }

  @override
  Future<List<ContenidoModel>> getContenidosConProgreso(String usuarioId) async {
    final response = await apiService.get('/usuarios/$usuarioId/progreso');
    
    if (response.statusCode == 200 && response.data != null) {
      final List<dynamic> contenidosJson = response.data['data'] ?? [];
      return contenidosJson.map((json) => ContenidoModel.fromJson(json)).toList();
    } else {
      throw ServerException(response.data?['message'] ?? 'Error al obtener contenidos con progreso');
    }
  }

  @override
  Future<List<CategoriaModel>> getCategorias() async {
    final response = await apiService.get('/categorias');
    
    if (response.statusCode == 200 && response.data != null) {
      final List<dynamic> categoriasJson = response.data['data'] ?? [];
      return categoriasJson.map((json) => CategoriaModel.fromJson(json)).toList();
    } else {
      throw ServerException(response.data?['message'] ?? 'Error al obtener categorías');
    }
  }
}

// Excepciones personalizadas
class ServerException implements Exception {
  final String message;
  
  const ServerException(this.message);
}