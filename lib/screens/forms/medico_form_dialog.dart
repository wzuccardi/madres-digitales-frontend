import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/integrated_models.dart';
import '../../providers/integrated_admin_provider.dart';
import '../../providers/service_providers.dart';

class MedicoFormDialog extends ConsumerStatefulWidget {
  final MedicoIntegrado? medico;
  final String municipioId;
  final List<IPSIntegrada>? ipsList;

  const MedicoFormDialog({
    super.key,
    this.medico,
    required this.municipioId,
    this.ipsList,
  });

  @override
  ConsumerState<MedicoFormDialog> createState() => _MedicoFormDialogState();
}

class _MedicoFormDialogState extends ConsumerState<MedicoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _registroMedicoController = TextEditingController();
  
  String _especialidad = 'Medicina General';
  String? _ipsId;
  bool _activo = true;
  bool _isLoading = false;
  bool _isVerificandoDocumento = false;
  String? _documentoError;
  bool _hasUnsavedChanges = false;
  Timer? _debounceTimer;

  final List<String> _especialidades = [
    'Medicina General',
    'Ginecología y Obstetricia',
    'Pediatría',
    'Medicina Interna',
    'Medicina Familiar',
    'Anestesiología',
    'Cirugía General',
    'Cardiología',
    'Neurología',
    'Psiquiatría',
    'Radiología',
    'Patología',
    'Medicina de Urgencias',
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('🔧 [MedicoFormDialog] Inicializando formulario Médico');
    debugPrint('🔧 [MedicoFormDialog] Modo: ${widget.medico == null ? "Creación" : "Edición"}');
    debugPrint('🔧 [MedicoFormDialog] Municipio ID: ${widget.municipioId}');
    debugPrint('🔧 [MedicoFormDialog] Lista de IPS disponible: ${widget.ipsList?.length ?? 0}');
    
    if (widget.medico != null) {
      debugPrint('🔧 [MedicoFormDialog] Cargando datos de médico existente: ${widget.medico!.nombre}');
      _nombreController.text = widget.medico!.nombre;
      _documentoController.text = widget.medico!.documento;
      _telefonoController.text = widget.medico!.telefono ?? '';
      _emailController.text = widget.medico!.email ?? '';
      _registroMedicoController.text = widget.medico!.registroMedico ?? '';
      _especialidad = widget.medico!.especialidad;
      _ipsId = widget.medico!.ipsId;
      _activo = widget.medico!.activo;
      debugPrint('✅ [MedicoFormDialog] Datos de médico cargados correctamente');
    } else {
      debugPrint('🔧 [MedicoFormDialog] Inicializando formulario para nuevo médico');
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _registroMedicoController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.medico == null ? 'Crear Médico' : 'Editar Médico'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre Completo *',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  maxLength: 100,
                  onChanged: (value) {
                    _markAsChanged();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    if (value.length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
                      return 'El nombre solo puede contener letras y espacios';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _documentoController,
                        decoration: InputDecoration(
                          labelText: 'Documento *',
                          border: const OutlineInputBorder(),
                          counterText: '',
                          suffixIcon: _isVerificandoDocumento
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : _documentoError != null
                                  ? const Icon(Icons.error, color: Colors.red)
                                  : null,
                        ),
                        maxLength: 20,
                        onChanged: (value) {
                          _markAsChanged();
                          // Implementar validación asíncrona con debounce
                          _debounceVerificarDocumento(value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El documento es requerido';
                          }
                          // Validación básica de formato
                          if (value.length < 5) {
                            return 'El documento debe tener al menos 5 caracteres';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'El documento solo puede contener números';
                          }
                          if (_documentoError != null) {
                            return _documentoError;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _registroMedicoController,
                        decoration: const InputDecoration(
                          labelText: 'Registro Médico',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        maxLength: 50,
                        onChanged: (value) {
                          _markAsChanged();
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (value.length < 3) {
                              return 'El registro médico debe tener al menos 3 caracteres';
                            }
                            if (!RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(value)) {
                              return 'El registro médico solo puede contener letras, números y guiones';
                            }
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
                        controller: _telefonoController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        maxLength: 15,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          _markAsChanged();
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(r'^[0-9\-\+\(\)\s]+$').hasMatch(value)) {
                              return 'El teléfono solo puede contener números y caracteres especiales (+-())';
                            }
                            if (value.replaceAll(RegExp(r'[^\d]'), '').length < 7) {
                              return 'El teléfono debe tener al menos 7 dígitos';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        maxLength: 100,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          _markAsChanged();
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (value.length < 5) {
                              return 'El email debe tener al menos 5 caracteres';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Email inválido';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _especialidad,
                  decoration: const InputDecoration(
                    labelText: 'Especialidad *',
                    border: OutlineInputBorder(),
                  ),
                  items: _especialidades.map((especialidad) {
                    return DropdownMenuItem(
                      value: especialidad,
                      child: Text(especialidad),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _especialidad = value!;
                      _markAsChanged();
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (widget.ipsList != null && widget.ipsList!.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: _ipsId,
                    decoration: const InputDecoration(
                      labelText: 'IPS Asignada',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sin asignar'),
                      ),
                      ...widget.ipsList!.map((ips) {
                        return DropdownMenuItem(
                          value: ips.id,
                          child: Text(ips.nombre),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      debugPrint('🔍 [MedicoFormDialog] IPS seleccionada: $value');
                      setState(() {
                        _ipsId = value;
                        _markAsChanged();
                      });
                    },
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No hay IPS disponibles en este municipio. Primero crea una IPS.',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Médico Activo'),
                  value: _activo,
                  onChanged: (value) {
                    setState(() {
                      _activo = value;
                      _markAsChanged();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => _confirmarSalida(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _guardarMedico,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.medico == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  // Marcar que hay cambios sin guardar
  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
      debugPrint('🔍 [MedicoFormDialog] Formulario marcado con cambios sin guardar');
    }
  }

  // Confirmar salida si hay cambios sin guardar
  Future<void> _confirmarSalida() async {
    if (_hasUnsavedChanges) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Salir sin guardar?'),
          content: const Text('Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Salir'),
            ),
          ],
        ),
      );
      
      if (shouldExit == true && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // Verificación asíncrona de unicidad de documento con debounce
  void _debounceVerificarDocumento(String documento) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _verificarUnicidadDocumento(documento);
    });
  }

  // Implementar verificación asíncrona de unicidad de documento
  Future<void> _verificarUnicidadDocumento(String documento) async {
    if (documento.length < 5 || documento == widget.medico?.documento) return;
    
    debugPrint('🔍 [MedicoFormDialog] Verificando unicidad del documento: $documento');
    setState(() {
      _isVerificandoDocumento = true;
      _documentoError = null;
    });
    
    try {
      final service = await ref.read(integratedAdminServiceProvider.future);
      final medicos = await service.getAllMedicosIntegrados();
      final existe = medicos.any((m) => m.documento == documento && m.id != widget.medico?.id);
      
      if (existe) {
        setState(() {
          _documentoError = 'Ya existe un médico con este documento';
        });
        debugPrint('❌ [MedicoFormDialog] Documento ya existe: $documento');
      } else {
        debugPrint('✅ [MedicoFormDialog] Documento disponible: $documento');
      }
    } catch (e) {
      debugPrint('❌ [MedicoFormDialog] Error verificando unicidad: $e');
    } finally {
      setState(() {
        _isVerificandoDocumento = false;
      });
    }
  }

  Future<void> _guardarMedico() async {
    debugPrint('🔍 [MedicoFormDialog] Iniciando guardado de médico');
    
    // Validación personalizada del documento
    if (_documentoError != null) {
      debugPrint('❌ [MedicoFormDialog] Error de documento: $_documentoError');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_documentoError!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ [MedicoFormDialog] Validación del formulario falló');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    debugPrint('🔄 [MedicoFormDialog] Estado de carga activado');

    try {
      final data = {
        'nombre': _nombreController.text.trim(),
        'documento': _documentoController.text.trim(),
        'telefono': _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'especialidad': _especialidad,
        'registro_medico': _registroMedicoController.text.trim().isEmpty ? null : _registroMedicoController.text.trim(),
        'ips_id': _ipsId,
        'municipio_id': widget.municipioId,
        'activo': _activo,
      };
      
      debugPrint('🔍 [MedicoFormDialog] Datos a guardar: $data');
      debugPrint('🔍 [MedicoFormDialog] Conectando con servicio real');

      // Implementar llamada real al servicio
      final service = await ref.read(integratedAdminServiceProvider.future);
      
      if (widget.medico == null) {
        debugPrint('🔍 [MedicoFormDialog] Creando nuevo médico');
        await service.createMedico(data);
      } else {
        debugPrint('🔍 [MedicoFormDialog] Actualizando médico existente: ${widget.medico!.id}');
        await service.updateMedico(widget.medico!.id, data);
      }

      // Mostrar mensaje de éxito real
      if (widget.medico == null) {
        debugPrint('✅ [MedicoFormDialog] Médico creado exitosamente');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Médico creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        debugPrint('✅ [MedicoFormDialog] Médico actualizado exitosamente');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Médico actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      // Marcar que no hay cambios sin guardar
      _hasUnsavedChanges = false;

      // Refrescar la lista de médicos
      debugPrint('🔄 [MedicoFormDialog] Refrescando lista de médicos');
      ref.invalidate(medicosIntegradosProvider(widget.municipioId));
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('❌ [MedicoFormDialog] Error al guardar médico: $e');
      debugPrint('❌ [MedicoFormDialog] Stack trace: ${StackTrace.current}');
      // Reemplazado con log de error directo
      debugPrint('❌ [MedicoFormDialog] Error: $e');
      
      String errorMessage = 'Error al guardar médico';
      
      // Clasificar el error para mostrar mensaje específico
      if (e.toString().contains('SocketException')) {
        errorMessage = 'Error de conexión. Verifica tu acceso a internet.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'La operación tardó demasiado. Intenta nuevamente.';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage = 'No tienes permisos para realizar esta operación.';
      } else if (e.toString().contains('409')) {
        errorMessage = 'Ya existe un médico con este documento o registro médico.';
      } else if (e.toString().contains('422')) {
        errorMessage = 'Hay datos inválidos en el formulario. Verifica los campos.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Error del servidor. Intenta más tarde.';
      } else {
        errorMessage = 'Error al guardar médico: $e';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('🔄 [MedicoFormDialog] Estado de carga desactivado');
      }
    }
  }
}