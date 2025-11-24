import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/gestante/presentation/providers/madrina_session_provider.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

/// Página de terminal de monitoreo de alertas SOS
class SOSTerminalPage extends ConsumerWidget {
  const SOSTerminalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Verificar permisos de acceso
    final madrinaSession = ref.watch(madrinaSessionProvider);
    final tieneAccesoTerminal = verificarAccesoTerminal(madrinaSession);
    
    if (!tieneAccesoTerminal) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso Restringido'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'No tienes permisos para acceder a la terminal de monitoreo SOS.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Regresar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal de Monitoreo SOS'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              final alertaService = ref.read(alertaServiceProvider);
              alertaService.getActiveAlertas().then((alertas) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Alertas activas: ${alertas.length}')),
                );
              }).catchError((e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Error refrescando alertas: $e')),
                );
              });
            },
            tooltip: 'Refrescar alertas',
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber,
              size: 64,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'Terminal SOS en construcción',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Esta funcionalidad está siendo desarrollada.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Verificar si el usuario tiene acceso a la terminal de monitoreo SOS
  bool verificarAccesoTerminal(MadrinaSessionState madrinaSession) {
    // Solo roles con acceso a terminal: coordinador, admin, super_admin
    final rol = madrinaSession.user?.role;
    return ['coordinator', 'admin', 'super_admin'].contains(rol);
  }
}
