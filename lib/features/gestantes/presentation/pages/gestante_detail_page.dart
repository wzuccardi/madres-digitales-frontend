import 'package:flutter/material.dart';

class GestanteDetailPage extends StatelessWidget {
  final String gestanteId;
  const GestanteDetailPage({required this.gestanteId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle Gestante')),
      body: Center(child: Text('Detalle de gestante: $gestanteId')),
    );
  }
}
