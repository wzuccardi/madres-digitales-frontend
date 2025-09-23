import 'package:flutter/material.dart';

class ControlFormPage extends StatelessWidget {
  const ControlFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Control Prenatal')),
      body: Center(child: Text('Formulario de control prenatal aquí')),
    );
  }
}
