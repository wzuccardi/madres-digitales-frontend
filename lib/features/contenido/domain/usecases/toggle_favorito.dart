import 'package:madres_digitales_flutter_new/core/interfaces/usecase.dart';
import '../repositories/contenido_repository.dart';

class ToggleFavoritoUseCase implements UseCase<void, String> {

  ToggleFavoritoUseCase(this.repository);
  final ContenidoRepository repository;

  @override
  Future<void> call(String contenidoId) async {
    return await repository.toggleFavorito(contenidoId);
  }
}
