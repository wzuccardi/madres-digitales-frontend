import 'package:flutter/material.dart';

class SimpleMedicoForm extends StatefulWidget {
  const SimpleMedicoForm({super.key});

  @override
  State<SimpleMedicoForm> createState() => _SimpleMedicoFormState();
}

class _SimpleMedicoFormState extends State<SimpleMedicoForm> {
  final _nombreController = TextEditingController();
  
  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🏥 SimpleMedicoForm: Construyendo formulario ultra-simple');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Médico - Minimalista'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Formulario Minimalista',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Médico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('🏥 Guardando médico: ${_nombreController.text}');
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
            const SizedBox(height: 20),
            const Text('✅ Sin setState durante build'),
            const Text('✅ Sin widgets complejos'),
            const Text('✅ Sin providers'),
            const Text('✅ Sin riverpod'),
          ],
        ),
      ),
    );
  }
}