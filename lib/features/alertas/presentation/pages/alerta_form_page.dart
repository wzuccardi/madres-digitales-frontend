import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../providers/service_providers.dart';

class AlertaFormPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? alerta;
  const AlertaFormPage({this.alerta, super.key});
  @override
  ConsumerState<AlertaFormPage> createState() => _AlertaFormPageState();
}

class _AlertaFormPageState extends ConsumerState<AlertaFormPage> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.alerta != null) {
      tituloController.text = widget.alerta!['titulo'] ?? '';
      descripcionController.text = widget.alerta!['descripcion'] ?? '';
    }
  }

  Future<void> guardarAlerta() async {
    final data = {
      'titulo': tituloController.text,
      'descripcion': descripcionController.text,
    };
    final apiService = ref.read(apiServiceProvider);
    if (widget.alerta == null) {
      await apiService.post('/alertas', data: data);
    } else {
      await apiService.put('/alertas/${widget.alerta!['id']}', data: data);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.alerta == null ? 'Nueva Alerta' : 'Editar Alerta')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: guardarAlerta,
              child: Text(widget.alerta == null ? 'Crear' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
