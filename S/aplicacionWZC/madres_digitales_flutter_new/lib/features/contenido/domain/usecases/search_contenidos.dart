import 'package:madres_digitales_flutter_new/core/interfaces/usecase.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import '../repositories/contenido_repository.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';

class SearchContenidosParams {

  SearchContenidosParams({
    required this.query,
    this.categoria,
    this.tipo,
    this.nivel,
    this.page = 1,
    this.limit = 20,
  });
  final String query;
  final CategoriaContenido? categoria;
  final TipoContenido? tipo;
  final NivelDificultad? nivel;
  final int page;
  final int limit;
}

class SearchContenidosUseCase implements UseCase<Result<List<Contenido>, AppError>, SearchContenidosParams> {

  SearchContenidosUseCase(this.repository);
  final ContenidoRepository repository;

  @override
  Future<Result<List<Contenido>, AppError>> call(SearchContenidosParams params) async {
    return await repository.searchContenidos(
      params.query,
      categoria: params.categoria,
      tipo: params.tipo,
      nivel: params.nivel,
      page: params.page,
      limit: params.limit,
    );
  }
}
