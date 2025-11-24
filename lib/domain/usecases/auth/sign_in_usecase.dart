import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/interfaces/usecase.dart';
/// Parámetros para el caso de uso de inicio de sesión
class SignInParams {

  const SignInParams({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;
}

/// Caso de uso para iniciar sesión de usuario
/// 
/// Este caso de uso se encarga de validar las credenciales del usuario
/// y retornar el usuario autenticado si las credenciales son válidas.
class SignInUseCase implements UseCase<Result<User, AppError>, SignInParams> {

  SignInUseCase(this._authRepository);
  final AuthRepository _authRepository;

  @override
  Future<Result<User, AppError>> call(SignInParams params) async {
    // Validaciones mínimas locales
    bool isValidEmail(String v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    if (!isValidEmail(params.email)) {
      return const Result.failure(ValidationError('Email inválido'));
    }
    if (params.password.length < 6) {
      return const Result.failure(ValidationError('La contraseña debe tener al menos 6 caracteres'));
    }

    final result = await _authRepository.signIn(
      email: params.email,
      password: params.password,
    );
    return result;
  }
}
