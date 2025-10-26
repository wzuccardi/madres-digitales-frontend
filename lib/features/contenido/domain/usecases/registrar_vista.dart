import '../../../../core/usecases/usecase.dart';
import '../repositories/contenido_repository.dart';

class RegistrarVistaUseCase implements UseCase<void, String> {
  final ContenidoRepository repository;

  RegistrarVistaUseCase(this.repository);

  @override
  Future<void> call(String contenidoId) async {
    return await repository.registrarVista(contenidoId);
  }
}