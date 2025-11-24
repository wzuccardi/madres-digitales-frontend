import 'package:madres_digitales_flutter_new/core/interfaces/usecase.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import '../repositories/contenido_repository.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';

class CreateContenidoParams {

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
}

class CreateContenidoUseCase implements UseCase<Result<Contenido, AppError>, CreateContenidoParams> {

  CreateContenidoUseCase(this.repository);
  final ContenidoRepository repository;

  @override
  Future<Result<Contenido, AppError>> call(CreateContenidoParams params) async {
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
