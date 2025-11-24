import 'package:madres_digitales_flutter_new/core/interfaces/usecase.dart';
import '../repositories/contenido_repository.dart';

class RegistrarVistaUseCase implements UseCase<void, String> {

  RegistrarVistaUseCase(this.repository);
  final ContenidoRepository repository;

  @override
  Future<void> call(String contenidoId) async {
    return await repository.registrarVista(contenidoId);
  }
}
