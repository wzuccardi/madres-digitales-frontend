import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:madres_digitales_flutter_new/models/integrated_models.dart';
import 'package:madres_digitales_flutter_new/data/services/municipio_service.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';
import 'package:madres_digitales_flutter_new/core/utils/permissions_helper.dart';

class UsuarioFormScreen extends ConsumerStatefulWidget {

  const UsuarioFormScreen({super.key, this.usuario});
  final UsuarioModel? usuario;

  @override
  ConsumerState<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends ConsumerState<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MunicipioService _municipioService = MunicipioService();

  // Controladores de texto
  final _emailController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRol = 'MADRINA';
  String? _selectedMunicipioId;
  bool _isLoading = false;
  bool _isLoadingMunicipios = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  List<Map<String, dynamic>> _municipiosList = [];

  @override
  void initState() {
    super.initState();
    _loadMunicipios();
    if (widget.usuario != null) {
      _loadUsuarioData();
    }
  }


  Future<void> _loadMunicipios() async {
    try {
      AppLogger.info('UsuarioFormScreen: Cargando municipios desde la API...');
      
      final municipios = await _municipioService.getMunicipios(activo: true, limit: 200);
      AppLogger.info('UsuarioFormScreen: ${municipios.length} municipios cargados');
      
      setState(() {
        _municipiosList = municipios.map((m) => {
          'id': m.id,
          'nombre': m.nombre,
        }).toList();
        _isLoadingMunicipios = false;
      });
    } catch (e) {
      AppLogger.error('UsuarioFormScreen: Error cargando municipios', error: e);
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

  void _loadUsuarioData() {
    final usuario = widget.usuario!;
    _emailController.text = usuario.email;
    _nombreController.text = usuario.nombre;
    _selectedRol = usuario.rol;
    _selectedMunicipioId = _municipiosList.isNotEmpty ? _municipiosList.first['id'] : null;
  }

  /// Obtener roles permitidos según el rol del usuario actual
  List<Map<String, String>> _getAllowedRoles(String currentUserRole) {
    return PermissionsHelper.getRoleDropdownItems(currentUserRole);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nombreController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveUsuario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar contraseñas para nuevo usuario
    if (widget.usuario == null) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Combinar nombre y apellido para el backend
      final nombreCompleto = '${_nombreController.text.trim()} ${_apellidoController.text.trim()}';
      
      final usuarioData = {
        'email': _emailController.text.trim(),
        'nombre': nombreCompleto,
        'documento': _documentoController.text.trim(),
        'telefono': _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        'rol': _selectedRol,
        'municipio_id': _selectedMunicipioId,
        'activo': widget.usuario?.activo ?? true,
      };
      
      // Solo agregar password para usuarios nuevos
      if (widget.usuario == null) {
        usuarioData['password'] = _passwordController.text.trim();
      }

      if (widget.usuario == null) {
        // Crear nuevo usuario - usar API directamente
        final apiService = ref.read(apiServiceProvider);
        await apiService.post('/usuarios', data: usuarioData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Actualizar usuario existente - usar API directamente
        final apiService = ref.read(apiServiceProvider);
        await apiService.put('/usuarios/${widget.usuario!.id}', data: usuarioData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.usuario != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Usuario' : 'Crear Usuario'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveUsuario,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                hintText: 'usuario@ejemplo.com',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El email es obligatorio';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Ingrese un email válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nombre
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombres *',
                hintText: 'Ej: María',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Los nombres son obligatorios';
                }
                if (value.trim().length < 2) {
                  return 'Los nombres deben tener al menos 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Apellido
            TextFormField(
              controller: _apellidoController,
              decoration: const InputDecoration(
                labelText: 'Apellidos *',
                hintText: 'Ej: González',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Los apellidos son obligatorios';
                }
                if (value.trim().length < 2) {
                  return 'Los apellidos deben tener al menos 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Rol - Filtrado según permisos del usuario actual
            Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authProvider);
                final currentUserRole = authState.user?.rol ?? 'MADRINA';
                
                // Importar el helper de permisos
                final allowedRoles = _getAllowedRoles(currentUserRole);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: allowedRoles.any((r) => r['value'] == _selectedRol) 
                          ? _selectedRol 
                          : (allowedRoles.isNotEmpty ? allowedRoles.first['value'] : 'MADRINA'),
                      decoration: const InputDecoration(
                        labelText: 'Rol *',
                        prefixIcon: Icon(Icons.work),
                        border: OutlineInputBorder(),
                      ),
                      items: allowedRoles.map((role) {
                        return DropdownMenuItem<String>(
                          value: role['value'],
                          child: Text(role['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRol = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione un rol';
                        }
                        return null;
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Documento
            TextFormField(
              controller: _documentoController,
              decoration: const InputDecoration(
                labelText: 'Documento',
                hintText: 'Ej: 12345678',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Teléfono
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                hintText: 'Ej: 3001234567',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Dirección
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                hintText: 'Ej: Calle 123 #45-67',
                prefixIcon: Icon(Icons.location_on),
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
                    value: _selectedMunicipioId,
                    decoration: const InputDecoration(
                      labelText: 'Municipio',
                      prefixIcon: Icon(Icons.location_city),
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

            // Campos de contraseña solo para usuarios nuevos
            if (!isEditing) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña *',
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña *',
                  hintText: 'Repita la contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirme la contraseña';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 32),

            // Botón de guardar
            ElevatedButton(
              onPressed: _isLoading ? null : _saveUsuario,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
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
                      isEditing ? 'Actualizar Usuario' : 'Crear Usuario',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
