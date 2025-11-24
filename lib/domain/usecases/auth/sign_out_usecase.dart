import '../../repositories/auth_repository.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/interfaces/usecase.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';

/// Caso de uso para cerrar sesión del usuario
/// 
/// Este caso de uso se encarga de cerrar la sesión del usuario
/// y limpiar los tokens de autenticación almacenados.
class SignOutUseCase implements NoParamsUseCase<Result<void, AppError>> {

  SignOutUseCase(this._authRepository);
  final AuthRepository _authRepository;

  @override
  Future<Result<void, AppError>> call() async {
    final result = await _authRepository.signOut();
    return result;
  }
}
