import 'package:madres_digitales_flutter_new/core/interfaces/usecase.dart';
import '../repositories/contenido_repository.dart';

class ActualizarProgresoParams {

  ActualizarProgresoParams({
    required this.contenidoId,
    this.tiempoVisualizado,
    this.porcentaje,
    this.completado,
  });
  final String contenidoId;
  final int? tiempoVisualizado;
  final double? porcentaje;
  final bool? completado;
}

class ActualizarProgresoUseCase implements UseCase<void, ActualizarProgresoParams> {

  ActualizarProgresoUseCase(this.repository);
  final ContenidoRepository repository;

  @override
  Future<void> call(ActualizarProgresoParams params) async {
    return await repository.actualizarProgreso(
      params.contenidoId,
      tiempoVisualizado: params.tiempoVisualizado,
      porcentaje: params.porcentaje,
      completado: params.completado,
    );
  }
}
