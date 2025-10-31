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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo MÃ©dico - Minimalista'),
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
                labelText: 'Nombre del MÃ©dico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
            const SizedBox(height: 20),
            const Text('âœ… Sin setState durante build'),
            const Text('âœ… Sin widgets complejos'),
            const Text('âœ… Sin providers'),
            const Text('âœ… Sin riverpod'),
          ],
        ),
      ),
    );
  }
}
