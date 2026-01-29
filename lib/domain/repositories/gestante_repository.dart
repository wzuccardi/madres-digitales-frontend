import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';


abstract class GestanteRepository {
  Future<Result<List<Gestante>, AppError>> getGestantes({
    String? madrinaId,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  });

  Future<Result<Gestante, AppError>> getGestanteById(String id);

  Future<Result<Gestante, AppError>> createGestante(Gestante gestante);

  Future<Result<Gestante, AppError>> updateGestante(Gestante gestante);

  Future<Result<void, AppError>> deleteGestante(String id);

  Future<Result<bool, AppError>> assignGestanteToMadrina({
    required String gestanteId,
    required String madrinaId,
    String? asignadoPor,
  });
}
