import '../../domain/entities/gestante.dart';
import '../../domain/entities/asignacion.dart';

abstract class GestanteLocalDataSource {
  // Caché de Gestantes
  Future<Gestante?> getGestanteById(String id);
  Future<void> cacheGestante(Gestante gestante);
  Future<void> cacheGestantesList(List<Gestante> gestantes, String madrinaId);
  Future<List<Gestante>> getCachedGestantesList({
    required String madrinaId,
    int page = 1,
    int limit = 20,
  });
  
  // Caché de Asignaciones
  Future<Asignacion?> getActiveAsignation({
    required String gestanteId,
    required String madrinaId,
  });
  Future<void> cacheAsignacion(Asignacion asignacion);
  
  // Modo Offline
  Future<Gestante> createGestanteForSync({
    required Gestante gestante,
    required String madrinaId,
    Set<TipoPermiso>? permisosAdicionales,
  });
  Future<Asignacion> createAsignacionForSync(Asignacion asignacion);
  Future<List<Gestante>> getPendingSyncGestantes();
  Future<List<Asignacion>> getPendingSyncAsignaciones();
  Future<void> markAsSynced(String id, {bool isGestante = true});
  
  // Verificación de Permisos
  Future<bool> verifyMadrinaPermission({
    required String madrinaId,
    required String gestanteId,
    required String permiso,
  });
  
  // Datos Auxiliares
  Future<Map<String, dynamic>?> getMadrinaById(String id);
}