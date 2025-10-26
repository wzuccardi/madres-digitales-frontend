import '../../../../core/usecases/usecase.dart';
import '../entities/contenido.dart';
import '../repositories/contenido_repository.dart';

class SearchContenidosParams {
  final String query;
  final CategoriaContenido? categoria;
  final TipoContenido? tipo;
  final NivelDificultad? nivel;
  final int page;
  final int limit;

  SearchContenidosParams({
    required this.query,
    this.categoria,
    this.tipo,
    this.nivel,
    this.page = 1,
    this.limit = 20,
  });
}

class SearchContenidosUseCase implements UseCase<List<Contenido>, SearchContenidosParams> {
  final ContenidoRepository repository;

  SearchContenidosUseCase(this.repository);

  @override
  Future<List<Contenido>> call(SearchContenidosParams params) async {
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