import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/application/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${usuario?.name ?? "Usuario"}'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refrescar datos si es necesario
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Actualizando...')),
              );
            },
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppConstants.loginRoute);
              }
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de bienvenida
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.pink,
                          radius: 30,
                          child: Text(
                            usuario?.name.substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usuario?.name ?? 'Usuario',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                usuario?.email ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (usuario?.role != null)
                                Chip(
                                  label: Text(
                                    usuario?.role.toUpperCase() ?? 'USER',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.pink.shade100,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Título de secciones
            const Text(
              'Menú Principal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid de opciones principales
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _MenuCard(
                  title: 'Gestantes',
                  icon: Icons.pregnant_woman,
                  color: Colors.purple,
                  onTap: () => context.go(AppConstants.gestantesRoute),
                ),
                _MenuCard(
                  title: 'Controles',
                  icon: Icons.medical_services,
                  color: Colors.green,
                  onTap: () => context.go(AppConstants.controlsRoute),
                ),
                _MenuCard(
                  title: 'Alertas',
                  icon: Icons.warning,
                  color: Colors.orange,
                  onTap: () => context.go(AppConstants.alertsRoute),
                ),
                _MenuCard(
                  title: 'Reportes',
                  icon: Icons.assessment,
                  color: Colors.blue,
                  onTap: () => context.go(AppConstants.reportsRoute),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Opciones adicionales
            const Text(
              'Configuración',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.person, color: Colors.pink),
              title: const Text('Mi Perfil'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(AppConstants.profileRoute),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.pink),
              title: const Text('Configuración'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(AppConstants.settingsRoute),
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.pink),
              title: const Text('Notificaciones'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(AppConstants.notificationsRoute),
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Colors.pink),
              title: const Text('Ayuda'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(AppConstants.helpRoute),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
