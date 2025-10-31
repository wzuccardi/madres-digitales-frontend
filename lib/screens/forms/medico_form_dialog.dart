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
    'GinecologÃ­a y Obstetricia',
    'PediatrÃ­a',
    'Medicina Interna',
    'Medicina Familiar',
    'AnestesiologÃ­a',
    'CirugÃ­a General',
    'CardiologÃ­a',
    'NeurologÃ­a',
    'PsiquiatrÃ­a',
    'RadiologÃ­a',
    'PatologÃ­a',
    'Medicina de Urgencias',
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.medico != null) {
      _nombreController.text = widget.medico!.nombre;
      _documentoController.text = widget.medico!.documento;
      _telefonoController.text = widget.medico!.telefono ?? '';
      _emailController.text = widget.medico!.email ?? '';
      _registroMedicoController.text = widget.medico!.registroMedico ?? '';
      _especialidad = widget.medico!.especialidad;
      _ipsId = widget.medico!.ipsId;
      _activo = widget.medico!.activo;
    } else {
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
      title: Text(widget.medico == null ? 'Crear MÃ©dico' : 'Editar MÃ©dico'),
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
                    if (!RegExp(r'^[a-zA-ZÃ¡Ã©Ã­Ã³ÃºÃÃ‰ÃÃ“ÃšÃ±Ã‘\s]+$').hasMatch(value)) {
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
                          // Implementar validaciÃ³n asÃ­ncrona con debounce
                          _debounceVerificarDocumento(value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El documento es requerido';
                          }
                          // ValidaciÃ³n bÃ¡sica de formato
                          if (value.length < 5) {
                            return 'El documento debe tener al menos 5 caracteres';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'El documento solo puede contener nÃºmeros';
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
                          labelText: 'Registro MÃ©dico',
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
                              return 'El registro mÃ©dico debe tener al menos 3 caracteres';
                            }
                            if (!RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(value)) {
                              return 'El registro mÃ©dico solo puede contener letras, nÃºmeros y guiones';
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
                          labelText: 'TelÃ©fono',
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
                              return 'El telÃ©fono solo puede contener nÃºmeros y caracteres especiales (+-())';
                            }
                            if (value.replaceAll(RegExp(r'[^\d]'), '').length < 7) {
                              return 'El telÃ©fono debe tener al menos 7 dÃ­gitos';
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
                              return 'Email invÃ¡lido';
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
                  title: const Text('MÃ©dico Activo'),
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
    }
  }

  // Confirmar salida si hay cambios sin guardar
  Future<void> _confirmarSalida() async {
    if (_hasUnsavedChanges) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Â¿Salir sin guardar?'),
          content: const Text('Tienes cambios sin guardar. Â¿EstÃ¡s seguro de que quieres salir?'),
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

  // VerificaciÃ³n asÃ­ncrona de unicidad de documento con debounce
  void _debounceVerificarDocumento(String documento) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _verificarUnicidadDocumento(documento);
    });
  }

  // Implementar verificaciÃ³n asÃ­ncrona de unicidad de documento
  Future<void> _verificarUnicidadDocumento(String documento) async {
    if (documento.length < 5 || documento == widget.medico?.documento) return;
    
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
          _documentoError = 'Ya existe un mÃ©dico con este documento';
        });
      } else {
      }
    } finally {
      setState(() {
        _isVerificandoDocumento = false;
      });
    }
  }

  Future<void> _guardarMedico() async {
    
    // ValidaciÃ³n personalizada del documento
    if (_documentoError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_documentoError!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

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
      

      // Implementar llamada real al servicio
      final service = await ref.read(integratedAdminServiceProvider.future);
      
      if (widget.medico == null) {
        await service.createMedico(data);
      } else {
        await service.updateMedico(widget.medico!.id, data);
      }

      // Mostrar mensaje de Ã©xito real
      if (widget.medico == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('MÃ©dico creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('MÃ©dico actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      // Marcar que no hay cambios sin guardar
      _hasUnsavedChanges = false;

      // Refrescar la lista de mÃ©dicos
      ref.invalidate(medicosIntegradosProvider(widget.municipioId));
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Reemplazado con log de error directo
      
      String errorMessage = 'Error al guardar mÃ©dico';
      
      // Clasificar el error para mostrar mensaje especÃ­fico
      if (e.toString().contains('SocketException')) {
        errorMessage = 'Error de conexiÃ³n. Verifica tu acceso a internet.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'La operaciÃ³n tardÃ³ demasiado. Intenta nuevamente.';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage = 'No tienes permisos para realizar esta operaciÃ³n.';
      } else if (e.toString().contains('409')) {
        errorMessage = 'Ya existe un mÃ©dico con este documento o registro mÃ©dico.';
      } else if (e.toString().contains('422')) {
        errorMessage = 'Hay datos invÃ¡lidos en el formulario. Verifica los campos.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Error del servidor. Intenta mÃ¡s tarde.';
      } else {
        errorMessage = 'Error al guardar mÃ©dico: $e';
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
      }
    }
  }
}
