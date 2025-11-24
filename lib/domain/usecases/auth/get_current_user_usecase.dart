import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/interfaces/usecase.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';


/// Caso de uso para obtener el usuario actual autenticado
/// 
/// Este caso de uso se encarga de obtener el usuario
/// que está actualmente autenticado en el sistema.
class GetCurrentUserUseCase implements NoParamsUseCase<Result<User?, AppError>> {

  GetCurrentUserUseCase(this._authRepository);
  final AuthRepository _authRepository;

  @override
  Future<Result<User?, AppError>> call() async {
    final result = await _authRepository.getCurrentUser();
    return result;
  }
}
