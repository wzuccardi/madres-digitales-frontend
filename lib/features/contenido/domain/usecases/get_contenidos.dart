import '../../../../core/usecases/usecase.dart';
import '../entities/contenido.dart';
import '../repositories/contenido_repository.dart';

class GetContenidosUseCase implements UseCase<List<Contenido>, GetContenidosParams> {
  final ContenidoRepository repository;

  GetContenidosUseCase(this.repository);

  @override
  Future<List<Contenido>> call(GetContenidosParams params) async {
    return await repository.getContenidos(
      categoria: params.categoria,
      tipo: params.tipo,
      nivel: params.nivel,
      page: params.page,
      limit: params.limit,
      forceRefresh: params.forceRefresh,
    );
  }
}

class GetContenidosParams {
  final CategoriaContenido? categoria;
  final TipoContenido? tipo;
  final NivelDificultad? nivel;
  final int page;
  final int limit;
  final bool forceRefresh;

  GetContenidosParams({
    this.categoria,
    this.tipo,
    this.nivel,
    this.page = 1,
    this.limit = 20,
    this.forceRefresh = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is GetContenidosParams &&
        other.categoria == categoria &&
        other.tipo == tipo &&
        other.nivel == nivel &&
        other.page == page &&
        other.limit == limit &&
        other.forceRefresh == forceRefresh;
  }

  @override
  int get hashCode {
    return categoria.hashCode ^
        tipo.hashCode ^
        nivel.hashCode ^
        page.hashCode ^
        limit.hashCode ^
        forceRefresh.hashCode;
  }
}