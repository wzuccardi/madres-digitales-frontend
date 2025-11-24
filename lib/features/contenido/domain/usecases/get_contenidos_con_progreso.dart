import 'package:madres_digitales_flutter_new/core/interfaces/usecase.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import '../repositories/contenido_repository.dart';

class GetContenidosConProgresoUseCase implements UseCase<List<Contenido>, String> {

  GetContenidosConProgresoUseCase(this.repository);
  final ContenidoRepository repository;

  @override
  Future<List<Contenido>> call(String usuarioId) async {
    return await repository.getContenidosConProgreso(usuarioId);
  }
}
