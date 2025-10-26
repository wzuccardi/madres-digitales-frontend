import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/medico_service.dart';
import '../../../../services/ips_service.dart';
import '../../../../services/api_service.dart';
import '../../../../utils/logger.dart';

class MedicoFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? medico;

  const MedicoFormScreen({super.key, this.medico});

  @override
  ConsumerState<MedicoFormScreen> createState() => _MedicoFormScreenState();
}

class _MedicoFormScreenState extends ConsumerState<MedicoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _especialidadController = TextEditingController();
  final _registroMedicoController = TextEditingController();
  
  bool _activo = true;
  String? _ipsId;
  String? _municipioId;
  List<Map<String, dynamic>> _ipsList = [];
  List<Map<String, dynamic>> _municipios = [];
  bool _isLoading = false;
  bool _isLoadingData = true;
  final bool _isDisposed = false;
  late MedicoService _medicoService;
  late IPSService _ipsService;

  @override
  void initState() {
    super.initState();
    _medicoService = MedicoService();
    _ipsService = IPSService(ApiService()); // Usar el singleton
    _loadData();
    if (widget.medico != null) {
      _loadMedicoData();
    }
  }

  void _loadMedicoData() {
    final medico = widget.medico!;
    _nombreController.text = medico['nombre'] ?? '';
    _documentoController.text = medico['documento'] ?? '';
    _telefonoController.text = medico['telefono'] ?? '';
    _emailController.text = medico['email'] ?? '';
    _especialidadController.text = medico['especialidad'] ?? '';
    _registroMedicoController.text = medico['registro_medico'] ?? '';
    _activo = medico['activo'] ?? true;
    _ipsId = medico['ips_id'];
    _municipioId = medico['municipio_id'];
  }

  Future<void> _loadData() async {
    try {
      final futures = await Future.wait([
        _ipsService.obtenerTodasLasIPS(),
        _ipsService.obtenerMunicipios(),
      ]);
      
      if (mounted && !_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed) {
            setState(() {
              _ipsList = List<Map<String, dynamic>>.from(futures[0]);
              _municipios = List<Map<String, dynamic>>.from(futures[1]);
              _isLoadingData = false;
            });
          }
        });
      }
    } catch (e) {
      appLogger.error('Error cargando datos', error: e);
      if (mounted && !_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed) {
            setState(() {
              _isLoadingData = false;
            });
          }
        });
      }
    }
  }

  Future<void> _saveMedico() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (mounted && !_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() {
            _isLoading = true;
          });
        }
      });
    }

    try {
      final medicoData = {
        'nombre': _nombreController.text.trim(),
        'documento': _documentoController.text.trim(),
        'telefono': _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'especialidad': _especialidadController.text.trim(),
        'registro_medico': _registroMedicoController.text.trim(),
        'ips_id': _ipsId,
        'municipio_id': _municipioId,
        'activo': _activo,
      };

      appLogger.info('Guardando médico: ${medicoData.toString()}');

      if (widget.medico != null) {
        // Actualizar médico existente
        await _medicoService.updateMedico(widget.medico!['id'], medicoData);
        if (mounted && !_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Médico actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Crear nuevo médico
        await _medicoService.createMedico(medicoData);
        if (mounted && !_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Médico creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted && !_isDisposed) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      appLogger.error('Error guardando médico', error: e);
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar médico: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted && !_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medico != null ? 'Editar Médico' : 'Nuevo Médico'),
        backgroundColor: Colors.blue[100],
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveMedico,
              child: const Text(
                'GUARDAR',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información Básica',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del Médico *',
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
                          TextFormField(
                            controller: _documentoController,
                            decoration: const InputDecoration(
                              labelText: 'Documento de Identidad *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El documento es requerido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _registroMedicoController,
                            decoration: const InputDecoration(
                              labelText: 'Registro Médico *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El registro médico es requerido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _especialidadController,
                            decoration: const InputDecoration(
                              labelText: 'Especialidad *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La especialidad es requerida';
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información de Contacto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _telefonoController,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Email inválido';
                                }
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ubicación',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _municipioId,
                            decoration: const InputDecoration(
                              labelText: 'Municipio',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Seleccionar municipio'),
                              ),
                              ..._municipios.map((municipio) => DropdownMenuItem(
                                value: municipio['id'],
                                child: Text(municipio['nombre'] ?? 'Sin nombre'),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _municipioId = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _ipsId,
                            decoration: const InputDecoration(
                              labelText: 'IPS',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Seleccionar IPS'),
                              ),
                              ..._ipsList.map((ips) => DropdownMenuItem(
                                value: ips['id'],
                                child: Text(ips['nombre'] ?? 'Sin nombre'),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _ipsId = value;
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Médico Activo'),
                            subtitle: Text(_activo ? 'El médico está activo' : 'El médico está inactivo'),
                            value: _activo,
                            onChanged: (value) {
                              setState(() {
                                _activo = value;
                              });
                            },
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

  @override
  void dispose() {
    _nombreController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _especialidadController.dispose();
    _registroMedicoController.dispose();
    super.dispose();
  }
}
