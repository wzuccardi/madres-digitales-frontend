import 'package:flutter/material.dart';

class InfoContextualWidget extends StatelessWidget {

  const InfoContextualWidget({
    super.key,
    required this.titulo,
    required this.contenido,
    this.icono = Icons.info_outline,
    this.color,
  });
  final String titulo;
  final String contenido;
  final IconData icono;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _mostrarInfo(context),
      child: Icon(
        icono,
        color: color ?? Colors.blue,
        size: 20,
      ),
    );
  }

  void _mostrarInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icono, color: color ?? Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(titulo)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(contenido),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

class PresionArterialInfoWidget extends StatelessWidget {
  const PresionArterialInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContextualWidget(
      titulo: 'Información sobre Presión Arterial',
      icono: Icons.favorite,
      color: Colors.red,
      contenido: '''
📊 VALORES NORMALES DE PRESIÓN ARTERIAL:

🟢 NORMAL:
• Sistólica: 90-119 mmHg
• Diastólica: 60-79 mmHg

🟡 ELEVADA:
• Sistólica: 120-129 mmHg
• Diastólica: menos de 80 mmHg

🟠 HIPERTENSIÓN ETAPA 1:
• Sistólica: 130-139 mmHg
• Diastólica: 80-89 mmHg

🔴 HIPERTENSIÓN ETAPA 2:
• Sistólica: 140 mmHg o más
• Diastólica: 90 mmHg o más

⚠️ CRISIS HIPERTENSIVA:
• Sistólica: más de 180 mmHg
• Diastólica: más de 120 mmHg

🤰 IMPORTANTE PARA GESTANTES:
• La presión alta puede indicar preeclampsia
• Valores altos requieren atención médica inmediata
• Monitoreo regular es esencial durante el embarazo

💡 CONSEJOS:
• Tomar la presión en reposo
• Evitar cafeína antes de la medición
• Usar el brazo derecho preferiblemente
• Registrar fecha y hora de la medición

🚨 CUÁNDO BUSCAR AYUDA:
• Presión sistólica > 140 mmHg
• Presión diastólica > 90 mmHg
• Síntomas como dolor de cabeza, visión borrosa
• Dolor en el pecho o dificultad para respirar
''',
    );
  }
}

class SintomasInfoWidget extends StatelessWidget {
  const SintomasInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContextualWidget(
      titulo: 'Síntomas de Alarma en el Embarazo',
      icono: Icons.warning_amber,
      color: Colors.orange,
      contenido: '''
🚨 SÍNTOMAS QUE REQUIEREN ATENCIÓN INMEDIATA:

🔴 SÍNTOMAS CRÍTICOS:
• Dolor de cabeza fuerte y persistente
• Visión borrosa o manchas en la vista
• Dolor abdominal intenso (parte superior)
• Sangrado vaginal abundante
• Contracciones regulares antes de las 37 semanas
• Pérdida de líquido amniótico

🟠 SÍNTOMAS IMPORTANTES:
• Hinchazón excesiva en cara, manos o pies
• Náuseas y vómitos severos
• Fiebre alta (más de 38°C)
• Dolor al orinar o ardor
• Disminución notable de movimientos del bebé

🟡 SÍNTOMAS A MONITOREAR:
• Acidez estomacal severa
• Estreñimiento persistente
• Dolor de espalda intenso
• Fatiga extrema
• Cambios en el flujo vaginal

💡 RECOMENDACIONES:
• Mantener un registro de síntomas
• No automedicarse
• Contactar inmediatamente al médico si presenta síntomas críticos
• Acudir a controles prenatales regulares

📞 CUÁNDO LLAMAR AL MÉDICO:
• Cualquier síntoma crítico
• Dudas sobre síntomas nuevos
• Cambios súbitos en el bienestar
• Preocupaciones sobre el bebé
''',
    );
  }
}

class ControlPrenatalInfoWidget extends StatelessWidget {
  const ControlPrenatalInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContextualWidget(
      titulo: 'Guía de Controles Prenatales',
      icono: Icons.medical_information,
      color: Colors.green,
      contenido: '''
📅 FRECUENCIA DE CONTROLES:

🗓️ PRIMER TRIMESTRE (0-12 semanas):
• Control mensual
• Exámenes de laboratorio iniciales
• Ecografía de confirmación

🗓️ SEGUNDO TRIMESTRE (13-28 semanas):
• Control cada 4 semanas
• Ecografía morfológica (18-22 semanas)
• Pruebas de glucosa

🗓️ TERCER TRIMESTRE (29-40 semanas):
• Control cada 2 semanas hasta semana 36
• Control semanal desde semana 37
• Monitoreo fetal

📋 QUÉ SE EVALÚA EN CADA CONTROL:
• Peso y talla
• Presión arterial
• Altura uterina
• Frecuencia cardíaca fetal
• Posición del bebé
• Análisis de orina

🔬 EXÁMENES IMPORTANTES:
• Hemograma completo
• Glicemia
• Pruebas de VIH, sífilis, hepatitis
• Cultivo de orina
• Ecografías programadas

⚠️ SEÑALES DE ALERTA:
• Presión arterial alta
• Proteínas en la orina
• Crecimiento inadecuado del bebé
• Posición anormal del bebé

💡 CONSEJOS PARA EL CONTROL:
• Llevar lista de preguntas
• Informar todos los síntomas
• Traer exámenes anteriores
• No faltar a las citas programadas
''',
    );
  }
}
