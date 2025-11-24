import '../../../core/interfaces/usecase.dart';
import '../../entities/sos_alert.dart';
import '../../repositories/sos_repository.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/exceptions/exceptions.dart';

/// Caso de uso para obtener alertas SOS activas
class GetActiveSOSAlertsUseCase implements NoParamsUseCase<List<SOSAlert>> {

  GetActiveSOSAlertsUseCase(this._repository);
  final SOSRepository _repository;

  @override
  Future<List<SOSAlert>> call() async {
    try {
      return await _repository.obtenerAlertasActivas();
    } on NetworkException catch (e) {
      throw NetworkError(e.toString());
    } on ServerException catch (e) {
      throw ServerError(e.toString());
    } on TimeoutException catch (e) {
      throw TimeoutError(e.toString());
    } on SessionExpiredException catch (e) {
      throw SessionExpiredError(e.toString());
    } on InvalidTokenException catch (e) {
      throw InvalidTokenError(e.toString());
    } on AuthException catch (e) {
      throw AuthenticationError(e.toString());
    } catch (e) {
      throw UnknownError('Error obteniendo alertas activas: ${e.toString()}');
    }
  }
}
