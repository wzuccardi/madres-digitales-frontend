import 'package:flutter/material.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('🔍 DebugScreen: ========== CONSTRUYENDO PANTALLA DEBUG ==========');
    print('🔍 DebugScreen: Fecha/Hora: ${DateTime.now()}');
    print('🔍 DebugScreen: Context disponible: ${context != null}');
    print('🔍 DebugScreen: Iniciando construcción de Scaffold...');
    
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: const Text('DEBUG - Pantalla de Prueba'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bug_report, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'PANTALLA DE DEBUG',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Si ves esta pantalla, la aplicación está funcionando',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text('✅ Flutter funciona'),
            Text('✅ GoRouter funciona'),
            Text('✅ MaterialApp funciona'),
            Text('✅ Scaffold funciona'),
          ],
        ),
      ),
    );
  }
}