import 'package:flutter/material.dart';

class GestantesListPage extends StatelessWidget {
  const GestantesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestantes')),
      body: Center(child: Text('Listado de gestantes aquí')),
    );
  }
}
