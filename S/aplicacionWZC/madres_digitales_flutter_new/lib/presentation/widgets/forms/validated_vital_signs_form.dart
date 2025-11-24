import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'vital_signs_validator.dart';

/// Formulario de signos vitales con validación en tiempo real
class ValidatedVitalSignsForm extends StatefulWidget {

  const ValidatedVitalSignsForm({
    super.key,
    required this.onDataChanged,
    this.gestationalWeeks,
  });
  final Function(Map<String, dynamic>) onDataChanged;
  final int? gestationalWeeks;

  @override
  State<ValidatedVitalSignsForm> createState() => _ValidatedVitalSignsFormState();
}

class _ValidatedVitalSignsFormState extends State<ValidatedVitalSignsForm> {
  final _temperaturaController = TextEditingController();
  final _sistolicaController = TextEditingController();
  final _diastolicaController = TextEditingController();
  final _frecuenciaCardiacaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaUterinaController = TextEditingController();

  ValidationResult _tempValidation = ValidationResult.normal;
  ValidationResult _bpValidation = ValidationResult.normal;
  ValidationResult _hrValidation = ValidationResult.normal;
  final ValidationResult _weightValidation = ValidationResult.normal;
  ValidationResult _heightValidation = ValidationResult.normal;
  ValidationResult _edemaValidation = ValidationResult.normal;
  ValidationResult _movementValidation = ValidationResult.normal;

  bool? _tieneEdemas;
  bool? _tieneMovimientos;

  @override
  void dispose() {
    _temperaturaController.dispose();
    _sistolicaController.dispose();
    _diastolicaController.dispose();
    _frecuenciaCardiacaController.dispose();
    _pesoController.dispose();
    _alturaUterinaController.dispose();
    super.dispose();
  }

  void _validateTemperature() {
    final temp = double.tryParse(_temperaturaController.text);
    setState(() {
      _tempValidation = VitalSignsValidator.validateTemperature(temp);
    });
    _notifyDataChanged();
  }

  void _validateBloodPressure() {
    final systolic = int.tryParse(_sistolicaController.text);
    final diastolic = int.tryParse(_diastolicaController.text);
    setState(() {
      _bpValidation = VitalSignsValidator.validateBloodPressure(systolic, diastolic);
    });
    _notifyDataChanged();
  }

  void _validateHeartRate() {
    final hr = int.tryParse(_frecuenciaCardiacaController.text);
    setState(() {
      _hrValidation = VitalSignsValidator.validateHeartRate(hr);
    });
    _notifyDataChanged();
  }

  void _validateUterineHeight() {
    final height = double.tryParse(_alturaUterinaController.text);
    setState(() {
      _heightValidation = VitalSignsValidator.validateUterineHeight(
        height,
        widget.gestationalWeeks,
      );
    });
    _notifyDataChanged();
  }

  void _validateEdema() {
    setState(() {
      _edemaValidation = VitalSignsValidator.validateEdema(_tieneEdemas, null);
    });
    _notifyDataChanged();
  }

  void _validateFetalMovement() {
    setState(() {
      _movementValidation = VitalSignsValidator.validateFetalMovement(
        _tieneMovimientos,
        widget.gestationalWeeks,
      );
    });
    _notifyDataChanged();
  }

  void _notifyDataChanged() {
    widget.onDataChanged({
      'temperatura': double.tryParse(_temperaturaController.text),
      'presion_sistolica': int.tryParse(_sistolicaController.text),
      'presion_diastolica': int.tryParse(_diastolicaController.text),
      'frecuencia_cardiaca': int.tryParse(_frecuenciaCardiacaController.text),
      'peso': double.tryParse(_pesoController.text),
      'altura_uterina': double.tryParse(_alturaUterinaController.text),
      'edemas': _tieneEdemas,
      'movimientos_fetales': _tieneMovimientos,
      'validations': {
        'temperatura': _tempValidation,
        'presion': _bpValidation,
        'frecuencia_cardiaca': _hrValidation,
        'altura_uterina': _heightValidation,
        'edemas': _edemaValidation,
        'movimientos': _movementValidation,
      },
      'has_critical_alerts': _hasCriticalAlerts(),
    });
  }

  bool _hasCriticalAlerts() {
    return !_tempValidation.isNormal ||
        !_bpValidation.isNormal ||
        !_hrValidation.isNormal ||
        !_heightValidation.isNormal ||
        !_edemaValidation.isNormal ||
        !_movementValidation.isNormal;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alerta general si hay valores críticos
          if (_hasCriticalAlerts()) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '⚠️ VALORES ANORMALES DETECTADOS',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Revise las recomendaciones en cada campo',
                          style: TextStyle(
                            color: Colors.red.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Temperatura
          _buildTextField(
            controller: _temperaturaController,
            label: 'Temperatura (°C)',
            hint: 'Ej: 36.5',
            icon: Icons.thermostat,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _validateTemperature(),
          ),
          ValidationMessageWidget(result: _tempValidation),
          const SizedBox(height: 16),

          // Presión Arterial
          const Text(
            'Presión Arterial',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  onChanged: (_) => _validateBloodPressure(),
                ),
              ),
              const SizedBox(width: 12),
              const Text('/', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _diastolicaController,
                  label: 'Diastólica',
                  hint: '80',
                  icon: Icons.favorite,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _validateBloodPressure(),
                ),
              ),
            ],
          ),
          ValidationMessageWidget(result: _bpValidation),
          const SizedBox(height: 16),

          // Frecuencia Cardíaca
          _buildTextField(
            controller: _frecuenciaCardiacaController,
            label: 'Frecuencia Cardíaca (lpm)',
            hint: 'Ej: 75',
            icon: Icons.monitor_heart,
            keyboardType: TextInputType.number,
            onChanged: (_) => _validateHeartRate(),
          ),
          ValidationMessageWidget(result: _hrValidation),
          const SizedBox(height: 16),

          // Peso
          _buildTextField(
            controller: _pesoController,
            label: 'Peso (kg)',
            hint: 'Ej: 65.5',
            icon: Icons.monitor_weight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _notifyDataChanged(),
          ),
          const SizedBox(height: 16),

          // Altura Uterina
          if (widget.gestationalWeeks != null && widget.gestationalWeeks! >= 20) ...[
            _buildTextField(
              controller: _alturaUterinaController,
              label: 'Altura Uterina (cm)',
              hint: 'Ej: ${widget.gestationalWeeks}',
              icon: Icons.straighten,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _validateUterineHeight(),
            ),
            ValidationMessageWidget(result: _heightValidation),
            const SizedBox(height: 16),
          ],

          // Edemas
          const Text(
            '¿Presenta edemas?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Sí'),
                  value: true,
                  groupValue: _tieneEdemas,
                  onChanged: (value) {
                    setState(() => _tieneEdemas = value);
                    _validateEdema();
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('No'),
                  value: false,
                  groupValue: _tieneEdemas,
                  onChanged: (value) {
                    setState(() => _tieneEdemas = value);
                    _validateEdema();
                  },
                ),
              ),
            ],
          ),
          ValidationMessageWidget(result: _edemaValidation),
          const SizedBox(height: 16),

          // Movimientos Fetales
          if (widget.gestationalWeeks != null && widget.gestationalWeeks! >= 20) ...[
            const Text(
              '¿Siente movimientos fetales?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      _validateFetalMovement();
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
                      _validateFetalMovement();
                    },
                  ),
                ),
              ],
            ),
            ValidationMessageWidget(result: _movementValidation),
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
}
