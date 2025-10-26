import '../../../../core/usecases/usecase.dart';
import '../entities/contenido.dart';
import '../repositories/contenido_repository.dart';

class CreateContenidoParams {
  final String titulo;
  final String descripcion;
  final CategoriaContenido categoria;
  final TipoContenido tipo;
  final String? url;
  final String? thumbnailUrl;
  final int? duracion;
  final NivelDificultad nivel;
  final List<String> etiquetas;
  final int? semanaGestacionInicio;
  final int? semanaGestacionFin;

  CreateContenidoParams({
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.tipo,
    this.url,
    this.thumbnailUrl,
    this.duracion,
    this.nivel = NivelDificultad.basico,
    this.etiquetas = const [],
    this.semanaGestacionInicio,
    this.semanaGestacionFin,
  });
}

class CreateContenidoUseCase implements UseCase<Contenido, CreateContenidoParams> {
  final ContenidoRepository repository;

  CreateContenidoUseCase(this.repository);

  @override
  Future<Contenido> call(CreateContenidoParams params) async {
    return await repository.createContenido(
      titulo: params.titulo,
      descripcion: params.descripcion,
      categoria: params.categoria,
      tipo: params.tipo,
      url: params.url,
      thumbnailUrl: params.thumbnailUrl,
      duracion: params.duracion,
      nivel: params.nivel,
      etiquetas: params.etiquetas,
      semanaGestacionInicio: params.semanaGestacionInicio,
      semanaGestacionFin: params.semanaGestacionFin,
    );
  }
}