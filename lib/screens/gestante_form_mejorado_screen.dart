// Formulario Mejorado de Gestantes con Validación Completa
// Incluye todos los campos necesarios para el sistema de alertas automáticas

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/service_providers.dart';
import '../services/municipio_service.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

class GestanteFormMejoradoScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? gestante;

  const GestanteFormMejoradoScreen({super.key, this.gestante});

  @override
  ConsumerState<GestanteFormMejoradoScreen> createState() => _GestanteFormMejoradoScreenState();
}

class _GestanteFormMejoradoScreenState extends ConsumerState<GestanteFormMejoradoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Controladores de texto
  final _documentoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _epsController = TextEditingController();
  final _contactoEmergenciaNombreController = TextEditingController();
  final _contactoEmergenciaTelefonoController = TextEditingController();
  final _pesoController = TextEditingController();
  final _tallaController = TextEditingController();

  // Variables de estado
  bool _activa = true;
  bool _riesgoAlto = false;
  DateTime? _fechaNacimiento;
  DateTime? _fechaProbableParto;
  DateTime? _fechaUltimaMenstruacion;
  String _tipoDocumento = 'cedula';
  String _regimenSalud = 'subsidiado';
  int _numeroEmbarazo = 1;
  String? _grupoSanguineo;
  String? _selectedMunicipioId;
  final List<String> _factoresRiesgo = [];
  bool _isLoading = false;
  bool _isLoadingMunicipios = true;
  
  // Servicios
  final MunicipioService _municipioService = MunicipioService();
  List<Map<String, dynamic>> _municipiosList = [];

  // Opciones
  final List<String> _tiposDocumento = ['cedula', 'tarjeta_identidad', 'pasaporte', 'registro_civil'];
  final List<String> _regimenesSalud = ['subsidiado', 'contributivo', 'especial', 'no_asegurado'];
  final List<String> _gruposSanguineos = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _factoresRiesgoDisponibles = [
    'Hipertensión',
    'Diabetes',
    'Preeclampsia previa',
    'Embarazo múltiple',
    'Edad < 18 años',
    'Edad > 35 años',
    'Obesidad',
    'Bajo peso',
    'Anemia',
    'Infecciones',
    'Consumo de sustancias',
    'Violencia doméstica',
  ];

  @override
  void initState() {
    super.initState();
    _loadMunicipios();
    _initializeForm();
  }

  Future<void> _loadMunicipios() async {
    try {
      appLogger.info('GestanteFormScreen: Cargando municipios desde la API...');
      
      final municipios = await _municipioService.getAllMunicipios();
      appLogger.info('GestanteFormScreen: ${municipios.length} municipios cargados');
      
      setState(() {
        _municipiosList = municipios.map((municipio) => {
          'id': municipio['id'].toString(),
          'nombre': municipio['nombre'].toString(),
        }).toList();
        _isLoadingMunicipios = false;
      });
    } catch (e) {
      appLogger.error('GestanteFormScreen: Error cargando municipios', error: e);
      setState(() {
        _isLoadingMunicipios = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando municipios: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _initializeForm() {
    if (widget.gestante != null) {
      final g = widget.gestante!;
      _documentoController.text = g['documento'] ?? '';
      _nombreController.text = g['nombre'] ?? '';
      _telefonoController.text = g['telefono'] ?? '';
      _direccionController.text = g['direccion'] ?? '';
      _epsController.text = g['eps'] ?? '';
      _activa = g['activa'] ?? true;
      _riesgoAlto = g['riesgo_alto'] ?? false;
      if (g['fecha_nacimiento'] != null) {
        _fechaNacimiento = DateTime.parse(g['fecha_nacimiento']);
      }
      if (g['fecha_probable_parto'] != null) {
        _fechaProbableParto = DateTime.parse(g['fecha_probable_parto']);
      }
      _selectedMunicipioId = g['municipio_id'];
    }
  }

  @override
  void dispose() {
    _documentoController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _epsController.dispose();
    _contactoEmergenciaNombreController.dispose();
    _contactoEmergenciaTelefonoController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gestante == null ? 'Nueva Gestante' : 'Editar Gestante'),
        backgroundColor: Colors.pink[100],
      ),
      body: Column(
        children: [
          // Indicador de progreso
          _buildProgressIndicator(),
          // Formulario por páginas
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildPage1DatosBasicos(),
                _buildPage2DatosObstetricos(),
                _buildPage3FactoresRiesgo(),
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
                color: isActive ? Colors.pink : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPage1DatosBasicos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Datos Básicos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Tipo de documento
            DropdownButtonFormField<String>(
              initialValue: _tipoDocumento,
              decoration: const InputDecoration(
                labelText: 'Tipo de Documento',
                border: OutlineInputBorder(),
              ),
              items: _tiposDocumento.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(_formatTipoDocumento(tipo)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _tipoDocumento = value!),
            ),
            const SizedBox(height: 16),
            
            // Número de documento
            TextFormField(
              controller: _documentoController,
              decoration: const InputDecoration(
                labelText: 'Número de Documento *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El documento es obligatorio';
                }
                if (value.length < 6) {
                  return 'El documento debe tener al menos 6 dígitos';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Nombre completo
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre Completo *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (value.length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Fecha de nacimiento
            ListTile(
              title: const Text('Fecha de Nacimiento *'),
              subtitle: Text(
                _fechaNacimiento != null
                    ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                    : 'No seleccionada',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate('nacimiento'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey[400]!),
              ),
            ),
            const SizedBox(height: 16),
            
            // Teléfono
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono *',
                border: OutlineInputBorder(),
                prefixText: '+57 ',
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El teléfono es obligatorio';
                }
                if (value.length != 10) {
                  return 'El teléfono debe tener 10 dígitos';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Dirección
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Municipio
            _isLoadingMunicipios
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : DropdownButtonFormField<String>(
                    initialValue: _selectedMunicipioId,
                    decoration: const InputDecoration(
                      labelText: 'Municipio',
                      border: OutlineInputBorder(),
                      hintText: 'Seleccionar municipio',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Sin municipio asignado'),
                      ),
                      ..._municipiosList.map((municipio) {
                        return DropdownMenuItem<String>(
                          value: municipio['id'],
                          child: Text(municipio['nombre']),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedMunicipioId = value;
                      });
                    },
                  ),
            const SizedBox(height: 16),
            
            // EPS
            TextFormField(
              controller: _epsController,
              decoration: const InputDecoration(
                labelText: 'EPS',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Régimen de salud
            DropdownButtonFormField<String>(
              initialValue: _regimenSalud,
              decoration: const InputDecoration(
                labelText: 'Régimen de Salud',
                border: OutlineInputBorder(),
              ),
              items: _regimenesSalud.map((regimen) {
                return DropdownMenuItem(
                  value: regimen,
                  child: Text(_formatRegimenSalud(regimen)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _regimenSalud = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage2DatosObstetricos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2. Datos Obstétricos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Número de embarazo
          TextFormField(
            initialValue: _numeroEmbarazo.toString(),
            decoration: const InputDecoration(
              labelText: 'Número de Embarazo',
              border: OutlineInputBorder(),
              helperText: '1 = Primer embarazo, 2 = Segundo, etc.',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              final num = int.tryParse(value);
              if (num != null && num > 0) {
                setState(() => _numeroEmbarazo = num);
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Fecha de última menstruación
          ListTile(
            title: const Text('Fecha de Última Menstruación (FUM)'),
            subtitle: Text(
              _fechaUltimaMenstruacion != null
                  ? '${_fechaUltimaMenstruacion!.day}/${_fechaUltimaMenstruacion!.month}/${_fechaUltimaMenstruacion!.year}'
                  : 'No seleccionada',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate('ultima_menstruacion'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: Colors.grey[400]!),
            ),
          ),
          const SizedBox(height: 16),
          
          // Fecha probable de parto (calculada automáticamente)
          if (_fechaUltimaMenstruacion != null)
            Card(
              color: Colors.blue[50],
              child: ListTile(
                leading: const Icon(Icons.child_care, color: Colors.blue),
                title: const Text('Fecha Probable de Parto (FPP)'),
                subtitle: Text(
                  _calcularFechaProbableParto(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(height: 16),
          
          // Peso
          TextFormField(
            controller: _pesoController,
            decoration: const InputDecoration(
              labelText: 'Peso Actual (kg)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          
          // Talla
          TextFormField(
            controller: _tallaController,
            decoration: const InputDecoration(
              labelText: 'Talla (cm)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          
          // Grupo sanguíneo
          DropdownButtonFormField<String>(
            initialValue: _grupoSanguineo,
            decoration: const InputDecoration(
              labelText: 'Grupo Sanguíneo',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('No especificado')),
              ..._gruposSanguineos.map((grupo) {
                return DropdownMenuItem(value: grupo, child: Text(grupo));
              }),
            ],
            onChanged: (value) => setState(() => _grupoSanguineo = value),
          ),
        ],
      ),
    );
  }

  Widget _buildPage3FactoresRiesgo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3. Factores de Riesgo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona todos los factores de riesgo que apliquen:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          ..._factoresRiesgoDisponibles.map((factor) {
            final isSelected = _factoresRiesgo.contains(factor);
            return CheckboxListTile(
              title: Text(factor),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _factoresRiesgo.add(factor);
                  } else {
                    _factoresRiesgo.remove(factor);
                  }
                  // Actualizar riesgo alto automáticamente
                  _riesgoAlto = _factoresRiesgo.isNotEmpty;
                });
              },
              activeColor: Colors.red,
            );
          }),
          
          const SizedBox(height: 24),
          
          // Resumen de riesgo
          if (_factoresRiesgo.isNotEmpty)
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'GESTANTE DE ALTO RIESGO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_factoresRiesgo.length} factor${_factoresRiesgo.length > 1 ? 'es' : ''} de riesgo identificado${_factoresRiesgo.length > 1 ? 's' : ''}',
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
            'Datos Básicos',
            [
              'Documento: $_tipoDocumento ${_documentoController.text}',
              'Nombre: ${_nombreController.text}',
              'Teléfono: ${_telefonoController.text}',
              if (_direccionController.text.isNotEmpty)
                'Dirección: ${_direccionController.text}',
              if (_epsController.text.isNotEmpty)
                'EPS: ${_epsController.text}',
            ],
          ),
          
          _buildConfirmacionCard(
            'Datos Obstétricos',
            [
              'Embarazo número: $_numeroEmbarazo',
              if (_fechaUltimaMenstruacion != null)
                'FUM: ${_formatDate(_fechaUltimaMenstruacion!)}',
              if (_fechaUltimaMenstruacion != null)
                'FPP: ${_calcularFechaProbableParto()}',
              if (_pesoController.text.isNotEmpty)
                'Peso: ${_pesoController.text} kg',
              if (_tallaController.text.isNotEmpty)
                'Talla: ${_tallaController.text} cm',
              if (_grupoSanguineo != null)
                'Grupo sanguíneo: $_grupoSanguineo',
            ],
          ),
          
          if (_factoresRiesgo.isNotEmpty)
            _buildConfirmacionCard(
              'Factores de Riesgo',
              _factoresRiesgo,
              isRisk: true,
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
            color: Colors.grey.withOpacity(0.3),
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
                backgroundColor: Colors.pink,
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
                      _currentPage < 3 ? 'Siguiente' : 'Guardar',
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
      // Validar página actual antes de avanzar
      if (_currentPage == 0 && !_formKey.currentState!.validate()) {
        return;
      }
      if (_currentPage == 0 && _fechaNacimiento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona la fecha de nacimiento')),
        );
        return;
      }
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _guardarGestante();
    }
  }

  Future<void> _guardarGestante() async {
    setState(() => _isLoading = true);

    try {
      // Obtener información del usuario actual para auto-asignación
      final authService = AuthService();
      final currentUser = authService.currentUser;
      final userRole = authService.userRole;
      final userId = authService.userId;

      // Preparar datos para enviar al backend
      final gestanteData = {
        'documento': _documentoController.text,
        'tipo_documento': _tipoDocumento,
        'nombre': _nombreController.text,
        'telefono': _telefonoController.text.isNotEmpty ? _telefonoController.text : null,
        'direccion': _direccionController.text.isNotEmpty ? _direccionController.text : null,
        'municipio_id': _selectedMunicipioId,
        'eps': _epsController.text.isNotEmpty ? _epsController.text : null,
        'regimen_salud': _regimenSalud,
        'activa': _activa,
        'riesgo_alto': _riesgoAlto,
        'numero_embarazo': _numeroEmbarazo,
        if (_fechaNacimiento != null)
          'fecha_nacimiento': _fechaNacimiento!.toIso8601String(),
        if (_fechaUltimaMenstruacion != null)
          'fecha_ultima_menstruacion': _fechaUltimaMenstruacion!.toIso8601String(),
        if (_fechaProbableParto != null)
          'fecha_probable_parto': _fechaProbableParto!.toIso8601String(),
        if (_pesoController.text.isNotEmpty)
          'peso': double.tryParse(_pesoController.text),
        if (_tallaController.text.isNotEmpty)
          'talla': double.tryParse(_tallaController.text),
        if (_grupoSanguineo != null)
          'grupo_sanguineo': _grupoSanguineo,
        if (_factoresRiesgo.isNotEmpty)
          'factores_riesgo': _factoresRiesgo,
        if (_contactoEmergenciaNombreController.text.isNotEmpty)
          'contacto_emergencia_nombre': _contactoEmergenciaNombreController.text,
        if (_contactoEmergenciaTelefonoController.text.isNotEmpty)
          'contacto_emergencia_telefono': _contactoEmergenciaTelefonoController.text,
      };

      // Auto-asignación de madrina si el usuario es madrina y está creando una nueva gestante
      if (widget.gestante == null && userRole == 'madrina' && userId != null) {
        gestanteData['madrina_id'] = userId;
        appLogger.info('GestanteForm: Auto-asignando madrina ${currentUser?['nombre']} a nueva gestante');
      }

      // Pre-seleccionar municipio de la madrina si no se ha seleccionado uno
      if (_selectedMunicipioId == null && currentUser?['municipio_id'] != null) {
        gestanteData['municipio_id'] = currentUser!['municipio_id'];
        appLogger.info('GestanteForm: Pre-seleccionando municipio de la madrina');
      }

      // Llamada al backend
      final apiService = ref.read(apiServiceProvider);
      
      if (widget.gestante == null) {
        // Crear nueva gestante
        await apiService.post('/gestantes', data: gestanteData);
      } else {
        // Actualizar gestante existente
        await apiService.put('/gestantes/${widget.gestante!['id']}', data: gestanteData);
      }
      
      if (mounted) {
        String mensaje = widget.gestante == null 
            ? 'Gestante creada exitosamente' 
            : 'Gestante actualizada exitosamente';
        
        // Agregar información sobre auto-asignación
        if (widget.gestante == null && userRole == 'madrina') {
          mensaje += '\nAsignada automáticamente a tu cuidado';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(String tipo) async {
    DateTime? initialDate;
    DateTime firstDate;
    DateTime lastDate;
    
    if (tipo == 'nacimiento') {
      initialDate = _fechaNacimiento ?? DateTime.now().subtract(const Duration(days: 365 * 25));
      firstDate = DateTime(1950);
      lastDate = DateTime.now();
    } else {
      initialDate = _fechaUltimaMenstruacion ?? DateTime.now().subtract(const Duration(days: 30));
      firstDate = DateTime.now().subtract(const Duration(days: 365));
      lastDate = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (tipo == 'nacimiento') {
          _fechaNacimiento = picked;
        } else {
          _fechaUltimaMenstruacion = picked;
          // Calcular FPP automáticamente (FUM + 280 días)
          _fechaProbableParto = picked.add(const Duration(days: 280));
        }
      });
    }
  }

  String _calcularFechaProbableParto() {
    if (_fechaUltimaMenstruacion == null) return 'No calculada';
    final fpp = _fechaUltimaMenstruacion!.add(const Duration(days: 280));
    return _formatDate(fpp);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTipoDocumento(String tipo) {
    switch (tipo) {
      case 'cedula': return 'Cédula de Ciudadanía';
      case 'tarjeta_identidad': return 'Tarjeta de Identidad';
      case 'pasaporte': return 'Pasaporte';
      case 'registro_civil': return 'Registro Civil';
      default: return tipo;
    }
  }

  String _formatRegimenSalud(String regimen) {
    switch (regimen) {
      case 'subsidiado': return 'Subsidiado';
      case 'contributivo': return 'Contributivo';
      case 'especial': return 'Especial';
      case 'no_asegurado': return 'No Asegurado';
      default: return regimen;
    }
  }
}

