import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, this.token});
  final String? token;
  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  bool _loading = false;
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
  Future<void> _submit() async {
    final token = widget.token ?? '';
    final newPassword = _passwordController.text.trim();
    if (token.isEmpty || newPassword.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).confirmResetPassword(token, newPassword);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actualizada')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restablecer contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Nueva contraseña'), obscureText: true),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loading ? null : _submit, child: const Text('Actualizar')),
          ],
        ),
      ),
    );
  }
}
