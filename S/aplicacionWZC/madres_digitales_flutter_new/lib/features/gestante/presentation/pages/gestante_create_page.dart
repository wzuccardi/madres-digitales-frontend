import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';
import 'package:madres_digitales_flutter_new/data/services/location_service.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';

class GestanteCreatePage extends ConsumerStatefulWidget {
  const GestanteCreatePage({super.key});
  @override
  ConsumerState<GestanteCreatePage> createState() => _GestanteCreatePageState();
}

class _GestanteCreatePageState extends ConsumerState<GestanteCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _documentoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _epsCtrl = TextEditingController();
  final _coordenadasCtrl = TextEditingController();
  final _medicoIdCtrl = TextEditingController();
  final _ipsIdCtrl = TextEditingController();
  final _contactoEmergenciaNombreCtrl = TextEditingController();
  final _contactoEmergenciaTelefonoCtrl = TextEditingController();
  final _barrioCtrl = TextEditingController();
  
  String _regimenSalud = 'subsidiado';
  String _tipoDocumento = 'CC';
  DateTime? _fechaNacimiento;
  DateTime? _fechaUltimaMenstruacion;
  DateTime? _fechaProbableParto;
  bool _riesgoAlto = false;
  
  // Coordenadas
  double? _latitud;
  double? _longitud;
  bool _isCapturingLocation = false;
  
  final List<String> _tiposDocumento = ['CC', 'TI', 'CE', 'PA', 'RC'];
  bool _isLoading = false;
  String? _error;
  String? _municipioId;
  bool _loadingMunicipios = true;
  List<Map<String, String>> _municipios = [];
  final List<String> _regimenesSalud = ['subsidiado', 'contributivo'];

  @override
  void initState() {
    super.initState();
    _loadMunicipios();
  }

  String _getTipoDocumentoLabel(String tipo) {
    switch (tipo) {
      case 'CC': return 'Cédula de Ciudadanía';
      case 'TI': return 'Tarjeta de Identidad';
      case 'CE': return 'Cédula de Extranjería';
      case 'PA': return 'Pasaporte';
      case 'RC': return 'Registro Civil';
      default: return tipo;
    }
  }

  Future<void> _selectFechaNacimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now().subtract(const Duration(days: 6570)), // 18 años por defecto
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _selectFechaUltimaMenstruacion() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaUltimaMenstruacion ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaUltimaMenstruacion) {
      setState(() {
        _fechaUltimaMenstruacion = picked;
        _calcularFechaProbableParto();
      });
    }
  }

  void _calcularFechaProbableParto() {
    if (_fechaUltimaMenstruacion != null) {
      // El cálculo se basa en la regla de Naegele: FPP = FUM + 280 días
      setState(() {
        _fechaProbableParto = _fechaUltimaMenstruacion!.add(const Duration(days: 280));
      });
    }
  }

  Future<void> _captureCoordinates() async {
    setState(() => _isCapturingLocation = true);
    try {
      final locationService = LocationService.instance;
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _latitud = position.latitude;
          _longitud = position.longitude;
          _coordenadasCtrl.text = '${position.latitude},${position.longitude}';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Coordenadas capturadas: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener la ubicación'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('GestanteCreatePage: Error capturando coordenadas', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturando ubicación: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturingLocation = false);
      }
    }
  }

  void _clearCoordinates() {
    setState(() {
      _latitud = null;
      _longitud = null;
      _coordenadasCtrl.clear();
    });
  }

  Future<void> _loadMunicipios() async {
    setState(() { _loadingMunicipios = true; });
    try {
      final ms = ref.read(municipioServiceProvider);
      final list = await ms.getMunicipios(activo: true, limit: 200);
      setState(() {
        _municipios = list.map((m) => {'id': m.id, 'nombre': m.nombre}).toList();
        _loadingMunicipios = false;
      });
    } catch (e) {
      setState(() { _loadingMunicipios = false; _error = e.toString(); });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    final repo = ref.read(gestanteRepositoryProvider);
    final now = DateTime.now();
    final gestante = Gestante(
      id: '',
      nombre: _nombreCtrl.text.trim(),
      apellido: _apellidoCtrl.text.trim(),
      documento: _documentoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      fechaNacimiento: _fechaNacimiento,
      eps: _epsCtrl.text.trim().isEmpty ? null : _epsCtrl.text.trim(),
      riesgoAlto: _riesgoAlto,
      fechaProbableParto: _fechaProbableParto,
      madrinaId: null,
      ipsId: _ipsIdCtrl.text.trim().isEmpty ? null : _ipsIdCtrl.text.trim(),
      medicoId: _medicoIdCtrl.text.trim().isEmpty ? null : _medicoIdCtrl.text.trim(),
      municipioId: _municipioId,
      regimen: _regimenSalud,
      tipoDocumento: _tipoDocumento,
      barrio: _barrioCtrl.text.trim().isEmpty ? null : _barrioCtrl.text.trim(),
      coordenadas: _coordenadasCtrl.text.trim().isEmpty ? null : _coordenadasCtrl.text.trim(),
      fechaUltimaMestruacion: _fechaUltimaMenstruacion,
      createdAt: now,
      updatedAt: now,
    );
    final res = await repo.createGestante(gestante);
    if (!mounted) return;
    
    setState(() { _isLoading = false; });
    
    if (res.isFailure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.errorOrThrow.message)),
        );
      }
      return;
    }
    
    // Verificar que el contexto sigue montado y que podemos hacer pop
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context, res.dataOrThrow);
    } else if (mounted) {
      // Si no podemos hacer pop, mostrar mensaje de éxito y navegar manualmente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Gestante creada exitosamente')),
      );
      // Navegar a la lista de gestantes
      context.go('/gestantes');
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _documentoCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _direccionCtrl.dispose();
    _epsCtrl.dispose();
    _coordenadasCtrl.dispose();
    _medicoIdCtrl.dispose();
    _ipsIdCtrl.dispose();
    _contactoEmergenciaNombreCtrl.dispose();
    _contactoEmergenciaTelefonoCtrl.dispose();
    _barrioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Gestante')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Información Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null),
                      const SizedBox(height: 12),
                      TextFormField(controller: _apellidoCtrl, decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder()), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _tipoDocumento,
                        decoration: const InputDecoration(labelText: 'Tipo de Documento', border: OutlineInputBorder()),
                        items: _tiposDocumento.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(_getTipoDocumentoLabel(tipo)),
                          );
                        }).toList(),
                        onChanged: (String? value) => setState(() => _tipoDocumento = value!),
                        validator: (v) => v == null ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(controller: _documentoCtrl, decoration: const InputDecoration(labelText: 'Documento', border: OutlineInputBorder()), validator: (v){
                        if (v==null||v.isEmpty) return 'Requerido';
                        final digits = RegExp(r'^\d{6,}$');
                        if (!digits.hasMatch(v.trim())) return 'Documento inválido';
                        return null;
                      }),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _selectFechaNacimiento,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Fecha de Nacimiento', border: OutlineInputBorder()),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_fechaNacimiento != null 
                                ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                                : 'Seleccionar fecha'),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
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
                      const Text('Contacto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(controller: _telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()), validator: (v){
                        if (v==null||v.isEmpty) return null;
                        final digits = RegExp(r'^\+?\d{7,}$');
                        if (!digits.hasMatch(v.trim())) return 'Teléfono inválido';
                        return null;
                      }),
                      const SizedBox(height: 12),
                      TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), validator: (v){
                        if (v==null||v.isEmpty) return null;
                        final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        if (!pattern.hasMatch(v.trim())) return 'Email inválido';
                        return null;
                      }),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _regimenSalud,
                        decoration: const InputDecoration(labelText: 'Régimen de Salud', border: OutlineInputBorder()),
                        items: _regimenesSalud.map((regimen) {
                          return DropdownMenuItem(
                            value: regimen,
                            child: Text(regimen == 'subsidiado' ? 'Subsidiado' : 'Contributivo'),
                          );
                        }).toList(),
                        onChanged: (String? value) => setState(() => _regimenSalud = value!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(controller: _direccionCtrl, decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder()), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null),
                      const SizedBox(height: 12),
                      TextFormField(controller: _barrioCtrl, decoration: const InputDecoration(labelText: 'Barrio', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      // Botón de captura de coordenadas
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isCapturingLocation ? null : _captureCoordinates,
                              icon: _isCapturingLocation
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.location_on),
                              label: Text(_latitud != null && _longitud != null
                                  ? 'Coordenadas: ${_latitud!.toStringAsFixed(4)}, ${_longitud!.toStringAsFixed(4)}'
                                  : 'Capturar Ubicación'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          if (_latitud != null && _longitud != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _clearCoordinates,
                              icon: const Icon(Icons.clear, color: Colors.red),
                              tooltip: 'Limpiar coordenadas',
                            ),
                          ],
                        ],
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
                      const Text('Ubicación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _loadingMunicipios
                          ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                          : DropdownButtonFormField<String?>(
                              value: _municipioId,
                              decoration: const InputDecoration(labelText: 'Municipio', border: OutlineInputBorder()),
                              items: [
                                const DropdownMenuItem<String?>(value: null, child: Text('Seleccionar municipio')),
                                ..._municipios.map((m) => DropdownMenuItem<String?>(value: m['id'], child: Text(m['nombre']!)))
                              ],
                              onChanged: (String? v) => setState(() => _municipioId = v),
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
                      const Text('Información Médica', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(controller: _epsCtrl, decoration: const InputDecoration(labelText: 'EPS', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _selectFechaUltimaMenstruacion,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Fecha Última Menstruación', border: OutlineInputBorder()),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_fechaUltimaMenstruacion != null 
                                ? '${_fechaUltimaMenstruacion!.day}/${_fechaUltimaMenstruacion!.month}/${_fechaUltimaMenstruacion!.year}'
                                : 'Seleccionar fecha'),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      if (_fechaProbableParto != null) ...[
                        const SizedBox(height: 12),
                        InputDecorator(
                          decoration: const InputDecoration(labelText: 'Fecha Probable de Parto', border: OutlineInputBorder()),
                          child: Text('${_fechaProbableParto!.day}/${_fechaProbableParto!.month}/${_fechaProbableParto!.year}'),
                        ),
                      ],
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: const Text('¿Gestante de alto riesgo?'),
                        value: _riesgoAlto,
                        onChanged: (bool? value) {
                          setState(() {
                            _riesgoAlto = value ?? false;
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
                      const Text('Asignación Médica', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(controller: _medicoIdCtrl, decoration: const InputDecoration(labelText: 'ID Médico Tratante', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextFormField(controller: _ipsIdCtrl, decoration: const InputDecoration(labelText: 'ID IPS Asignada', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextFormField(controller: _contactoEmergenciaNombreCtrl, decoration: const InputDecoration(labelText: 'Contacto de Emergencia - Nombre', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextFormField(controller: _contactoEmergenciaTelefonoCtrl, decoration: const InputDecoration(labelText: 'Contacto de Emergencia - Teléfono', border: OutlineInputBorder())),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _isLoading?null:_save, child: _isLoading?const CircularProgressIndicator():const Text('Crear')),
            ],
          ),
        ),
      ),
    );
  }
}