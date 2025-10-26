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
    print('🚀 SplashPage: initState called');
    
    // Usar WidgetsBinding para asegurar que el widget esté completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
    });
  }

  Future<void> _initializeAndNavigate() async {
    print('⏰ SplashPage: Starting initialization and navigation');
    
    try {
      // Inicializar el servicio de autenticación
      print('🔐 SplashPage: Inicializando AuthService...');
      final authService = AuthService();
      await authService.initialize();
      print('✅ SplashPage: AuthService inicializado correctamente');
      
      // Verificar si ya está autenticado
      if (authService.isAuthenticated) {
        print('✅ SplashPage: Usuario ya autenticado, navegando al dashboard');
        if (mounted && context.mounted) {
          context.pushReplacement('/dashboard');
        }
      } else {
        print('🔄 SplashPage: Usuario no autenticado, navegando al login');
        // Reducir el tiempo de espera para testing
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted && context.mounted) {
          try {
            // Usar pushReplacement en lugar de go para asegurar la navegación
            context.pushReplacement('/login');
            print('✅ SplashPage: Navigation to /login successful');
          } catch (e) {
            print('❌ SplashPage: Navigation error: $e');
            // Fallback: intentar con go
            try {
              context.go('/login');
              print('✅ SplashPage: Fallback navigation successful');
            } catch (e2) {
              print('❌ SplashPage: Fallback navigation also failed: $e2');
            }
          }
        }
      }
    } catch (e) {
      print('❌ SplashPage: Error en inicialización: $e');
      // En caso de error, navegar al login después de un breve retraso
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted && context.mounted) {
        context.pushReplacement('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 SplashPage: build method called');
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
                print('🔘 Manual navigation button pressed');
                try {
                  context.go('/login');
                  print('✅ Manual navigation successful');
                } catch (e) {
                  print('❌ Manual navigation failed: $e');
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
