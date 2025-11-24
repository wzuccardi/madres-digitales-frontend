import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStream = ref.watch(connectivityStreamProvider);

    return connectivityStream.when(
      data: (result) {
        final isOffline = result == ConnectivityResult.none;
        final isWifi = result == ConnectivityResult.wifi;
        final isMobile = result == ConnectivityResult.mobile;
        
        // Determinar color, icono y mensaje según el estado
        Color backgroundColor;
        IconData icon;
        String message;
        
        if (isOffline) {
          backgroundColor = Colors.red.shade700;
          icon = Icons.wifi_off;
          message = 'Sin conexión - Modo offline';
        } else if (isWifi) {
          backgroundColor = Colors.green.shade700;
          icon = Icons.wifi;
          message = 'Conectado - WiFi';
        } else if (isMobile) {
          backgroundColor = Colors.blue.shade700;
          icon = Icons.signal_cellular_alt;
          message = 'Conectado - Datos móviles';
        } else {
          backgroundColor = Colors.green.shade700;
          icon = Icons.check_circle;
          message = 'Conectado';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: backgroundColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isOffline) ...[
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                  onPressed: () {
                    ref.invalidate(connectivityStreamProvider);
                  },
                  tooltip: 'Reintentar',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: Colors.grey.shade600,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Verificando conexión...',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
      error: (_, __) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: Colors.orange.shade700,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Error al verificar conexión',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
