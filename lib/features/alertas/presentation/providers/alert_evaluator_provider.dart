import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

class AlertEvaluatorParams {
  AlertEvaluatorParams({
    required this.gestanteId,
    this.sintomas,
    this.signos,
    this.latitud,
    this.longitud,
    this.mensaje,
  });
  final String gestanteId;
  final List<String>? sintomas;
  final Map<String, num>? signos; // presion_sistolica, presion_diastolica, frecuencia_cardiaca, temperatura, etc.
  final double? latitud;
  final double? longitud;
  final String? mensaje;
}

final alertEvaluatorProvider = Provider((ref) {
  Future<void> evaluateAndCreateIfNeeded(AlertEvaluatorParams params) async {
    final alertaService = ref.read(alertaServiceProvider);

    // Enviar al endpoint con evaluación automática. El backend semaforiza tipo/prioridad.
    await alertaService.crearAlertaConEvaluacion(
      gestanteId: params.gestanteId,
      tipoAlerta: 'sintomas_criticos',
      nivelPrioridad: 'media',
      mensaje: params.mensaje ?? 'Evaluación automática de signos/síntomas',
      sintomas: params.sintomas,
      latitud: params.latitud,
      longitud: params.longitud,
      signos: params.signos,
      evaluarAutomaticamente: true,
      sobrescribirConAutomatica: true,
    );
  }

  return evaluateAndCreateIfNeeded;
});

