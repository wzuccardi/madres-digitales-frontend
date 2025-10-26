import '../../../../core/usecases/usecase.dart';
import '../entities/contenido.dart';
import '../repositories/contenido_repository.dart';

class GetFavoritosUseCase implements UseCase<List<Contenido>, String> {
  final ContenidoRepository repository;

  GetFavoritosUseCase(this.repository);

  @override
  Future<List<Contenido>> call(String usuarioId) async {
    return await repository.getFavoritos(usuarioId);
  }
}