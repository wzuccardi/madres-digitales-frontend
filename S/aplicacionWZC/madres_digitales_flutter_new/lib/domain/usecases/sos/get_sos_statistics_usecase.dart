import '../../../core/interfaces/usecase.dart';
import '../../entities/sos_statistics.dart';
import '../../repositories/sos_repository.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/exceptions/exceptions.dart';

/// Caso de uso para obtener estadísticas de SOS
class GetSOSStatisticsUseCase implements NoParamsUseCase<SOSStatistics> {

  GetSOSStatisticsUseCase(this._repository);
  final SOSRepository _repository;

  @override
  Future<SOSStatistics> call() async {
    try {
      return await _repository.obtenerEstadisticasSOS();
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
      throw UnknownError('Error obteniendo estadísticas de SOS: ${e.toString()}');
    }
  }
}
