import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/core/providers/usecase_providers.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/get_gestantes_usecase.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';

class AlertaFormPage extends ConsumerStatefulWidget {
  const AlertaFormPage({this.alerta, super.key});
  final Map<String, dynamic>? alerta;
  @override
  ConsumerState<AlertaFormPage> createState() => _AlertaFormPageState();
}

class _AlertaFormPageState extends ConsumerState<AlertaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController mensajeController = TextEditingController();
  String? _gestanteSeleccionada;
  String? _tipoSeleccionado;
  String? _prioridadSeleccionada;
  bool _isLoadingGestantes = true;
  String? _error;
  List<Map<String, String>> _gestantes = [];
  static const tipos = [
    'EMERGENCIA',
    'SOS_MEDICA',
    'CONTROL_VENCIDO',
    'SINTOMAS_PREOCUPANTES',
    'RECORDATORIO_CONTROL',
    'SEGUIMIENTO',
    'hipertension_severa',
    'hipertension',
    'preeclampsia',
    'preeclampsia_severa',
    'hemorragia',
    'parto_prematuro',
    'sepsis',
    'ausencia_movimientos_fetales',
    'signos_vitales_anormales',
    'sintomas_criticos',
  ];
  static const prioridades = ['BAJA', 'MEDIA', 'ALTA', 'CRITICA'];

  @override
  void initState() {
    super.initState();
    _cargarGestantes();
    if (widget.alerta != null) {
      _gestanteSeleccionada = widget.alerta!['gestante_id']?.toString();
      _tipoSeleccionado = widget.alerta!['tipo_alerta']?.toString();
      _prioridadSeleccionada = widget.alerta!['nivel_prioridad']?.toString();
      mensajeController.text = widget.alerta!['mensaje'] ?? '';
    }
  }

  Future<void> _cargarGestantes() async {
    setState(() {
      _isLoadingGestantes = true;
      _error = null;
    });
    try {
      final authState = ref.read(authProvider);
      final madrinaId = authState.user?.id;
      final usecase = ref.read(getGestantesUseCaseProvider);
      final result = await usecase(GetGestantesParams(limit: 100, offset: 0, madrinaId: madrinaId));
      if (result.isFailure) {
        throw result.errorOrThrow;
      }
      final gestantes = result.dataOrThrow;
      setState(() {
        _gestantes = gestantes.map((g) => {'id': g.id, 'nombre': g.nombre}).toList();
        _isLoadingGestantes = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingGestantes = false;
      });
    }
  }

  Future<void> guardarAlerta() async {
    if (!_formKey.currentState!.validate()) return;
    final apiService = ref.read(apiServiceProvider);
    final payload = {
      'gestante_id': _gestanteSeleccionada,
      'tipo_alerta': _tipoSeleccionado,
      'nivel_prioridad': _prioridadSeleccionada,
      'mensaje': mensajeController.text.trim(),
    };
    if (widget.alerta == null) {
      await apiService.post('/alertas', data: payload);
    } else {
      await apiService.put('/alertas/${widget.alerta!['id']}', data: payload);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.alerta == null ? 'Nueva Alerta' : 'Editar Alerta')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isLoadingGestantes
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _gestanteSeleccionada,
                      items: _gestantes
                          .map((g) => DropdownMenuItem<String>(value: g['id'], child: Text(g['nombre']!)))
                          .toList(),
                      onChanged: (v) => setState(() => _gestanteSeleccionada = v),
                      decoration: const InputDecoration(labelText: 'Gestante'),
                      validator: (v) => v == null || v.isEmpty ? 'Seleccione una gestante' : null,
                    ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipoSeleccionado,
                items: tipos.map((t) => DropdownMenuItem<String>(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _tipoSeleccionado = v),
                decoration: const InputDecoration(labelText: 'Tipo de Alerta'),
                validator: (v) => v == null || v.isEmpty ? 'Seleccione el tipo de alerta' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _prioridadSeleccionada,
                items: prioridades.map((p) => DropdownMenuItem<String>(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _prioridadSeleccionada = v),
                decoration: const InputDecoration(labelText: 'Nivel de Prioridad'),
                validator: (v) => v == null || v.isEmpty ? 'Seleccione el nivel de prioridad' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: mensajeController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mensaje'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese un mensaje' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: guardarAlerta,
                  child: Text(widget.alerta == null ? 'Crear' : 'Guardar'),
                ),
              ),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }
}
