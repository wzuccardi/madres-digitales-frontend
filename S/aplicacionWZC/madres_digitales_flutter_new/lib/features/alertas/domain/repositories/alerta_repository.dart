import '../../../../domain/entities/alerta.dart';

import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';

abstract class AlertaRepository {
  Future<Result<List<Alerta>, AppError>> fetchAlertas();
  Future<Result<Alerta, AppError>> createAlerta(Map<String, dynamic> data);
  Future<Result<void, AppError>> resolverAlerta(String id);
  Future<Result<void, AppError>> marcarComoLeida(String id);
}
