import '../utils/logger.dart';

/// Servicio para calcular scores de riesgo y determinar prioridades automáticamente
class RiskScoringService {
  
  /// Calcula el score de riesgo total (0-100) basado en múltiples factores
  static RiskScore calcularScoreRiesgo(Map<String, dynamic> datosGestante) {
    try {
      double scoreTotal = 0.0;
      final factoresRiesgo = <String, double>{};
      
      // 1. Factores demográficos (peso: 15%)
      scoreTotal += _evaluarFactoresDemograficos(datosGestante, factoresRiesgo);
      
      // 2. Antecedentes médicos (peso: 20%)
      scoreTotal += _evaluarAntecedentesMedicos(datosGestante, factoresRiesgo);
      
      // 3. Signos vitales actuales (peso: 30%)
      scoreTotal += _evaluarSignosVitales(datosGestante, factoresRiesgo);
      
      // 4. Síntomas críticos (peso: 25%)
      scoreTotal += _evaluarSintomasCriticos(datosGestante, factoresRiesgo);
      
      // 5. Factores obstétricos (peso: 10%)
      scoreTotal += _evaluarFactoresObstetricos(datosGestante, factoresRiesgo);
      
      // Normalizar score a 0-100
      scoreTotal = scoreTotal.clamp(0.0, 100.0);
      
      // Determinar prioridad basada en score
      final prioridad = _determinarPrioridad(scoreTotal, factoresRiesgo);
      
      appLogger.info('RiskScoringService: Score calculado: ${scoreTotal.toStringAsFixed(1)}');
      
      return RiskScore(
        scoreTotal: scoreTotal,
        prioridad: prioridad,
        factoresRiesgo: factoresRiesgo,
        recomendaciones: _generarRecomendaciones(scoreTotal, factoresRiesgo),
      );
      
    } catch (e) {
      appLogger.error('RiskScoringService: Error calculando score', error: e);
      return RiskScore(
        scoreTotal: 0.0,
        prioridad: 'baja',
        factoresRiesgo: {},
        recomendaciones: ['Error en evaluación de riesgo'],
      );
    }
  }
  
  /// Evalúa factores demográficos (15% del score total)
  static double _evaluarFactoresDemograficos(Map<String, dynamic> datos, Map<String, double> factores) {
    double score = 0.0;
    
    // Edad materna
    final edad = datos['edad'] as int?;
    if (edad != null) {
      if (edad < 18) {
        score += 8.0; // Gestante adolescente
        factores['gestante_adolescente'] = 8.0;
      } else if (edad > 35) {
        score += 6.0; // Gestante añosa
        factores['gestante_anosa'] = 6.0;
      } else if (edad > 40) {
        score += 10.0; // Alto riesgo por edad
        factores['edad_muy_avanzada'] = 10.0;
      }
    }
    
    // Nivel socioeconómico
    final nivelSocioeconomico = datos['nivelSocioeconomico'] as String?;
    if (nivelSocioeconomico == 'bajo') {
      score += 3.0;
      factores['nivel_socioeconomico_bajo'] = 3.0;
    }
    
    // Acceso a servicios de salud
    final accesoSalud = datos['accesoSalud'] as String?;
    if (accesoSalud == 'limitado') {
      score += 2.0;
      factores['acceso_salud_limitado'] = 2.0;
    }
    
    return score;
  }
  
  /// Evalúa antecedentes médicos (20% del score total)
  static double _evaluarAntecedentesMedicos(Map<String, dynamic> datos, Map<String, double> factores) {
    double score = 0.0;
    
    // Diabetes pregestacional
    if (datos['diabetesPregestacional'] == true) {
      score += 12.0;
      factores['diabetes_pregestacional'] = 12.0;
    }
    
    // Hipertensión crónica
    if (datos['hipertensionCronica'] == true) {
      score += 10.0;
      factores['hipertension_cronica'] = 10.0;
    }
    
    // Antecedente de preeclampsia
    if (datos['antecedentePreeclampsia'] == true) {
      score += 8.0;
      factores['antecedente_preeclampsia'] = 8.0;
    }
    
    // Abortos previos
    final abortosPrevios = datos['abortosPrevios'] as int? ?? 0;
    if (abortosPrevios >= 2) {
      score += 6.0;
      factores['abortos_recurrentes'] = 6.0;
    }
    
    // Cesáreas previas
    final cesareasPrevias = datos['cesareasPrevias'] as int? ?? 0;
    if (cesareasPrevias >= 2) {
      score += 4.0;
      factores['cesareas_multiples'] = 4.0;
    }
    
    // Enfermedades crónicas
    final enfermedadesCronicas = datos['enfermedadesCronicas'] as List<String>? ?? [];
    if (enfermedadesCronicas.isNotEmpty) {
      score += enfermedadesCronicas.length * 2.0;
      factores['enfermedades_cronicas'] = enfermedadesCronicas.length * 2.0;
    }
    
    return score;
  }
  
  /// Evalúa signos vitales actuales (30% del score total)
  static double _evaluarSignosVitales(Map<String, dynamic> datos, Map<String, double> factores) {
    double score = 0.0;
    
    // Presión arterial
    final sistolica = datos['presionSistolica'] as double?;
    final diastolica = datos['presionDiastolica'] as double?;
    
    if (sistolica != null && diastolica != null) {
      if (sistolica >= 160 || diastolica >= 110) {
        score += 20.0; // Hipertensión severa
        factores['hipertension_severa'] = 20.0;
      } else if (sistolica >= 140 || diastolica >= 90) {
        score += 12.0; // Hipertensión moderada
        factores['hipertension_moderada'] = 12.0;
      } else if (sistolica < 90 || diastolica < 60) {
        score += 8.0; // Hipotensión
        factores['hipotension'] = 8.0;
      }
    }
    
    // Frecuencia cardíaca fetal
    final fcf = datos['frecuenciaCardiacaFetal'] as double?;
    if (fcf != null) {
      if (fcf < 110) {
        score += 15.0; // Bradicardia fetal crítica
        factores['bradicardia_fetal'] = 15.0;
      } else if (fcf > 160) {
        score += 10.0; // Taquicardia fetal
        factores['taquicardia_fetal'] = 10.0;
      }
    }
    
    // Temperatura
    final temperatura = datos['temperatura'] as double?;
    if (temperatura != null) {
      if (temperatura >= 38.5) {
        score += 8.0; // Fiebre alta
        factores['fiebre_alta'] = 8.0;
      } else if (temperatura >= 37.5) {
        score += 4.0; // Fiebre moderada
        factores['fiebre_moderada'] = 4.0;
      }
    }
    
    return score;
  }
  
  /// Evalúa síntomas críticos (25% del score total)
  static double _evaluarSintomasCriticos(Map<String, dynamic> datos, Map<String, double> factores) {
    double score = 0.0;
    
    // Hemorragia
    if (datos['hemorragia'] == true) {
      score += 20.0;
      factores['hemorragia'] = 20.0;
    }
    
    // Ausencia de movimientos fetales
    if (datos['ausenciaMovimientosFetales'] == true) {
      score += 18.0;
      factores['ausencia_movimientos_fetales'] = 18.0;
    }
    
    // Contracciones prematuras
    if (datos['contraccionesPematuras'] == true) {
      final semanas = datos['semanasGestacion'] as int? ?? 40;
      if (semanas < 37) {
        score += 15.0;
        factores['contracciones_prematuras'] = 15.0;
      }
    }
    
    // Cefalea severa
    if (datos['cefaleaSevera'] == true) {
      score += 8.0;
      factores['cefalea_severa'] = 8.0;
    }
    
    // Visión borrosa
    if (datos['visionBorrosa'] == true) {
      score += 6.0;
      factores['vision_borrosa'] = 6.0;
    }
    
    // Edema severo
    if (datos['edemaSevero'] == true) {
      score += 5.0;
      factores['edema_severo'] = 5.0;
    }
    
    // Dolor epigástrico
    if (datos['dolorEpigastrico'] == true) {
      score += 7.0;
      factores['dolor_epigastrico'] = 7.0;
    }
    
    return score;
  }
  
  /// Evalúa factores obstétricos (10% del score total)
  static double _evaluarFactoresObstetricos(Map<String, dynamic> datos, Map<String, double> factores) {
    double score = 0.0;
    
    // Embarazo múltiple
    if (datos['embarazoMultiple'] == true) {
      score += 6.0;
      factores['embarazo_multiple'] = 6.0;
    }
    
    // Placenta previa
    if (datos['placentaPrevia'] == true) {
      score += 8.0;
      factores['placenta_previa'] = 8.0;
    }
    
    // Restricción del crecimiento fetal
    if (datos['restriccionCrecimientoFetal'] == true) {
      score += 7.0;
      factores['restriccion_crecimiento_fetal'] = 7.0;
    }
    
    // Oligohidramnios
    if (datos['oligohidramnios'] == true) {
      score += 5.0;
      factores['oligohidramnios'] = 5.0;
    }
    
    return score;
  }
  
  /// Determina la prioridad basada en el score y factores críticos
  static String _determinarPrioridad(double score, Map<String, double> factores) {
    // Prioridad crítica por factores específicos
    if (factores.containsKey('hemorragia') || 
        factores.containsKey('bradicardia_fetal') ||
        factores.containsKey('hipertension_severa') ||
        factores.containsKey('ausencia_movimientos_fetales')) {
      return 'critica';
    }
    
    // Prioridad por score
    if (score >= 70) {
      return 'critica';
    } else if (score >= 50) {
      return 'alta';
    } else if (score >= 25) {
      return 'media';
    } else {
      return 'baja';
    }
  }
  
  /// Genera recomendaciones basadas en el score y factores
  static List<String> _generarRecomendaciones(double score, Map<String, double> factores) {
    final recomendaciones = <String>[];
    
    // Recomendaciones por factores críticos
    if (factores.containsKey('hemorragia')) {
      recomendaciones.add('URGENTE: Evaluación obstétrica inmediata por hemorragia');
    }
    
    if (factores.containsKey('bradicardia_fetal')) {
      recomendaciones.add('URGENTE: Monitoreo fetal continuo - bradicardia detectada');
    }
    
    if (factores.containsKey('hipertension_severa')) {
      recomendaciones.add('URGENTE: Control de presión arterial y evaluación de preeclampsia');
    }
    
    if (factores.containsKey('ausencia_movimientos_fetales')) {
      recomendaciones.add('URGENTE: Evaluación de bienestar fetal inmediata');
    }
    
    // Recomendaciones por score general
    if (score >= 70) {
      recomendaciones.add('Gestante de muy alto riesgo - Seguimiento especializado');
      recomendaciones.add('Controles prenatales semanales');
    } else if (score >= 50) {
      recomendaciones.add('Gestante de alto riesgo - Controles frecuentes');
      recomendaciones.add('Evaluación por especialista en medicina materno-fetal');
    } else if (score >= 25) {
      recomendaciones.add('Gestante de riesgo moderado - Controles regulares');
      recomendaciones.add('Educación sobre signos de alarma');
    }
    
    // Recomendaciones específicas por factores
    if (factores.containsKey('gestante_adolescente')) {
      recomendaciones.add('Reforzar educación prenatal y apoyo nutricional');
    }
    
    if (factores.containsKey('diabetes_pregestacional')) {
      recomendaciones.add('Control estricto de glicemia y seguimiento endocrinológico');
    }
    
    if (factores.containsKey('hipertension_cronica')) {
      recomendaciones.add('Monitoreo de presión arterial y función renal');
    }
    
    return recomendaciones;
  }
  
  /// Detecta múltiples síntomas simultáneos y ajusta prioridad
  static String evaluarSintomasMultiples(List<String> sintomas, String prioridadBase) {
    if (sintomas.length >= 3) {
      // Múltiples síntomas siempre elevan la prioridad
      if (prioridadBase == 'baja') return 'media';
      if (prioridadBase == 'media') return 'alta';
      if (prioridadBase == 'alta') return 'critica';
    }
    
    // Combinaciones específicas críticas
    final combinacionesCriticas = [
      ['hipertension', 'cefalea', 'vision_borrosa'], // Preeclampsia severa
      ['hemorragia', 'hipotension', 'taquicardia'], // Shock hemorrágico
      ['fiebre', 'taquicardia', 'hipotension'], // Sepsis
    ];
    
    for (final combinacion in combinacionesCriticas) {
      if (combinacion.every((sintoma) => sintomas.contains(sintoma))) {
        return 'critica';
      }
    }
    
    return prioridadBase;
  }
  
  /// Calcula tendencia de riesgo comparando scores históricos
  static TendenciaRiesgo calcularTendencia(List<RiskScore> scoresHistoricos) {
    if (scoresHistoricos.length < 2) {
      return TendenciaRiesgo(
        direccion: 'estable',
        cambio: 0.0,
        velocidad: 'normal',
      );
    }
    
    // Ordenar por fecha (más reciente primero)
    scoresHistoricos.sort((a, b) => b.fecha.compareTo(a.fecha));
    
    final scoreActual = scoresHistoricos.first.scoreTotal;
    final scoreAnterior = scoresHistoricos[1].scoreTotal;
    final cambio = scoreActual - scoreAnterior;
    
    String direccion;
    if (cambio > 5) {
      direccion = 'empeorando';
    } else if (cambio < -5) {
      direccion = 'mejorando';
    } else {
      direccion = 'estable';
    }
    
    String velocidad;
    if (cambio.abs() > 15) {
      velocidad = 'rapida';
    } else if (cambio.abs() > 8) {
      velocidad = 'moderada';
    } else {
      velocidad = 'lenta';
    }
    
    return TendenciaRiesgo(
      direccion: direccion,
      cambio: cambio,
      velocidad: velocidad,
    );
  }
}

/// Clase para representar el resultado del scoring de riesgo
class RiskScore {
  final double scoreTotal;
  final String prioridad;
  final Map<String, double> factoresRiesgo;
  final List<String> recomendaciones;
  final DateTime fecha;
  
  RiskScore({
    required this.scoreTotal,
    required this.prioridad,
    required this.factoresRiesgo,
    required this.recomendaciones,
    DateTime? fecha,
  }) : fecha = fecha ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'scoreTotal': scoreTotal,
      'prioridad': prioridad,
      'factoresRiesgo': factoresRiesgo,
      'recomendaciones': recomendaciones,
      'fecha': fecha.toIso8601String(),
    };
  }
}

/// Clase para representar la tendencia de riesgo
class TendenciaRiesgo {
  final String direccion; // 'mejorando', 'empeorando', 'estable'
  final double cambio;
  final String velocidad; // 'lenta', 'moderada', 'rapida'
  
  TendenciaRiesgo({
    required this.direccion,
    required this.cambio,
    required this.velocidad,
  });
}