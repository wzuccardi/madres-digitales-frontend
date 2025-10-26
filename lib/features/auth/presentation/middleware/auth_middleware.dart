import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../gestante/presentation/providers/madrina_session_provider.dart';

class AuthMiddleware {
  static Route<dynamic> guardRoute({
    required RouteSettings settings,
    required Widget Function(BuildContext, Object?) builder,
    String? requiredRole,
    String? requiredPermission,
    String? gestanteId,
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final authState = ref.watch(authProvider);
            
            // Verificar si el usuario está autenticado
            if (!authState.isAuthenticated) {
              return const UnauthorizedPage();
            }
            
            // Verificar si el usuario tiene el rol requerido
            if (requiredRole != null && authState.usuario?.rol != requiredRole) {
              return const AccessDeniedPage();
            }
            
            // Verificar si el usuario tiene el permiso requerido
            if (requiredPermission != null) {
              final tienePermiso = ref.read(madrinaSessionProvider.notifier)
                  .tienePermisoGeneral(requiredPermission);
              
              if (!tienePermiso) {
                return const AccessDeniedPage();
              }
            }
            
            // Verificar si el usuario tiene permiso sobre una gestante específica
            if (gestanteId != null && requiredPermission != null) {
              final tienePermisoGestanteFuture = ref.read(madrinaSessionProvider.notifier)
                  .tienePermiso(gestanteId, requiredPermission);
              
              // Usar FutureBuilder para manejar el Future<bool>
              return FutureBuilder<bool>(
                future: tienePermisoGestanteFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final tienePermisoGestante = snapshot.data ?? false;
                  
                  if (!tienePermisoGestante) {
                    return const AccessDeniedPage();
                  }
                  
                  // Si todas las verificaciones pasan, mostrar la página solicitada
                  return builder(context, settings.arguments);
                },
              );
            }
            
            // Si todas las verificaciones pasan, mostrar la página solicitada
            return builder(context, settings.arguments);
          },
        );
      },
    );
  }
}

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('No Autorizado'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'No has iniciado sesión',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Por favor inicia sesión para continuar',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso Denegado'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Acceso Denegado',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'No tienes los permisos necesarios para acceder a esta página',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}