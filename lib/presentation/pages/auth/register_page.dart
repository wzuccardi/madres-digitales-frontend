import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/common/custom_button.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController documentoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController epsController = TextEditingController();
  final TextEditingController contactoEmergenciaNombreController = TextEditingController();
  final TextEditingController contactoEmergenciaTelefonoController = TextEditingController();

  bool isLoading = false;
  bool isLoadingMunicipios = false;
  String? errorMessage;
  String selectedRol = 'madrina'; // Rol por defecto
  String selectedTipoDocumento = 'cedula';
  DateTime? fechaNacimiento;
  String? selectedGrupoSanguineo;
  String? selectedMunicipioId;
  List<Map<String, dynamic>> municipios = [];

  // Opciones
  final List<String> _tiposDocumento = ['cedula', 'tarjeta_identidad', 'pasaporte', 'registro_civil'];
  final List<String> _gruposSanguineos = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _loadMunicipios();
  }

  Future<void> _loadMunicipios() async {
    setState(() => isLoadingMunicipios = true);
    try {
      // Usar el apiService directamente desde el provider
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/api/municipios');
      
      if (response.success && response.data != null) {
        final List<dynamic> municipiosList = response.data is List 
          ? response.data as List<dynamic>
          : [];
        
        setState(() {
          municipios = municipiosList
            .where((m) => m['activo'] == true)
            .map((m) => {
              'id': m['id'].toString(),
              'nombre': m['nombre'].toString(),
            })
            .toList();
          isLoadingMunicipios = false;
        });
      } else {
        setState(() => isLoadingMunicipios = false);
      }
    } catch (e) {
      print('Error cargando municipios: $e');
      setState(() => isLoadingMunicipios = false);
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    documentoController.dispose();
    telefonoController.dispose();
    direccionController.dispose();
    epsController.dispose();
    contactoEmergenciaNombreController.dispose();
    contactoEmergenciaTelefonoController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);

      // Registrar usuario usando el provider con todos los campos
      await authNotifier.register(
        nombreController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
        selectedRol,
        documento: documentoController.text.trim().isNotEmpty ? documentoController.text.trim() : null,
        tipoDocumento: selectedTipoDocumento,
        telefono: telefonoController.text.trim().isNotEmpty ? telefonoController.text.trim() : null,
        municipioId: selectedMunicipioId,
      );

      if (!mounted) return;

      // Registro exitoso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Cuenta creada exitosamente. Por favor inicia sesión.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Navegar al login
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        String errorMsg = e.toString();
        // Extraer mensaje de error más amigable
        if (errorMsg.contains('email ya está registrado')) {
          errorMessage = 'Este correo electrónico ya está registrado';
        } else if (errorMsg.contains('409')) {
          errorMessage = 'Este correo electrónico ya está registrado';
        } else {
          errorMessage = 'Error al crear la cuenta. Intenta nuevamente.';
        }
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaNacimiento ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => fechaNacimiento = picked);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.pink.shade100,
        foregroundColor: Colors.pink.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Icono
              const Icon(
                Icons.person_add,
                size: 60,
                color: Colors.pink,
              ),
              const SizedBox(height: 20),
              const Text(
                'Regístrate',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Crea tu cuenta para acceder al sistema',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 30),

              // Selector de rol (primero)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRol,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'madrina', child: Text('Madrina')),
                      DropdownMenuItem(value: 'gestante', child: Text('Gestante')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedRol = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Campos básicos
              // Tipo de documento
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedTipoDocumento,
                    isExpanded: true,
                    items: _tiposDocumento.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(_formatTipoDocumento(tipo)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedTipoDocumento = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: documentoController,
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

              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo *',
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

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo electrónico es obligatorio';
                  }
                  if (!value.contains('@')) {
                    return 'Ingresa un correo electrónico válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: telefonoController,
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

              // Municipio
              if (isLoadingMunicipios)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMunicipioId,
                      isExpanded: true,
                      hint: const Text('Seleccione un municipio'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Sin municipio'),
                        ),
                        ...municipios.map((municipio) {
                          return DropdownMenuItem<String>(
                            value: municipio['id'],
                            child: Text(municipio['nombre']),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => selectedMunicipioId = value);
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña *',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
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
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Contraseña *',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma tu contraseña';
                  }
                  if (value != passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campos adicionales según el rol
              if (selectedRol == 'gestante') ...[
                // Fecha de nacimiento
                ListTile(
                  title: const Text('Fecha de Nacimiento *'),
                  subtitle: Text(
                    fechaNacimiento != null
                        ? '${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}'
                        : 'No seleccionada',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
                const SizedBox(height: 16),

                // Grupo sanguíneo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGrupoSanguineo,
                      isExpanded: true,
                      hint: const Text('Grupo Sanguíneo'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('No especificado')),
                        ..._gruposSanguineos.map((grupo) {
                          return DropdownMenuItem(value: grupo, child: Text(grupo));
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => selectedGrupoSanguineo = value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // EPS
                TextFormField(
                  controller: epsController,
                  decoration: const InputDecoration(
                    labelText: 'EPS',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (selectedRol == 'madrina' || selectedRol == 'gestante') ...[
                // Dirección
                TextFormField(
                  controller: direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Contacto de emergencia
                const Text(
                  'Contacto de Emergencia',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: contactoEmergenciaNombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Contacto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: contactoEmergenciaTelefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono del Contacto',
                    border: OutlineInputBorder(),
                    prefixText: '+57 ',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 24),
              ],

              // Mensaje de error
              if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

              // Botón de registro
              CustomButton(
                text: isLoading ? 'Creando cuenta...' : 'Crear Cuenta',
                onPressed: isLoading ? null : _handleRegister,
              ),
              const SizedBox(height: 20),

              // Botón para volver al login
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  '¿Ya tienes cuenta? Inicia sesión',
                  style: TextStyle(
                    color: Colors.pink.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

