import 'package:dartz/dartz.dart';
import '../entities/gestante.dart';
import '../repositories/gestante_repository.interface.dart';
import '../../../../core/error/failures.dart';

class CreateGestante {
  final GestanteRepository _repository;

  CreateGestante(this._repository);

  Future<Either<Failure, Gestante>> call({
    required Gestante gestante,
    required String madrinaId,
    Set<TipoPermiso>? permisosAdicionales,
  }) async {
    // Validar que la gestante tenga los datos obligatorios
    if (gestante.nombres.isEmpty || gestante.apellidos.isEmpty) {
      return const Left(ValidationFailure('Los nombres y apellidos son obligatorios'));
    }
    
    if (gestante.numeroDocumento.isEmpty) {
      return const Left(ValidationFailure('El número de documento es obligatorio'));
    }
    
    if (gestante.telefono.isEmpty) {
      return const Left(ValidationFailure('El teléfono es obligatorio'));
    }
    
    if (gestante.direccion.isEmpty) {
      return const Left(ValidationFailure('La dirección es obligatoria'));
    }
    
    // Validar que la madrina exista y tenga permisos
    final tienePermisos = await _repository.verifyMadrinaPermissions(
      madrinaId: madrinaId,
      permiso: 'crear_gestante',
    );
    
    if (!tienePermisos) {
      return const Left(PermissionFailure('La madrina no tiene permisos para crear gestantes'));
    }
    
    // Crear la gestante con la madrina como propietaria
    final gestanteConPropietaria = gestante.copyWith(
      creadaPor: madrinaId,
      madrinasAsignadas: [madrinaId],
      fechaCreacion: DateTime.now(),
    );
    
    return await _repository.createGestante(
      gestante: gestanteConPropietaria,
      madrinaId: madrinaId,
      permisosAdicionales: permisosAdicionales,
    );
  }
}