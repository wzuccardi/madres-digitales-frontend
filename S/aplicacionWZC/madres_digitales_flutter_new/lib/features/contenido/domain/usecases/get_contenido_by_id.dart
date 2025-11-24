import 'package:madres_digitales_flutter_new/core/interfaces/usecase.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import '../repositories/contenido_repository.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';

class GetContenidoByIdUseCase implements UseCase<Result<Contenido?, AppError>, String> {

  GetContenidoByIdUseCase(this.repository);
  final ContenidoRepository repository;

  @override
  Future<Result<Contenido?, AppError>> call(String id) async {
    return await repository.getContenidoById(id);
  }
}
