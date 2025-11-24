import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

class IPSFormScreen extends ConsumerStatefulWidget {
  const IPSFormScreen({super.key, this.ipsId});
  final String? ipsId;
  @override
  ConsumerState<IPSFormScreen> createState() => _IPSFormScreenState();
}

class _IPSFormScreenState extends ConsumerState<IPSFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _tipoCtrl = TextEditingController();
  final _nivelCtrl = TextEditingController(text: '1');
  bool _isLoading = false;
  String? _error;
  String? _municipioId;
  bool _isLoadingMunicipios = true;
  List<Map<String, String>> _municipios = [];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _nitCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _tipoCtrl.dispose();
    _nivelCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadMunicipios();
    if (widget.ipsId != null && widget.ipsId!.isNotEmpty) {
      _loadExisting(widget.ipsId!);
    }
  }

  Future<void> _loadExisting(String id) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final service = ref.read(ipsServiceProvider);
      final ips = await service.getIPSById(id);
      if (ips != null) {
        _nombreCtrl.text = ips.nombre;
        _nitCtrl.text = ips.nit;
        _direccionCtrl.text = ips.direccion;
        _telefonoCtrl.text = ips.telefono;
        _emailCtrl.text = ips.email;
        _municipioId = ips.municipioId;
        _tipoCtrl.text = ips.tipo;
        _nivelCtrl.text = ips.nivel.toString();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final service = ref.read(ipsServiceProvider);
      final payloadNivel = int.tryParse(_nivelCtrl.text.trim()) ?? 1;
      final isEdit = widget.ipsId != null && widget.ipsId!.isNotEmpty;
      final ips = isEdit
          ? await service.updateIPS(
              id: widget.ipsId!,
              nombre: _nombreCtrl.text.trim(),
              nit: _nitCtrl.text.trim(),
              direccion: _direccionCtrl.text.trim(),
              telefono: _telefonoCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              municipioId: _municipioId,
              tipo: _tipoCtrl.text.trim(),
              nivel: payloadNivel,
              servicios: const <String>[],
            )
          : await service.createIPS(
              nombre: _nombreCtrl.text.trim(),
              nit: _nitCtrl.text.trim(),
              direccion: _direccionCtrl.text.trim(),
              telefono: _telefonoCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              municipioId: _municipioId,
              tipo: _tipoCtrl.text.trim(),
              nivel: payloadNivel,
              servicios: const <String>[],
            );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context, ips);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text((widget.ipsId != null && widget.ipsId!.isNotEmpty) ? 'Editar IPS' : 'Nueva IPS')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
              TextFormField(controller: _nitCtrl, decoration: const InputDecoration(labelText: 'NIT'), validator: (v) {
                if (v==null||v.isEmpty) return 'Requerido';
                final digits = RegExp(r'^\d{5,}$');
                if (!digits.hasMatch(v.trim())) return 'NIT inválido';
                return null;
              }),
              TextFormField(controller: _direccionCtrl, decoration: const InputDecoration(labelText: 'Dirección')),
              TextFormField(controller: _telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono'), validator: (v){
                if (v==null||v.isEmpty) return null;
                final digits = RegExp(r'^\+?\d{7,}$');
                if (!digits.hasMatch(v.trim())) return 'Teléfono inválido';
                return null;
              }),
              TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email'), validator: (v) {
                if (v==null||v.isEmpty) return null;
                final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!pattern.hasMatch(v.trim())) return 'Email inválido';
                return null;
              }),
              const SizedBox(height: 12),
              _isLoadingMunicipios
                  ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                  : DropdownButtonFormField<String?>(
                      value: _municipioId,
                      decoration: const InputDecoration(labelText: 'Municipio', hintText: 'Seleccionar municipio', border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('Seleccionar municipio')),
                        ..._municipios.map((m) => DropdownMenuItem<String?>(value: m['id'], child: Text(m['nombre']!)))
                      ],
                      onChanged: (String? v) => setState(() => _municipioId = v),
                    ),
              const SizedBox(height: 12),
              TextFormField(controller: _tipoCtrl, decoration: const InputDecoration(labelText: 'Tipo')),
              TextFormField(controller: _nivelCtrl, decoration: const InputDecoration(labelText: 'Nivel')),
              const SizedBox(height: 16),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _isLoading?null:_submit, child: _isLoading?const CircularProgressIndicator():Text(widget.ipsId != null && widget.ipsId!.isNotEmpty ? 'Guardar' : 'Crear')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadMunicipios() async {
    setState(() { _isLoadingMunicipios = true; });
    try {
      final ms = ref.read(municipioServiceProvider);
      final list = await ms.getMunicipios(activo: true, limit: 200);
      setState(() {
        _municipios = list.map((m) => {'id': m.id, 'nombre': m.nombre}).toList();
        _isLoadingMunicipios = false;
      });
    } catch (e) {
      setState(() { _isLoadingMunicipios = false; _error = e.toString(); });
    }
  }
}
