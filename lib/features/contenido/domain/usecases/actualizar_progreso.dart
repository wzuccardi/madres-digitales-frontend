import '../../../../core/usecases/usecase.dart';
import '../repositories/contenido_repository.dart';

class ActualizarProgresoParams {
  final String contenidoId;
  final int? tiempoVisualizado;
  final double? porcentaje;
  final bool? completado;

  ActualizarProgresoParams({
    required this.contenidoId,
    this.tiempoVisualizado,
    this.porcentaje,
    this.completado,
  });
}

class ActualizarProgresoUseCase implements UseCase<void, ActualizarProgresoParams> {
  final ContenidoRepository repository;

  ActualizarProgresoUseCase(this.repository);

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