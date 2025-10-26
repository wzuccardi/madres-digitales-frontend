import 'package:flutter/material.dart';

class IPSCercanasScreen extends StatelessWidget {
  const IPSCercanasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPS Cercanas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Funcionalidad de IPS Cercanas en desarrollo',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}