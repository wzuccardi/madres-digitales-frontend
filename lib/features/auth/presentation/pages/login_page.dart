import 'package:flutter/material.dart';
import '../../../../../shared/widgets/custom_text_field.dart';
import '../../../../../shared/widgets/custom_button.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
// import '../../data/repositories/auth_repository_impl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool isLoading = false;
  String? errorMessage;

  void _handleLogin() {
    _loginAsync();
  }

  Future<void> _loginAsync() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final response = await Dio(BaseOptions(baseUrl: 'http://localhost:3000/api')).post('/auth/login', data: {
        'email': emailController.text,
        'password': passwordController.text,
      });
      final token = response.data['token'];
      await secureStorage.write(key: 'jwt_token', value: token);
      setState(() { isLoading = false; });
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/gestantes');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Credenciales inválidas o error de red.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          ],
        ),
      ),
    );
  }
}
