import '../../../core/interfaces/usecase.dart';
import '../../entities/sos_alert.dart';
import '../../repositories/sos_repository.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/exceptions/exceptions.dart';

/// Parámetros para actualizar el estado de una alerta SOS
class UpdateSOSStatusParams {

  const UpdateSOSStatusParams({
    required this.alertaId,
    required this.nuevoEstado,
    this.atendidoPor,
    this.motivoCancelacion,
  });
  final String alertaId;
  final SOSAlertStatus nuevoEstado;
  final String? atendidoPor;
  final String? motivoCancelacion;
}

/// Caso de uso para actualizar el estado de una alerta SOS
class UpdateSOSStatusUseCase implements UseCase<SOSAlert, UpdateSOSStatusParams> {

  UpdateSOSStatusUseCase(this._repository);
  final SOSRepository _repository;

  @override
  Future<SOSAlert> call(UpdateSOSStatusParams params) async {
    try {
      return await _repository.actualizarEstadoAlerta(
        params.alertaId,
        params.nuevoEstado,
        atendidoPor: params.atendidoPor,
        motivoCancelacion: params.motivoCancelacion,
      );
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
      throw UnknownError('Error actualizando estado de alerta SOS: ${e.toString()}');
    }
  }
}
