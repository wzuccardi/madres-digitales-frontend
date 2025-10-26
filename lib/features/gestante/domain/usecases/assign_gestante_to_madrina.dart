import 'package:dartz/dartz.dart';
import '../entities/asignacion.dart';
import '../entities/gestante.dart';
import '../repositories/gestante_repository.interface.dart';
import '../../../../core/error/failures.dart';

class AssignGestanteToMadrina {
  final GestanteRepository _repository;

  AssignGestanteToMadrina(this._repository);

  Future<Either<Failure, Asignacion>> call({
    required String gestanteId,
    required String madrinaId,
    required String asignadoPor,
    TipoAsignacion tipo = TipoAsignacion.manual,
    bool esPrincipal = false,
    int prioridad = 3,
    String? motivoAsignacion,
  }) async {
    // Validar que la gestante exista
    final gestanteResult = await _repository.getGestanteById(gestanteId);
    if (gestanteResult.isLeft()) {
      return const Left(NotFoundFailure('Gestante no encontrada'));
    }
    
    
    // Validar que la madrina exista
    final madrinaResult = await _repository.getMadrinaById(madrinaId);
    if (madrinaResult.isLeft()) {
      return const Left(NotFoundFailure('Madrina no encontrada'));
    }
    
    // Validar que el asignador tenga permisos
    final tienePermisos = await _repository.verifyUserPermissions(
      userId: asignadoPor,
      permiso: 'asignar_gestante',
    );
    
    if (!tienePermisos) {
      return const Left(PermissionFailure('El usuario no tiene permisos para asignar gestantes'));
    }
    
    // Verificar si ya existe una asignación activa
    final asignacionExistenteResult = await _repository.getActiveAsignation(
      gestanteId: gestanteId,
      madrinaId: madrinaId,
    );
    
    final asignacionExistente = asignacionExistenteResult.getOrElse(() => null);
    
    if (asignacionExistente != null && asignacionExistente.estado == EstadoAsignacion.activa) {
      return const Left(ValidationFailure('La gestante ya está asignada a esta madrina'));
    }
    
    // Si es principal, desactivar otras asignaciones principales
    if (esPrincipal) {
      await _repository.deactivatePrincipalAssignments(gestanteId);
    }
    
    // Crear la asignación
    final asignacion = Asignacion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gestanteId: gestanteId,
      madrinaId: madrinaId,
      estado: EstadoAsignacion.activa,
      tipo: tipo,
      fechaAsignacion: DateTime.now(),
      asignadoPor: asignadoPor,
      esPrincipal: esPrincipal,
      prioridad: prioridad,
      motivoAsignacion: motivoAsignacion,
    );
    
    return await _repository.createAsignacion(asignacion);
  }
}