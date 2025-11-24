import 'package:flutter/material.dart';

class DashboardMinimal extends StatelessWidget {
  const DashboardMinimal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text('Dashboard Minimal'),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              '¡Dashboard funcionando!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Si ves esto, el routing está funcionando correctamente.'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Test scroll
              },
              child: const Text('Test Button'),
            ),
          ],
        ),
      ),
    );
  }
}
