import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/sos_listener_provider.dart';
import 'package:madres_digitales_flutter_new/core/firebase/firebase_boot.dart';
import 'dart:async';

class MainLayout extends ConsumerStatefulWidget {

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });
  final Widget child;
  final String currentRoute;

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _unreadAlertas = 0;
  StreamSubscription? _alertCreatedSub;
  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para acceder a ref después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      ref.listen(connectivityStreamProvider, (prev, next) {
        final connected = next.value != null && next.value != ConnectivityResult.none;
        if (connected) {
          final sync = ref.read(syncServiceProvider);
          if (!sync.status.toString().contains('syncing')) {
            sync.sync();
          }
        }
      });
      
      _subscribeAlertas();
      _refreshUnreadAlertas();
      _initNotifications();
    });
  }
  int _getCurrentIndex() {
    switch (widget.currentRoute) {
      case AppConstants.dashboardRoute:
        return 0;
      case AppConstants.gestantesRoute:
        return 1;
      case '/medicos':
        return 2;
      case '/ips':
        return 3;
      case AppConstants.controlsRoute:
        return 4;
      case AppConstants.alertsRoute:
        return 5;
      case '/alertas-dashboard':
        return 6;
      case AppConstants.contenidoListRoute:
        return 7;
      case '/mensajes':
        return 8;
      case AppConstants.reportsRoute:
        return 9;
      default:
        return 0;
    }
  }
  Future<void> _refreshUnreadAlertas() async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.id.isEmpty) return;
    try {
      final service = ref.read(alertaServiceProvider);
      final count = await service.getUnreadAlertasCount(user.id);
      if (mounted) {
        setState(() {
          _unreadAlertas = count;
        });
      }
    } catch (_) {}
  }
  Future<void> _subscribeAlertas() async {
    final ws = ref.read(webSocketServiceProvider);
    await ws.connect();
    _alertCreatedSub = ws.stream<Map<String, dynamic>>('alerta:created').listen((_) async {

      // Evitar usar context tras una espera: refrescar sin await
      // ignore: unawaited_futures
      _refreshUnreadAlertas();
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);
      try {
        final notifications = ref.read(notificationServiceProvider);
        // ignore: unawaited_futures
        notifications.showAlert(title: 'Nueva alerta', body: 'Se ha generado una nueva alerta');
      } catch (_) {}
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Nueva alerta recibida'),
          action: SnackBarAction(
            label: 'Ver',
            onPressed: () => router.go(AppConstants.alertsRoute),
          ),
        ),
      );
    });
    ws.stream<Map<String, dynamic>>('alerta:read').listen((_) async {
      await _refreshUnreadAlertas();
    });
    ws.stream<Map<String, dynamic>>('alerta:status').listen((_) async {
      await _refreshUnreadAlertas();
    });
    ws.stream<Map<String, dynamic>>('control:created').listen((_) async {
      try {
        final notifications = ref.read(notificationServiceProvider);
        await notifications.showReminder(title: 'Nuevo control', body: 'Se ha registrado un control');
      } catch (_) {}
    });
  }
  Future<void> _initNotifications() async {
    try {
      await FirebaseBoot.init();
      final notifications = ref.read(notificationServiceProvider);
      await notifications.init();
    } catch (_) {}
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go(AppConstants.dashboardRoute);
        break;
      case 1:
        context.go(AppConstants.gestantesRoute);
        break;
      case 2:
        context.go('/medicos');
        break;
      case 3:
        context.go('/ips');
        break;
      case 4:
        context.go(AppConstants.controlsRoute);
        break;
      case 5:
        context.go(AppConstants.alertsRoute);
        break;
      case 6:
        context.go('/alertas-dashboard');
        break;
      case 7:
        context.go(AppConstants.contenidoListRoute);
        break;
      case 8:
        context.go('/mensajes');
        break;
      case 9:
        context.go(AppConstants.reportsRoute);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(connectivityStreamProvider);
    final sync = ref.read(syncServiceProvider);
    
    // Determinar estado de conexión
    final connectivityResult = connectivity.value;
    final isOnline = connectivityResult != null && connectivityResult != ConnectivityResult.none;
    final status = sync.status.toString();
    
    // Determinar tipo de conexión
    String connectionType = 'Sin conexión';
    IconData connectionIcon = Icons.signal_wifi_off;
    
    if (isOnline) {
      if (connectivityResult == ConnectivityResult.wifi) {
        connectionType = 'WiFi';
        connectionIcon = Icons.wifi;
      } else if (connectivityResult == ConnectivityResult.mobile) {
        connectionType = 'Datos móviles';
        connectionIcon = Icons.signal_cellular_alt;
      } else if (connectivityResult == ConnectivityResult.ethernet) {
        connectionType = 'Ethernet';
        connectionIcon = Icons.settings_ethernet;
      } else {
        connectionType = 'Conectado';
        connectionIcon = Icons.check_circle;
      }
      
      if (status.contains('syncing')) {
        connectionType = 'Sincronizando...';
        connectionIcon = Icons.sync;
      }
    }
    
    // No usar Scaffold aquí para evitar conflictos con los Scaffold de las pantallas
    return SOSListenerWidget(
      child: Column(
        children: [
        Expanded(child: widget.child),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: !isOnline
                ? Colors.orange.withValues(alpha: 0.15)
                : status.contains('syncing')
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.06),
            border: Border(
              top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
          ),
          child: Row(
            children: [
              Icon(
                connectionIcon,
                size: 16,
                color: !isOnline
                    ? Colors.orange
                    : status.contains('syncing')
                        ? Colors.blue
                        : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  connectionType,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: !isOnline
                        ? Colors.orange.shade800
                        : status.contains('syncing')
                            ? Colors.blue.shade800
                            : Colors.green.shade800,
                  ),
                ),
              ),
              if (!isOnline)
                TextButton.icon(
                  onPressed: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Intentando sincronizar...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      final result = await sync.sync();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.success 
                                ? '✅ Sincronización exitosa' 
                                : '❌ Error: ${result.error}'
                            ),
                            backgroundColor: result.success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.sync, size: 14),
                  label: const Text('Sincronizar', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ),
        BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _getCurrentIndex(),
          onTap: _onItemTapped,
          selectedItemColor: Colors.pink,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, size: 20),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.pregnant_woman, size: 20),
              label: 'Gestantes',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.medical_services, size: 20),
              label: 'Médicos',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital, size: 20),
              label: 'IPS',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.assignment, size: 20),
              label: 'Controles',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_active, size: 20),
                  if (_unreadAlertas > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _unreadAlertas > 99 ? '99+' : _unreadAlertas.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Alertas',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.analytics, size: 20),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.library_books, size: 20),
              label: 'Contenido',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat, size: 20),
              label: 'Mensajes',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.assessment, size: 20),
              label: 'Reportes',
            ),
          ],
        ),
      ],
      ),
    );
  }
  @override
  void dispose() {
    _alertCreatedSub?.cancel();
    super.dispose();
  }
}
