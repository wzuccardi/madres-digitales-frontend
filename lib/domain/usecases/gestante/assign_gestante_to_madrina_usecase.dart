import 'package:madres_digitales_flutter_new/domain/repositories/gestante_repository.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/interfaces/usecase.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/core/errors/error_converter.dart';
class AssignGestanteToMadrinaUseCase implements UseCase<Result<bool, AppError>, AssignGestanteToMadrinaParams> {

  AssignGestanteToMadrinaUseCase(this._repository);
  final GestanteRepository _repository;

  @override
  Future<Result<bool, AppError>> call(AssignGestanteToMadrinaParams params) async {
    try {
      AppLogger.debug('AssignGestanteToMadrinaUseCase: Asignando gestante a madrina', context: {
        'gestanteId': params.gestanteId,
        'madrinaId': params.madrinaId,
        'asignadoPor': params.asignadoPor,
      });

      final result = await _repository.assignGestanteToMadrina(
        gestanteId: params.gestanteId,
        madrinaId: params.madrinaId,
        asignadoPor: params.asignadoPor,
      );

      if (result.isSuccess) {
        AppLogger.debug('AssignGestanteToMadrinaUseCase: Gestante asignada a madrina', context: {
          'gestanteId': params.gestanteId,
          'madrinaId': params.madrinaId,
        });
        return Result.success(result.data!);
      } else {
        AppLogger.error('AssignGestanteToMadrinaUseCase: Error asignando gestante a madrina', error: result.error, context: {
          'gestanteId': params.gestanteId,
          'madrinaId': params.madrinaId,
        });
        return Result.failure(result.error!);
      }
    } catch (e) {
      AppLogger.error('AssignGestanteToMadrinaUseCase: Error asignando gestante a madrina', error: e, context: {
        'gestanteId': params.gestanteId,
          'madrinaId': params.madrinaId,
        });
      return Result.failure(ErrorConverter.convert(e));
    }
  }
}

class AssignGestanteToMadrinaParams {

  AssignGestanteToMadrinaParams({
    required this.gestanteId,
    required this.madrinaId,
    this.asignadoPor,
  });
  final String gestanteId;
  final String madrinaId;
  final String? asignadoPor;

  @override
  String toString() {
    return 'AssignGestanteToMadrinaParams{gestanteId: $gestanteId, madrinaId: $madrinaId}';
  }
}
