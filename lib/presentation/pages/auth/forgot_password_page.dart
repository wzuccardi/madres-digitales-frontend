import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _loading = false;
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correo de reseteo enviado')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Olvidé mi contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loading ? null : _submit, child: const Text('Enviar')),
          ],
        ),
      ),
    );
  }
}
