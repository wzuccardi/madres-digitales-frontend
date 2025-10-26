import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';
import 'package:madres_digitales_flutter_new/providers/service_providers.dart';

/// Widget para mostrar el estado de sincronización de contenidos
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.read(contenidoSyncServiceProvider);
    final syncProgressStream = syncService.syncProgress;
    final isSyncing = syncService.isSyncing;

    return StreamBuilder<double>(
      stream: syncProgressStream,
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;
        
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isSyncing ? Icons.sync : Icons.sync_disabled,
                      color: isSyncing ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Estado de Sincronización',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isSyncing) ...[
                  Text(
                    'Sincronizando contenidos... ${progress.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ] else ...[
                  const Text(
                    'Todos los contenidos están sincronizados',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isSyncing)
                      TextButton(
                        onPressed: () {
                          appLogger.debug('SyncStatusWidget: Botón de sincronización presionado');
                          _forzarSincronizacion(ref);
                        },
                        child: const Text('Sincronizar ahora'),
                      ),
                    if (isSyncing)
                      TextButton(
                        onPressed: () {
                          appLogger.debug('SyncStatusWidget: Botón de cancelar presionado');
                          _cancelarSincronizacion(ref);
                        },
                        child: const Text('Cancelar'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _forzarSincronizacion(WidgetRef ref) {
    appLogger.debug('SyncStatusWidget: Forzando sincronización');
    try {
      final syncService = ref.read(contenidoSyncServiceProvider);
      syncService.syncContenidos();
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(
          content: Text('Sincronización iniciada'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      appLogger.error('Error iniciando sincronización', error: e);
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(
          content: Text('Error al iniciar sincronización'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _cancelarSincronizacion(WidgetRef ref) {
    appLogger.debug('SyncStatusWidget: Cancelando sincronización');
    // En una implementación real, aquí se cancelaría la sincronización
    // Por ahora, solo mostramos un mensaje
    
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(
        content: Text('Cancelación no implementada'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Widget compacto para mostrar el estado de sincronización en la barra de navegación
class CompactSyncStatusWidget extends ConsumerWidget {
  const CompactSyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.read(contenidoSyncServiceProvider);
    final isSyncing = syncService.isSyncing;

    return IconButton(
      icon: Stack(
        children: [
          Icon(
            isSyncing ? Icons.sync : Icons.sync_disabled,
            color: isSyncing ? Colors.blue : Colors.white,
          ),
          if (isSyncing)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      onPressed: () {
        appLogger.debug('CompactSyncStatusWidget: Icono presionado');
        _mostrarDialogoEstado(context, ref);
      },
      tooltip: 'Estado de sincronización',
    );
  }

  void _mostrarDialogoEstado(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estado de Sincronización'),
        content: const SyncStatusWidget(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar el estado de sincronización en el dashboard
class DashboardSyncStatusWidget extends ConsumerWidget {
  const DashboardSyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.read(contenidoSyncServiceProvider);
    final isSyncing = syncService.isSyncing;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSyncing ? Icons.sync : Icons.cloud_done,
                color: isSyncing ? Colors.blue : Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Sincronización de Contenidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isSyncing) ...[
            Text(
              'Sincronizando contenidos...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<double>(
              stream: syncService.syncProgress,
              builder: (context, snapshot) {
                final progress = snapshot.data ?? 0.0;
                return LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                );
              },
            ),
          ] else ...[
            Text(
              'Todos los contenidos están sincronizados',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 1.0,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isSyncing)
                ElevatedButton.icon(
                  onPressed: () {
                    appLogger.debug('DashboardSyncStatusWidget: Botón de sincronización presionado');
                    _forzarSincronizacion(ref);
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('Sincronizar ahora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _forzarSincronizacion(WidgetRef ref) {
    appLogger.debug('DashboardSyncStatusWidget: Forzando sincronización');
    try {
      final syncService = ref.read(contenidoSyncServiceProvider);
      syncService.syncContenidos();
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(
          content: Text('Sincronización iniciada'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      appLogger.error('Error iniciando sincronización', error: e);
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(
          content: Text('Error al iniciar sincronización'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
