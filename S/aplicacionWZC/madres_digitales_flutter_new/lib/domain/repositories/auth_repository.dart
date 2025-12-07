import '../../domain/entities/user.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';


/// Interfaz abstracta para el repositorio de autenticación
/// Define los contratos para operaciones de autenticación en la capa de dominio
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña
  /// 
  /// [email] Correo electrónico del usuario
  /// [password] Contraseña del usuario
  /// 
  /// Retorna [User] si la autenticación es exitosa
  /// Lanza [AuthException] si hay un error de autenticación
  Future<Result<User, AppError>> signIn({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario
  /// 
  /// [name] Nombre completo del usuario
  /// [email] Correo electrónico del usuario
  /// [password] Contraseña del usuario
  /// [role] Rol del usuario (opcional, por defecto 'gestante')
  /// [documento] Número de documento (opcional)
  /// [tipoDocumento] Tipo de documento (opcional)
  /// [telefono] Teléfono (opcional)
  /// [municipioId] ID del municipio (opcional)
  /// 
  /// Retorna [User] si el registro es exitoso
  /// Lanza [AuthException] si hay un error de registro
  Future<Result<User, AppError>> signUp({
    required String name,
    required String email,
    required String password,
    String? role,
    String? documento,
    String? tipoDocumento,
    String? telefono,
    String? municipioId,
  });

  /// Cierra la sesión del usuario actual
  /// 
  /// Lanza [AuthException] si hay un error al cerrar sesión
  Future<Result<void, AppError>> signOut();

  /// Refresca el token de autenticación
  /// 
  /// [refreshToken] Token de refresco
  /// 
  /// Retorna el nuevo token de acceso
  /// Lanza [AuthException] si hay un error al refrescar el token
  Future<Result<String, AppError>> refreshToken(String refreshToken);

  /// Obtiene el usuario actual autenticado
  /// 
  /// Retorna [User] si hay un usuario autenticado
  /// Retorna null si no hay usuario autenticado
  /// Lanza [AuthException] si hay un error al obtener el usuario
  Future<Result<User?, AppError>> getCurrentUser();

  /// Envía un correo de restablecimiento de contraseña
  /// 
  /// [email] Correo electrónico del usuario
  /// 
  /// Lanza [AuthException] si hay un error al enviar el correo
  Future<Result<void, AppError>> sendPasswordResetEmail(String email);

  /// Restablece la contraseña con un token
  /// 
  /// [token] Token de restablecimiento
  /// [newPassword] Nueva contraseña
  /// 
  /// Lanza [AuthException] si hay un error al restablecer la contraseña
  Future<Result<void, AppError>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Cambia la contraseña del usuario actual
  /// 
  /// [currentPassword] Contraseña actual
  /// [newPassword] Nueva contraseña
  /// 
  /// Lanza [AuthException] si hay un error al cambiar la contraseña
  Future<Result<void, AppError>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Verifica si el usuario está autenticado
  /// 
  /// Retorna true si hay un usuario autenticado
  /// Lanza [AuthException] si hay un error al verificar la autenticación
  Future<Result<bool, AppError>> isAuthenticated();

  /// Obtiene el token de acceso actual
  /// 
  /// Retorna el token de acceso si existe
  /// Retorna null si no hay token
  /// Lanza [AuthException] si hay un error al obtener el token
  Future<Result<String?, AppError>> getAccessToken();

  /// Guarda el token de acceso
  /// 
  /// [token] Token de acceso a guardar
  /// 
  /// Lanza [AuthException] si hay un error al guardar el token
  Future<Result<void, AppError>> saveAccessToken(String token);

  /// Elimina el token de acceso
  /// 
  /// Lanza [AuthException] si hay un error al eliminar el token
  Future<Result<void, AppError>> removeAccessToken();
}

/// Excepción base para errores de autenticación
abstract class AuthException implements Exception {
  
  const AuthException(this.message, {this.code});
  final String message;
  final String? code;
  
  @override
  String toString() => 'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}
