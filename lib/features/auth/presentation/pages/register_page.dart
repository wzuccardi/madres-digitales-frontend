import 'package:flutter/material.dart';
import '../../../../../shared/widgets/custom_text_field.dart';
import '../../../../../shared/widgets/custom_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(label: 'Nombre', controller: nombreController),
            const SizedBox(height: 16),
            CustomTextField(label: 'Correo electrónico', controller: emailController),
            const SizedBox(height: 16),
            CustomTextField(label: 'Contraseña', controller: passwordController, obscureText: true),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Registrarse',
              onPressed: () {
                // Lógica de registro aquí
              },
            ),
          ],
        ),
      ),
    );
  }
}
