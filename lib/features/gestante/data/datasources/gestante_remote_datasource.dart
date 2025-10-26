import '../../domain/entities/gestante.dart';
import '../../domain/entities/asignacion.dart';

abstract class GestanteRemoteDataSource {
  // CRUD de Gestantes
  Future<Gestante> createGestante({
    required Gestante gestante,
    required String madrinaId,
    Set<TipoPermiso>? permisosAdicionales,
  });
  
  Future<Gestante> getGestanteById(String id);
  Future<List<Gestante>> getAllGestantes({
    int page = 1,
    int limit = 20,
    String? search,
    bool? soloActivas,
  });
  
  Future<Gestante> updateGestante(Gestante gestante);
  Future<bool> deleteGestante(String id);
  
  // Gestión de Asignaciones
  Future<Asignacion> createAsignacion(Asignacion asignacion);
  Future<Asignacion?> getActiveAsignation({
    required String gestanteId,
    required String madrinaId,
  });
  Future<List<Asignacion>> getAsignacionesByGestante(String gestanteId);
  Future<List<Asignacion>> getAsignacionesByMadrina(String madrinaId);
  Future<bool> deactivatePrincipalAssignments(String gestanteId);
  
  // Gestión de Gestantes Asignadas
  Future<List<Gestante>> getGestantesAsignadas({
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
  Future<Map<String, dynamic>> getMadrinaById(String id);
  Future<List<Map<String, dynamic>>> getAvailableMadrinas();
}