import '../../../../core/usecases/usecase.dart';
import '../repositories/contenido_repository.dart';

class ToggleFavoritoUseCase implements UseCase<void, String> {
  final ContenidoRepository repository;

  ToggleFavoritoUseCase(this.repository);

  @override
  Future<void> call(String contenidoId) async {
    return await repository.toggleFavorito(contenidoId);
  }
}