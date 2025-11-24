/// Helper para gestión de permisos jerárquicos
/// Implementa la matriz de permisos del sistema
library;

class PermissionsHelper {
  // Roles del sistema
  static const String superAdmin = 'SUPER_ADMIN';
  static const String admin = 'ADMIN';
  static const String coordinador = 'COORDINADOR';
  static const String medico = 'MEDICO';
  static const String madrina = 'MADRINA';
  static const String gestante = 'GESTANTE';
  static const String familiar = 'FAMILIAR';

  /// Obtener roles que un usuario puede crear según su rol
  static List<String> getRolesCanCreate(String userRole) {
    switch (userRole.toUpperCase()) {
      case superAdmin:
        return [superAdmin, admin, coordinador, medico, madrina];
      
      case admin:
        return [admin, coordinador, medico, madrina];
      
      case coordinador:
        return [madrina];
      
      default:
        return [];
    }
  }

  /// Verificar si un usuario puede crear un rol específico
  static bool canCreateRole(String userRole, String targetRole) {
    final allowedRoles = getRolesCanCreate(userRole);
    return allowedRoles.contains(targetRole.toUpperCase());
  }

  /// Verificar si un usuario puede asignar gestantes
  static bool canAssignGestantes(String userRole) {
    return [superAdmin, admin, coordinador].contains(userRole.toUpperCase());
  }

  /// Verificar si un usuario puede crear IPS
  static bool canCreateIPS(String userRole) {
    return [superAdmin, admin].contains(userRole.toUpperCase());
  }

  /// Verificar si un usuario puede crear médicos
  static bool canCreateMedicos(String userRole) {
    return [superAdmin, admin].contains(userRole.toUpperCase());
  }

  /// Verificar si un usuario puede ver todos los usuarios
  static bool canViewAllUsers(String userRole) {
    return [superAdmin, admin].contains(userRole.toUpperCase());
  }

  /// Verificar si un usuario puede editar otro usuario
  static bool canEditUser(String userRole, String targetUserRole) {
    // Super admin puede editar a todos
    if (userRole.toUpperCase() == superAdmin) return true;
    
    // Admin puede editar a todos excepto super admins
    if (userRole.toUpperCase() == admin) {
      return targetUserRole.toUpperCase() != superAdmin;
    }
    
    // Coordinador puede editar solo madrinas
    if (userRole.toUpperCase() == coordinador) {
      return targetUserRole.toUpperCase() == madrina;
    }
    
    return false;
  }

  /// Verificar si un usuario puede eliminar otro usuario
  static bool canDeleteUser(String userRole, String targetUserRole) {
    // Super admin puede eliminar a todos excepto otros super admins
    if (userRole.toUpperCase() == superAdmin) {
      return targetUserRole.toUpperCase() != superAdmin;
    }
    
    // Admin puede eliminar coordinadores, médicos y madrinas
    if (userRole.toUpperCase() == admin) {
      return [coordinador, medico, madrina].contains(targetUserRole.toUpperCase());
    }
    
    // Coordinador no puede eliminar
    return false;
  }

  /// Obtener nombre legible del rol
  static String getRoleName(String role) {
    switch (role.toUpperCase()) {
      case superAdmin:
        return 'Super Administrador';
      case admin:
        return 'Administrador';
      case coordinador:
        return 'Coordinador';
      case medico:
        return 'Médico';
      case madrina:
        return 'Madrina Comunitaria';
      case gestante:
        return 'Gestante';
      case familiar:
        return 'Familiar';
      default:
        return role;
    }
  }

  /// Obtener lista de DropdownMenuItems según permisos del usuario
  static List<Map<String, String>> getRoleDropdownItems(String userRole) {
    final allowedRoles = getRolesCanCreate(userRole);
    
    return allowedRoles.map((role) => {
      'value': role,
      'label': getRoleName(role),
    }).toList();
  }

  /// Verificar si un rol es administrativo
  static bool isAdministrativeRole(String role) {
    return [superAdmin, admin, coordinador].contains(role.toUpperCase());
  }

  /// Verificar si un rol es clínico
  static bool isClinicalRole(String role) {
    return [medico, madrina].contains(role.toUpperCase());
  }

  /// Obtener nivel jerárquico del rol (mayor número = mayor jerarquía)
  static int getRoleLevel(String role) {
    switch (role.toUpperCase()) {
      case superAdmin:
        return 5;
      case admin:
        return 4;
      case coordinador:
        return 3;
      case medico:
        return 2;
      case madrina:
        return 2;
      case gestante:
        return 1;
      case familiar:
        return 1;
      default:
        return 0;
    }
  }

  /// Verificar si userRole tiene mayor jerarquía que targetRole
  static bool hasHigherHierarchy(String userRole, String targetRole) {
    return getRoleLevel(userRole) > getRoleLevel(targetRole);
  }

  /// Obtener descripción de permisos del rol
  static String getRoleDescription(String role) {
    switch (role.toUpperCase()) {
      case superAdmin:
        return 'Acceso completo al sistema. Puede crear administradores y gestionar todo.';
      case admin:
        return 'Gestiona su municipio. Puede crear coordinadores, médicos, madrinas e IPS.';
      case coordinador:
        return 'Coordina un equipo de madrinas. Puede asignar gestantes a madrinas.';
      case medico:
        return 'Atiende gestantes. Puede crear controles y alertas médicas.';
      case madrina:
        return 'Acompaña gestantes. Puede registrar controles y activar alertas SOS.';
      case gestante:
        return 'Usuario gestante con acceso limitado a su información.';
      case familiar:
        return 'Familiar de gestante con acceso limitado.';
      default:
        return 'Rol sin descripción';
    }
  }

  /// Verificar permisos para módulos específicos
  static bool canAccessModule(String userRole, String module) {
    switch (module.toLowerCase()) {
      case 'usuarios':
        return [superAdmin, admin].contains(userRole.toUpperCase());
      
      case 'municipios':
        return userRole.toUpperCase() == superAdmin;
      
      case 'ips':
        return [superAdmin, admin, coordinador, medico].contains(userRole.toUpperCase());
      
      case 'medicos':
        return [superAdmin, admin, coordinador, medico].contains(userRole.toUpperCase());
      
      case 'gestantes':
        return true; // Todos pueden ver gestantes (filtradas por permisos)
      
      case 'controles':
        return true; // Todos pueden ver controles (filtrados por permisos)
      
      case 'alertas':
        return true; // Todos pueden ver alertas (filtradas por permisos)
      
      case 'reportes':
        return [superAdmin, admin, coordinador].contains(userRole.toUpperCase());
      
      case 'asignar_gestantes':
        return canAssignGestantes(userRole);
      
      default:
        return false;
    }
  }
}
