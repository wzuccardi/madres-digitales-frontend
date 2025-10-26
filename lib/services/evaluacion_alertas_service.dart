import '../utils/logger.dart';

class EvaluacionAlertasService {
  static const Map<String, Map<String, dynamic>> _criteriosAlertas = {
    'hipertension_severa': {
      'condicion': 'sistolica >= 160 || diastolica >= 110',
      'prioridad': 'critica',
      'mensaje': 'Hipertensión severa detectada',
      'recomendacion': 'Requiere atención médica inmediata',
    },
    'hipertension_moderada': {
      'condicion': 'sistolica >= 140 || diastolica >= 90',
      'prioridad': 'alta',
      'mensaje': 'Hipertensión moderada detectada',
      'recomendacion': 'Monitoreo frecuente requerido',
    },
    'hipotension': {
      'condicion': 'sistolica < 90 || diastolica < 60',
      'prioridad': 'media',
      'mensaje': 'Hipotensión detectada',
      'recomendacion': 'Evaluar hidratación y posición',
    },
    'bradicardia_fetal': {
      'condicion': 'fcf < 110',
      'prioridad': 'critica',
      'mensaje': 'Bradicardia fetal detectada',
      'recomendacion': 'Evaluación obstétrica urgente',
    },
    'taquicardia_fetal': {
      'condicion': 'fcf > 160',
      'prioridad': 'alta',
      'mensaje': 'Taquicardia fetal detectada',
      'recomendacion': 'Monitoreo fetal continuo',
    },
    'ganancia_peso_excesiva': {
      'condicion': 'ganancia_peso > 2.0 && semanas > 20',
      'prioridad': 'alta',
      'mensaje': 'Ganancia de peso excesiva',
      'recomendacion': 'Evaluar retención de líquidos y dieta',
    },
    'perdida_peso': {
      'condicion': 'ganancia_peso < -1.0',
      'prioridad': 'media',
      'mensaje': 'Pérdida de peso detectada',
      'recomendacion': 'Evaluar nutrición y bienestar fetal',
    },
    'amenaza_parto_pretermino': {
      'condicion': 'semanas < 37 && contracciones_frecuentes',
      'prioridad': 'critica',
      'mensaje': 'Posible amenaza de parto pretérmino',
      'recomendacion': 'Evaluación obstétrica inmediata',
    },
  };

  /// Evalúa los datos de un control prenatal y retorna las alertas detectadas
  static List<AlertaEvaluada> evaluarControl(Map<String, dynamic> datosControl) {
    final alertas = <AlertaEvaluada>[];

    try {
      // Extraer valores del control
      final sistolica = datosControl['presionSistolica'] as double?;
      final diastolica = datosControl['presionDiastolica'] as double?;
      final peso = datosControl['peso'] as double?;
      final pesoAnterior = datosControl['pesoAnterior'] as double?;
      final fcf = datosControl['frecuenciaCardiacaFetal'] as double?;
      final semanas = datosControl['semanasGestacion'] as int?;
      final contracciones = datosControl['contracionesFrecuentes'] as bool? ?? false;

      // Evaluar presión arterial
      if (sistolica != null && diastolica != null) {
        if (sistolica >= 160 || diastolica >= 110) {
          alertas.add(_crearAlerta(
            'hipertension_severa',
            'Presión arterial crítica: ${sistolica.toInt()}/${diastolica.toInt()} mmHg',
            datosControl,
          ));
        } else if (sistolica >= 140 || diastolica >= 90) {
          alertas.add(_crearAlerta(
            'hipertension_moderada',
            'Presión arterial elevada: ${sistolica.toInt()}/${diastolica.toInt()} mmHg',
            datosControl,
          ));
        } else if (sistolica < 90 || diastolica < 60) {
          alertas.add(_crearAlerta(
            'hipotension',
            'Presión arterial baja: ${sistolica.toInt()}/${diastolica.toInt()} mmHg',
            datosControl,
          ));
        }
      }

      // Evaluar frecuencia cardíaca fetal
      if (fcf != null) {
        if (fcf < 110) {
          alertas.add(_crearAlerta(
            'bradicardia_fetal',
            'Bradicardia fetal: ${fcf.toInt()} lpm',
            datosControl,
          ));
        } else if (fcf > 160) {
          alertas.add(_crearAlerta(
            'taquicardia_fetal',
            'Taquicardia fetal: ${fcf.toInt()} lpm',
            datosControl,
          ));
        }
      }

      // Evaluar ganancia de peso
      if (peso != null && pesoAnterior != null && semanas != null) {
        final ganancia = peso - pesoAnterior;
        if (ganancia > 2.0 && semanas > 20) {
          alertas.add(_crearAlerta(
            'ganancia_peso_excesiva',
            'Ganancia de peso excesiva: +${ganancia.toStringAsFixed(1)} kg',
            datosControl,
          ));
        } else if (ganancia < -1.0) {
          alertas.add(_crearAlerta(
            'perdida_peso',
            'Pérdida de peso: ${ganancia.toStringAsFixed(1)} kg',
            datosControl,
          ));
        }
      }

      // Evaluar amenaza de parto pretérmino
      if (semanas != null && semanas < 37 && contracciones) {
        alertas.add(_crearAlerta(
          'amenaza_parto_pretermino',
          'Posible amenaza de parto pretérmino: $semanas semanas',
          datosControl,
        ));
      }

      appLogger.info('EvaluacionAlertasService: ${alertas.length} alertas detectadas');
      return alertas;

    } catch (e) {
      appLogger.error('EvaluacionAlertasService: Error evaluando control', error: e);
      return [];
    }
  }

  /// Evalúa múltiples controles y detecta patrones de riesgo
  static List<AlertaEvaluada> evaluarPatronesRiesgo(List<Map<String, dynamic>> controles) {
    final alertas = <AlertaEvaluada>[];

    if (controles.length < 2) return alertas;

    try {
      // Ordenar controles por fecha
      controles.sort((a, b) {
        final fechaA = DateTime.parse(a['fechaControl'] as String);
        final fechaB = DateTime.parse(b['fechaControl'] as String);
        return fechaA.compareTo(fechaB);
      });

      // Evaluar tendencias de presión arterial
      _evaluarTendenciaPresion(controles, alertas);

      // Evaluar tendencias de peso
      _evaluarTendenciaPeso(controles, alertas);

      // Evaluar frecuencia de controles
      _evaluarFrecuenciaControles(controles, alertas);

      appLogger.info('EvaluacionAlertasService: ${alertas.length} alertas de patrones detectadas');
      return alertas;

    } catch (e) {
      appLogger.error('EvaluacionAlertasService: Error evaluando patrones', error: e);
      return [];
    }
  }

  static void _evaluarTendenciaPresion(List<Map<String, dynamic>> controles, List<AlertaEvaluada> alertas) {
    final presiones = controles
        .where((c) => c['presionSistolica'] != null && c['presionDiastolica'] != null)
        .map((c) => {
              'sistolica': c['presionSistolica'] as double,
              'diastolica': c['presionDiastolica'] as double,
              'fecha': DateTime.parse(c['fechaControl'] as String),
            })
        .toList();

    if (presiones.length < 3) return;

    // Verificar tendencia ascendente en presión sistólica
    var aumentosSistolica = 0;
    for (int i = 1; i < presiones.length; i++) {
      if ((presiones[i]['sistolica'] as double) > (presiones[i - 1]['sistolica'] as double)) {
        aumentosSistolica++;
      }
    }

    if (aumentosSistolica >= presiones.length - 1) {
      alertas.add(AlertaEvaluada(
        tipo: 'tendencia_hipertension',
        prioridad: 'alta',
        mensaje: 'Tendencia ascendente en presión arterial',
        recomendacion: 'Monitoreo estrecho y evaluación de preeclampsia',
        datosControl: controles.last,
      ));
    }
  }

  static void _evaluarTendenciaPeso(List<Map<String, dynamic>> controles, List<AlertaEvaluada> alertas) {
    final pesos = controles
        .where((c) => c['peso'] != null)
        .map((c) => {
              'peso': c['peso'] as double,
              'fecha': DateTime.parse(c['fechaControl'] as String),
              'semanas': c['semanasGestacion'] as int?,
            })
        .toList();

    if (pesos.length < 3) return;

    // Calcular ganancia de peso total
    final pesoInicial = pesos.first['peso'] as double;
    final pesoActual = pesos.last['peso'] as double;
    final semanasActuales = pesos.last['semanas'] as int?;

    if (semanasActuales != null) {
      final gananciaTotal = pesoActual - pesoInicial;
      final gananciaEsperada = _calcularGananciaEsperada(semanasActuales);

      if (gananciaTotal > gananciaEsperada * 1.5) {
        alertas.add(AlertaEvaluada(
          tipo: 'ganancia_peso_total_excesiva',
          prioridad: 'alta',
          mensaje: 'Ganancia de peso total excesiva: ${gananciaTotal.toStringAsFixed(1)} kg',
          recomendacion: 'Evaluación nutricional y descarte de diabetes gestacional',
          datosControl: controles.last,
        ));
      }
    }
  }

  static void _evaluarFrecuenciaControles(List<Map<String, dynamic>> controles, List<AlertaEvaluada> alertas) {
    if (controles.length < 2) return;

    final ultimoControl = DateTime.parse(controles.last['fechaControl'] as String);
    final penultimoControl = DateTime.parse(controles[controles.length - 2]['fechaControl'] as String);
    final diasSinControl = DateTime.now().difference(ultimoControl).inDays;
    final intervaloPrevio = ultimoControl.difference(penultimoControl).inDays;

    // Control vencido
    if (diasSinControl > 30) {
      alertas.add(AlertaEvaluada(
        tipo: 'control_vencido',
        prioridad: 'media',
        mensaje: 'Control prenatal vencido: $diasSinControl días sin control',
        recomendacion: 'Programar control prenatal urgente',
        datosControl: controles.last,
      ));
    }

    // Intervalos irregulares
    if (intervaloPrevio > 45) {
      alertas.add(AlertaEvaluada(
        tipo: 'controles_irregulares',
        prioridad: 'baja',
        mensaje: 'Intervalos irregulares entre controles',
        recomendacion: 'Reforzar importancia de controles regulares',
        datosControl: controles.last,
      ));
    }
  }

  static double _calcularGananciaEsperada(int semanas) {
    // Ganancia de peso esperada según semanas de gestación
    if (semanas <= 12) return 1.5;
    if (semanas <= 20) return 4.0;
    if (semanas <= 28) return 7.0;
    if (semanas <= 36) return 11.0;
    return 12.5;
  }

  static AlertaEvaluada _crearAlerta(String tipo, String mensaje, Map<String, dynamic> datosControl) {
    final criterio = _criteriosAlertas[tipo]!;
    return AlertaEvaluada(
      tipo: tipo,
      prioridad: criterio['prioridad'] as String,
      mensaje: mensaje,
      recomendacion: criterio['recomendacion'] as String,
      datosControl: datosControl,
    );
  }

  /// Genera recomendaciones específicas basadas en el perfil de la gestante
  static List<String> generarRecomendaciones(Map<String, dynamic> perfilGestante, List<AlertaEvaluada> alertas) {
    final recomendaciones = <String>[];

    try {
      final edad = perfilGestante['edad'] as int?;
      final nivelRiesgo = perfilGestante['nivelRiesgo'] as String?;
      final semanasGestacion = perfilGestante['semanasGestacion'] as int?;

      // Recomendaciones por edad
      if (edad != null) {
        if (edad < 18) {
          recomendaciones.add('Gestante adolescente: Reforzar educación prenatal y apoyo nutricional');
        } else if (edad > 35) {
          recomendaciones.add('Gestante añosa: Monitoreo estrecho para complicaciones');
        }
      }

      // Recomendaciones por nivel de riesgo
      if (nivelRiesgo == 'alto' || nivelRiesgo == 'critico') {
        recomendaciones.add('Gestante de alto riesgo: Controles más frecuentes y seguimiento especializado');
      }

      // Recomendaciones por semanas de gestación
      if (semanasGestacion != null) {
        if (semanasGestacion >= 37) {
          recomendaciones.add('Embarazo a término: Preparar plan de parto y signos de alarma');
        } else if (semanasGestacion >= 34) {
          recomendaciones.add('Embarazo pretérmino tardío: Monitoreo de madurez pulmonar fetal');
        }
      }

      // Recomendaciones específicas por alertas
      for (final alerta in alertas) {
        if (alerta.prioridad == 'critica') {
          recomendaciones.add('URGENTE: ${alerta.recomendacion}');
        }
      }

      return recomendaciones;

    } catch (e) {
      appLogger.error('EvaluacionAlertasService: Error generando recomendaciones', error: e);
      return ['Error generando recomendaciones personalizadas'];
    }
  }
}

class AlertaEvaluada {
  final String tipo;
  final String prioridad;
  final String mensaje;
  final String recomendacion;
  final Map<String, dynamic> datosControl;

  AlertaEvaluada({
    required this.tipo,
    required this.prioridad,
    required this.mensaje,
    required this.recomendacion,
    required this.datosControl,
  });

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'nivelPrioridad': prioridad,
      'mensaje': mensaje,
      'observaciones': recomendacion,
      'esAutomatica': true,
      'fechaCreacion': DateTime.now().toIso8601String(),
      'resuelta': false,
    };
  }
}