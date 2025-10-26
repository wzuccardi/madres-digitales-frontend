import 'package:flutter/material.dart';

class SesionStatusWidget extends StatelessWidget {
  final String? userName;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onLogout;

  const SesionStatusWidget({
    super.key,
    this.userName,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 8),
              Text('Verificando sesión...'),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error de autenticación: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              if (onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Reintentar'),
                ),
            ],
          ),
        ),
      );
    }

    return _buildUserStatus();
  }

  Widget _buildUserStatus() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sesión activa: ${userName ?? 'Usuario'}',
                style: const TextStyle(color: Colors.green),
              ),
            ),
            if (onLogout != null)
              TextButton(
                onPressed: onLogout,
                child: const Text('Cerrar sesión'),
              ),
          ],
        ),
      ),
    );
  }
}