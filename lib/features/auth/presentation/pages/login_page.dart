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
    print('🔐 LoginPage: initState called - LoginPage loaded successfully');
    _initializeAuthService();
  }

  Future<void> _initializeAuthService() async {
    try {
      print('🔐 LoginPage: Inicializando AuthService...');
      final authService = AuthService();
      await authService.initialize();
      print('✅ LoginPage: AuthService inicializado correctamente');
    } catch (e) {
      print('❌ LoginPage: Error inicializando AuthService: $e');
    }
  }

  void _handleLogin() {
    print('🔐 LoginPage: Login button pressed');
    _loginAsync();
  }

  Future<void> _loginAsync() async {
    print('🔐 LoginPage: Starting login process');
  if (!mounted) return;
  setState(() { isLoading = true; errorMessage = null; });
    try {
      print('🔐 LoginPage: Sending login request to backend via AuthService');
      final authService = AuthService();
      final ok = await authService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      if (!ok) {
        throw Exception('Credenciales inválidas');
      }

      // Enviar ubicación tras login exitoso (no bloquear navegación si falla)
      try {
        await enviarUbicacionAlBackend();
      } catch (e) {
        print('⚠️ LoginPage: No se pudo enviar la ubicación: $e');
      }

      print('🔐 LoginPage: Login successful, navigating to dashboard');
      if (!mounted) return;
      setState(() { isLoading = false; });
      if (mounted) {
        context.go('/dashboard');
        print('✅ LoginPage: Navigation to /dashboard successful');
      }
    } catch (e) {
      print('❌ LoginPage: Login failed: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = 'Credenciales inválidas o error de red.';
        isLoading = false;
      });
    }
  }

  // Geolocalización: integración en Flutter
  // Envía la ubicación real del usuario al backend usando AuthService (con token automático)
  Future<void> enviarUbicacionAlBackend() async {
    // Solicita permisos de ubicación
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw Exception('Permiso de ubicación denegado');
    }

    // Obtiene la ubicación actual
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    // Envía la ubicación al backend con autenticación centralizada
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
    print('🔐 LoginPage: Auto login button pressed');
    emailController.text = 'wzuccardi@gmail.com';
    passwordController.text = '73102604722';
    _handleLogin();
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 LoginPage: build method called');
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
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
            CustomTextField(label: 'Correo electrónico', controller: emailController),
            const SizedBox(height: 16),
            CustomTextField(label: 'Contraseña', controller: passwordController, obscureText: true),
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
            // Botón de login automático para desarrollo
            ElevatedButton(
              onPressed: isLoading ? null : _handleAutoLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                foregroundColor: Colors.green.shade800,
              ),
              child: const Text('Login Automático (Admin)'),
            ),
            const SizedBox(height: 10),
            // Botón para ir al registro
            TextButton(
              onPressed: () {
                print('🔐 LoginPage: Navigate to register button pressed');
                context.go('/register');
              },
              child: Text(
                '¿No tienes cuenta? Regístrate',
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
