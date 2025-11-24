import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/categoria.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';

abstract class ContenidoRepository {
  // Obtener contenidos
  Future<Result<List<Contenido>, AppError>> getContenidos({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  });

  // Obtener contenido por ID
  Future<Result<Contenido?, AppError>> getContenidoById(String id);

  // Crear contenido
  Future<Result<Contenido, AppError>> createContenido({
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
  Future<Result<Contenido, AppError>> updateContenido(
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
  Future<Result<void, AppError>> deleteContenido(String id);

  // Buscar contenidos
  Future<Result<List<Contenido>, AppError>> searchContenidos(
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
