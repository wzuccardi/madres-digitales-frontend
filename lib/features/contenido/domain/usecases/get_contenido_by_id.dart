import '../../../../core/usecases/usecase.dart';
import '../entities/contenido.dart';
import '../repositories/contenido_repository.dart';

class GetContenidoByIdUseCase implements UseCase<Contenido?, String> {
  final ContenidoRepository repository;

  GetContenidoByIdUseCase(this.repository);

  @override
  Future<Contenido?> call(String id) async {
    return await repository.getContenidoById(id);
  }
}