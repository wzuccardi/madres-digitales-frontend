import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    
    // Usar WidgetsBinding para asegurar que el widget estÃ© completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
    });
  }

  Future<void> _initializeAndNavigate() async {
    
    try {
      // Inicializar el servicio de autenticaciÃ³n
      final authService = AuthService();
      await authService.initialize();
      
      // Verificar si ya estÃ¡ autenticado
      if (authService.isAuthenticated) {
        if (mounted && context.mounted) {
          context.pushReplacement('/dashboard');
        }
      } else {
        // Reducir el tiempo de espera para testing
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted && context.mounted) {
          try {
            // Usar pushReplacement en lugar de go para asegurar la navegaciÃ³n
            context.pushReplacement('/login');
          } catch (e) {
            // Fallback: intentar con go
            try {
              context.go('/login');
            } catch (e2) {
            }
          }
        }
      }
    } catch (e) {
      // En caso de error, navegar al login despuÃ©s de un breve retraso
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
            // BotÃ³n de debug para navegaciÃ³n manual
            ElevatedButton(
              onPressed: () {
                try {
                  context.go('/login');
                } catch (e) {
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

