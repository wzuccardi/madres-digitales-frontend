import '../../../../core/usecases/usecase.dart';
import '../entities/contenido.dart';
import '../repositories/contenido_repository.dart';

class GetContenidosConProgresoUseCase implements UseCase<List<Contenido>, String> {
  final ContenidoRepository repository;

  GetContenidosConProgresoUseCase(this.repository);

  @override
  Future<List<Contenido>> call(String usuarioId) async {
    return await repository.getContenidosConProgreso(usuarioId);
  }
}