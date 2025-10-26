import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/integrated_models.dart';
import '../../providers/integrated_admin_provider.dart';
import '../../providers/service_providers.dart';

class IPSFormDialog extends ConsumerStatefulWidget {
  final IPSIntegrada? ips;
  final String municipioId;

  const IPSFormDialog({
    super.key,
    this.ips,
    required this.municipioId,
  });

  @override
  ConsumerState<IPSFormDialog> createState() => _IPSFormDialogState();
}

class _IPSFormDialogState extends ConsumerState<IPSFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  
  String _nivelAtencion = 'primario';
  bool _activa = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔧 [IPSFormDialog] Inicializando formulario IPS');
    debugPrint('🔧 [IPSFormDialog] Modo: ${widget.ips == null ? "Creación" : "Edición"}');
    debugPrint('🔧 [IPSFormDialog] Municipio ID: ${widget.municipioId}');
    
    if (widget.ips != null) {
      debugPrint('🔧 [IPSFormDialog] Cargando datos de IPS existente: ${widget.ips!.nombre}');
      _nombreController.text = widget.ips!.nombre;
      _direccionController.text = widget.ips!.direccion;
      _telefonoController.text = widget.ips!.telefono ?? '';
      _emailController.text = widget.ips!.email ?? '';
      _latitudController.text = widget.ips!.latitud?.toString() ?? '';
      _longitudController.text = widget.ips!.longitud?.toString() ?? '';
      _nivelAtencion = widget.ips!.nivelAtencion;
      _activa = widget.ips!.activa;
      debugPrint('✅ [IPSFormDialog] Datos de IPS cargados correctamente');
    } else {
      debugPrint('🔧 [IPSFormDialog] Inicializando formulario para nueva IPS');
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ips == null ? 'Crear IPS' : 'Editar IPS'),
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
                    labelText: 'Nombre de la IPS *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La dirección es requerida';
                    }
                    return null;
                  },
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
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _nivelAtencion,
                  decoration: const InputDecoration(
                    labelText: 'Nivel de Atención *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'primario', child: Text('Nivel I - Primario')),
                    DropdownMenuItem(value: 'secundario', child: Text('Nivel II - Secundario')),
                    DropdownMenuItem(value: 'terciario', child: Text('Nivel III - Terciario')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _nivelAtencion = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudController,
                        decoration: const InputDecoration(
                          labelText: 'Latitud',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final lat = double.tryParse(value);
                            if (lat == null || lat < -90 || lat > 90) {
                              return 'Latitud inválida (-90 a 90)';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudController,
                        decoration: const InputDecoration(
                          labelText: 'Longitud',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final lng = double.tryParse(value);
                            if (lng == null || lng < -180 || lng > 180) {
                              return 'Longitud inválida (-180 a 180)';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('IPS Activa'),
                  value: _activa,
                  onChanged: (value) {
                    setState(() {
                      _activa = value;
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
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _guardarIPS,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.ips == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  Future<void> _guardarIPS() async {
    debugPrint('🔍 [IPSFormDialog] Iniciando guardado de IPS');
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ [IPSFormDialog] Validación del formulario falló');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    debugPrint('🔄 [IPSFormDialog] Estado de carga activado');

    try {
      final data = {
        'nombre': _nombreController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'telefono': _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'nivel_atencion': _nivelAtencion,
        'municipio_id': widget.municipioId,
        'latitud': _latitudController.text.trim().isEmpty ? null : double.tryParse(_latitudController.text.trim()),
        'longitud': _longitudController.text.trim().isEmpty ? null : double.tryParse(_longitudController.text.trim()),
        'activa': _activa,
      };
      
      debugPrint('🔍 [IPSFormDialog] Datos a guardar: $data');
      debugPrint('🔍 [IPSFormDialog] Conectando con servicio real');

      // Implementar llamada real al servicio
      final service = await ref.read(integratedAdminServiceProvider.future);
      
      if (widget.ips == null) {
        debugPrint('🔍 [IPSFormDialog] Creando nueva IPS');
        await service.createIPS(data);
      } else {
        debugPrint('🔍 [IPSFormDialog] Actualizando IPS existente: ${widget.ips!.id}');
        await service.updateIPS(widget.ips!.id, data);
      }

      // Por ahora, solo mostramos un mensaje de éxito
      if (widget.ips == null) {
        debugPrint('✅ [IPSFormDialog] IPS creada exitosamente (simulado)');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('IPS creada exitosamente (simulado)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        debugPrint('✅ [IPSFormDialog] IPS actualizada exitosamente (simulado)');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('IPS actualizada exitosamente (simulado)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      // Refrescar la lista de IPS
      debugPrint('🔄 [IPSFormDialog] Refrescando lista de IPS');
      ref.invalidate(ipsIntegradaProvider(widget.municipioId));
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('❌ [IPSFormDialog] Error al guardar IPS: $e');
      debugPrint('❌ [IPSFormDialog] Stack trace: ${StackTrace.current}');
      // Reemplazado con log de error directo
      debugPrint('❌ [IPSFormDialog] Error: $e');
      
      String errorMessage = 'Error al guardar IPS';
      
      // Clasificar el error para mostrar mensaje específico
      if (e.toString().contains('SocketException')) {
        errorMessage = 'Error de conexión. Verifica tu acceso a internet.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'La operación tardó demasiado. Intenta nuevamente.';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage = 'No tienes permisos para realizar esta operación.';
      } else if (e.toString().contains('409')) {
        errorMessage = 'Ya existe una IPS con este nombre en el municipio.';
      } else if (e.toString().contains('422')) {
        errorMessage = 'Hay datos inválidos en el formulario. Verifica los campos.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Error del servidor. Intenta más tarde.';
      } else {
        errorMessage = 'Error al guardar IPS: $e';
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
        debugPrint('🔄 [IPSFormDialog] Estado de carga desactivado');
      }
    }
  }
}