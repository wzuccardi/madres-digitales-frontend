import '../../repositories/auth_repository.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/interfaces/usecase.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';

/// Caso de uso para verificar si el usuario está autenticado
/// 
/// Este caso de uso se encarga de verificar si existe un token
/// de autenticación válido y si el usuario está autenticado.
class VerifyTokenUseCase implements NoParamsUseCase<Result<bool, AppError>> {

  VerifyTokenUseCase(this._authRepository);
  final AuthRepository _authRepository;

  @override
  Future<Result<bool, AppError>> call() async {
    final result = await _authRepository.isAuthenticated();
    return result;
  }
}
