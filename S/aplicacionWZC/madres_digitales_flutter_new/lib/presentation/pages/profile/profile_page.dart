import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  
  String _getRoleLabel(String? role) {
    switch (role?.toLowerCase()) {
      case 'super_admin':
        return 'Super Administrador';
      case 'admin':
        return 'Administrador';
      case 'coordinador':
        return 'Coordinador';
      case 'madrina':
        return 'Madrina';
      case 'medico':
        return 'Médico';
      case 'gestante':
        return 'Gestante';
      default:
        return role ?? 'Usuario';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final u = auth.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/perfil/editar'),
            tooltip: 'Editar perfil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  (u?.name ?? 'U').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Información del usuario
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información Personal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.person, 'Nombre', u?.name ?? 'No especificado'),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.email, 'Email', u?.email ?? 'No especificado'),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.badge, 'Rol', _getRoleLabel(u?.role)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botón de editar perfil
            ElevatedButton.icon(
              onPressed: () => context.push('/perfil/editar'),
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 8),

            // Botón de cerrar sesión
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cerrar Sesión'),
                    content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(authProvider.notifier).logout();
                          Navigator.pop(context);
                          context.go('/login');
                        },
                        child: const Text('Cerrar Sesión'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
