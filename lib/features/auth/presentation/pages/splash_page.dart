import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        // Usar GoRouter para navegación
        context.go('/login');
      }
    });
    return Scaffold(
      body: Center(child: Text('Bienvenida a Madres Digitales')),
    );
  }
}
