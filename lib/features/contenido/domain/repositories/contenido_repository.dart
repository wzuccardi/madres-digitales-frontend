import '../entities/contenido.dart';
import '../entities/categoria.dart';

abstract class ContenidoRepository {
  // Obtener contenidos
  Future<List<Contenido>> getContenidos({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  });

  // Obtener contenido por ID
  Future<Contenido?> getContenidoById(String id);

  // Crear contenido
  Future<Contenido> createContenido({
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

  // Actualizar contenido
  Future<Contenido> updateContenido(
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

  // Eliminar contenido
  Future<void> deleteContenido(String id);

  // Buscar contenidos
  Future<List<Contenido>> searchContenidos(
    String query, {
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
  });

  // Alternar favorito
  Future<void> toggleFavorito(String contenidoId);

  // Registrar vista
  Future<void> registrarVista(String contenidoId);

  // Actualizar progreso
  Future<void> actualizarProgreso(
    String contenidoId, {
    int? tiempoVisualizado,
    double? porcentaje,
    bool? completado,
  });

  // Obtener favoritos de un usuario
  Future<List<Contenido>> getFavoritos(String usuarioId);

  // Obtener contenidos con progreso de un usuario
  Future<List<Contenido>> getContenidosConProgreso(String usuarioId);

  // Obtener categorías
  Future<List<Categoria>> getCategorias();

  // Limpiar caché
  Future<void> clearCache({CategoriaContenido? categoria});
}