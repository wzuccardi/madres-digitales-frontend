import '../../repositories/auth_repository.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/interfaces/usecase.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';

/// Parámetros para el caso de uso de refresh token
class RefreshTokenParams {

  const RefreshTokenParams({
    required this.refreshToken,
  });
  final String refreshToken;
}

/// Caso de uso para refrescar el token de autenticación
/// 
/// Este caso de uso se encarga de refrescar el token de acceso
/// usando el refresh token almacenado, extendiendo la sesión del usuario.
class RefreshTokenUseCase implements UseCase<Result<String, AppError>, RefreshTokenParams> {

  RefreshTokenUseCase(this._authRepository);
  final AuthRepository _authRepository;

  @override
  Future<Result<String, AppError>> call(RefreshTokenParams params) async {
    // Validar que el refresh token no esté vacío
    if (params.refreshToken.isEmpty) {
      return const Result.failure(ValidationError('El refresh token no puede estar vacío'));
    }

    final result = await _authRepository.refreshToken(params.refreshToken);
    return result;
  }
}
