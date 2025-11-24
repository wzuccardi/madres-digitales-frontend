import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/application/providers/auth_provider.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/contenido/sync_status_widget.dart';
import '../../../core/constants/app_constants.dart';
import 'package:madres_digitales_flutter_new/features/alertas/presentation/providers/alerta_provider.dart';

/// Dashboard optimizado siguiendo especificaciones de newgeneration.md
/// - Elimina redundancias
/// - Mejora la organización visual
/// - Optimiza el rendimiento
/// - Sigue principios de diseño: Simplicidad, Accesibilidad, Consistencia
class DashboardPageOptimized extends ConsumerStatefulWidget {
  const DashboardPageOptimized({super.key});

  @override
  ConsumerState<DashboardPageOptimized> createState() => _DashboardPageOptimizedState();
}

class _DashboardPageOptimizedState extends ConsumerState<DashboardPageOptimized> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _stats;
  int _alertasCriticas = 0;
  StreamSubscription? _alertCreatedSub;
  StreamSubscription? _controlCreatedSub;

  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para acceder a ref después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
      _subscribeRealtime();
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Cargar estadísticas
      final service = ref.read(dashboardServiceProvider);
      final stats = await service.getStatistics();
      
      // Cargar alertas críticas
      final alertas = await ref.read(alertaProvider.future);
      final criticas = alertas.where((a) => a.nivelPrioridad.toLowerCase() == 'critica').length;

      if (mounted) {
        setState(() {
          _stats = stats;
          _alertasCriticas = criticas;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar datos: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _subscribeRealtime() async {
    if (!mounted) return;
    
    try {
      final ws = ref.read(webSocketServiceProvider);
      await ws.connect();
      
      _alertCreatedSub = ws.stream<Map<String, dynamic>>('alerta:created').listen((_) {
        if (mounted) {
          _loadDashboardData();
        }
      });
      
      _controlCreatedSub = ws.stream<Map<String, dynamic>>('control:created').listen((_) {
        if (mounted) {
          _loadDashboardData();
        }
      });
    } catch (e) {
      // Silenciar errores de WebSocket si no está disponible
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role.toLowerCase();
    final authNotifier = ref.read(authProvider.notifier);

    // Mostrar error
    if (_error != null) {
      return _buildErrorScreen();
    }

    // Mostrar loading
    if (_loading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text(
          'Madres Digitales',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          const CompactSyncStatusWidget(),
          IconButton(
            onPressed: () async {
              await authNotifier.logout();
              if (context.mounted) {
                context.go(AppConstants.loginRoute);
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bienvenida
                _buildWelcomeCard(authState),
                
                const SizedBox(height: 16),
                
                // Alertas críticas (si existen)
                if (_alertasCriticas > 0) ...[
                  _buildCriticalAlertsCard(),
                  const SizedBox(height: 16),
                ],
                
                // Estadísticas principales
                _buildStatsGrid(userRole),
                
                const SizedBox(height: 24),
                
                // Acciones rápidas
                _buildQuickActions(userRole),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.pink,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildWelcomeCard(authState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade400, Colors.pink.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.waving_hand, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¡Bienvenida!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      authState.user?.name ?? 'Usuario',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (authState.user?.role != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRoleDisplayName(authState.user?.role ?? ''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalAlertsCard() {
    return Card(
      color: Colors.red.shade50,
      elevation: 2,
      child: InkWell(
        onTap: () => context.go(AppConstants.alertsRoute),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alertas Críticas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      '$_alertasCriticas alertas requieren atención inmediata',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(String? userRole) {
    final isAdmin = userRole == AppConstants.adminRole || 
                    userRole == AppConstants.superAdminRole ||
                    userRole == AppConstants.coordinatorRole;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Gestantes',
          (_stats!['totalGestantes'] ?? 0).toString(),
          Colors.pink,
          Icons.pregnant_woman,
          () => context.go(AppConstants.gestantesRoute),
        ),
        _buildStatCard(
          'Controles',
          (_stats!['controlesRealizados'] ?? 0).toString(),
          Colors.blue,
          Icons.assignment,
          () => context.go(AppConstants.controlsRoute),
        ),
        _buildStatCard(
          'Alertas',
          (_stats!['alertasActivas'] ?? 0).toString(),
          Colors.orange,
          Icons.warning,
          () => context.go(AppConstants.alertsRoute),
        ),
        _buildStatCard(
          'Alto Riesgo',
          (_stats!['gestantesAltoRiesgo'] ?? 0).toString(),
          Colors.red,
          Icons.error,
          () => context.go(AppConstants.gestantesRoute),
        ),
        if (isAdmin) ...[
          _buildStatCard(
            'Médicos',
            (_stats!['totalMedicos'] ?? 0).toString(),
            Colors.indigo,
            Icons.medical_information,
            null,
          ),
          _buildStatCard(
            'IPS',
            (_stats!['totalIps'] ?? 0).toString(),
            Colors.brown,
            Icons.local_hospital,
            null,
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    String titulo,
    String valor,
    Color color,
    IconData icono,
    VoidCallback? onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(String? userRole) {
    final actions = <Map<String, dynamic>>[
      {
        'title': 'Gestantes',
        'icon': Icons.pregnant_woman,
        'color': Colors.purple,
        'route': AppConstants.gestantesRoute,
      },
      {
        'title': 'Controles',
        'icon': Icons.medical_services,
        'color': Colors.green,
        'route': AppConstants.controlsRoute,
      },
      {
        'title': 'Alertas',
        'icon': Icons.warning,
        'color': Colors.orange,
        'route': AppConstants.alertsRoute,
      },
      {
        'title': 'Reportes',
        'icon': Icons.assessment,
        'color': Colors.blue,
        'route': AppConstants.reportsRoute,
      },
      {
        'title': 'Contenido',
        'icon': Icons.library_books,
        'color': Colors.pink,
        'route': AppConstants.contenidoListRoute,
      },
      {
        'title': 'Notificaciones',
        'icon': Icons.notifications,
        'color': Colors.teal,
        'route': AppConstants.notificationsRoute,
      },
    ];

    // Agregar acciones específicas por rol
    if (userRole == AppConstants.adminRole || userRole == AppConstants.superAdminRole) {
      actions.add({
        'title': 'Usuarios',
        'icon': Icons.people,
        'color': Colors.indigo,
        'route': '/usuarios',
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildQuickActionCard(
              action['title'],
              action['icon'],
              action['color'],
              () => context.go(action['route']),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.adminRole:
        return 'Administrador';
      case AppConstants.superAdminRole:
        return 'Super Admin';
      case AppConstants.madrinaRole:
        return 'Madrina';
      case AppConstants.medicoRole:
        return 'Médico';
      case AppConstants.gestanteRole:
        return 'Gestante';
      case AppConstants.coordinatorRole:
        return 'Coordinador';
      default:
        return role;
    }
  }

  @override
  void dispose() {
    _alertCreatedSub?.cancel();
    _controlCreatedSub?.cancel();
    super.dispose();
  }
}
