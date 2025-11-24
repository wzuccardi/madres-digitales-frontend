import 'package:madres_digitales_flutter_new/domain/repositories/gestante_repository.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/interfaces/usecase.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/core/errors/error_converter.dart';
class DeleteGestanteUseCase implements UseCase<Result<bool, AppError>, DeleteGestanteParams> {

  DeleteGestanteUseCase(this._repository);
  final GestanteRepository _repository;

  @override
  Future<Result<bool, AppError>> call(DeleteGestanteParams params) async {
    try {
      AppLogger.debug('DeleteGestanteUseCase: Eliminando gestante', context: {
        'id': params.id,
      });

      final result = await _repository.deleteGestante(params.id);

      if (result.isSuccess) {
        AppLogger.debug('DeleteGestanteUseCase: Gestante eliminada', context: {
          'gestanteId': params.id,
        });
        return const Result.success(true);
      } else {
        AppLogger.error('DeleteGestanteUseCase: Error eliminando gestante', error: result.error, context: {
          'gestanteId': params.id,
        });
        return Result.failure(result.error!);
      }
    } catch (e) {
      AppLogger.error('DeleteGestanteUseCase: Error eliminando gestante', error: e, context: {
        'gestanteId': params.id,
      });
      return Result.failure(ErrorConverter.convert(e));
    }
  }
}

class DeleteGestanteParams {

  DeleteGestanteParams({
    required this.id,
  });
  final String id;

  @override
  String toString() {
    return 'DeleteGestanteParams{id: $id}';
  }
}
