import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/widgets/custom_text_field.dart';
import '../../../../../shared/widgets/custom_button.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../services/auth_service.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAuthService();
  }

  Future<void> _initializeAuthService() async {
    try {
      final authService = AuthService();
      await authService.initialize();
    } catch (e) {
    }
  }

  void _handleLogin() {
    _loginAsync();
  }

  Future<void> _loginAsync() async {
  if (!mounted) return;
  setState(() { isLoading = true; errorMessage = null; });
    try {
      final authService = AuthService();
      final ok = await authService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      if (!ok) {
        throw Exception('Credenciales invÃ¡lidas');
      }

      // Enviar ubicaciÃ³n tras login exitoso (no bloquear navegaciÃ³n si falla)
      try {
        await enviarUbicacionAlBackend();
      } catch (e) {
      }

      if (!mounted) return;
      setState(() { isLoading = false; });
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Credenciales invÃ¡lidas o error de red.';
        isLoading = false;
      });
    }
  }

  // GeolocalizaciÃ³n: integraciÃ³n en Flutter
  // EnvÃ­a la ubicaciÃ³n real del usuario al backend usando AuthService (con token automÃ¡tico)
  Future<void> enviarUbicacionAlBackend() async {
    // Solicita permisos de ubicaciÃ³n
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw Exception('Permiso de ubicaciÃ³n denegado');
    }

    // Obtiene la ubicaciÃ³n actual
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    // EnvÃ­a la ubicaciÃ³n al backend con autenticaciÃ³n centralizada
    await AuthService().authenticatedRequest(
      'PUT',
      '/auth/profile',
      body: {
        'latitud': position.latitude,
        'longitud': position.longitude,
      },
    );
  }

  void _handleAutoLogin() {
    emailController.text = 'wzuccardi@gmail.com';
    passwordController.text = '73102604722';
    _handleLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text('Iniciar sesiÃ³n'),
        backgroundColor: Colors.pink.shade100,
        foregroundColor: Colors.pink.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o icono
            const Icon(
              Icons.favorite,
              size: 60,
              color: Colors.pink,
            ),
            const SizedBox(height: 20),
            const Text(
              'Bienvenida de vuelta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 40),
            CustomTextField(label: 'Correo electrÃ³nico', controller: emailController),
            const SizedBox(height: 16),
            CustomTextField(label: 'ContraseÃ±a', controller: passwordController, obscureText: true),
            const SizedBox(height: 24),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            CustomButton(
              text: isLoading ? 'Ingresando...' : 'Ingresar',
              onPressed: isLoading ? null : _handleLogin,
            ),
            const SizedBox(height: 10),
            // BotÃ³n de login automÃ¡tico para desarrollo
            ElevatedButton(
              onPressed: isLoading ? null : _handleAutoLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                foregroundColor: Colors.green.shade800,
              ),
              child: const Text('Login AutomÃ¡tico (Admin)'),
            ),
            const SizedBox(height: 10),
            // BotÃ³n para ir al registro
            TextButton(
              onPressed: () {
                context.go('/register');
              },
              child: Text(
                'Â¿No tienes cuenta? RegÃ­strate',
                style: TextStyle(
                  color: Colors.pink.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

