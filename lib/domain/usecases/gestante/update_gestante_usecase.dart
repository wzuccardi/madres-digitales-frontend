import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';
import 'package:madres_digitales_flutter_new/domain/repositories/gestante_repository.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/interfaces/usecase.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/core/errors/error_converter.dart';


class UpdateGestanteUseCase implements UseCase<Result<Gestante, AppError>, UpdateGestanteParams> {

  UpdateGestanteUseCase(this._repository);
  final GestanteRepository _repository;

  @override
  Future<Result<Gestante, AppError>> call(UpdateGestanteParams params) async {
    try {
      AppLogger.debug('UpdateGestanteUseCase: Actualizando gestante', context: {
        'id': params.id,
        'nombre': params.nombre,
        'apellido': params.apellido,
      });

      final result = await _repository.getGestanteById(params.id);
      
      if (result.isFailure) {
        AppLogger.error('UpdateGestanteUseCase: Gestante no encontrada', error: result.error, context: {
          'gestanteId': params.id,
        });
        return Result.failure(result.error!);
      }

      final gestante = result.data!;
      final updatedGestanteData = gestante.copyWith(
        nombre: params.nombre ?? gestante.nombre,
        apellido: params.apellido ?? gestante.apellido,
        telefono: params.telefono ?? gestante.telefono,
        email: params.email ?? gestante.email,
        documento: params.documento ?? gestante.documento,
        direccion: params.direccion ?? gestante.direccion,
        eps: params.eps ?? gestante.eps,
        activa: params.activa ?? gestante.activa,
        riesgoAlto: params.riesgoAlto ?? gestante.riesgoAlto,
        fechaNacimiento: params.fechaNacimiento ?? gestante.fechaNacimiento,
        fechaProbableParto: params.fechaProbableParto ?? gestante.fechaProbableParto,
        updatedAt: DateTime.now(),
      );

      final updateResult = await _repository.updateGestante(updatedGestanteData);

      if (updateResult.isSuccess) {
        AppLogger.debug('UpdateGestanteUseCase: Gestante actualizada', context: {
          'gestanteId': updateResult.data!.id,
          'nombre': updateResult.data!.nombre,
        });
        return Result.success(updateResult.data!);
      } else {
        AppLogger.error('UpdateGestanteUseCase: Error actualizando gestante', error: updateResult.error, context: {
          'gestanteId': params.id,
          'nombre': params.nombre,
        });
        return Result.failure(updateResult.error!);
      }
    } catch (e) {
      AppLogger.error('UpdateGestanteUseCase: Error actualizando gestante', error: e, context: {
        'gestanteId': params.id,
        'nombre': params.nombre,
      });
      return Result.failure(ErrorConverter.convert(e));
    }
  }
}

class UpdateGestanteParams {

  UpdateGestanteParams({
    required this.id,
    this.nombre,
    this.apellido,
    this.telefono,
    this.email,
    this.documento,
    this.direccion,
    this.eps,
    this.activa,
    this.riesgoAlto,
    this.fechaNacimiento,
    this.fechaProbableParto,
  });
  final String id;
  final String? nombre;
  final String? apellido;
  final String? telefono;
  final String? email;
  final String? documento;
  final String? direccion;
  final String? eps;
  final bool? activa;
  final bool? riesgoAlto;
  final DateTime? fechaNacimiento;
  final DateTime? fechaProbableParto;

  @override
  String toString() {
    return 'UpdateGestanteParams{id: $id, nombre: $nombre}';
  }
}
