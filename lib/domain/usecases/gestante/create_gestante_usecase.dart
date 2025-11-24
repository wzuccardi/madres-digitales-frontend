import 'package:madres_digitales_flutter_new/domain/repositories/gestante_repository.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/interfaces/usecase.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/core/errors/error_converter.dart';
import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';


class CreateGestanteUseCase implements UseCase<Result<Gestante, AppError>, CreateGestanteParams> {

  CreateGestanteUseCase(this._repository);
  final GestanteRepository _repository;

  @override
  Future<Result<Gestante, AppError>> call(CreateGestanteParams params) async {
    try {
      AppLogger.debug('CreateGestanteUseCase: Creando gestante', context: {
        'nombre': params.nombre,
        'apellido': params.apellido,
        'documento': params.documento,
        'telefono': params.telefono,
        'direccion': params.direccion,
        'eps': params.eps,
        'activa': params.activa,
        'riesgoAlto': params.riesgoAlto,
        'fechaNacimiento': params.fechaNacimiento?.toIso8601String(),
        'fechaProbableParto': params.fechaProbableParto?.toIso8601String(),
        'creadaPor': params.creadaPor,
      });

      final gestante = Gestante(
        id: '', // ID temporal, será asignado por el repositorio
        nombre: params.nombre,
        apellido: params.apellido,
        telefono: params.telefono ?? '',
        email: params.email ?? '',
        documento: params.documento ?? '',
        direccion: params.direccion ?? '',
        fechaNacimiento: params.fechaNacimiento ?? DateTime.now(),
        eps: params.eps,
        activa: params.activa,
        riesgoAlto: params.riesgoAlto,
        fechaProbableParto: params.fechaProbableParto,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _repository.createGestante(gestante);

      if (result.isSuccess) {
        final createdGestante = result.data!;
        AppLogger.debug('CreateGestanteUseCase: Gestante creada', context: {
          'gestanteId': createdGestante.id,
          'nombre': createdGestante.nombre,
        });
        return Result.success(createdGestante);
      } else {
        AppLogger.error('CreateGestanteUseCase: Error creando gestante', error: result.error, context: {
          'nombre': params.nombre,
          'apellido': params.apellido,
        });
        return Result.failure(result.error!);
      }
    } catch (e) {
      AppLogger.error('CreateGestanteUseCase: Error creando gestante', error: e, context: {
        'nombre': params.nombre,
        'apellido': params.apellido,
      });
      return Result.failure(ErrorConverter.convert(e));
    }
  }
}

class CreateGestanteParams {

  CreateGestanteParams({
    required this.nombre,
    required this.apellido,
    this.telefono,
    this.email,
    this.documento,
    this.direccion,
    this.eps,
    this.activa = true,
    this.riesgoAlto = false,
    this.fechaNacimiento,
    this.fechaProbableParto,
    this.creadaPor,
  });
  final String nombre;
  final String apellido;
  final String? telefono;
  final String? email;
  final String? documento;
  final String? direccion;
  final String? eps;
  final bool activa;
  final bool riesgoAlto;
  final DateTime? fechaNacimiento;
  final DateTime? fechaProbableParto;
  final String? creadaPor;

  @override
  String toString() {
    return 'CreateGestanteParams{nombre: $nombre, apellido: $apellido}';
  }
}
