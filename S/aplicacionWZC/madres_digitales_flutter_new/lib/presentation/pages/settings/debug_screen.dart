import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/data/services/offline_error_service.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  List<OfflineError> _errors = const [];

  @override
  void initState() {
    super.initState();
    _loadErrors();
  }

  Future<void> _loadErrors() async {
    final svc = ref.read(offlineErrorServiceProvider);
    final list = await svc.getAllErrors();
    setState(() => _errors = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: const Text('DEBUG - Pantalla de Prueba'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadErrors,
          ),
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: () async {
              final svc = ref.read(offlineErrorServiceProvider);
              final messenger = ScaffoldMessenger.of(context);
              await svc.retryAllErrors();
              await _loadErrors();
              messenger.showSnackBar(
                const SnackBar(content: Text('Reintentos ejecutados')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text('Errores Offline Pendientes'),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: _errors.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final e = _errors[index];
                return ListTile(
                  leading: const Icon(Icons.error_outline, color: Colors.red),
                  title: Text(e.message),
                  subtitle: Text('${e.method} ${e.endpoint}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.replay),
                    onPressed: () async {
                      final svc = ref.read(offlineErrorServiceProvider);
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await svc.retryError(e.id);
                      if (ok) {
                        await _loadErrors();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Error reintentado')),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
