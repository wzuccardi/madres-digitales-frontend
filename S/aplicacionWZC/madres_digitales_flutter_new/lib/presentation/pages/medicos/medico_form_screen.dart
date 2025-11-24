import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/data/services/medico_service.dart';
import 'package:madres_digitales_flutter_new/data/services/municipio_service.dart';
import 'package:madres_digitales_flutter_new/data/services/ips_service.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/app_bar_with_logo.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

class MedicoFormScreen extends ConsumerStatefulWidget {

  const MedicoFormScreen({super.key, this.medico});
  final Map<String, dynamic>? medico;

  @override
  ConsumerState<MedicoFormScreen> createState() => _MedicoFormScreenState();
}

class _MedicoFormScreenState extends ConsumerState<MedicoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final MedicoService _medicoService;
  late final MunicipioService _municipioService;
  late final IPSService _ipsService;
  
  // Controladores
  late final TextEditingController _nombreController;
  late final TextEditingController _documentoController;
  late final TextEditingController _registroMedicoController;
  late final TextEditingController _especialidadController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _emailController;
  
  // Variables adicionales
  String _tipoDocumento = 'cedula';
  String? _ipsId;
  String? _municipioId;
  
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isDisposed = false;
  bool _isLoadingData = true;
  
  List<Map<String, dynamic>> _ipsList = [];
  List<Map<String, dynamic>> _municipiosList = [];

  @override
  void initState() {
    super.initState();
    AppLogger.info('MedicoFormScreen: Inicializando formulario');
    _medicoService = ref.read(medicoServiceProvider);
    _municipioService = ref.read(municipioServiceProvider);
    _ipsService = ref.read(ipsServiceProvider);
    
    // Inicializar controladores
    _nombreController = TextEditingController();
    _documentoController = TextEditingController();
    _registroMedicoController = TextEditingController();
    _especialidadController = TextEditingController();
    _telefonoController = TextEditingController();
    _emailController = TextEditingController();
    
    _isEditing = widget.medico != null;
    AppLogger.info('MedicoFormScreen: Modo ${_isEditing ? "EDICIÓN" : "CREACIÓN"}');
    
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      AppLogger.info('MedicoFormScreen: Cargando datos iniciales...');
      // Cargar municipios reales desde la API
      final municipios = await _municipioService.getAllMunicipios();
      // Cargar IPS reales desde la API
      final ipsEntities = await _ipsService.getAllIPS();
      AppLogger.info('MedicoFormScreen: ${municipios.length} municipios cargados desde la API');
      
      setState(() {
        _ipsList = ipsEntities.map((e) => {
          'id': e.id,
          'nombre': e.nombre,
        }).toList();
        // Usar municipios reales de la API
        _municipiosList = municipios.map((m) => {
          'id': m.id,
          'nombre': m.nombre,
        }).toList();
        
        _isLoadingData = false;
      });
      
      if (_isEditing) {
        _loadMedicoData();
      }
    } catch (e) {
      AppLogger.error('MedicoFormScreen: Error cargando datos iniciales', error: e);
      
      setState(() {
        _isLoadingData = false;
      });
      
      // Mostrar error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando municipios: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _loadMedicoData() {
    if (widget.medico != null) {
      final medico = widget.medico!;
      AppLogger.info('MedicoFormScreen: Cargando datos del médico');
      
      _nombreController.text = medico['nombre']?.toString() ?? '';
      _documentoController.text = medico['documento']?.toString() ?? '';
      _registroMedicoController.text = medico['registro_medico']?.toString() ?? '';
      _especialidadController.text = medico['especialidad']?.toString() ?? '';
      _telefonoController.text = medico['telefono']?.toString() ?? '';
      _emailController.text = medico['email']?.toString() ?? '';
      
      _tipoDocumento = medico['tipo_documento']?.toString() ?? 'cedula';
      _ipsId = medico['ips_id']?.toString();
      _municipioId = medico['municipio_id']?.toString();
      
      AppLogger.info('MedicoFormScreen: Datos cargados exitosamente');
    }
  }

  @override
  void dispose() {
    AppLogger.info('MedicoFormScreen: Liberando recursos');
    _isDisposed = true;
    
    _nombreController.dispose();
    _documentoController.dispose();
    _registroMedicoController.dispose();
    _especialidadController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    
    super.dispose();
  }

  Future<void> _saveMedico() async {
    AppLogger.info('MedicoFormScreen: Iniciando guardado');
    
    if (!_formKey.currentState!.validate()) {
      AppLogger.warn('MedicoFormScreen: Validación fallida');
      return;
    }

    if (!mounted || _isDisposed) {
      AppLogger.warn('MedicoFormScreen: Widget no montado o disposed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'nombre': _nombreController.text.trim(),
        'documento': _documentoController.text.trim(),
        'tipo_documento': _tipoDocumento,
        'registro_medico': _registroMedicoController.text.trim(),
        'especialidad': _especialidadController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'email': _emailController.text.trim(),
        if (_ipsId != null) 'ips_id': _ipsId,
        if (_municipioId != null) 'municipio_id': _municipioId,
      };

      AppLogger.info('MedicoFormScreen: Datos a enviar: $data');

      if (_isEditing && widget.medico != null) {
        final id = widget.medico!['id'].toString();
        await _medicoService.updateMedico(id, data);
        AppLogger.info('MedicoFormScreen: Médico actualizado exitosamente');
      } else {
        await _medicoService.createMedico(data);
        AppLogger.info('MedicoFormScreen: Médico creado exitosamente');
      }

      if (!mounted || _isDisposed) return;
      
      final mensaje = _isEditing 
        ? 'Médico actualizado exitosamente' 
        : 'Médico creado exitosamente';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop(true);
      
    } catch (e) {
      AppLogger.error('MedicoFormScreen: Error durante el guardado', error: e);
      
      if (!mounted || _isDisposed) return;
      
      setState(() {
        _isLoading = false;
      });
      
      String errorMessage = 'Error al guardar médico';
      if (e.toString().contains('SocketException')) {
        errorMessage = 'Error de conexión. Verifica tu acceso a internet.';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage = 'No tienes permisos para realizar esta operación.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithLogo(
        title: _isEditing ? 'Editar Médico' : 'Nuevo Médico',
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información Personal',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre Completo *',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es requerido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: _tipoDocumento,
                                  decoration: const InputDecoration(
                                    labelText: 'Tipo de Documento',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'cedula', child: Text('Cédula')),
                                    DropdownMenuItem(value: 'tarjeta_identidad', child: Text('T.I.')),
                                    DropdownMenuItem(value: 'pasaporte', child: Text('Pasaporte')),
                                    DropdownMenuItem(value: 'registro_civil', child: Text('R.C.')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _tipoDocumento = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _documentoController,
                                  decoration: const InputDecoration(
                                    labelText: 'Número de Documento *',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'El documento es requerido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _registroMedicoController,
                            decoration: const InputDecoration(
                              labelText: 'Registro Médico *',
                              prefixIcon: Icon(Icons.medical_services),
                              border: OutlineInputBorder(),
                              hintText: 'Número de registro profesional',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El registro médico es requerido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información Profesional',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _especialidadController,
                            decoration: const InputDecoration(
                              labelText: 'Especialidad *',
                              prefixIcon: Icon(Icons.local_hospital),
                              border: OutlineInputBorder(),
                              hintText: 'Ej: Ginecología, Pediatría, Medicina General',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La especialidad es requerida';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String?>(
                            value: _ipsId,
                            decoration: const InputDecoration(
                              labelText: 'IPS de Trabajo',
                              prefixIcon: Icon(Icons.business),
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Seleccionar IPS'),
                              ),
                              ..._ipsList.map((ips) {
                                return DropdownMenuItem<String?>(
                                  value: ips['id'] as String?,
                                  child: Text(ips['nombre'].toString()),
                                );
                              }),
                            ],
                            onChanged: (String? value) {
                              setState(() {
                                _ipsId = value;
                              });
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String?>(
                            value: _municipioId,
                            decoration: const InputDecoration(
                              labelText: 'Municipio',
                              prefixIcon: Icon(Icons.location_city),
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Seleccionar Municipio'),
                              ),
                              ..._municipiosList.map((municipio) {
                                  return DropdownMenuItem<String?>(
                                  value: municipio['id'] as String?,
                                  child: Text(municipio['nombre'].toString()),
                                );
                              }),
                            ],
                            onChanged: (String? value) {
                              setState(() {
                                _municipioId = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de Contacto',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _telefonoController,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                              hintText: 'Ej: 3001234567',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                              hintText: 'medico@ejemplo.com',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Ingrese un email válido';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveMedico,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_isEditing ? 'Actualizar' : 'Crear'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
