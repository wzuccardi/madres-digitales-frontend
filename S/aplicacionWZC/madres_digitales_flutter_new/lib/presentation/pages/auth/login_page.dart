import 'package:flutter/material.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/custom_text_field.dart';
import 'package:geolocator/geolocator.dart';
import 'package:madres_digitales_flutter_new/application/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

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
  }

  void _handleLogin() {
    AppLogger.info('Login tap');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Intentando autenticación...')));
    _loginAsync();
  }

  Future<void> _loginAsync() async {
    if (!mounted) return;
    setState(() { isLoading = true; errorMessage = null; });
    
    try {
      AppLogger.info('Login button pressed', context: {'email': emailController.text.trim()});
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.login(
        emailController.text.trim(),
        passwordController.text,
      );
      
      // Verificar si el login fue exitoso revisando el estado de autenticación
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        AppLogger.info('Login succeeded', context: {'email': emailController.text.trim()});
        // Enviar ubicación tras login exitoso (no bloquear navegación si falla)
        try {
          await enviarUbicacionAlBackend();
        } catch (e) {
          // No bloquear navegación si falla el envío de ubicación
        }

        if (!mounted) return;
        // Disparar sincronización de cola y datos tras login
        try {
          final sync = ref.read(syncServiceProvider);
          await sync.forceSync();
        } catch (_) {}

        setState(() { isLoading = false; });
        if (mounted) {
          context.go(AppConstants.dashboardRoute);
        }
      } else {
        AppLogger.error('Login failed state', context: {'email': emailController.text.trim()});
        throw Exception('Credenciales inválidas');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Credenciales inválidas o error de red.';
        isLoading = false;
      });
      AppLogger.error('Login exception', error: e, context: {'email': emailController.text.trim()});
    }
  }

  // Geolocalización: integración en Flutter
  // Envía la ubicación real del usuario al backend usando authProvider (con token automático)
  Future<void> enviarUbicacionAlBackend() async {
    try {
      // Solicita permisos de ubicación
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Permiso de ubicación denegado');
      }

      // Obtiene la ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Aquí se podría enviar la ubicación al backend usando el authProvider
      // Por ahora, solo registramos la ubicación en los logs
      AppLogger.info('Ubicación obtenida: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      // No bloquear el login si falla el envío de ubicación
    }
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
            CustomTextField(labelText: 'Correo electrónico', controller: emailController),
            const SizedBox(height: 16),
            CustomTextField(labelText: 'Contraseña', controller: passwordController, obscureText: true),
            const SizedBox(height: 24),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade400,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(isLoading ? 'Ingresando...' : 'Ingresar'),
            ),
            const SizedBox(height: 10),
            // Botón de login automático solo visible en modo debug
            if (kDebugMode)
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
