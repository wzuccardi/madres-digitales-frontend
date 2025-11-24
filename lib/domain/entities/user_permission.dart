import 'tipo_permiso.dart';

class UserPermission {

  const UserPermission({
    required this.userId,
    required this.rol,
    required this.permisos,
    required this.metadata,
    required this.fechaActualizacion,
  });

  factory UserPermission.fromJson(Map<String, dynamic> json) {
    return UserPermission(
      userId: json['userId'] as String,
      rol: json['rol'] as String,
      permisos: (json['permisos'] as List<dynamic>)
          .map((p) => TipoPermiso.values.firstWhere(
                (e) => e.toString() == 'TipoPermiso.$p',
                orElse: () => TipoPermiso.verGestantesAsignadas,
              ))
          .toSet(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      fechaActualizacion: DateTime.parse(json['fechaActualizacion'] as String),
    );
  }
  final String userId;
  final String rol;
  final Set<TipoPermiso> permisos;
  final Map<String, dynamic> metadata;
  final DateTime fechaActualizacion;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'rol': rol,
      'permisos': permisos.map((p) => p.toString().split('.').last).toList(),
      'metadata': metadata,
      'fechaActualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  UserPermission copyWith({
    String? userId,
    String? rol,
    Set<TipoPermiso>? permisos,
    Map<String, dynamic>? metadata,
    DateTime? fechaActualizacion,
  }) {
    return UserPermission(
      userId: userId ?? this.userId,
      rol: rol ?? this.rol,
      permisos: permisos ?? this.permisos,
      metadata: metadata ?? this.metadata,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  bool tienePermiso(TipoPermiso permiso) => permisos.contains(permiso);
  
  bool tieneAlgunPermiso(Set<TipoPermiso> permisosRequeridos) {
    return permisosRequeridos.any((permiso) => permisos.contains(permiso));
  }
  
  bool tieneTodosPermisos(Set<TipoPermiso> permisosRequeridos) {
    return permisosRequeridos.every((permiso) => permisos.contains(permiso));
  }

  bool get tieneAccesoTotal => permisos.length == TipoPermiso.values.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPermission &&
        other.userId == userId &&
        other.rol == rol &&
        other.permisos == permisos &&
        other.metadata == metadata &&
        other.fechaActualizacion == fechaActualizacion;
  }

  @override
  int get hashCode => Object.hash(
        userId,
        rol,
        permisos,
        metadata,
        fechaActualizacion,
      );

  @override
  String toString() {
    return 'UserPermission{userId: $userId, rol: $rol, permisos: ${permisos.length}}';
  }

  // Métodos estáticos para crear instancias comunes
  static UserPermission fromRole(String userId, String roleName) {
    final rolePermissions = RolePermissions.getPermissionsForRole(roleName);
    return UserPermission(
      userId: userId,
      rol: roleName,
      permisos: rolePermissions,
      metadata: {'generatedFromRole': true},
      fechaActualizacion: DateTime.now(),
    );
  }

  static UserPermission madrina(String userId) {
    return fromRole(userId, 'madrina');
  }

  static UserPermission medico(String userId) {
    return fromRole(userId, 'medico');
  }

  static UserPermission coordinador(String userId) {
    return fromRole(userId, 'coordinador');
  }

  static UserPermission admin(String userId) {
    return fromRole(userId, 'admin');
  }

  static UserPermission superAdmin(String userId) {
    return fromRole(userId, 'super_admin');
  }

  // Métodos de utilidad para permisos específicos
  bool get puedeVerGestantesAsignadas => tienePermiso(TipoPermiso.verGestantesAsignadas);
  bool get puedeVerTodasGestantes => tienePermiso(TipoPermiso.verTodasGestantes);
  bool get puedeCrearGestante => tienePermiso(TipoPermiso.crearGestante);
  bool get puedeEditarGestante => tienePermiso(TipoPermiso.editarGestante);
  bool get puedeEliminarGestante => tienePermiso(TipoPermiso.eliminarGestante);
  bool get puedeAsignarGestante => tienePermiso(TipoPermiso.asignarGestante);
  
  bool get puedeVerControles => tienePermiso(TipoPermiso.verControles);
  bool get puedeCrearControl => tienePermiso(TipoPermiso.crearControl);
  bool get puedeEditarControl => tienePermiso(TipoPermiso.editarControl);
  
  bool get puedeVerAlertas => tienePermiso(TipoPermiso.verAlertas);
  bool get puedeCrearAlerta => tienePermiso(TipoPermiso.crearAlerta);
  bool get puedeGestionarAlertasCriticas => tienePermiso(TipoPermiso.gestionarAlertasCriticas);
  
  bool get puedeVerReportesBasicos => tienePermiso(TipoPermiso.verReportesBasicos);
  bool get puedeVerReportesAvanzados => tienePermiso(TipoPermiso.verReportesAvanzados);
  bool get puedeExportarReportes => tienePermiso(TipoPermiso.exportarReportes);
  
  bool get puedeActivarSOS => tienePermiso(TipoPermiso.activarSOS);
  bool get puedeVerTerminalSOS => tienePermiso(TipoPermiso.verTerminalSOS);
  bool get puedeGestionarEmergencias => tienePermiso(TipoPermiso.gestionarEmergencias);
  
  bool get puedeGestionarUsuarios => tienePermiso(TipoPermiso.gestionarUsuarios);
  bool get puedeGestionarMunicipios => tienePermiso(TipoPermiso.gestionarMunicipios);
  bool get puedeConfigurarSistema => tienePermiso(TipoPermiso.configurarSistema);
}

class RolePermissions {
  static Set<TipoPermiso> getPermissionsForRole(String roleName) {
    switch (roleName) {
      case 'super_admin':
        return Set<TipoPermiso>.from(TipoPermiso.values);
      case 'admin':
        return Set<TipoPermiso>.from(TipoPermiso.values)
          ..remove(TipoPermiso.configurarSistema);
      case 'coordinador':
        return {
          TipoPermiso.verGestantesAsignadas,
          TipoPermiso.verTodasGestantes,
          TipoPermiso.verControles,
          TipoPermiso.verAlertas,
          TipoPermiso.verReportes,
          TipoPermiso.verReportesBasicos,
          TipoPermiso.verReportesAvanzados,
          TipoPermiso.exportarReportes,
          TipoPermiso.gestionarEmergencias,
        };
      case 'medico':
        return {
          TipoPermiso.verGestantesAsignadas,
          TipoPermiso.verControles,
          TipoPermiso.crearControl,
          TipoPermiso.editarControl,
          TipoPermiso.verAlertas,
        };
      case 'madrina':
        return {
          TipoPermiso.verGestantesAsignadas,
          TipoPermiso.crearGestante,
          TipoPermiso.editarGestante,
          TipoPermiso.asignarGestante,
          TipoPermiso.verControles,
          TipoPermiso.verAlertas,
          TipoPermiso.activarSOS,
          TipoPermiso.verContenidos,
        };
      default:
        return {TipoPermiso.verGestantesAsignadas, TipoPermiso.verContenidos};
    }
  }
}
