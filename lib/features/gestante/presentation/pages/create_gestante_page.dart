import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/gestante.dart';
import '../providers/gestante_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class CreateGestantePage extends ConsumerStatefulWidget {
  const CreateGestantePage({super.key});

  @override
  ConsumerState<CreateGestantePage> createState() => _CreateGestantePageState();
}

class _CreateGestantePageState extends ConsumerState<CreateGestantePage> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _tipoDocumentoController = TextEditingController();
  final _numeroDocumentoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _barrioController = TextEditingController();
  final _contactoEmergenciaNombreController = TextEditingController();
  final _contactoEmergenciaTelefonoController = TextEditingController();
  
  DateTime? _fechaNacimiento;
  DateTime? _fechaUltimaMestruacion;
  DateTime? _fechaProbableParto;
  String _tipoDocumento = 'CC';
  String _grupoSanguineo = 'O+';
  String _eps = 'No afiliada';
  String _regimen = 'Subsidiado';
  bool _esAltoRiesgo = false;
  final List<String> _factoresRiesgo = [];
  String? _fotoUrl;
  
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _tipoDocumentoController.dispose();
    _numeroDocumentoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _barrioController.dispose();
    _contactoEmergenciaNombreController.dispose();
    _contactoEmergenciaTelefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Gestante'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información básica
                    _buildSectionTitle('Información Básica'),
                    _buildInformacionBasica(),
                    
                    const SizedBox(height: 24),
                    
                    // Información de contacto
                    _buildSectionTitle('Información de Contacto'),
                    _buildInformacionContacto(),
                    
                    const SizedBox(height: 24),
                    
                    // Información médica
                    _buildSectionTitle('Información Médica'),
                    _buildInformacionMedica(),
                    
                    const SizedBox(height: 24),
                    
                    // Información de emergencia
                    _buildSectionTitle('Contacto de Emergencia'),
                    _buildInformacionEmergencia(),
                    
                    const SizedBox(height: 24),
                    
                    // Foto
                    _buildSectionTitle('Foto'),
                    _buildFotoSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Mensaje de error
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Guardar Gestante',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.pink,
        ),
      ),
    );
  }

  Widget _buildInformacionBasica() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nombresController,
                  decoration: const InputDecoration(
                    labelText: 'Nombres *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Los nombres son obligatorios';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _apellidosController,
                  decoration: const InputDecoration(
                    labelText: 'Apellidos *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Los apellidos son obligatorios';
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
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _tipoDocumento,
                  decoration: const InputDecoration(
                    labelText: 'Tipo Doc. *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CC', child: Text('Cédula')),
                    DropdownMenuItem(value: 'TI', child: Text('Tarjeta Identidad')),
                    DropdownMenuItem(value: 'RC', child: Text('Registro Civil')),
                    DropdownMenuItem(value: 'CE', child: Text('Cédula Extranjería')),
                  ],
                  onChanged: (value) => setState(() => _tipoDocumento = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _numeroDocumentoController,
                  decoration: const InputDecoration(
                    labelText: 'Número Doc. *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El número de documento es obligatorio';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _telefonoController,
            decoration: const InputDecoration(
              labelText: 'Teléfono *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El teléfono es obligatorio';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email (opcional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          
          const SizedBox(height: 16),
          
          ListTile(
            title: const Text('Fecha de Nacimiento *'),
            subtitle: Text(
              _fechaNacimiento != null 
                  ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                  : 'Seleccionar fecha',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectFechaNacimiento,
          ),
        ],
      ),
    );
  }

  Widget _buildInformacionContacto() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _direccionController,
            decoration: const InputDecoration(
              labelText: 'Dirección *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.home),
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La dirección es obligatoria';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _barrioController,
            decoration: const InputDecoration(
              labelText: 'Barrio/Vereda',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
          
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            initialValue: _eps,
            decoration: const InputDecoration(
              labelText: 'EPS',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'No afiliada', child: Text('No afiliada')),
              DropdownMenuItem(value: 'SURA', child: Text('SURA')),
              DropdownMenuItem(value: 'Nueva EPS', child: Text('Nueva EPS')),
              DropdownMenuItem(value: 'Coomeva', child: Text('Coomeva')),
              DropdownMenuItem(value: 'Famisanar', child: Text('Famisanar')),
              DropdownMenuItem(value: 'Sanitas', child: Text('Sanitas')),
            ],
            onChanged: (value) => setState(() => _eps = value!),
          ),
          
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            initialValue: _regimen,
            decoration: const InputDecoration(
              labelText: 'Régimen',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Subsidiado', child: Text('Subsidiado')),
              DropdownMenuItem(value: 'Contributivo', child: Text('Contributivo')),
              DropdownMenuItem(value: 'Especial', child: Text('Especial')),
              DropdownMenuItem(value: 'No afiliado', child: Text('No afiliado')),
            ],
            onChanged: (value) => setState(() => _regimen = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildInformacionMedica() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text('Fecha Última Menstruación'),
            subtitle: Text(
              _fechaUltimaMestruacion != null 
                  ? '${_fechaUltimaMestruacion!.day}/${_fechaUltimaMestruacion!.month}/${_fechaUltimaMestruacion!.year}'
                  : 'Seleccionar fecha',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectFechaUltimaMestruacion,
          ),
          
          const Divider(),
          
          ListTile(
            title: const Text('Fecha Probable de Parto'),
            subtitle: Text(
              _fechaProbableParto != null 
                  ? '${_fechaProbableParto!.day}/${_fechaProbableParto!.month}/${_fechaProbableParto!.year}'
                  : 'Se calculará automáticamente',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_fechaProbableParto != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _fechaProbableParto = null),
                  ),
                const Icon(Icons.calendar_today),
              ],
            ),
            onTap: _selectFechaProbableParto,
          ),
          
          const Divider(),
          
          DropdownButtonFormField<String>(
            initialValue: _grupoSanguineo,
            decoration: const InputDecoration(
              labelText: 'Grupo Sanguíneo',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'O+', child: Text('O+')),
              DropdownMenuItem(value: 'O-', child: Text('O-')),
              DropdownMenuItem(value: 'A+', child: Text('A+')),
              DropdownMenuItem(value: 'A-', child: Text('A-')),
              DropdownMenuItem(value: 'B+', child: Text('B+')),
              DropdownMenuItem(value: 'B-', child: Text('B-')),
              DropdownMenuItem(value: 'AB+', child: Text('AB+')),
              DropdownMenuItem(value: 'AB-', child: Text('AB-')),
            ],
            onChanged: (value) => setState(() => _grupoSanguineo = value!),
          ),
          
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Gestante de Alto Riesgo'),
            subtitle: const Text('Marcar como gestante de alto riesgo'),
            value: _esAltoRiesgo,
            onChanged: (value) => setState(() => _esAltoRiesgo = value),
          ),
          
          if (_esAltoRiesgo) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Factores de Riesgo:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFactorRiesgoChip('Hipertensión'),
                      _buildFactorRiesgoChip('Diabetes'),
                      _buildFactorRiesgoChip('Edad avanzada'),
                      _buildFactorRiesgoChip('Embarazo múltiple'),
                      _buildFactorRiesgoChip('Antecedentes quirúrgicos'),
                      _buildFactorRiesgoChip('Enfermedades crónicas'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFactorRiesgoChip(String factor) {
    final isSelected = _factoresRiesgo.contains(factor);
    
    return FilterChip(
      label: Text(factor),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _factoresRiesgo.add(factor);
          } else {
            _factoresRiesgo.remove(factor);
          }
        });
      },
      backgroundColor: isSelected ? Colors.red : Colors.grey[300],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontSize: 12,
      ),
    );
  }

  Widget _buildInformacionEmergencia() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _contactoEmergenciaNombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre Contacto Emergencia',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.contact_phone),
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _contactoEmergenciaTelefonoController,
            decoration: const InputDecoration(
              labelText: 'Teléfono Emergencia',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildFotoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (_fotoUrl != null)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _fotoUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 64, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _selectFoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cambiar Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 64, color: Color(0xFF9E9E9E)),
                      SizedBox(height: 8),
                      Text(
                        'Agregar Foto',
                        style: TextStyle(color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _selectFoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tomar Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _selectFechaNacimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 50)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _selectFechaUltimaMestruacion() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _fechaUltimaMestruacion = picked;
        // Calcular automáticamente la fecha probable de parto
        _fechaProbableParto = picked.add(const Duration(days: 280));
      });
    }
  }

  Future<void> _selectFechaProbableParto() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaProbableParto ?? DateTime.now().add(const Duration(days: 200)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 300)),
    );
    
    if (picked != null) {
      setState(() {
        _fechaProbableParto = picked;
      });
    }
  }

  Future<void> _selectFoto() async {
    // Aquí iría la lógica para seleccionar foto
    // Por ahora, solo simulamos
    setState(() {
      _fotoUrl = 'https://via.placeholder.com/150';
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final authState = ref.read(authProvider);
      
      if (!authState.isAuthenticated || authState.usuario?.id == null) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'No tienes permisos para crear gestantes';
        });
        return;
      }

      // Crear objeto Gestante
      final gestante = Gestante(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporal
        nombres: _nombresController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        tipoDocumento: _tipoDocumento,
        numeroDocumento: _numeroDocumentoController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
        fechaNacimiento: _fechaNacimiento!,
        fechaUltimaMestruacion: _fechaUltimaMestruacion,
        fechaProbableParto: _fechaProbableParto,
        esAltoRiesgo: _esAltoRiesgo,
        factoresRiesgo: _factoresRiesgo,
        grupoSanguineo: _grupoSanguineo,
        contactoEmergenciaNombre: _contactoEmergenciaNombreController.text.trim(),
        contactoEmergenciaTelefono: _contactoEmergenciaTelefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
        barrio: _barrioController.text.trim().isEmpty ? null : _barrioController.text.trim(),
        eps: _eps,
        regimen: _regimen,
        activa: true,
        fechaCreacion: DateTime.now(),
        creadaPor: authState.usuario!.id,
        madrinasAsignadas: [authState.usuario!.id], // El usuario que crea es asignado automáticamente
        fotoUrl: _fotoUrl,
      );

      // Crear gestante a través del provider
      final success = await ref.read(gestanteProvider.notifier).createGestante(
        gestante: gestante,
        madrinaId: authState.usuario!.id,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gestante creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Error al crear la gestante';
        });
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Error: $e';
      });
    }
  }
}