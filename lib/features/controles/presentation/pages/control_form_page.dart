import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../providers/service_providers.dart';

class ControlFormPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? control;
  const ControlFormPage({this.control, super.key});
  @override
  ConsumerState<ControlFormPage> createState() => _ControlFormPageState();
}

class _ControlFormPageState extends ConsumerState<ControlFormPage> {
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.control != null) {
      fechaController.text = widget.control!['fecha'] ?? '';
      descripcionController.text = widget.control!['descripcion'] ?? '';
    }
  }

  Future<void> guardarControl() async {
    final data = {
      'fecha': fechaController.text,
      'descripcion': descripcionController.text,
    };
    final apiService = ref.read(apiServiceProvider);
    if (widget.control == null) {
      await apiService.post('/controles', data: data);
    } else {
      await apiService.put('/controles/${widget.control!['id']}', data: data);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.control == null ? 'Nuevo Control Prenatal' : 'Editar Control Prenatal')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: fechaController,
              decoration: const InputDecoration(labelText: 'Fecha'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: guardarControl,
              child: Text(widget.control == null ? 'Crear' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
