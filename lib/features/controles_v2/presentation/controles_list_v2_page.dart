import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import '../../controles_v2/data/control_api_v2.dart';
import '../../controles_v2/domain/control_dto.dart';
// Detail page is defined below in the same file
import 'package:madres_digitales_flutter_new/core/providers/usecase_providers.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/get_gestantes_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

class ControlesListV2Page extends ConsumerStatefulWidget {
  const ControlesListV2Page({super.key, this.gestanteId});
  final String? gestanteId;
  @override
  ConsumerState<ControlesListV2Page> createState() => _ControlesListV2PageState();
}

class _ControlesListV2PageState extends ConsumerState<ControlesListV2Page> {
  bool _loading = true;
  String? _error;
  List<ControlDto> _items = [];
  String? _filterGestanteId;

  @override
  void initState() {
    super.initState();
    _filterGestanteId = widget.gestanteId;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ControlApiV2(api: ref.read(apiServiceProvider));
      final items = await api.fetchControles();
      final filtered = (_filterGestanteId == null || _filterGestanteId!.isEmpty)
          ? items
          : items.where((c) => c.gestanteId == _filterGestanteId).toList();
      setState(() {
        _items = filtered;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_filterGestanteId == null ? 'Controles Prenatales V2' : 'Controles de Gestante $_filterGestanteId')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final c = _items[index];
                    return Card(
                      child: ListTile(
                        title: Text(c.fechaControl != null ? _formatDate(c.fechaControl!) : '-'),
                        subtitle: Text(c.observaciones ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () => _openDetail(c),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ControlFormV2Page(gestanteId: _filterGestanteId))),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _openDetail(ControlDto c) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ControlDetailV2Page(control: c)));
  }
}

class ControlFormV2Page extends ConsumerStatefulWidget {
  const ControlFormV2Page({super.key, this.gestanteId});
  final String? gestanteId;
  @override
  ConsumerState<ControlFormV2Page> createState() => _ControlFormV2PageState();
}

class _ControlFormV2PageState extends ConsumerState<ControlFormV2Page> {
  final _formKey = GlobalKey<FormState>();
  String? _gestanteId;
  DateTime _fecha = DateTime.now();
  final _pesoCtrl = TextEditingController();
  final _sisCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _fcCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _frCtrl = TextEditingController();
  final _alturaCtrl = TextEditingController();
  final _semanasCtrl = TextEditingController();
  final _recomendacionesCtrl = TextEditingController();
  bool _movimientosFetales = true;
  bool _edemas = false;
  final List<String> _sintomas = [];
  bool _evaluar = true;
  bool _loading = false;
  List<Map<String, String>> _gestantes = [];
  List<Map<String, String>> _medicos = [];
  String? _medicoId;
  DateTime? _proximoControl;
  String? _error;
  Gestante? _gestante;
  DateTime? _fum;
  static const sintomasDisponibles = [
    {'id': 'sangrado_vaginal', 'nombre': 'Sangrado vaginal'},
    {'id': 'dolor_abdominal_severo', 'nombre': 'Dolor abdominal severo'},
    {'id': 'cefalea_severa', 'nombre': 'Cefalea severa'},
    {'id': 'vision_borrosa', 'nombre': 'Visión borrosa'},
    {'id': 'dolor_epigastrico', 'nombre': 'Dolor epigástrico'},
    {'id': 'contracciones_regulares', 'nombre': 'Contracciones regulares'},
    {'id': 'ruptura_membranas', 'nombre': 'Ruptura de membranas'},
    {'id': 'ausencia_movimiento_fetal', 'nombre': 'Ausencia de movimientos fetales'},
  ];

  @override
  void initState() {
    super.initState();
    _gestanteId = widget.gestanteId;
    _loadGestantes();
    _loadMedicos();
    if (_gestanteId != null && _gestanteId!.isNotEmpty) {
      _loadGestanteDetails();
    }
  }

  Future<void> _loadGestantes() async {
    setState(() {
      _error = null;
    });
    try {
      final authState = ref.read(authProvider);
      final madrinaId = authState.user?.id;
      final usecase = ref.read(getGestantesUseCaseProvider);
      final result = await usecase(GetGestantesParams(limit: 100, offset: 0, madrinaId: madrinaId));
      if (result.isFailure) throw result.errorOrThrow;
      final gestantes = result.dataOrThrow;
      setState(() {
        _gestantes = gestantes.map((g) => {'id': g.id, 'nombre': g.nombre}).toList();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _loadMedicos() async {
    setState(() {
      _error = null;
    });
    try {
      final service = ref.read(medicoServiceProvider);
      final data = await service.getActiveMedicos();
      setState(() {
        _medicos = data.map((m) => {
          'id': (m is Map<String, dynamic> ? (m['id']?.toString() ?? '') : ''),
          'nombre': (m is Map<String, dynamic> ? (m['nombre']?.toString() ?? '') : '')
        }).where((e) => (e['id'] ?? '').isNotEmpty && (e['nombre'] ?? '').isNotEmpty).toList();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _loadGestanteDetails() async {
    if (_gestanteId == null || _gestanteId!.isEmpty) return;
    try {
      final service = ref.read(gestanteServiceProvider);
      final g = await service.obtenerGestantePorId(_gestanteId!);
      setState(() {
        _gestante = g;
        _fum = g.fechaUltimaMestruacion;
      });
      _recalculateWeeks();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  void _recalculateWeeks() {
    if (_fum != null) {
      final days = _fecha.difference(_fum!).inDays;
      final weeks = days < 0 ? 0 : (days ~/ 7);
      _semanasCtrl.text = weeks.toString();
    } else if (_gestante?.semanasGestacion != null) {
      _semanasCtrl.text = _gestante!.semanasGestacion!.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Control V2')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String?>(
                value: _gestanteId,
                items: _gestantes.map((g) => DropdownMenuItem(value: g['id'], child: Text(g['nombre']!))).toList(),
                onChanged: (v) {
                  setState(() => _gestanteId = v);
                  _loadGestanteDetails();
                },
                decoration: const InputDecoration(labelText: 'Gestante'),
                validator: (v) => v == null || v.isEmpty ? 'Seleccione una gestante' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Fecha del Control'),
                subtitle: Text(_formatDate(_fecha)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _semanasCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Semanas de gestación'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pesoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(controller: _sisCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sistólica'))),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _diaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Diastólica'))),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                controller: _obsCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Observaciones'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _recomendacionesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Recomendaciones'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fcCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Frecuencia Cardíaca (lpm)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tempCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Temperatura (°C)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _frCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Frecuencia Respiratoria (rpm)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _alturaCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Altura Uterina (cm)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                value: _medicoId,
                items: _medicos.map((m) => DropdownMenuItem(value: m['id'], child: Text(m['nombre']!))).toList(),
                onChanged: (v) => setState(() => _medicoId = v),
                decoration: const InputDecoration(labelText: 'Médico'),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Próximo control'),
                subtitle: Text(_proximoControl != null ? _formatDate(_proximoControl!) : '-'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickProximo,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _movimientosFetales,
                onChanged: (v) => setState(() => _movimientosFetales = v),
                title: const Text('Movimientos Fetales'),
                subtitle: Text(_movimientosFetales ? 'Presentes' : 'Ausentes'),
              ),
              SwitchListTile(
                value: _edemas,
                onChanged: (v) => setState(() => _edemas = v),
                title: const Text('Edemas'),
                subtitle: Text(_edemas ? 'Presentes' : 'Ausentes'),
              ),
              const SizedBox(height: 8),
              const Text('Síntomas de alarma'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: sintomasDisponibles.map((s) {
                  final selected = _sintomas.contains(s['id']);
                  return FilterChip(
                    label: Text(s['nombre']!),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _sintomas.add(s['id']!);
                        } else {
                          _sintomas.remove(s['id']!);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _evaluar,
                onChanged: (v) => setState(() => _evaluar = v),
                title: const Text('Evaluar alertas automáticamente'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _loading ? null : _submit, child: const Text('Guardar')),
              ),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _fecha, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now());
    if (picked != null) {
      setState(() => _fecha = picked);
      _recalculateWeeks();
    }
  }

  Future<void> _pickProximo() async {
    final picked = await showDatePicker(context: context, initialDate: _proximoControl ?? DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) setState(() => _proximoControl = picked);
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    setState(() => _loading = true);
    try {
      final api = ControlApiV2(api: ref.read(apiServiceProvider));
      final payload = {
        'id': const Uuid().v4(),
        'gestante_id': _gestanteId,
        'fecha_control': _fecha.toIso8601String(),
        'semanas_gestacion': int.tryParse(_semanasCtrl.text),
        'peso': double.tryParse(_pesoCtrl.text),
        'presion_sistolica': int.tryParse(_sisCtrl.text),
        'presion_diastolica': int.tryParse(_diaCtrl.text),
        'observaciones': _obsCtrl.text.trim(),
        'recomendaciones': _recomendacionesCtrl.text.trim(),
        'frecuencia_cardiaca': int.tryParse(_fcCtrl.text),
        'temperatura': double.tryParse(_tempCtrl.text),
        'frecuencia_respiratoria': int.tryParse(_frCtrl.text),
        'altura_uterina': double.tryParse(_alturaCtrl.text),
        'medico_id': _medicoId,
        'movimientos_fetales': _movimientosFetales ? 'presentes' : 'ausentes',
        'edemas': _edemas ? 'presentes' : 'ausentes',
        'sintomas': _sintomas,
        if (_proximoControl != null) 'proximo_control': _proximoControl!.toIso8601String(),
      };
      final ok = await api.createControl(payload, evaluar: _evaluar);
      if (!ok) throw Exception('No se pudo guardar');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class ControlDetailV2Page extends StatelessWidget {
  const ControlDetailV2Page({super.key, required this.control});
  final ControlDto control;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Control')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ID: ${control.id}'),
          Text('Gestante: ${control.gestanteNombre ?? control.gestanteId ?? '-'}'),
          Text('Fecha: ${control.fechaControl != null ? '${control.fechaControl!.day}/${control.fechaControl!.month}/${control.fechaControl!.year}' : '-'}'),
          if (control.semanasGestacion != null) Text('Semanas: ${control.semanasGestacion}'),
          if (control.peso != null) Text('Peso: ${control.peso} kg'),
          if (control.presionSistolica != null && control.presionDiastolica != null) Text('Presión: ${control.presionSistolica}/${control.presionDiastolica} mmHg'),
          if (control.frecuenciaCardiaca != null) Text('FC: ${control.frecuenciaCardiaca} lpm'),
          if (control.temperatura != null) Text('Temp: ${control.temperatura} °C'),
          if (control.observaciones != null && control.observaciones!.isNotEmpty) Text('Obs: ${control.observaciones}'),
          if (control.recomendaciones != null && control.recomendaciones!.isNotEmpty) Text('Rec: ${control.recomendaciones}'),
          if (control.proximoControl != null) Text('Próximo: ${control.proximoControl!.day}/${control.proximoControl!.month}/${control.proximoControl!.year}'),
        ]),
      ),
    );
  }
}
