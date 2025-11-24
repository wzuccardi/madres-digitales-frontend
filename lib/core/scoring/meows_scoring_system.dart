/// Sistema de Puntuación MEOWS (Modified Early Obstetric Warning System)
/// Basado en guías clínicas: ACOG, RCOG, OMS
/// 
/// Este sistema detecta deterioro materno temprano mediante scoring
/// de signos vitales y síntomas críticos.
library;

enum AlertLevel {
  normal,      // Score 0-2: Rutina
  yellow,      // Score 3-4: Monitoreo aumentado
  red,         // Score ≥5 o disparador crítico: Emergencia
}

enum ConsciousnessLevel {
  alert,              // Alerta, orientada
  respondsToVoice,    // Responde a voz
  respondsToPain,     // Responde a dolor
  unconscious,        // Inconsciente
}

/// Resultado del scoring MEOWS
class MEOWSResult {

  const MEOWSResult({
    required this.totalScore,
    required this.alertLevel,
    required this.triggeredAlerts,
    required this.recommendations,
    required this.componentScores,
    required this.hasImmediateTrigger,
  });
  final int totalScore;
  final AlertLevel alertLevel;
  final List<String> triggeredAlerts;
  final List<String> recommendations;
  final Map<String, int> componentScores;
  final bool hasImmediateTrigger;

  bool get isNormal => alertLevel == AlertLevel.normal && !hasImmediateTrigger;
  bool get needsAttention => alertLevel != AlertLevel.normal || hasImmediateTrigger;
  bool get isCritical => alertLevel == AlertLevel.red || hasImmediateTrigger;
}

/// Sistema de scoring MEOWS
class MEOWSScoringSystem {
  
  /// Calcular score completo MEOWS
  static MEOWSResult calculateScore({
    int? respiratoryRate,
    int? heartRate,
    int? systolicBP,
    int? diastolicBP,
    double? temperature,
    ConsciousnessLevel? consciousness,
    double? bleedingML,
    bool? hasNeurologicalSymptoms,
    bool? hasFetalMovement,
    int? gestationalWeeks,
    bool? hasSepsisSymptoms,
  }) {
    final componentScores = <String, int>{};
    final triggeredAlerts = <String>[];
    final recommendations = <String>[];
    bool hasImmediateTrigger = false;

    // 1. FRECUENCIA RESPIRATORIA
    if (respiratoryRate != null) {
      final rrScore = _scoreRespiratoryRate(respiratoryRate);
      componentScores['respiratory_rate'] = rrScore;
      
      if (rrScore == 1) {
        triggeredAlerts.add('⚠️ Frecuencia respiratoria elevada (21-24 rpm)');
        recommendations.add('Monitorear cada 30 minutos');
      } else if (rrScore >= 2) {
        triggeredAlerts.add('🚨 Frecuencia respiratoria muy elevada (≥25 rpm)');
        recommendations.add('URGENTE: Evaluar dificultad respiratoria, saturación O₂');
      }
    }

    // 2. FRECUENCIA CARDÍACA
    if (heartRate != null) {
      final hrScore = _scoreHeartRate(heartRate);
      componentScores['heart_rate'] = hrScore;
      
      if (hrScore == 1) {
        triggeredAlerts.add('⚠️ Taquicardia leve (101-120 lpm)');
        recommendations.add('Evaluar causa: ansiedad, dolor, fiebre, anemia');
      } else if (hrScore >= 2) {
        triggeredAlerts.add('🚨 Taquicardia severa (>120 lpm)');
        recommendations.add('URGENTE: Descartar choque, sepsis, embolia pulmonar');
      }
    }

    // 3. TENSIÓN ARTERIAL SISTÓLICA
    if (systolicBP != null) {
      final sysScore = _scoreSystolicBP(systolicBP);
      componentScores['systolic_bp'] = sysScore;
      
      if (sysScore == 1) {
        triggeredAlerts.add('⚠️ Presión sistólica baja (91-100 mmHg)');
        recommendations.add('Hidratar y monitorear signos de choque');
      } else if (sysScore >= 3) {
        triggeredAlerts.add('🚨 HIPOTENSIÓN SEVERA (≤90 mmHg)');
        recommendations.add('EMERGENCIA: Iniciar reanimación con fluidos, descartar hemorragia');
        hasImmediateTrigger = true;
      }
    }

    // 4. TENSIÓN ARTERIAL DIASTÓLICA
    if (diastolicBP != null) {
      final diaScore = _scoreDiastolicBP(diastolicBP);
      componentScores['diastolic_bp'] = diaScore;
      
      if (diaScore == 1) {
        triggeredAlerts.add('⚠️ Presión diastólica baja (50-59 mmHg)');
      } else if (diaScore >= 2) {
        triggeredAlerts.add('🚨 Presión diastólica muy baja (≤50 mmHg)');
        recommendations.add('URGENTE: Evaluar perfusión periférica');
      }
    }

    // 5. TEMPERATURA
    if (temperature != null) {
      final tempScore = _scoreTemperature(temperature);
      componentScores['temperature'] = tempScore;
      
      if (tempScore >= 2) {
        triggeredAlerts.add('🚨 FIEBRE (≥38.0°C)');
        recommendations.add('Iniciar protocolo de sepsis materna: cultivos, antibióticos');
        hasImmediateTrigger = true;
      }
    }

    // 6. NIVEL DE CONCIENCIA
    if (consciousness != null) {
      final consScore = _scoreConsciousness(consciousness);
      componentScores['consciousness'] = consScore;
      
      if (consScore == 2) {
        triggeredAlerts.add('⚠️ Alteración de conciencia (responde a voz)');
        recommendations.add('Evaluar neurológicamente, descartar eclampsia');
      } else if (consScore >= 3) {
        triggeredAlerts.add('🚨 ALTERACIÓN SEVERA DE CONCIENCIA');
        recommendations.add('EMERGENCIA: Proteger vía aérea, evaluar eclampsia/ACV');
        hasImmediateTrigger = true;
      }
    }

    // 7. DISPARADORES INMEDIATOS (no suman al score, activan alerta roja directa)

    // Hemorragia
    if (bleedingML != null) {
      if (bleedingML > 500 && bleedingML <= 1000) {
        triggeredAlerts.add('⚠️ HEMORRAGIA MODERADA (>500 ml)');
        recommendations.add('Activar protocolo de hemorragia obstétrica');
      } else if (bleedingML > 1000) {
        triggeredAlerts.add('🚨 HEMORRAGIA MASIVA (>1000 ml)');
        recommendations.add('CÓDIGO ROJO: Activar equipo de hemorragia, transfusión masiva');
        hasImmediateTrigger = true;
      }
    }

    // Síntomas neurológicos + hipertensión (preeclampsia severa)
    if (hasNeurologicalSymptoms == true && systolicBP != null && systolicBP >= 140) {
      triggeredAlerts.add('🚨 PREECLAMPSIA SEVERA (síntomas neurológicos + HTA)');
      recommendations.add('EMERGENCIA: Sulfato de magnesio, antihipertensivos, evaluar terminación');
      hasImmediateTrigger = true;
    }

    // Ausencia de movimientos fetales
    if (gestationalWeeks != null && gestationalWeeks >= 20) {
      if (hasFetalMovement == false) {
        triggeredAlerts.add('🚨 AUSENCIA DE MOVIMIENTOS FETALES');
        recommendations.add('EMERGENCIA OBSTÉTRICA: Monitoreo fetal inmediato (NST)');
        hasImmediateTrigger = true;
      }
    }

    // Sospecha de sepsis
    if (hasSepsisSymptoms == true) {
      triggeredAlerts.add('🚨 SOSPECHA DE SEPSIS MATERNA');
      recommendations.add('EMERGENCIA: Protocolo sepsis-6 (cultivos, antibióticos, fluidos)');
      hasImmediateTrigger = true;
    }

    // Calcular score total
    final totalScore = componentScores.values.fold(0, (sum, score) => sum + score);

    // Determinar nivel de alerta
    AlertLevel alertLevel;
    if (hasImmediateTrigger) {
      alertLevel = AlertLevel.red;
    } else if (totalScore >= 5) {
      alertLevel = AlertLevel.red;
      triggeredAlerts.add('🚨 SCORE MEOWS CRÍTICO (≥5 puntos)');
      recommendations.add('ALERTA ROJA: Llamar equipo obstétrico, traslado a observación');
    } else if (totalScore >= 3) {
      alertLevel = AlertLevel.yellow;
      triggeredAlerts.add('⚠️ Score MEOWS elevado (3-4 puntos)');
      recommendations.add('ALERTA AMARILLA: Reevaluar en 15-30 minutos, notificar enfermería');
    } else {
      alertLevel = AlertLevel.normal;
    }

    return MEOWSResult(
      totalScore: totalScore,
      alertLevel: alertLevel,
      triggeredAlerts: triggeredAlerts,
      recommendations: recommendations,
      componentScores: componentScores,
      hasImmediateTrigger: hasImmediateTrigger,
    );
  }

  // Funciones de scoring individuales

  static int _scoreRespiratoryRate(int rr) {
    if (rr <= 20) return 0;
    if (rr >= 21 && rr <= 24) return 1;
    return 2; // ≥25
  }

  static int _scoreHeartRate(int hr) {
    if (hr <= 100) return 0;
    if (hr >= 101 && hr <= 120) return 1;
    return 2; // >120
  }

  static int _scoreSystolicBP(int sys) {
    if (sys >= 101 && sys <= 140) return 0;
    if (sys >= 91 && sys <= 100) return 1;
    return 3; // ≤90
  }

  static int _scoreDiastolicBP(int dia) {
    if (dia > 60) return 0;
    if (dia >= 50 && dia <= 59) return 1;
    return 2; // ≤50
  }

  static int _scoreTemperature(double temp) {
    if (temp >= 36.0 && temp <= 37.9) return 0;
    return 2; // ≥38.0
  }

  static int _scoreConsciousness(ConsciousnessLevel level) {
    switch (level) {
      case ConsciousnessLevel.alert:
        return 0;
      case ConsciousnessLevel.respondsToVoice:
        return 2;
      case ConsciousnessLevel.respondsToPain:
      case ConsciousnessLevel.unconscious:
        return 3;
    }
  }

  /// Verificar si hay sospecha de sepsis
  /// Criterios: Fiebre ≥38 + (FR ≥22 o FC ≥100 o TAS ≤100)
  static bool checkSepsisSuspicion({
    double? temperature,
    int? respiratoryRate,
    int? heartRate,
    int? systolicBP,
  }) {
    if (temperature == null || temperature < 38.0) return false;

    return (respiratoryRate != null && respiratoryRate >= 22) ||
           (heartRate != null && heartRate >= 100) ||
           (systolicBP != null && systolicBP <= 100);
  }

  /// Obtener color según nivel de alerta
  static String getAlertColor(AlertLevel level) {
    switch (level) {
      case AlertLevel.normal:
        return '#4CAF50'; // Verde
      case AlertLevel.yellow:
        return '#FF9800'; // Naranja
      case AlertLevel.red:
        return '#F44336'; // Rojo
    }
  }

  /// Obtener descripción del nivel de alerta
  static String getAlertDescription(AlertLevel level) {
    switch (level) {
      case AlertLevel.normal:
        return 'Normal - Rutina';
      case AlertLevel.yellow:
        return 'Alerta Amarilla - Monitoreo Aumentado';
      case AlertLevel.red:
        return 'Alerta Roja - Emergencia';
    }
  }
}
