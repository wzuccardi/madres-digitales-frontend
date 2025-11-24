import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

class AssignMadrinasToCoordinatorPage extends ConsumerStatefulWidget {
  const AssignMadrinasToCoordinatorPage({super.key});
  @override
  ConsumerState<AssignMadrinasToCoordinatorPage> createState() => _AssignMadrinasToCoordinatorPageState();
}

class _AssignMadrinasToCoordinatorPageState extends ConsumerState<AssignMadrinasToCoordinatorPage> {
  String? _coordinadorSeleccionado;
  final Set<String> _madrinasSeleccionadas = {};
  bool _loading = true;
  String? _error;
  List<Map<String, String>> _coordinadores = [];
  List<Map<String, String>> _madrinas = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiServiceProvider);
      final coordResp = await api.get<dynamic>('/usuarios', queryParameters: {'rol': 'coordinador'});
      final madrResp = await api.get<dynamic>('/usuarios', queryParameters: {'rol': 'madrina'});
      final coords = api.extractData(coordResp.data);
      final mads = api.extractData(madrResp.data);
      final coordList = <Map<String, String>>[];
      final madrList = <Map<String, String>>[];
      if (coords is List) {
        for (final u in coords) {
          final m = u as Map<String, dynamic>;
          coordList.add({'id': (m['id'] ?? '').toString(), 'nombre': (m['nombre'] ?? m['email'] ?? '').toString()});
        }
      }
      if (mads is List) {
        for (final u in mads) {
          final m = u as Map<String, dynamic>;
          madrList.add({'id': (m['id'] ?? '').toString(), 'nombre': (m['nombre'] ?? m['email'] ?? '').toString()});
        }
      }
      setState(() {
        _coordinadores = coordList;
        _madrinas = madrList;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _guardarAsignaciones() async {
    if (_coordinadorSeleccionado == null || _madrinasSeleccionadas.isEmpty) return;
    final api = ref.read(apiServiceProvider);
    for (final mid in _madrinasSeleccionadas) {
      await api.post('/asignaciones/madrinas', data: {
        'coordinador_id': _coordinadorSeleccionado,
        'madrina_id': mid,
      });
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asignaciones guardadas')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Madrinas a Coordinador')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _coordinadorSeleccionado,
                    items: _coordinadores
                        .map((c) => DropdownMenuItem<String>(value: c['id'], child: Text(c['nombre']!)))
                        .toList(),
                    onChanged: (v) => setState(() => _coordinadorSeleccionado = v),
                    decoration: const InputDecoration(labelText: 'Coordinador'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _madrinas.length,
                      itemBuilder: (context, index) {
                        final m = _madrinas[index];
                        final selected = _madrinasSeleccionadas.contains(m['id']);
                        return CheckboxListTile(
                          title: Text(m['nombre']!),
                          value: selected,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _madrinasSeleccionadas.add(m['id']!);
                              } else {
                                _madrinasSeleccionadas.remove(m['id']!);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _guardarAsignaciones, child: const Text('Guardar Asignaciones')),
                  ),
                  if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
                ],
              ),
            ),
    );
  }
}
