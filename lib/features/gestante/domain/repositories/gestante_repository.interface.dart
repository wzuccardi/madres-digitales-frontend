import '../../../../domain/entities/gestante.dart';
import 'package:dartz/dartz.dart';
import '../entities/asignacion.dart';
import '../../../../domain/entities/tipo_permiso.dart';
import 'package:madres_digitales_flutter_new/core/error/failures.dart';


abstract class GestanteRepository {
  // CRUD de Gestantes
  Future<Either<Failure, Gestante>> createGestante({
    required Gestante gestante,
    required String madrinaId,
    Set<TipoPermiso>? permisosAdicionales,
  });
  
  Future<Either<Failure, Gestante>> getGestanteById(String id);
  Future<Either<Failure, List<Gestante>>> getAllGestantes({
    int page = 1,
    int limit = 20,
    String? search,
    bool? soloActivas,
  });
  
  Future<Either<Failure, Gestante>> updateGestante(Gestante gestante);
  Future<Either<Failure, bool>> deleteGestante(String id);
  
  // Gestión de Asignaciones
  Future<Either<Failure, Asignacion>> createAsignacion(Asignacion asignacion);
  Future<Either<Failure, Asignacion?>> getActiveAsignation({
    required String gestanteId,
    required String madrinaId,
  });
  Future<Either<Failure, List<Asignacion>>> getAsignacionesByGestante(String gestanteId);
  Future<Either<Failure, List<Asignacion>>> getAsignacionesByMadrina(String madrinaId);
  Future<Either<Failure, bool>> deactivatePrincipalAssignments(String gestanteId);
  
  // Gestión de Gestantes Asignadas
  Future<Either<Failure, List<Gestante>>> getGestantesAsignadas({
    required String madrinaId,
    int page = 1,
    int limit = 20,
    String? search,
    bool? soloActivas,
    bool? soloPropias,
    String? sortBy,
    bool ascending = true,
  });
  
  // Verificación de Permisos
  Future<bool> verifyMadrinaPermission({
    required String madrinaId,
    required String gestanteId,
    required String permiso,
  });
  
  Future<bool> verifyMadrinaPermissions({
    required String madrinaId,
    required String permiso,
  });
  
  Future<bool> verifyUserPermissions({
    required String userId,
    required String permiso,
  });
  
  // Obtención de Datos Auxiliares
  Future<Either<Failure, Map<String, dynamic>>> getMadrinaById(String id);
  Future<Either<Failure, List<Map<String, dynamic>>>> getAvailableMadrinas();
}
