import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/interfaces/usecase.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';


/// Parámetros para el caso de uso de registro de usuario
class SignUpParams {

  const SignUpParams({
    required this.name,
    required this.email,
    required this.password,
    this.role,
    this.documento,
    this.tipoDocumento,
    this.telefono,
    this.municipioId,
  });
  final String name;
  final String email;
  final String password;
  final String? role;
  final String? documento;
  final String? tipoDocumento;
  final String? telefono;
  final String? municipioId;
}

/// Caso de uso para registrar un nuevo usuario
/// 
/// Este caso de uso se encarga de validar los datos del usuario
/// y crear una nueva cuenta en el sistema.
class SignUpUseCase implements UseCase<Result<User, AppError>, SignUpParams> {

  SignUpUseCase(this._authRepository);
  final AuthRepository _authRepository;

  @override
  Future<Result<User, AppError>> call(SignUpParams params) async {
    // Validaciones mínimas locales
    if (params.name.trim().isEmpty) {
      return const Result.failure(ValidationError('El nombre es obligatorio'));
    }
    bool isValidEmail(String v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    if (!isValidEmail(params.email)) {
      return const Result.failure(ValidationError('Email inválido'));
    }
    if (params.password.length < 6) {
      return const Result.failure(ValidationError('La contraseña debe tener al menos 6 caracteres'));
    }

    final result = await _authRepository.signUp(
      name: params.name,
      email: params.email,
      password: params.password,
      role: params.role ?? 'gestante',
      documento: params.documento,
      tipoDocumento: params.tipoDocumento,
      telefono: params.telefono,
      municipioId: params.municipioId,
    );
    return result;
  }
}
