import 'package:flutter/material.dart';

// Implementaciones temporales para las clases que faltan
class AuthMiddleware {
  static Route<dynamic> guardRoute({
    required RouteSettings settings,
    required Widget Function(BuildContext, dynamic) builder,
    required String requiredPermission,
    String? gestanteId,
  }) {
    return MaterialPageRoute(
      builder: (context) => builder(context, settings.arguments),
      settings: settings,
    );
  }
}

class CreateGestantePage extends StatelessWidget {
  const CreateGestantePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Crear Gestante - Página en desarrollo')),
    );
  }
}

class AssignGestantePage extends StatelessWidget {
  const AssignGestantePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Asignar Gestante - Página en desarrollo')),
    );
  }
}

class GestanteDetailPage extends StatelessWidget {
  final String gestanteId;
  
  const GestanteDetailPage({super.key, required this.gestanteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Detalle de Gestante - ID: $gestanteId - Página en desarrollo'),
      ),
    );
  }
}

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String gestantes = '/gestantes';
  static const String createGestante = '/gestantes/create';
  static const String assignGestante = '/gestantes/assign';
  static const String gestanteDetail = '/gestantes/detail';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case createGestante:
        return AuthMiddleware.guardRoute(
          settings: settings,
          builder: (context, args) => const CreateGestantePage(),
          requiredPermission: 'crear_gestante',
        );
        
      case assignGestante:
        return AuthMiddleware.guardRoute(
          settings: settings,
          builder: (context, args) => const AssignGestantePage(),
          requiredPermission: 'asignar_gestante',
        );
        
      case gestanteDetail:
        final gestanteId = settings.arguments as String?;
        if (gestanteId == null) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Error: ID de gestante no proporcionado')),
            ),
          );
        }
        
        return AuthMiddleware.guardRoute(
          settings: settings,
          builder: (context, args) => GestanteDetailPage(gestanteId: gestanteId),
          requiredPermission: 'ver',
          gestanteId: gestanteId,
        );
        
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}