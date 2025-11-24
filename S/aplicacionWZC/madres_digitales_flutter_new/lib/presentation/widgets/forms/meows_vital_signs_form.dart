import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/scoring/meows_scoring_system.dart';

/// Formulario de signos vitales con sistema MEOWS integrado
class MEOWSVitalSignsForm extends StatefulWidget {

  const MEOWSVitalSignsForm({
    super.key,
    required this.onDataChanged,
    this.gestationalWeeks,
  });
  final Function(Map<String, dynamic>) onDataChanged;
  final int? gestationalWeeks;

  @override
  State<MEOWSVitalSignsForm> createState() => _MEOWSVitalSignsFormState();
}

class _MEOWSVitalSignsFormState extends State<MEOWSVitalSignsForm> {
  final _temperaturaController = TextEditingController();
  final _sistolicaController = TextEditingController();
  final _diastolicaController = TextEditingController();
  final _frecuenciaCardiacaController = TextEditingController();
  final _frecuenciaRespiratoriaController = TextEditingController();
  final _sangradoController = TextEditingController();

  ConsciousnessLevel? _nivelConciencia = ConsciousnessLevel.alert;
  bool? _tieneMovimientos;
  bool? _sintomasNeurologicos;

  MEOWSResult? _meowsResult;

  @override
  void dispose() {
    _temperaturaController.dispose();
    _sistolicaController.dispose();
    _diastolicaController.dispose();
    _frecuenciaCardiacaController.dispose();
    _frecuenciaRespiratoriaController.dispose();
    _sangradoController.dispose();
    super.dispose();
  }

  void _calculateMEOWS() {
    final temp = double.tryParse(_temperaturaController.text);
    final systolic = int.tryParse(_sistolicaController.text);
    final diastolic = int.tryParse(_diastolicaController.text);
    final hr = int.tryParse(_frecuenciaCardiacaController.text);
    final rr = int.tryParse(_frecuenciaRespiratoriaController.text);
    final bleeding = double.tryParse(_sangradoController.text);

    // Verificar sospecha de sepsis
    final hasSepsis = MEOWSScoringSystem.checkSepsisSuspicion(
      temperature: temp,
      respiratoryRate: rr,
      heartRate: hr,
      systolicBP: systolic,
    );

    final result = MEOWSScoringSystem.calculateScore(
      respiratoryRate: rr,
      heartRate: hr,
      systolicBP: systolic,
      diastolicBP: diastolic,
      temperature: temp,
      consciousness: _nivelConciencia,
      bleedingML: bleeding,
      hasNeurologicalSymptoms: _sintomasNeurologicos,
      hasFetalMovement: _tieneMovimientos,
      gestationalWeeks: widget.gestationalWeeks,
      hasSepsisSymptoms: hasSepsis,
    );

    setState(() {
      _meowsResult = result;
    });

    // Notificar cambios
    widget.onDataChanged({
      'temperatura': temp,
      'presion_sistolica': systolic,
      'presion_diastolica': diastolic,
      'frecuencia_cardiaca': hr,
      'frecuencia_respiratoria': rr,
      'sangrado_ml': bleeding,
      'nivel_conciencia': _nivelConciencia?.toString(),
      'movimientos_fetales': _tieneMovimientos,
      'sintomas_neurologicos': _sintomasNeurologicos,
      'meows_score': result.totalScore,
      'alert_level': result.alertLevel.toString(),
      'is_critical': result.isCritical,
      'triggered_alerts': result.triggeredAlerts,
      'recommendations': result.recommendations,
    });
  }

  Color _getAlertColor() {
    if (_meowsResult == null) return Colors.grey;
    switch (_meowsResult!.alertLevel) {
      case AlertLevel.normal:
        return Colors.green;
      case AlertLevel.yellow:
        return Colors.orange;
      case AlertLevel.red:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel de Score MEOWS
          if (_meowsResult != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getAlertColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getAlertColor(), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getAlertColor(),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_meowsResult!.totalScore}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SCORE MEOWS: ${_meowsResult!.totalScore} puntos',
                              style: TextStyle(
                                color: _getAlertColor(),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              MEOWSScoringSystem.getAlertDescription(_meowsResult!.alertLevel),
                              style: TextStyle(
                                color: _getAlertColor().withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Alertas disparadas
                  if (_meowsResult!.triggeredAlerts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Alertas Detectadas:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._meowsResult!.triggeredAlerts.map((alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(child: Text(alert, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    )),
                  ],

                  // Recomendaciones
                  if (_meowsResult!.recommendations.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Recomendaciones:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._meowsResult!.recommendations.map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right, size: 16),
                          Expanded(
                            child: Text(
                              rec,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],

                  // Desglose de scores
                  if (_meowsResult!.componentScores.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Desglose de Puntuación:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _meowsResult!.componentScores.entries.map((entry) {
                        final label = _getComponentLabel(entry.key);
                        final score = entry.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: score == 0 ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$label: $score pt',
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Formulario de signos vitales
          const Text(
            'Signos Vitales',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Frecuencia Respiratoria
          _buildTextField(
            controller: _frecuenciaRespiratoriaController,
            label: 'Frecuencia Respiratoria (rpm)',
            hint: 'Ej: 18',
            icon: Icons.air,
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateMEOWS(),
          ),
          const SizedBox(height: 12),

          // Frecuencia Cardíaca
          _buildTextField(
            controller: _frecuenciaCardiacaController,
            label: 'Frecuencia Cardíaca (lpm)',
            hint: 'Ej: 75',
            icon: Icons.monitor_heart,
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateMEOWS(),
          ),
          const SizedBox(height: 12),

          // Presión Arterial
          const Text(
            'Presión Arterial (mmHg)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _sistolicaController,
                  label: 'Sistólica',
                  hint: '120',
                  icon: Icons.favorite,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _calculateMEOWS(),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('/', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: _buildTextField(
                  controller: _diastolicaController,
                  label: 'Diastólica',
                  hint: '80',
                  icon: Icons.favorite,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _calculateMEOWS(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Temperatura
          _buildTextField(
            controller: _temperaturaController,
            label: 'Temperatura (°C)',
            hint: 'Ej: 36.5',
            icon: Icons.thermostat,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _calculateMEOWS(),
          ),
          const SizedBox(height: 16),

          // Nivel de Conciencia
          const Text(
            'Nivel de Conciencia (AVPU)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ConsciousnessLevel>(
            value: _nivelConciencia,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.1),
            ),
            items: const [
              DropdownMenuItem(
                value: ConsciousnessLevel.alert,
                child: Text('Alerta (orientada, responde)'),
              ),
              DropdownMenuItem(
                value: ConsciousnessLevel.respondsToVoice,
                child: Text('Responde a voz'),
              ),
              DropdownMenuItem(
                value: ConsciousnessLevel.respondsToPain,
                child: Text('Responde a dolor'),
              ),
              DropdownMenuItem(
                value: ConsciousnessLevel.unconscious,
                child: Text('Inconsciente'),
              ),
            ],
            onChanged: (value) {
              setState(() => _nivelConciencia = value);
              _calculateMEOWS();
            },
          ),
          const SizedBox(height: 16),

          // Sangrado (si aplica)
          _buildTextField(
            controller: _sangradoController,
            label: 'Sangrado estimado (ml) - Opcional',
            hint: 'Ej: 300',
            icon: Icons.water_drop,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _calculateMEOWS(),
          ),
          const SizedBox(height: 16),

          // Síntomas neurológicos
          CheckboxListTile(
            title: const Text('¿Presenta síntomas neurológicos?'),
            subtitle: const Text('Cefalea intensa, escotomas, visión borrosa'),
            value: _sintomasNeurologicos ?? false,
            onChanged: (value) {
              setState(() => _sintomasNeurologicos = value);
              _calculateMEOWS();
            },
          ),

          // Movimientos fetales
          if (widget.gestationalWeeks != null && widget.gestationalWeeks! >= 20) ...[
            const Divider(),
            const Text(
              '¿Siente movimientos fetales?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Sí'),
                    value: true,
                    groupValue: _tieneMovimientos,
                    onChanged: (value) {
                      setState(() => _tieneMovimientos = value);
                      _calculateMEOWS();
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('No'),
                    value: false,
                    groupValue: _tieneMovimientos,
                    onChanged: (value) {
                      setState(() => _tieneMovimientos = value);
                      _calculateMEOWS();
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
      ),
    );
  }

  String _getComponentLabel(String key) {
    const labels = {
      'respiratory_rate': 'FR',
      'heart_rate': 'FC',
      'systolic_bp': 'TAS',
      'diastolic_bp': 'TAD',
      'temperature': 'Temp',
      'consciousness': 'Conciencia',
    };
    return labels[key] ?? key;
  }
}
