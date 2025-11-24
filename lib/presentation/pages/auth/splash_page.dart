import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/application/providers/auth_provider.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    
    // Usar WidgetsBinding para asegurar que el widget esté completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
    });
  }

  Future<void> _initializeAndNavigate() async {
    
    try {
      // Esperar un momento para que el provider se inicialice
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Verificar si ya está autenticado usando el provider
      final authState = ref.read(authProvider);
      
      if (authState.isAuthenticated) {
        if (mounted && context.mounted) {
          context.pushReplacement('/dashboard');
        }
      } else {
        // Reducir el tiempo de espera para testing
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted && context.mounted) {
          try {
            // Usar pushReplacement en lugar de go para asegurar la navegación
            context.pushReplacement('/login');
          } catch (e) {
            AppLogger.error('SplashPage: pushReplacement failed', error: e);
            try {
              context.go('/login');
            } catch (e2) {
              AppLogger.error('SplashPage: go navigation failed', error: e2);
            }
          }
        }
      }
    } catch (e) {
      // En caso de error, navegar al login después de un breve retraso
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted && context.mounted) {
        context.pushReplacement('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite,
              size: 80,
              color: Colors.pink,
            ),
            const SizedBox(height: 20),
            const Text(
              'Bienvenida a Madres Digitales',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.pink,
            ),
            const SizedBox(height: 20),
            const Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 40),
            // Botón de debug para navegación manual
            ElevatedButton(
              onPressed: () {
            try {
                  context.go('/login');
                } catch (e) {
                  AppLogger.error('SplashPage: manual navigation failed', error: e);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade100,
                foregroundColor: Colors.pink.shade800,
              ),
              child: const Text('Ir al Login (Debug)'),
            ),
          ],
        ),
      ),
    );
  }
}

