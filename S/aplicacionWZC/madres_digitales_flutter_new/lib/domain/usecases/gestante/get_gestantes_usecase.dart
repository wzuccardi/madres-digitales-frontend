import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';
import 'package:madres_digitales_flutter_new/domain/repositories/gestante_repository.dart';
import '../../../core/types/result.dart';
import '../../../core/interfaces/usecase.dart';
import '../../../core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/core/errors/error_converter.dart';


class GetGestantesUseCase implements UseCase<Result<List<Gestante>, AppError>, GetGestantesParams> {

  GetGestantesUseCase(this._repository);
  final GestanteRepository _repository;

  @override
  Future<Result<List<Gestante>, AppError>> call(GetGestantesParams params) async {
    try {
      AppLogger.debug('GetGestantesUseCase: Obteniendo gestantes', context: {
        'madrinaId': params.madrinaId,
        'limit': params.limit,
        'offset': params.offset,
      });

      final result = await _repository.getGestantes(
        madrinaId: params.madrinaId,
        limit: params.limit,
        offset: params.offset,
      );

      if (result.isSuccess) {
        AppLogger.debug('GetGestantesUseCase: Gestantes obtenidas', context: {
          'count': result.data!.length,
        });
        return Result.success(result.data!);
      } else {
        AppLogger.error('GetGestantesUseCase: Error obteniendo gestantes', error: result.error);
        return Result.failure(result.error!);
      }
    } catch (e) {
      AppLogger.error('GetGestantesUseCase: Error obteniendo gestantes', error: e);
      return Result.failure(ErrorConverter.convert(e));
    }
  }
}

class GetGestantesParams {

  GetGestantesParams({
    this.madrinaId,
    this.limit,
    this.offset,
  });
  final String? madrinaId;
  final int? limit;
  final int? offset;

  @override
  String toString() {
    return 'GetGestantesParams{madrinaId: $madrinaId, limit: $limit, offset: $offset}';
  }
}
