import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

class AlertaTiempoRealWidget extends ConsumerStatefulWidget {
  final String? gestanteId;
  final Map<String, dynamic> signosVitales;
  final Function(List<AlertaDetectada>) onAlertasDetectadas;

  const AlertaTiempoRealWidget({
    super.key,
    this.gestanteId,
    required this.signosVitales,
    required this.onAlertasDetectadas,
  });

  @override
  ConsumerState<AlertaTiempoRealWidget> createState() => _AlertaTiempoRealWidgetState();
}

class _AlertaTiempoRealWidgetState extends ConsumerState<AlertaTiempoRealWidget> {
  List<AlertaDetectada> _alertasDetectadas = [];
  bool _evaluandoAlertas = false;

  @override
  void initState() {
    super.initState();
    _evaluarAlertas();
  }

  @override
  void didUpdateWidget(AlertaTiempoRealWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-evaluar alertas cuando cambien los signos vitales
    if (oldWidget.signosVitales != widget.signosVitales) {
      _evaluarAlertas();
    }
  }

  Future<void> _evaluarAlertas() async {
    if (widget.gestanteId == null) return;

    setState(() {
      _evaluandoAlertas = true;
    });

    try {
      final alertasDetectadas = await _detectarAlertasEnTiempoReal();
      
      setState(() {
        _alertasDetectadas = alertasDetectadas;
        _evaluandoAlertas = false;
      });

      // Notificar al widget padre sobre las alertas detectadas
      widget.onAlertasDetectadas(alertasDetectadas);

    } catch (e) {
      appLogger.error('Error evaluando alertas en tiempo real', error: e);
      setState(() {
        _evaluandoAlertas = false;
      });
    }
  }

  Future<List<AlertaDetectada>> _detectarAlertasEnTiempoReal() async {
    final alertas = <AlertaDetectada>[];
    final signos = widget.signosVitales;

    // Evaluar presión arterial
    if (signos['presionSistolica'] != null && signos['presionDiastolica'] != null) {
      final sistolica = signos['presionSistolica'] as double?;
      final diastolica = signos['presionDiastolica'] as double?;

      if (sistolica != null && diastolica != null) {
        // Hipertensión severa
        if (sistolica >= 160 || diastolica >= 110) {
          alertas.add(AlertaDetectada(
            tipo: 'hipertension_severa',
            prioridad: 'critica',
            mensaje: 'Presión arterial crítica: $sistolica/$diastolica mmHg',
            recomendacion: 'Requiere atención médica inmediata',
            icono: Icons.warning,
            color: Colors.red,
          ));
        }
        // Hipertensión moderada
        else if (sistolica >= 140 || diastolica >= 90) {
          alertas.add(AlertaDetectada(
            tipo: 'hipertension_moderada',
            prioridad: 'alta',
            mensaje: 'Presión arterial elevada: $sistolica/$diastolica mmHg',
            recomendacion: 'Monitoreo frecuente requerido',
            icono: Icons.priority_high,
            color: Colors.orange,
          ));
        }
        // Hipotensión
        else if (sistolica < 90 || diastolica < 60) {
          alertas.add(AlertaDetectada(
            tipo: 'hipotension',
            prioridad: 'media',
            mensaje: 'Presión arterial baja: $sistolica/$diastolica mmHg',
            recomendacion: 'Evaluar hidratación y posición',
            icono: Icons.info,
            color: Colors.blue,
          ));
        }
      }
    }

    // Evaluar peso
    if (signos['peso'] != null && signos['pesoAnterior'] != null) {
      final peso = signos['peso'] as double?;
      final pesoAnterior = signos['pesoAnterior'] as double?;

      if (peso != null && pesoAnterior != null) {
        final diferencia = peso - pesoAnterior;
        final semanasGestacion = signos['semanasGestacion'] as int? ?? 0;

        // Ganancia excesiva de peso
        if (diferencia > 2.0 && semanasGestacion > 20) {
          alertas.add(AlertaDetectada(
            tipo: 'ganancia_peso_excesiva',
            prioridad: 'alta',
            mensaje: 'Ganancia de peso excesiva: +${diferencia.toStringAsFixed(1)} kg',
            recomendacion: 'Evaluar retención de líquidos y dieta',
            icono: Icons.trending_up,
            color: Colors.orange,
          ));
        }
        // Pérdida de peso
        else if (diferencia < -1.0) {
          alertas.add(AlertaDetectada(
            tipo: 'perdida_peso',
            prioridad: 'media',
            mensaje: 'Pérdida de peso: ${diferencia.toStringAsFixed(1)} kg',
            recomendacion: 'Evaluar nutrición y bienestar fetal',
            icono: Icons.trending_down,
            color: Colors.blue,
          ));
        }
      }
    }

    // Evaluar frecuencia cardíaca fetal
    if (signos['frecuenciaCardiacaFetal'] != null) {
      final fcf = signos['frecuenciaCardiacaFetal'] as double?;
      
      if (fcf != null) {
        // Bradicardia fetal
        if (fcf < 110) {
          alertas.add(AlertaDetectada(
            tipo: 'bradicardia_fetal',
            prioridad: 'critica',
            mensaje: 'Bradicardia fetal: ${fcf.toInt()} lpm',
            recomendacion: 'Evaluación obstétrica urgente',
            icono: Icons.warning,
            color: Colors.red,
          ));
        }
        // Taquicardia fetal
        else if (fcf > 160) {
          alertas.add(AlertaDetectada(
            tipo: 'taquicardia_fetal',
            prioridad: 'alta',
            mensaje: 'Taquicardia fetal: ${fcf.toInt()} lpm',
            recomendacion: 'Monitoreo fetal continuo',
            icono: Icons.priority_high,
            color: Colors.orange,
          ));
        }
      }
    }

    // Evaluar semanas de gestación vs controles
    if (signos['semanasGestacion'] != null) {
      final semanas = signos['semanasGestacion'] as int?;
      
      if (semanas != null) {
        // Embarazo de alto riesgo por edad gestacional
        if (semanas >= 37 && signos['tipoControl'] == 'rutina') {
          alertas.add(AlertaDetectada(
            tipo: 'termino_completo',
            prioridad: 'media',
            mensaje: 'Embarazo a término: $semanas semanas',
            recomendacion: 'Preparar plan de parto',
            icono: Icons.baby_changing_station,
            color: Colors.green,
          ));
        }
        // Embarazo pretérmino
        else if (semanas < 37 && signos['contraccionesFrecuentes'] == true) {
          alertas.add(AlertaDetectada(
            tipo: 'amenaza_parto_pretermino',
            prioridad: 'critica',
            mensaje: 'Posible amenaza de parto pretérmino: $semanas semanas',
            recomendacion: 'Evaluación obstétrica inmediata',
            icono: Icons.warning,
            color: Colors.red,
          ));
        }
      }
    }

    return alertas;
  }

  @override
  Widget build(BuildContext context) {
    if (_alertasDetectadas.isEmpty && !_evaluandoAlertas) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _alertasDetectadas.any((a) => a.prioridad == 'critica') 
                ? Colors.red[50] 
                : Colors.orange[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: _alertasDetectadas.any((a) => a.prioridad == 'critica') 
                    ? Colors.red[700] 
                    : Colors.orange[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Evaluación en Tiempo Real',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _alertasDetectadas.any((a) => a.prioridad == 'critica') 
                        ? Colors.red[700] 
                        : Colors.orange[700],
                    ),
                  ),
                ),
                if (_evaluandoAlertas)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          if (_alertasDetectadas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: _alertasDetectadas.map((alerta) => 
                  _buildAlertaItem(alerta)
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertaItem(AlertaDetectada alerta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alerta.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: alerta.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(alerta.icono, color: alerta.color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alerta.mensaje,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: alerta.color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: alerta.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  alerta.prioridad.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            alerta.recomendacion,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class AlertaDetectada {
  final String tipo;
  final String prioridad;
  final String mensaje;
  final String recomendacion;
  final IconData icono;
  final Color color;

  AlertaDetectada({
    required this.tipo,
    required this.prioridad,
    required this.mensaje,
    required this.recomendacion,
    required this.icono,
    required this.color,
  });
}