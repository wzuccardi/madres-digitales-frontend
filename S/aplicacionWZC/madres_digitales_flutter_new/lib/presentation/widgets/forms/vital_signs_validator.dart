import 'package:flutter/material.dart';

/// Resultado de validación de signos vitales
class ValidationResult {

  const ValidationResult({
    required this.isNormal,
    required this.message,
    required this.color,
    required this.icon,
    this.recommendation,
  });
  final bool isNormal;
  final String message;
  final Color color;
  final IconData icon;
  final String? recommendation;

  static const ValidationResult normal = ValidationResult(
    isNormal: true,
    message: 'Normal',
    color: Colors.green,
    icon: Icons.check_circle,
  );
}

/// Servicio de validación de signos vitales
class VitalSignsValidator {
  
  /// Validar temperatura
  static ValidationResult validateTemperature(double? temp) {
    if (temp == null) {
      return const ValidationResult(
        isNormal: true,
        message: '',
        color: Colors.grey,
        icon: Icons.info_outline,
      );
    }

    if (temp < 35.0) {
      return const ValidationResult(
        isNormal: false,
        message: '❄️ HIPOTERMIA - Temperatura muy baja',
        color: Colors.blue,
        icon: Icons.ac_unit,
        recommendation: 'Abrigar a la paciente y buscar atención médica inmediata',
      );
    } else if (temp >= 35.0 && temp < 36.0) {
      return const ValidationResult(
        isNormal: false,
        message: '⚠️ Temperatura baja',
        color: Colors.orange,
        icon: Icons.warning,
        recommendation: 'Monitorear y abrigar a la paciente',
      );
    } else if (temp >= 36.0 && temp <= 37.5) {
      return ValidationResult.normal;
    } else if (temp > 37.5 && temp < 38.0) {
      return const ValidationResult(
        isNormal: false,
        message: '⚠️ Temperatura elevada',
        color: Colors.orange,
        icon: Icons.warning,
        recommendation: 'Monitorear evolución',
      );
    } else if (temp >= 38.0 && temp < 39.0) {
      return const ValidationResult(
        isNormal: false,
        message: '🔥 FIEBRE - Temperatura alta',
        color: Colors.red,
        icon: Icons.local_fire_department,
        recommendation: 'Administrar antipiréticos y buscar causa',
      );
    } else {
      return const ValidationResult(
        isNormal: false,
        message: '🚨 FIEBRE ALTA - Temperatura muy elevada',
        color: Colors.red,
        icon: Icons.emergency,
        recommendation: 'ATENCIÓN MÉDICA URGENTE - Riesgo de sepsis',
      );
    }
  }

  /// Validar presión arterial
  static ValidationResult validateBloodPressure(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) {
      return const ValidationResult(
        isNormal: true,
        message: '',
        color: Colors.grey,
        icon: Icons.info_outline,
      );
    }

    // Hipotensión severa
    if (systolic < 90 || diastolic < 60) {
      return const ValidationResult(
        isNormal: false,
        message: '🚨 HIPOTENSIÓN SEVERA',
        color: Colors.red,
        icon: Icons.emergency,
        recommendation: 'ATENCIÓN URGENTE - Riesgo de shock',
      );
    }
    
    // Hipotensión
    if (systolic < 100 || diastolic < 65) {
      return const ValidationResult(
        isNormal: false,
        message: '⚠️ Presión arterial baja',
        color: Colors.orange,
        icon: Icons.warning,
        recommendation: 'Hidratar y monitorear',
      );
    }

    // Normal
    if (systolic >= 100 && systolic < 140 && diastolic >= 65 && diastolic < 90) {
      return ValidationResult.normal;
    }

    // Hipertensión leve
    if ((systolic >= 140 && systolic < 160) || (diastolic >= 90 && diastolic < 110)) {
      return const ValidationResult(
        isNormal: false,
        message: '⚠️ HIPERTENSIÓN - Presión elevada',
        color: Colors.orange,
        icon: Icons.warning,
        recommendation: 'Monitorear y evaluar riesgo de preeclampsia',
      );
    }

    // Hipertensión severa / Crisis hipertensiva
    return const ValidationResult(
      isNormal: false,
      message: '🚨 CRISIS HIPERTENSIVA',
      color: Colors.red,
      icon: Icons.emergency,
      recommendation: 'EMERGENCIA - Riesgo de preeclampsia/eclampsia. Atención inmediata',
    );
  }

  /// Validar frecuencia cardíaca
  static ValidationResult validateHeartRate(int? hr) {
    if (hr == null) {
      return const ValidationResult(
        isNormal: true,
        message: '',
        color: Colors.grey,
        icon: Icons.info_outline,
      );
    }

    if (hr < 50) {
      return const ValidationResult(
        isNormal: false,
        message: '🚨 BRADICARDIA SEVERA',
        color: Colors.red,
        icon: Icons.emergency,
        recommendation: 'Atención médica urgente',
      );
    } else if (hr >= 50 && hr < 60) {
      return const ValidationResult(
        isNormal: false,
        message: '⚠️ Frecuencia cardíaca baja',
        color: Colors.orange,
        icon: Icons.warning,
        recommendation: 'Monitorear',
      );
    } else if (hr >= 60 && hr <= 100) {
      return ValidationResult.normal;
    } else if (hr > 100 && hr <= 120) {
      return const ValidationResult(
        isNormal: false,
        message: '⚠️ TAQUICARDIA - Frecuencia elevada',
        color: Colors.orange,
        icon: Icons.warning,
        recommendation: 'Evaluar causa (ansiedad, fiebre, anemia)',
      );
    } else {
      return const ValidationResult(
        isNormal: false,
        message: '🚨 TAQUICARDIA SEVERA',
        color: Colors.red,
        icon: Icons.emergency,
        recommendation: 'Atención urgente - Riesgo cardiovascular',
      );
    }
  }

  /// Validar peso (ganancia semanal)
  static ValidationResult validateWeightGain(double? currentWeight, double? previousWeight, int? weeksBetween) {
    if (currentWeight == null || previousWeight == null || weeksBetween == null || weeksBetween == 0) {
      return const ValidationResult(
        isNormal: true,
        message: '',
        color: Colors.grey,
        icon: Icons.info_outline,
      );
    }

    final weightGain = currentWeight - previousWeight;
    final weeklyGain = weightGain / weeksBetween;

    if (weeklyGain < 0) {
      return const ValidationResult(
        isNormal: false,
        message: '⚠️ PÉRDIDA DE PESO',
        color: Colors.red,
        icon: Icons.warning,
        recommendation: 'Evaluar nutrición y descartar complicaciones',
      );
    } else if (weeklyGain >= 0 && weeklyGain < 0.3) {
      return const ValidationResult(
        isNormal: false,
        message: '⚠️ Ganancia de peso insuficiente',
        color: Colors.orange,
        icon: Icons.warning,
        recommendation: 'Mejorar nutrición',
      );
    } else if (weeklyGain >= 0.3 && weeklyGain <= 0.5) {
      return ValidationResult.normal;
    } else if (weeklyGain > 0.5 && weeklyGain <= 1.0) {
      return const ValidationResult(
        isNormal: false,
        message: '⚠️ Ganancia de peso elevada',
        color: Colors.orange,
        icon: Icons.warning,
        recommendation: 'Monitorear retención de líquidos',
      );
    } else {
      return const ValidationResult(
        isNormal: false,
        message: '🚨 GANANCIA EXCESIVA DE PESO',
        color: Colors.red,
        icon: Icons.emergency,
        recommendation: 'Evaluar preeclampsia y retención de líquidos',
      );
    }
  }

  /// Validar edemas
  static ValidationResult validateEdema(bool? hasEdema, String? location) {
    if (hasEdema == null || !hasEdema) {
      return ValidationResult.normal;
    }

    if (location != null && (location.contains('cara') || location.contains('manos'))) {
      return const ValidationResult(
        isNormal: false,
        message: '🚨 EDEMA EN CARA/MANOS',
        color: Colors.red,
        icon: Icons.emergency,
        recommendation: 'Signo de preeclampsia - Evaluar presión arterial',
      );
    }

    return const ValidationResult(
      isNormal: false,
      message: '⚠️ Edema presente',
      color: Colors.orange,
      icon: Icons.warning,
      recommendation: 'Monitorear evolución y presión arterial',
    );
  }

  /// Validar movimientos fetales
  static ValidationResult validateFetalMovement(bool? hasMovement, int? gestationalWeeks) {
    if (gestationalWeeks == null || gestationalWeeks < 20) {
      return const ValidationResult(
        isNormal: true,
        message: 'Aún no se esperan movimientos',
        color: Colors.grey,
        icon: Icons.info_outline,
      );
    }

    if (hasMovement == null) {
      return const ValidationResult(
        isNormal: true,
        message: '',
        color: Colors.grey,
        icon: Icons.info_outline,
      );
    }

    if (!hasMovement) {
      return const ValidationResult(
        isNormal: false,
        message: '🚨 AUSENCIA DE MOVIMIENTOS FETALES',
        color: Colors.red,
        icon: Icons.emergency,
        recommendation: 'EMERGENCIA OBSTÉTRICA - Atención inmediata',
      );
    }

    return const ValidationResult(
      isNormal: true,
      message: '✅ Movimientos fetales presentes',
      color: Colors.green,
      icon: Icons.check_circle,
    );
  }

  /// Validar altura uterina vs semanas de gestación
  static ValidationResult validateUterineHeight(double? height, int? gestationalWeeks) {
    if (height == null || gestationalWeeks == null || gestationalWeeks < 20) {
      return const ValidationResult(
        isNormal: true,
        message: '',
        color: Colors.grey,
        icon: Icons.info_outline,
      );
    }

    final expectedHeight = gestationalWeeks.toDouble();
    final difference = (height - expectedHeight).abs();

    if (difference <= 2) {
      return ValidationResult.normal;
    } else if (difference <= 4) {
      return ValidationResult(
        isNormal: false,
        message: height < expectedHeight 
            ? '⚠️ Altura uterina menor a lo esperado'
            : '⚠️ Altura uterina mayor a lo esperado',
        color: Colors.orange,
        icon: Icons.warning,
        recommendation: height < expectedHeight
            ? 'Evaluar crecimiento fetal'
            : 'Descartar polihidramnios o embarazo múltiple',
      );
    } else {
      return ValidationResult(
        isNormal: false,
        message: height < expectedHeight
            ? '🚨 RESTRICCIÓN DE CRECIMIENTO'
            : '🚨 CRECIMIENTO EXCESIVO',
        color: Colors.red,
        icon: Icons.emergency,
        recommendation: 'Requiere ecografía y evaluación especializada',
      );
    }
  }
}

/// Widget que muestra el resultado de validación
class ValidationMessageWidget extends StatelessWidget {

  const ValidationMessageWidget({
    super.key,
    required this.result,
    this.showRecommendation = true,
  });
  final ValidationResult result;
  final bool showRecommendation;

  @override
  Widget build(BuildContext context) {
    if (result.message.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: result.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: result.color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(result.icon, color: result.color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.message,
                  style: TextStyle(
                    color: result.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (showRecommendation && result.recommendation != null) ...[
            const SizedBox(height: 8),
            Text(
              result.recommendation!,
              style: TextStyle(
                color: result.color.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
