import '../../domain/entities/user.dart';


/// Interfaz abstracta para el repositorio de usuarios
/// Define los contratos para operaciones de gestión de usuarios en la capa de dominio
abstract class UserRepository {
  /// Obtiene todos los usuarios
  /// 
  /// [filters] Filtros opcionales para la consulta
  /// 
  /// Retorna una lista de usuarios
  /// Lanza [UserException] si hay un error en la consulta
  Future<List<User>> getAllUsers([Map<String, dynamic>? filters]);

  /// Obtiene un usuario por su ID
  /// 
  /// [id] ID del usuario
  /// 
  /// Retorna el usuario si existe
  /// Retorna null si no existe
  /// Lanza [UserException] si hay un error en la consulta
  Future<User?> getUserById(String id);

  /// Obtiene un usuario por su email
  /// 
  /// [email] Email del usuario
  /// 
  /// Retorna el usuario si existe
  /// Retorna null si no existe
  /// Lanza [UserException] si hay un error en la consulta
  Future<User?> getUserByEmail(String email);

  /// Obtiene usuarios por rol
  /// 
  /// [role] Rol a filtrar
  /// [filters] Filtros opcionales adicionales
  /// 
  /// Retorna una lista de usuarios con el rol especificado
  /// Lanza [UserException] si hay un error en la consulta
  Future<List<User>> getUsersByRole(String role, [Map<String, dynamic>? filters]);

  /// Obtiene usuarios por municipio
  /// 
  /// [municipalityId] ID del municipio
  /// [filters] Filtros opcionales adicionales
  /// 
  /// Retorna una lista de usuarios del municipio
  /// Lanza [UserException] si hay un error en la consulta
  Future<List<User>> getUsersByMunicipality(String municipalityId, [Map<String, dynamic>? filters]);

  /// Obtiene usuarios activos
  /// 
  /// [filters] Filtros opcionales para la consulta
  /// 
  /// Retorna una lista de usuarios activos
  /// Lanza [UserException] si hay un error en la consulta
  Future<List<User>> getActiveUsers([Map<String, dynamic>? filters]);

  /// Obtiene usuarios inactivos
  /// 
  /// [filters] Filtros opcionales para la consulta
  /// 
  /// Retorna una lista de usuarios inactivos
  /// Lanza [UserException] si hay un error en la consulta
  Future<List<User>> getInactiveUsers([Map<String, dynamic>? filters]);

  /// Obtiene el personal de salud (madrinas y médicos)
  /// 
  /// [filters] Filtros opcionales para la consulta
  /// 
  /// Retorna una lista de personal de salud
  /// Lanza [UserException] si hay un error en la consulta
  Future<List<User>> getHealthWorkers([Map<String, dynamic>? filters]);

  /// Obtiene las madrinas
  /// 
  /// [filters] Filtros opcionales para la consulta
  /// 
  /// Retorna una lista de madrinas
  /// Lanza [UserException] si hay un error en la consulta
  Future<List<User>> getMadrinas([Map<String, dynamic>? filters]);

  /// Obtiene los médicos
  /// 
  /// [filters] Filtros opcionales para la consulta
  /// 
  /// Retorna una lista de médicos
  /// Lanza [UserException] si hay un error en la consulta
  Future<List<User>> getMedicos([Map<String, dynamic>? filters]);

  /// Obtiene los administradores
  /// 
  /// [filters] Filtros opcionales para la consulta
  /// 
  /// Retorna una lista de administradores
  /// Lanza [UserException] si hay un error en la consulta
  Future<List<User>> getAdmins([Map<String, dynamic>? filters]);

  /// Crea un nuevo usuario
  /// 
  /// [user] Datos del usuario a crear
  /// [password] Contraseña del usuario
  /// 
  /// Retorna el usuario creado
  /// Lanza [UserException] si hay un error al crear
  Future<User> createUser(User user, String password);

  /// Actualiza un usuario existente
  /// 
  /// [user] Datos del usuario a actualizar
  /// 
  /// Retorna el usuario actualizado
  /// Lanza [UserException] si hay un error al actualizar
  Future<User> updateUser(User user);

  /// Elimina un usuario
  /// 
  /// [id] ID del usuario a eliminar
  /// 
  /// Lanza [UserException] si hay un error al eliminar
  Future<void> deleteUser(String id);

  /// Activa un usuario
  /// 
  /// [id] ID del usuario a activar
  /// 
  /// Lanza [UserException] si hay un error al activar
  Future<void> activateUser(String id);

  /// Desactiva un usuario
  /// 
  /// [id] ID del usuario a desactivar
  /// 
  /// Lanza [UserException] si hay un error al desactivar
  Future<void> deactivateUser(String id);

  /// Cambia el rol de un usuario
  /// 
  /// [id] ID del usuario
  /// [newRole] Nuevo rol
  /// 
  /// Lanza [UserException] si hay un error al cambiar el rol
  Future<void> changeUserRole(String id, String newRole);

  /// Actualiza la contraseña de un usuario
  /// 
  /// [id] ID del usuario
  /// [newPassword] Nueva contraseña
  /// 
  /// Lanza [UserException] si hay un error al actualizar la contraseña
  Future<void> updateUserPassword(String id, String newPassword);

  /// Restablece la contraseña de un usuario
  /// 
  /// [email] Email del usuario
  /// [resetToken] Token de restablecimiento
  /// [newPassword] Nueva contraseña
  /// 
  /// Lanza [UserException] si hay un error al restablecer la contraseña
  Future<void> resetUserPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  });

  /// Actualiza el último acceso de un usuario
  /// 
  /// [id] ID del usuario
  /// 
  /// Lanza [UserException] si hay un error al actualizar
  Future<void> updateUserLastAccess(String id);

  /// Actualiza la imagen de perfil de un usuario
  /// 
  /// [id] ID del usuario
  /// [profileImageUrl] URL de la imagen de perfil
  /// 
  /// Lanza [UserException] si hay un error al actualizar
  Future<void> updateUserProfileImage(String id, String profileImageUrl);

  /// Actualiza las preferencias de un usuario
  /// 
  /// [id] ID del usuario
  /// [preferences] Preferencias del usuario
  /// 
  /// Lanza [UserException] si hay un error al actualizar
  Future<void> updateUserPreferences(String id, Map<String, dynamic> preferences);

  /// Actualiza los metadatos de un usuario
  /// 
  /// [id] ID del usuario
  /// [metadata] Metadatos del usuario
  /// 
  /// Lanza [UserException] si hay un error al actualizar
  Future<void> updateUserMetadata(String id, Map<String, dynamic> metadata);

  /// Busca usuarios por criterios
  /// 
  /// [criteria] Criterios de búsqueda
  /// 
  /// Retorna una lista de usuarios que coinciden con los criterios
  /// Lanza [UserException] si hay un error en la búsqueda
  Future<List<User>> searchUsers(Map<String, dynamic> criteria);

  /// Obtiene estadísticas de usuarios
  /// 
  /// [filters] Filtros opcionales para las estadísticas
  /// 
  /// Retorna un mapa con estadísticas
  /// Lanza [UserException] si hay un error al obtener estadísticas
  Future<Map<String, dynamic>> getUserStats([Map<String, dynamic>? filters]);

  /// Obtiene una página de usuarios (paginación)
  /// 
  /// [page] Número de página (comienza en 1)
  /// [limit] Límite de elementos por página
  /// [filters] Filtros opcionales para la consulta
  /// 
  /// Retorna una lista de usuarios de la página especificada
  /// Lanza [UserException] si hay un error en la consulta
  Future<List<User>> getUsersPage({
    required int page,
    required int limit,
    Map<String, dynamic>? filters,
  });

  /// Obtiene el conteo total de usuarios
  /// 
  /// [filters] Filtros opcionales para el conteo
  /// 
  /// Retorna el número total de usuarios
  /// Lanza [UserException] si hay un error en el conteo
  Future<int> getUsersCount([Map<String, dynamic>? filters]);

  /// Verifica si un email ya está registrado
  /// 
  /// [email] Email a verificar
  /// 
  /// Retorna true si el email ya está registrado
  /// Lanza [UserException] si hay un error en la verificación
  Future<bool> isEmailRegistered(String email);

  /// Verifica si un documento ya está registrado
  /// 
  /// [document] Documento a verificar
  /// [documentType] Tipo de documento
  /// 
  /// Retorna true si el documento ya está registrado
  /// Lanza [UserException] si hay un error en la verificación
  Future<bool> isDocumentRegistered(String document, String documentType);
}

/// Excepciones específicas de usuarios
class UserException implements Exception {
  
  const UserException(this.message, {this.code});
  final String message;
  final String? code;
  
  @override
  String toString() => 'UserException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Excepción para usuario no encontrado
class UserNotFoundException extends UserException {
  const UserNotFoundException(super.message) : super(code: 'user_not_found');
}

/// Excepción para usuario ya existente
class UserAlreadyExistsException extends UserException {
  const UserAlreadyExistsException(super.message) : super(code: 'user_already_exists');
}

/// Excepción para email ya registrado
class EmailAlreadyRegisteredException extends UserException {
  const EmailAlreadyRegisteredException(super.message) : super(code: 'email_already_registered');
}

/// Excepción para documento ya registrado
class DocumentAlreadyRegisteredException extends UserException {
  const DocumentAlreadyRegisteredException(super.message) : super(code: 'document_already_registered');
}

/// Excepción para contraseña incorrecta
class IncorrectPasswordException extends UserException {
  const IncorrectPasswordException(super.message) : super(code: 'incorrect_password');
}

/// Excepción para rol inválido
class InvalidRoleException extends UserException {
  const InvalidRoleException(super.message) : super(code: 'invalid_role');
}

/// Excepción para datos inválidos de usuario
class InvalidUserDataException extends UserException {
  const InvalidUserDataException(super.message) : super(code: 'invalid_user_data');
}

/// Excepción para operación no permitida
class UserOperationNotAllowedException extends UserException {
  const UserOperationNotAllowedException(super.message) : super(code: 'operation_not_allowed');
}

/// Excepción para red no disponible
class UserNetworkException extends UserException {
  const UserNetworkException(super.message) : super(code: 'network_error');
}

/// Excepción para servidor no disponible
class UserServerException extends UserException {
  const UserServerException(super.message) : super(code: 'server_error');
}

/// Excepción para tiempo de espera agotado
class UserTimeoutException extends UserException {
  const UserTimeoutException(super.message) : super(code: 'timeout');
}

/// Excepción para conexión desconocida
class UserUnknownException extends UserException {
  const UserUnknownException(super.message) : super(code: 'unknown_error');
}
