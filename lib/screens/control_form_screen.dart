import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/service_providers.dart';
import '../services/control_service.dart';
import '../services/gestante_service.dart' as gs;
import '../services/alerta_service.dart';
import '../widgets/alerta_tiempo_real_widget.dart';
import '../utils/logger.dart';

class ControlFormScreen extends ConsumerStatefulWidget {
  final String? controlId;
  final String? gestantePreseleccionada;

  ControlFormScreen({
    super.key,
    this.controlId,
    this.gestantePreseleccionada,
  }) {
    print('🔶 CONTROL_FORM_SCREEN: Constructor llamado - ARCHIVO: control_form_screen.dart');
    print('🔶 CONTROL_FORM_SCREEN: controlId = $controlId');
    print('🔶 CONTROL_FORM_SCREEN: gestantePreseleccionada = $gestantePreseleccionada');
  }

  @override
  ConsumerState<ControlFormScreen> createState() {
    print('🔶 CONTROL_FORM_SCREEN: createState llamado - ARCHIVO: control_form_screen.dart');
    return _ControlFormScreenState();
  }
}

class _ControlFormScreenState extends ConsumerState<ControlFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Controladores de texto
  final _pesoController = TextEditingController();
  final _tallaController = TextEditingController();
  final _presionSistolicaController = TextEditingController();
  final _presionDiastolicaController = TextEditingController();
  final _frecuenciaCardiacaController = TextEditingController();
  final _frecuenciaCardiacaFetalController = TextEditingController();
  final _semanasGestacionController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _temperaturaController = TextEditingController();
  final _frecuenciaRespiratoriaController = TextEditingController();
  final _alturaUterinaController = TextEditingController();

  // Variables de estado
  List<gs.Gestante> _gestantesDisponibles = [];
  String? _gestanteSeleccionada;
  bool _isLoading = false;
  bool _isLoadingGestantes = true;
  String? _error;
  
  // Datos para evaluación de alertas
  Map<String, dynamic> _signosVitales = {};
  List<Map<String, dynamic>> _alertasDetectadas = [];
  bool _mostrarAlertas = true;
  
  // Nuevas variables para características mejoradas
  bool _movimientosFetales = true;
  bool _edemas = false;
  final List<String> _sintomasSeleccionados = [];
  
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
    print('🔍 ControlFormScreen: initState llamado');
    super.initState();
    print('🔍 ControlFormScreen: Estableciendo gestante preseleccionada');
    _gestanteSeleccionada = widget.gestantePreseleccionada;
    print('🔍 ControlFormScreen: Llamando a _cargarGestantesDisponibles');
    _cargarGestantesDisponibles();
    print('🔍 ControlFormScreen: Configurando listeners');
    _configurarListeners();
    print('🔍 ControlFormScreen: initState completado');
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _tallaController.dispose();
    _presionSistolicaController.dispose();
    _presionDiastolicaController.dispose();
    _frecuenciaCardiacaController.dispose();
    _frecuenciaCardiacaFetalController.dispose();
    _semanasGestacionController.dispose();
    _observacionesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _configurarListeners() {
    // Listeners para actualizar signos vitales en tiempo real
    _pesoController.addListener(_actualizarSignosVitales);
    _presionSistolicaController.addListener(_actualizarSignosVitales);
    _presionDiastolicaController.addListener(_actualizarSignosVitales);
    _frecuenciaCardiacaController.addListener(_actualizarSignosVitales);
    _frecuenciaCardiacaFetalController.addListener(_actualizarSignosVitales);
    _semanasGestacionController.addListener(_actualizarSignosVitales);
    _temperaturaController.addListener(_actualizarSignosVitales);
    _frecuenciaRespiratoriaController.addListener(_actualizarSignosVitales);
    _alturaUterinaController.addListener(_actualizarSignosVitales);
    
    // Listeners para validación en tiempo real
    _presionSistolicaController.addListener(() => _checkPresionArterial(''));
    _presionDiastolicaController.addListener(() => _checkPresionArterial(''));
    _frecuenciaCardiacaController.addListener(() => _checkFrecuenciaCardiaca(''));
    _temperaturaController.addListener(() => _checkTemperatura(''));
  }

  void _actualizarSignosVitales() {
    setState(() {
      _signosVitales = {
        'peso': double.tryParse(_pesoController.text),
        'presionSistolica': double.tryParse(_presionSistolicaController.text),
        'presionDiastolica': double.tryParse(_presionDiastolicaController.text),
        'frecuenciaCardiaca': double.tryParse(_frecuenciaCardiacaController.text),
        'frecuenciaCardiacaFetal': double.tryParse(_frecuenciaCardiacaFetalController.text),
        'semanasGestacion': int.tryParse(_semanasGestacionController.text),
        'temperatura': double.tryParse(_temperaturaController.text),
        'frecuenciaRespiratoria': double.tryParse(_frecuenciaRespiratoriaController.text),
        'alturaUterina': double.tryParse(_alturaUterinaController.text),
        'movimientosFetales': _movimientosFetales,
        'edemas': _edemas,
        'sintomas': _sintomasSeleccionados,
        'gestanteId': _gestanteSeleccionada,
      };
    });
  }

  Future<void> _cargarGestantesDisponibles() async {
    print('🔍 ControlFormScreen: Iniciando _cargarGestantesDisponibles');
    setState(() {
      _isLoadingGestantes = true;
      _error = null;
    });

    try {
      print('🔍 ControlFormScreen: Obteniendo apiService');
      final apiService = ref.read(apiServiceProvider);
      print('🔍 ControlFormScreen: Creando gestanteService');
      final gestanteService = gs.GestanteService(apiService);
      print('🔍 ControlFormScreen: Llamando a obtenerGestantes');
      
      final gestantes = await gestanteService.obtenerGestantes();
      print('🔍 ControlFormScreen: Gestantes obtenidas - Tipo: ${gestantes.runtimeType}, Cantidad: ${gestantes.length}');
      
      print('🔍 ControlFormScreen: Filtrando gestantes activas');
      final gestantesActivas = gestantes.where((g) => g.activa).toList();
      print('🔍 ControlFormScreen: Gestantes activas - Cantidad: ${gestantesActivas.length}');
      
      setState(() {
        _gestantesDisponibles = gestantesActivas;
        _isLoadingGestantes = false;
      });

      appLogger.info('ControlFormScreen: ${_gestantesDisponibles.length} gestantes disponibles');
      print('✅ ControlFormScreen: Carga completada exitosamente');
    } catch (e, stackTrace) {
      print('❌ ControlFormScreen: Error detallado:');
      print('   Error: $e');
      print('   Tipo: ${e.runtimeType}');
      print('   StackTrace: $stackTrace');
      appLogger.error('ControlFormScreen: Error cargando gestantes', error: e);
      setState(() {
        _error = 'Error cargando gestantes: ${e.toString()}';
        _isLoadingGestantes = false;
      });
    }
  }

  Future<void> _guardarControl() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_gestanteSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una gestante'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final controlService = ControlService(apiService);
      
      final controlData = {
        'gestante_id': _gestanteSeleccionada!,
        'fecha_control': DateTime.now().toIso8601String(),
        'peso': double.tryParse(_pesoController.text),
        'talla': double.tryParse(_tallaController.text),
        'presion_sistolica': int.tryParse(_presionSistolicaController.text),
        'presion_diastolica': int.tryParse(_presionDiastolicaController.text),
        'frecuencia_cardiaca': int.tryParse(_frecuenciaCardiacaController.text),
        'frecuencia_cardiaca_fetal': int.tryParse(_frecuenciaCardiacaFetalController.text),
        'semanas_gestacion': int.tryParse(_semanasGestacionController.text),
        'temperatura': double.tryParse(_temperaturaController.text),
        'frecuencia_respiratoria': int.tryParse(_frecuenciaRespiratoriaController.text),
        'altura_uterina': double.tryParse(_alturaUterinaController.text),
        'movimientos_fetales': _movimientosFetales,
        'edemas': _edemas ? 'presentes' : 'ausentes',
        'sintomas': _sintomasSeleccionados,
        'observaciones': _observacionesController.text.trim(),
      };
      
      print('🔍 ControlFormScreen: Enviando datos del control: $controlData');

      if (widget.controlId != null) {
        await controlService.actualizarControl(widget.controlId!, controlData);
      } else {
        await controlService.crearControl(controlData);
      }

      // Crear alertas automáticas si se detectaron
      await _crearAlertasAutomaticas();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.controlId != null ? 'Control actualizado exitosamente' : 'Control creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);

    } catch (e) {
      appLogger.error('ControlFormScreen: Error guardando control', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error guardando control: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _crearAlertasAutomaticas() async {
    if (_alertasDetectadas.isEmpty || _gestanteSeleccionada == null) return;

    try {
      final apiService = ref.read(apiServiceProvider);
      final alertaService = AlertaService(apiService);

      for (final alerta in _alertasDetectadas) {
        // Solo crear alertas críticas y altas automáticamente
        if (alerta['prioridad'] == 'critica' || alerta['prioridad'] == 'alta') {
          await alertaService.crearAlerta(
            gestanteId: _gestanteSeleccionada!,
            tipoAlerta: alerta['tipo'] ?? 'manual',
            nivelPrioridad: alerta['prioridad'] ?? 'media',
            mensaje: alerta['mensaje'] ?? 'Alerta automática',
          );
        }
      }

      appLogger.info('ControlFormScreen: ${_alertasDetectadas.length} alertas automáticas creadas');
    } catch (e) {
      appLogger.error('ControlFormScreen: Error creando alertas automáticas', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.controlId != null ? 'Editar Control' : 'Nuevo Control Prenatal'),
        backgroundColor: Colors.teal[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_mostrarAlertas ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _mostrarAlertas = !_mostrarAlertas;
              });
            },
            tooltip: _mostrarAlertas ? 'Ocultar alertas' : 'Mostrar alertas',
          ),
        ],
      ),
      body: _isLoadingGestantes
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarGestantesDisponibles,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Widget de alertas en tiempo real
                    if (_mostrarAlertas)
                      AlertaTiempoRealWidget(
                        gestanteId: _gestanteSeleccionada,
                        signosVitales: _signosVitales,
                        onAlertasDetectadas: (alertas) {
                          setState(() {
                            _alertasDetectadas = alertas.map((a) => {
                              'tipo': a.tipo,
                              'prioridad': a.prioridad,
                              'mensaje': a.mensaje,
                              'recomendacion': a.recomendacion,
                            }).toList();
                          });
                        },
                      ),
                    // Formulario
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGestanteSelector(),
                              const SizedBox(height: 20),
                              _buildSignosVitalesSection(),
                              const SizedBox(height: 20),
                              _buildSintomasAlarmaSection(),
                              const SizedBox(height: 20),
                              _buildObservacionesSection(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _guardarControl,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Guardando...'),
                  ],
                )
              : Text(widget.controlId != null ? 'Actualizar Control' : 'Guardar Control'),
        ),
      ),
    );
  }

  Widget _buildGestanteSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.teal[600]),
                const SizedBox(width: 8),
                const Text(
                  'Gestante',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _gestanteSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Seleccionar Gestante',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              items: _gestantesDisponibles.map<DropdownMenuItem<String>>((gestante) {
                return DropdownMenuItem<String>(
                  value: gestante.id.toString(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gestante.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (gestante.telefono != null)
                        Text(
                          'Tel: ${gestante.telefono}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _gestanteSeleccionada = value;
                  _actualizarSignosVitales();
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Debe seleccionar una gestante';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignosVitalesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart, color: Colors.teal[600]),
                const SizedBox(width: 8),
                const Text(
                  'Signos Vitales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _semanasGestacionController,
                    decoration: const InputDecoration(
                      labelText: 'Semanas de Gestación',
                      border: OutlineInputBorder(),
                      suffixText: 'sem',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      final semanas = int.tryParse(value);
                      if (semanas == null || semanas < 1 || semanas > 42) {
                        return 'Valor inválido (1-42)';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _pesoController,
                    decoration: const InputDecoration(
                      labelText: 'Peso',
                      border: OutlineInputBorder(),
                      suffixText: 'kg',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      final peso = double.tryParse(value);
                      if (peso == null || peso < 30 || peso > 200) {
                        return 'Valor inválido (30-200 kg)';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _presionSistolicaController,
                    decoration: const InputDecoration(
                      labelText: 'Presión Sistólica',
                      border: OutlineInputBorder(),
                      suffixText: 'mmHg',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      final presion = int.tryParse(value);
                      if (presion == null || presion < 70 || presion > 250) {
                        return 'Valor inválido (70-250)';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _presionDiastolicaController,
                    decoration: const InputDecoration(
                      labelText: 'Presión Diastólica',
                      border: OutlineInputBorder(),
                      suffixText: 'mmHg',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      final presion = int.tryParse(value);
                      if (presion == null || presion < 40 || presion > 150) {
                        return 'Valor inválido (40-150)';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _frecuenciaCardiacaController,
                    decoration: const InputDecoration(
                      labelText: 'Frecuencia Cardíaca Materna',
                      border: OutlineInputBorder(),
                      suffixText: 'lpm',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final fc = int.tryParse(value);
                        if (fc == null || fc < 50 || fc > 200) {
                          return 'Valor inválido (50-200)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _frecuenciaCardiacaFetalController,
                    decoration: const InputDecoration(
                      labelText: 'Frecuencia Cardíaca Fetal',
                      border: OutlineInputBorder(),
                      suffixText: 'lpm',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final fcf = int.tryParse(value);
                        if (fcf == null || fcf < 100 || fcf > 180) {
                          return 'Valor inválido (100-180)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Nuevos campos del formulario mejorado
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _temperaturaController,
                    decoration: const InputDecoration(
                      labelText: 'Temperatura',
                      border: OutlineInputBorder(),
                      suffixText: '°C',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _frecuenciaRespiratoriaController,
                    decoration: const InputDecoration(
                      labelText: 'Frecuencia Respiratoria',
                      border: OutlineInputBorder(),
                      suffixText: 'rpm',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            // Switches para características mejoradas
            SwitchListTile(
              title: const Text('Movimientos Fetales'),
              subtitle: Text(_movimientosFetales ? 'Presentes' : 'Ausentes'),
              value: _movimientosFetales,
              onChanged: (value) {
                setState(() => _movimientosFetales = value);
                _actualizarSignosVitales();
                if (!value) {
                  _mostrarAlertaMovimientosFetales();
                }
              },
              activeThumbColor: Colors.green,
            ),
            SwitchListTile(
              title: const Text('Edemas'),
              subtitle: Text(_edemas ? 'Presentes' : 'Ausentes'),
              value: _edemas,
              onChanged: (value) {
                setState(() => _edemas = value);
                _actualizarSignosVitales();
              },
              activeThumbColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservacionesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_alt, color: Colors.teal[600]),
                const SizedBox(width: 8),
                const Text(
                  'Observaciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones del control',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) => _actualizarSignosVitales(),
            ),
          ],
        ),
      ),
    );
  }

  // Nueva sección para síntomas de alarma
  Widget _buildSintomasAlarmaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'Síntomas de Alarma',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Selecciona todos los síntomas que presente la gestante:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
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
                    _actualizarSignosVitales();
                  });
                },
                activeColor: isEmergencia ? Colors.red : Colors.orange,
                secondary: isEmergencia
                    ? const Icon(Icons.error, color: Colors.red)
                    : const Icon(Icons.warning, color: Colors.orange),
              );
            }),
            
            const SizedBox(height: 16),
            
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
      ),
    );
  }

  // Método para verificar si un síntoma es de emergencia
  bool _isEmergencySintoma(String sintomaId) {
    const emergencySintomas = [
      'ausencia_movimiento_fetal',
      'convulsiones',
      'perdida_conciencia',
      'sangrado_vaginal',
    ];
    return emergencySintomas.contains(sintomaId);
  }

  // Método para verificar si hay síntomas de emergencia
  bool _hasEmergencySintomas() {
    return _sintomasSeleccionados.any((id) => _isEmergencySintoma(id));
  }

  // Método para mostrar alerta de movimientos fetales
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // Método para mostrar alerta de emergencia
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

  // Método para verificar presión arterial
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

  // Método para verificar frecuencia cardíaca
  void _checkFrecuenciaCardiaca(String value) {
    final fc = int.tryParse(value);
    if (fc != null && fc >= 120) {
      _mostrarAlertaSignoVital('Taquicardia severa (≥120 lpm)');
    } else if (fc != null && fc >= 100) {
      _mostrarAlertaSignoVital('Taquicardia (≥100 lpm)');
    }
  }

  // Método para verificar temperatura
  void _checkTemperatura(String value) {
    final temp = double.tryParse(value);
    if (temp != null && temp >= 39.0) {
      _mostrarAlertaSignoVital('Fiebre alta (≥39°C)');
    } else if (temp != null && temp >= 38.0) {
      _mostrarAlertaSignoVital('Fiebre (≥38°C)');
    }
  }

  // Método para mostrar alerta de signo vital
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
}