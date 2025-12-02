import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';

class GestanteEditPage extends ConsumerStatefulWidget {
  const GestanteEditPage({super.key, required this.gestanteId});
  final String gestanteId;

  @override
  ConsumerState<GestanteEditPage> createState() => _GestanteEditPageState();
}

class _GestanteEditPageState extends ConsumerState<GestanteEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _documentoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isLoading = true;
  String? _error;
  Gestante? _gestante;
  String? _municipioId;
  bool _loadingMunicipios = true;
  List<Map<String, String>> _municipios = [];
  DateTime? _fechaUltimaMenstruacion;
  DateTime? _fechaProbableParto;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final repo = ref.read(gestanteRepositoryProvider);
    final ms = ref.read(municipioServiceProvider);
    final res = await repo.getGestanteById(widget.gestanteId);
    final munList = await ms.getMunicipios(activo: true, limit: 200);
    if (!mounted) return;
    if (res.isFailure) {
      setState(() {
        _error = res.errorOrThrow.message;
        _isLoading = false;
      });
      return;
    }
    _gestante = res.dataOrThrow;
    _nombreCtrl.text = _gestante!.nombre;
    _apellidoCtrl.text = _gestante!.apellido;
    _documentoCtrl.text = _gestante!.documento;
    _telefonoCtrl.text = _gestante!.telefono;
    _emailCtrl.text = _gestante!.email;
    _municipioId = _gestante!.municipioId;
    _fechaUltimaMenstruacion = _gestante!.fechaUltimaMestruacion;
    _fechaProbableParto = _gestante!.fechaProbableParto;
    _municipios = munList.map((m) => {'id': m.id, 'nombre': m.nombre}).toList();
    setState(() {
      _isLoading = false;
      _loadingMunicipios = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _gestante == null) return;
    setState(() { _isLoading = true; _error = null; });
    final repo = ref.read(gestanteRepositoryProvider);
    final updated = _gestante!.copyWith(
      nombre: _nombreCtrl.text.trim(),
      apellido: _apellidoCtrl.text.trim(),
      documento: _documentoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      municipioId: _municipioId,
      fechaUltimaMestruacion: _fechaUltimaMenstruacion,
      fechaProbableParto: _fechaProbableParto,
      updatedAt: DateTime.now(),
    );
    final res = await repo.updateGestante(updated);
    if (!mounted) return;
    setState(() { _isLoading = false; });
    if (res.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorOrThrow.message)));
      return;
    }
    Navigator.pop(context, res.dataOrThrow);
  }

  Future<void> _selectFUM() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaUltimaMenstruacion ?? DateTime.now().subtract(const Duration(days: 90)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: 'Seleccionar Fecha Última Menstruación',
    );
    if (picked != null) {
      setState(() {
        _fechaUltimaMenstruacion = picked;
        // Calcular FPP automáticamente (FUM + 280 días)
        _fechaProbableParto = picked.add(const Duration(days: 280));
      });
    }
  }

  String _calcularFPP() {
    if (_fechaUltimaMenstruacion == null) return 'No calculada';
    final fpp = _fechaUltimaMenstruacion!.add(const Duration(days: 280));
    return '${fpp.day}/${fpp.month}/${fpp.year}';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _documentoCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Gestante')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                          TextFormField(controller: _documentoCtrl, decoration: const InputDecoration(labelText: 'Documento', border: OutlineInputBorder()), validator: (v){
                            if (v==null||v.isEmpty) return 'Requerido';
                            final digits = RegExp(r'^\d{6,}$');
                            if (!digits.hasMatch(v.trim())) return 'Documento inválido';
                            return null;
                          }),
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
                          const Text('Datos Obstétricos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ListTile(
                            title: const Text('Fecha Última Menstruación (FUM)'),
                            subtitle: Text(
                              _fechaUltimaMenstruacion != null
                                  ? '${_fechaUltimaMenstruacion!.day}/${_fechaUltimaMenstruacion!.month}/${_fechaUltimaMenstruacion!.year}'
                                  : 'No registrada',
                              style: TextStyle(
                                color: _fechaUltimaMenstruacion == null ? Colors.red : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectFUM(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(color: Colors.grey[400]!),
                            ),
                          ),
                          if (_fechaUltimaMenstruacion != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.child_care, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Fecha Probable de Parto (FPP)', style: TextStyle(fontSize: 12)),
                                        Text(
                                          _calcularFPP(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                              : DropdownButtonFormField<String?> (
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
                  ElevatedButton(onPressed: _isLoading?null:_save, child: _isLoading?const CircularProgressIndicator():const Text('Guardar')),
                ],
              ),
            ),
      ),
    );
  }
}
