import 'package:madres_digitales_flutter_new/domain/entities/user_permission.dart';
import 'package:madres_digitales_flutter_new/domain/entities/tipo_permiso.dart';

abstract class PermissionRepository {
  Future<UserPermission> obtenerPermisosUsuario(String userId);
  Future<bool> verificarPermiso(String userId, TipoPermiso permiso);
  Future<bool> verificarPermisoSobreGestante(String userId, String gestanteId, TipoPermiso permiso);
  Future<void> actualizarPermisosUsuario(String userId, Set<TipoPermiso> nuevosPermisos);
  Stream<UserPermission> observarCambiosPermisos(String userId);
  
  // Métodos para gestión de permisos específicos
  Future<bool> puedeVerGestantesAsignadas(String userId);
  Future<bool> puedeVerTodasGestantes(String userId);
  Future<bool> puedeCrearGestante(String userId);
  Future<bool> puedeEditarGestante(String userId);
  Future<bool> puedeEliminarGestante(String userId);
  Future<bool> puedeAsignarGestante(String userId);
  
  Future<bool> puedeVerControles(String userId);
  Future<bool> puedeCrearControl(String userId);
  Future<bool> puedeEditarControl(String userId);
  
  Future<bool> puedeVerAlertas(String userId);
  Future<bool> puedeCrearAlerta(String userId);
  Future<bool> puedeGestionarAlertasCriticas(String userId);
  
  Future<bool> puedeVerReportesBasicos(String userId);
  Future<bool> puedeVerReportesAvanzados(String userId);
  Future<bool> puedeExportarReportes(String userId);
  
  Future<bool> puedeActivarSOS(String userId);
  Future<bool> puedeVerTerminalSOS(String userId);
  Future<bool> puedeGestionarEmergencias(String userId);
  
  Future<bool> puedeGestionarUsuarios(String userId);
  Future<bool> puedeGestionarMunicipios(String userId);
  Future<bool> puedeConfigurarSistema(String userId);
}

// Clases para manejo de errores
class PermissionFailure implements Exception {
  
  const PermissionFailure(
    this.message, {
    this.code,
    this.originalError,
  });
  final String message;
  final String? code;
  final dynamic originalError;
  
  @override
  String toString() {
    return 'PermissionFailure: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

// Clases para parámetros de use cases
class VerifyPermissionParams {
  
  const VerifyPermissionParams({
    required this.userId,
    required this.permiso,
  });
  final String userId;
  final TipoPermiso permiso;
}

class VerifyGestantePermissionParams {
  
  const VerifyGestantePermissionParams({
    required this.userId,
    required this.gestanteId,
    required this.permiso,
  });
  final String userId;
  final String gestanteId;
  final TipoPermiso permiso;
}

class UpdateUserPermissionsParams {
  
  const UpdateUserPermissionsParams({
    required this.userId,
    required this.nuevosPermisos,
  });
  final String userId;
  final Set<TipoPermiso> nuevosPermisos;
}
