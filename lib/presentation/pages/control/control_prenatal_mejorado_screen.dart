// Formulario Mejorado de Control Prenatal con Evaluación Automática de Alertas
// Integra el sistema de alertas automáticas del backend

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/core/providers/usecase_providers.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/get_gestantes_usecase.dart';
import 'package:madres_digitales_flutter_new/features/alertas/presentation/providers/alert_evaluator_provider.dart';
import 'package:madres_digitales_flutter_new/data/services/location_service.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';

class ControlPrenatalMejoradoScreen extends ConsumerStatefulWidget {

  const ControlPrenatalMejoradoScreen({
    super.key,
    this.gestante,
    this.control,
  });
  final Map<String, dynamic>? gestante;
  final Map<String, dynamic>? control;

  @override
  ConsumerState<ControlPrenatalMejoradoScreen> createState() {
    return _ControlPrenatalMejoradoScreenState();
  }
}

class _ControlPrenatalMejoradoScreenState extends ConsumerState<ControlPrenatalMejoradoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Controladores
  final _pesoController = TextEditingController();
  final _presionSistolicaController = TextEditingController();
  final _presionDiastolicaController = TextEditingController();
  final _frecuenciaCardiacaController = TextEditingController();
  final _temperaturaController = TextEditingController();
  final _frecuenciaRespiratoriaController = TextEditingController();
  final _alturaUterinaController = TextEditingController();
  final _observacionesController = TextEditingController();

  // Variables de estado
  DateTime _fechaControl = DateTime.now();
  int? _semanasGestacion;
  bool _movimientosFetales = true;
  bool _edemas = false;
  final List<String> _sintomasSeleccionados = [];
  bool _isLoading = false;
  bool _evaluarAutomaticamente = true;
  Map<String, dynamic>? _gestanteActual;
  List<Map<String, String>> _gestantesDisponibles = [];
  bool _isLoadingGestantes = true;
  String? _errorGestantes;
  double? _latitud;
  double? _longitud;
  bool _isCapturingLocation = false;

  // Síntomas disponibles (del backend)
  final List<Map<String, String>> _sintomasDisponibles = [
    {'id': 'sangrado_vaginal', 'nombre': 'Sangrado vaginal'},
    {'id': 'dolor_abdominal_severo', 'nombre': 'Dolor abdominal severo'},
    {'id': 'cefalea_severa', 'nombre': 'Cefalea severa'},
    {'id': 'vision_borrosa', 'nombre': 'Visión borrosa'},
    {'id': 'dolor_epigastrico', 'nombre': 'Dolor epigástrico'},
    {'id': 'contracciones_regulares', 'nombre': 'Contracciones regulares'},
    {'id': 'ruptura_membranas', 'nombre': 'Ruptura de membranas'},
    {'id': 'ausencia_movimiento_fetal', 'nombre': 'Ausencia de movimientos fetales'},
    {'id': 'movimientos_fetales_disminuidos', 'nombre': 'Movimientos fetales disminuidos'},
    {'id': 'escalofrios', 'nombre': 'Escalofríos'},
    {'id': 'confusion', 'nombre': 'Confusión'},
    {'id': 'convulsiones', 'nombre': 'Convulsiones'},
    {'id': 'perdida_conciencia', 'nombre': 'Pérdida de conciencia'},
  ];

  @override
  void initState() {
    super.initState();
    _gestanteActual = widget.gestante;
    _cargarGestantesSiNecesario();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.control != null) {
      final c = widget.control!;
      _pesoController.text = (c['peso'] ?? '').toString();
      _presionSistolicaController.text = (c['presion_sistolica'] ?? '').toString();
      _presionDiastolicaController.text = (c['presion_diastolica'] ?? '').toString();
      _frecuenciaCardiacaController.text = (c['frecuencia_cardiaca'] ?? '').toString();
      _temperaturaController.text = (c['temperatura'] ?? '').toString();
      _alturaUterinaController.text = (c['altura_uterina'] ?? '').toString();
      _observacionesController.text = (c['observaciones'] ?? '').toString();
      final f = c['fecha_control']?.toString();
      if (f != null && f.isNotEmpty) {
        try { _fechaControl = DateTime.parse(f); } catch (_) {}
      }
    }
    _calcularSemanasGestacion();
  }

  void _calcularSemanasGestacion() {
    // Buscar fecha_ultima_menstruacion (snake_case del backend)
    final fum = _gestanteActual?['fecha_ultima_menstruacion'] ?? 
                _gestanteActual?['fechaUltimaMenstruacion'] ?? 
                _gestanteActual?['fechaUltimaMestruacion'];
    
    if (fum is String && fum.isNotEmpty) {
      try {
        final dt = DateTime.parse(fum);
        final diff = DateTime.now().difference(dt);
        final semanasCalculadas = (diff.inDays / 7).floor();
        // Validar que sea un valor razonable (entre 0 y 42 semanas)
        if (semanasCalculadas >= 0 && semanasCalculadas <= 42) {
          setState(() => _semanasGestacion = semanasCalculadas);
          return;
        }
      } catch (_) {}
    }
    
    // Si no se pudo calcular, buscar semanas guardadas
    final semanas = _gestanteActual?['semanas_gestacion'] ?? _gestanteActual?['semanasGestacion'];
    if (semanas is int && semanas >= 0 && semanas <= 42) {
      setState(() => _semanasGestacion = semanas);
    } else {
      // No usar valor por defecto - dejar que el usuario lo ingrese manualmente
      setState(() => _semanasGestacion = 0);
    }
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _presionSistolicaController.dispose();
    _presionDiastolicaController.dispose();
    _frecuenciaCardiacaController.dispose();
    _temperaturaController.dispose();
    _frecuenciaRespiratoriaController.dispose();
    _alturaUterinaController.dispose();
    _observacionesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Prenatal'),
        backgroundColor: Colors.blue[100],
      ),
      body: Column(
        children: [
          // Info de la gestante
          _buildGestanteSelector(),
          // Indicador de progreso
          _buildProgressIndicator(),
          // Formulario por páginas
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildPage1SignosVitales(),
                _buildPage2Sintomas(),
                _buildPage3Observaciones(),
                _buildPage4Confirmacion(),
              ],
            ),
          ),
          // Botones de navegación
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildGestanteSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _isLoadingGestantes
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<String>(
                        value: _gestanteActual?['id'],
                        items: _gestantesDisponibles
                            .map((g) => DropdownMenuItem<String>(
                                  value: g['id'],
                                  child: Text(g['nombre']!),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _gestanteActual = _gestantesDisponibles
                                .firstWhere((e) => e['id'] == v);
                          });
                          _calcularSemanasGestacion();
                        },
                        decoration: const InputDecoration(labelText: 'Gestante'),
                        validator: (v) => v == null || v.isEmpty ? 'Seleccione una gestante' : null,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_gestanteActual != null) ...[
            Text(
              _gestanteActual?['nombre'] ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Doc: ${_gestanteActual?['documento'] ?? ''}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (_semanasGestacion != null)
              Text(
                'Semanas de gestación: $_semanasGestacion',
                style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
              ),
          ],
          if (_errorGestantes != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_errorGestantes!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentPage;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPage1SignosVitales() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Signos Vitales',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Fecha del control
            ListTile(
              title: const Text('Fecha del Control'),
              subtitle: Text(_formatDate(_fechaControl)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey[400]!),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isCapturingLocation ? null : _captureCoordinates,
                    icon: _isCapturingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.location_on),
                    label: Text(
                      _latitud != null && _longitud != null
                          ? 'Coordenadas: ${_latitud!.toStringAsFixed(4)}, ${_longitud!.toStringAsFixed(4)}'
                          : 'Capturar Ubicación',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (_latitud != null && _longitud != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _clearCoordinates,
                    icon: const Icon(Icons.clear, color: Colors.red),
                  ),
                ],
              ],
            ),
            
            // Peso
            TextFormField(
              controller: _pesoController,
              decoration: const InputDecoration(
                labelText: 'Peso (kg) *',
                border: OutlineInputBorder(),
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El peso es obligatorio';
                }
                final peso = double.tryParse(value);
                if (peso == null || peso < 30 || peso > 200) {
                  return 'Peso inválido (30-200 kg)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Presión arterial
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _presionSistolicaController,
                    decoration: const InputDecoration(
                      labelText: 'Presión Sistólica *',
                      border: OutlineInputBorder(),
                      suffixText: 'mmHg',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatorio';
                      }
                      final presion = int.tryParse(value);
                      if (presion == null || presion < 70 || presion > 200) {
                        return 'Inválido';
                      }
                      return null;
                    },
                    onChanged: _checkPresionArterial,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _presionDiastolicaController,
                    decoration: const InputDecoration(
                      labelText: 'Presión Diastólica *',
                      border: OutlineInputBorder(),
                      suffixText: 'mmHg',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatorio';
                      }
                      final presion = int.tryParse(value);
                      if (presion == null || presion < 40 || presion > 130) {
                        return 'Inválido';
                      }
                      return null;
                    },
                    onChanged: _checkPresionArterial,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Frecuencia cardíaca
            TextFormField(
              controller: _frecuenciaCardiacaController,
              decoration: const InputDecoration(
                labelText: 'Frecuencia Cardíaca *',
                border: OutlineInputBorder(),
                suffixText: 'lpm',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La frecuencia cardíaca es obligatoria';
                }
                final fc = int.tryParse(value);
                if (fc == null || fc < 40 || fc > 180) {
                  return 'Frecuencia inválida (40-180 lpm)';
                }
                return null;
              },
              onChanged: _checkFrecuenciaCardiaca,
            ),
            const SizedBox(height: 16),
            
            // Temperatura
            TextFormField(
              controller: _temperaturaController,
              decoration: const InputDecoration(
                labelText: 'Temperatura',
                border: OutlineInputBorder(),
                suffixText: '°C',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _checkTemperatura,
            ),
            const SizedBox(height: 16),
            
            // Frecuencia respiratoria
            TextFormField(
              controller: _frecuenciaRespiratoriaController,
              decoration: const InputDecoration(
                labelText: 'Frecuencia Respiratoria',
                border: OutlineInputBorder(),
                suffixText: 'rpm',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            
            // Altura uterina
            TextFormField(
              controller: _alturaUterinaController,
              decoration: const InputDecoration(
                labelText: 'Altura Uterina',
                border: OutlineInputBorder(),
                suffixText: 'cm',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            
            // Movimientos fetales
            SwitchListTile(
              title: const Text('Movimientos Fetales'),
              subtitle: Text(_movimientosFetales ? 'Presentes' : 'Ausentes'),
              value: _movimientosFetales,
              onChanged: (value) {
                setState(() => _movimientosFetales = value);
                if (!value) {
                  _mostrarAlertaMovimientosFetales();
                }
              },
              activeColor: Colors.green,
            ),
            
            // Edemas
            SwitchListTile(
              title: const Text('Edemas'),
              subtitle: Text(_edemas ? 'Presentes' : 'Ausentes'),
              value: _edemas,
              onChanged: (value) => setState(() => _edemas = value),
              activeColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage2Sintomas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2. Síntomas de Alarma',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona todos los síntomas que presente la gestante:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          ..._sintomasDisponibles.map((sintoma) {
            final isSelected = _sintomasSeleccionados.contains(sintoma['id']);
            final isEmergencia = _isEmergencySintoma(sintoma['id']!);
            
            return CheckboxListTile(
              title: Text(sintoma['nombre']!),
              subtitle: isEmergencia 
                  ? const Text(
                      'EMERGENCIA',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  : null,
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _sintomasSeleccionados.add(sintoma['id']!);
                    if (isEmergencia) {
                      _mostrarAlertaEmergencia(sintoma['nombre']!);
                    }
                  } else {
                    _sintomasSeleccionados.remove(sintoma['id']!);
                  }
                });
              },
              activeColor: isEmergencia ? Colors.red : Colors.orange,
              secondary: isEmergencia 
                  ? const Icon(Icons.error, color: Colors.red)
                  : const Icon(Icons.warning, color: Colors.orange),
            );
          }),
          
          const SizedBox(height: 24),
          
          // Resumen de síntomas
          if (_sintomasSeleccionados.isNotEmpty)
            Card(
              color: _hasEmergencySintomas() ? Colors.red[50] : Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _hasEmergencySintomas() ? Icons.error : Icons.warning,
                          color: _hasEmergencySintomas() ? Colors.red : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _hasEmergencySintomas() 
                              ? 'SÍNTOMAS DE EMERGENCIA DETECTADOS'
                              : 'SÍNTOMAS DE ALARMA DETECTADOS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _hasEmergencySintomas() ? Colors.red : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_sintomasSeleccionados.length} síntoma${_sintomasSeleccionados.length > 1 ? 's' : ''} seleccionado${_sintomasSeleccionados.length > 1 ? 's' : ''}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage3Observaciones() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3. Observaciones',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _observacionesController,
            decoration: const InputDecoration(
              labelText: 'Observaciones del Control',
              border: OutlineInputBorder(),
              hintText: 'Escribe cualquier observación relevante...',
            ),
            maxLines: 8,
          ),
          const SizedBox(height: 24),
          
          // Opción de evaluación automática
          Card(
            color: Colors.blue[50],
            child: SwitchListTile(
              title: const Text('Evaluación Automática de Alertas'),
              subtitle: const Text(
                'El sistema evaluará automáticamente los signos vitales y síntomas para generar alertas',
              ),
              value: _evaluarAutomaticamente,
              onChanged: (value) => setState(() => _evaluarAutomaticamente = value),
              activeColor: Colors.blue,
              secondary: const Icon(Icons.auto_awesome, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage4Confirmacion() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '4. Confirmación',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Revisa los datos antes de guardar:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          _buildConfirmacionCard(
            'Signos Vitales',
            [
              'Fecha: ${_formatDate(_fechaControl)}',
              if (_pesoController.text.isNotEmpty)
                'Peso: ${_pesoController.text} kg',
              if (_presionSistolicaController.text.isNotEmpty && _presionDiastolicaController.text.isNotEmpty)
                'Presión Arterial: ${_presionSistolicaController.text}/${_presionDiastolicaController.text} mmHg',
              if (_frecuenciaCardiacaController.text.isNotEmpty)
                'Frecuencia Cardíaca: ${_frecuenciaCardiacaController.text} lpm',
              if (_temperaturaController.text.isNotEmpty)
                'Temperatura: ${_temperaturaController.text} °C',
              'Movimientos Fetales: ${_movimientosFetales ? "Presentes" : "Ausentes"}',
              'Edemas: ${_edemas ? "Presentes" : "Ausentes"}',
            ],
          ),
          
          if (_sintomasSeleccionados.isNotEmpty)
            _buildConfirmacionCard(
              'Síntomas de Alarma',
              _sintomasSeleccionados.map((id) {
                final sintoma = _sintomasDisponibles.firstWhere((s) => s['id'] == id);
                return sintoma['nombre']!;
              }).toList(),
              isRisk: true,
            ),
          
          if (_observacionesController.text.isNotEmpty)
            _buildConfirmacionCard(
              'Observaciones',
              [_observacionesController.text],
            ),
          
          if (_evaluarAutomaticamente)
            Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Se realizará evaluación automática de alertas al guardar',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmacionCard(String title, List<String> items, {bool isRisk = false}) {
    return Card(
      color: isRisk ? Colors.red[50] : null,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isRisk) const Icon(Icons.warning, color: Colors.red, size: 20),
                if (isRisk) const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isRisk ? Colors.red : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $item'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Anterior'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNextOrSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentPage < 3 ? 'Siguiente' : 'Guardar Control',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextOrSave() {
    if (_currentPage < 3) {
      final isValid = _currentPage == 0 ? (_formKey.currentState?.validate() ?? false) : true;
      if (!isValid) {
        return;
      }
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _guardarControl();
    }
  }

  Future<void> _guardarControl() async {
    setState(() => _isLoading = true);

    try {
      if (_gestanteActual == null || (_gestanteActual?['id'] ?? '').toString().isEmpty) {
        throw Exception('Debe seleccionar una gestante');
      }
      final payload = {
        // NO enviar ID, dejar que el backend lo genere automáticamente
        'gestante_id': _gestanteActual!['id'],
        'fecha_control': _fechaControl.toIso8601String(),
        'semanas_gestacion': _semanasGestacion,
        'peso': double.tryParse(_pesoController.text),
        'presion_sistolica': int.tryParse(_presionSistolicaController.text),
        'presion_diastolica': int.tryParse(_presionDiastolicaController.text),
        'frecuencia_cardiaca': int.tryParse(_frecuenciaCardiacaController.text),
        'temperatura': double.tryParse(_temperaturaController.text),
        'altura_uterina': double.tryParse(_alturaUterinaController.text),
        'movimientos_fetales': _movimientosFetales ? 'presentes' : 'ausentes',
        'edemas': _edemas ? 'presentes' : 'ausentes',
        'sintomas': _sintomasSeleccionados,
        'observaciones': _observacionesController.text.trim(),
        if (_latitud != null && _longitud != null) 'coordenadas_control': [_longitud, _latitud],
      };
      final api = ref.read(controlServiceProvider);
      final ok = _evaluarAutomaticamente
          ? await api.crearControlConEvaluacion(payload)
          : await api.crearControl(payload);
      if (!ok) {
        final apiService = ref.read(apiServiceProvider);
        final endpoint = _evaluarAutomaticamente
            ? '/api/alertas-automaticas/controles/con-evaluacion'
            : '/api/controles';
        final resp = await apiService.post<Map<String, dynamic>>(endpoint, data: payload);
        String mensaje = 'Error al guardar';
        if (resp.statusCode == 404) {
          mensaje = 'Ruta no encontrada: $endpoint';
        } else if (resp.statusCode == 401) {
          mensaje = 'No autorizado. Inicia sesión nuevamente.';
        } else if (resp.message != null && resp.message!.isNotEmpty) {
          mensaje = resp.message!;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensaje)),
          );
        }
        return;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _evaluarAutomaticamente
                  ? 'Control guardado y alertas evaluadas exitosamente'
                  : 'Control guardado exitosamente',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cargarGestantesSiNecesario() async {
    if (widget.gestante != null) {
      setState(() {
        _gestanteActual = widget.gestante;
        _isLoadingGestantes = false;
      });
      return;
    }
    setState(() {
      _isLoadingGestantes = true;
      _errorGestantes = null;
    });
    try {
      final authState = ref.read(authProvider);
      final madrinaId = authState.user?.id;
      final usecase = ref.read(getGestantesUseCaseProvider);
      final result = await usecase(GetGestantesParams(limit: 100, offset: 0, madrinaId: madrinaId));
      if (result.isFailure) throw result.errorOrThrow;
      final gestantes = result.dataOrThrow;
      setState(() {
        _gestantesDisponibles = gestantes.map((g) => {
          'id': g.id,
          'nombre': g.nombre,
          'documento': g.documento,
        }).toList();
        _isLoadingGestantes = false;
      });
    } catch (e) {
      setState(() {
        _errorGestantes = e.toString();
        _isLoadingGestantes = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaControl,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _fechaControl = picked);
    }
  }

  void _checkPresionArterial(String value) {
    final sistolica = int.tryParse(_presionSistolicaController.text);
    final diastolica = int.tryParse(_presionDiastolicaController.text);
    
    if (sistolica != null && sistolica >= 160) {
      _mostrarAlertaSignoVital('Presión arterial sistólica muy alta (≥160 mmHg)');
    } else if (sistolica != null && sistolica >= 140) {
      _mostrarAlertaSignoVital('Presión arterial sistólica alta (≥140 mmHg)');
    }
    
    if (diastolica != null && diastolica >= 110) {
      _mostrarAlertaSignoVital('Presión arterial diastólica muy alta (≥110 mmHg)');
    } else if (diastolica != null && diastolica >= 90) {
      _mostrarAlertaSignoVital('Presión arterial diastólica alta (≥90 mmHg)');
    }
  }

  void _checkFrecuenciaCardiaca(String value) {
    final fc = int.tryParse(value);
    if (fc != null && fc >= 120) {
      _mostrarAlertaSignoVital('Taquicardia severa (≥120 lpm)');
    } else if (fc != null && fc >= 100) {
      _mostrarAlertaSignoVital('Taquicardia (≥100 lpm)');
    }
  }

  void _checkTemperatura(String value) {
    final temp = double.tryParse(value);
    if (temp != null && temp >= 39.0) {
      _mostrarAlertaSignoVital('Fiebre alta (≥39°C)');
    } else if (temp != null && temp >= 38.0) {
      _mostrarAlertaSignoVital('Fiebre (≥38°C)');
    }
  }

  void _mostrarAlertaSignoVital(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('⚠️ $mensaje')),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarAlertaEmergencia(String sintoma) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('🚨 EMERGENCIA: $sintoma')),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _mostrarAlertaMovimientosFetales() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('EMERGENCIA OBSTÉTRICA'),
          ],
        ),
        content: const Text(
          'La ausencia de movimientos fetales es una EMERGENCIA OBSTÉTRICA. '
          'Se generará una alerta crítica automáticamente.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _triggerAutoAlertEmergency('ausencia_movimiento_fetal');
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  bool _isEmergencySintoma(String sintomaId) {
    const emergencySintomas = [
      'ausencia_movimiento_fetal',
      'convulsiones',
      'perdida_conciencia',
      'sangrado_vaginal',
    ];
    return emergencySintomas.contains(sintomaId);
  }

  bool _hasEmergencySintomas() {
    return _sintomasSeleccionados.any((id) => _isEmergencySintoma(id));
  }

  Future<void> _triggerAutoAlertEmergency(String sintomaId) async {
    try {
      if (_gestanteActual == null) return;
      final gestanteId = (_gestanteActual?['id'] ?? '').toString();
      if (gestanteId.isEmpty) return;

      final signos = {
        if (_presionSistolicaController.text.isNotEmpty)
          'presion_sistolica': int.tryParse(_presionSistolicaController.text) ?? 0,
        if (_presionDiastolicaController.text.isNotEmpty)
          'presion_diastolica': int.tryParse(_presionDiastolicaController.text) ?? 0,
        if (_frecuenciaCardiacaController.text.isNotEmpty)
          'frecuencia_cardiaca': int.tryParse(_frecuenciaCardiacaController.text) ?? 0,
        if (_temperaturaController.text.isNotEmpty)
          'temperatura': double.tryParse(_temperaturaController.text) ?? 0,
        if (_semanasGestacion != null) 'semanas_gestacion': _semanasGestacion!,
      };

      final evaluar = ref.read(alertEvaluatorProvider);
      await evaluar(AlertEvaluatorParams(
        gestanteId: gestanteId,
        sintomas: [..._sintomasSeleccionados, sintomaId],
        signos: signos.isEmpty ? null : signos,
        latitud: _latitud,
        longitud: _longitud,
        mensaje: 'Emergencia: ausencia de movimientos fetales',
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerta crítica generada automáticamente'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _captureCoordinates() async {
    setState(() => _isCapturingLocation = true);
    try {
      final locationService = LocationService.instance;
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _latitud = position.latitude;
          _longitud = position.longitude;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ubicación capturada: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener la ubicación'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error capturando ubicación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturingLocation = false);
    }
  }

  void _clearCoordinates() {
    setState(() {
      _latitud = null;
      _longitud = null;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}


