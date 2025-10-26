import 'package:dartz/dartz.dart';
import '../entities/gestante.dart';
import '../repositories/gestante_repository.interface.dart';
import '../../../../core/error/failures.dart';

class GetGestantesAsignadas {
  final GestanteRepository _repository;

  GetGestantesAsignadas(this._repository);

  Future<Either<Failure, List<Gestante>>> call({
    required String madrinaId,
    int page = 1,
    int limit = 20,
    String? search,
    bool? soloActivas,
    bool? soloPropias,
    String? sortBy,
    bool ascending = true,
  }) async {
    // Validar que la madrina exista
    final madrinaResult = await _repository.getMadrinaById(madrinaId);
    if (madrinaResult.isLeft()) {
      return const Left(NotFoundFailure('Madrina no encontrada'));
    }
    
    // Obtener gestantes asignadas
    return await _repository.getGestantesAsignadas(
      madrinaId: madrinaId,
      page: page,
      limit: limit,
      search: search,
      soloActivas: soloActivas,
      soloPropias: soloPropias,
      sortBy: sortBy,
      ascending: ascending,
    );
  }
}