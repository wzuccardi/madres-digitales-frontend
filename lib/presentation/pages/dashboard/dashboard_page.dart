import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/application/providers/auth_provider.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/contenido/sync_status_widget.dart';
import '../../../core/constants/app_constants.dart';
import 'package:madres_digitales_flutter_new/features/alertas/presentation/providers/alerta_provider.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _stats;
  int _alertasCriticas = 0;
  int _urgenciaCritica = 0;
  int _urgenciaAlta = 0;
  int _urgenciaMedia = 0;
  int _urgenciaBaja = 0;
  StreamSubscription? _alertCreatedSub;
  StreamSubscription? _controlCreatedSub;
  List<MapEntry<String, int>> _topMunicipios = const [];
  List<MapEntry<String, int>> _topIps = const [];
  List<MapEntry<String, int>> _topMedicos = const [];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadRealtime();
    _loadDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen(connectivityStreamProvider, (prev, next) async {
        final value = next.valueOrNull;
        if (value != null && value != ConnectivityResult.none) {
          try {
            final sync = ref.read(syncServiceProvider);
            await sync.sync();
          } catch (_) {}
        }
      });
    });
    _subscribeRealtime();
  }

  Future<void> _loadDashboardData() async {
    try {
      final service = ref.read(dashboardServiceProvider);
      final data = await service.getDashboardData();
      List<MapEntry<String, int>> asTop(Map<String, dynamic>? m) {
        if (m == null) return [];
        final entries = m.entries
            .map((e) => MapEntry(e.key, (e.value is num) ? (e.value as num).toInt() : 0))
            .toList();
        entries.sort((a, b) => b.value.compareTo(a.value));
        return entries.take(4).toList();
      }
      if (mounted) {
        setState(() {
          _topMunicipios = asTop(data['porMunicipio'] as Map<String, dynamic>?);
          _topIps = asTop(data['porIps'] as Map<String, dynamic>?);
          _topMedicos = asTop(data['porMedicos'] as Map<String, dynamic>?);
        });
      }
    } catch (_) {}
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(dashboardServiceProvider);
      final data = await service.getStatistics();
      setState(() {
        _stats = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar estadísticas: $e';
        _loading = false;
      });
    }
  }

  Future<void> _loadRealtime() async {
    try {
      final alertas = await ref.read(alertaProvider.future);
      final criticas = alertas.where((a) => a.nivelPrioridad.toLowerCase() == 'critica').length;
      final controles = await ref.read(controlServiceProvider).getControles();
      final Map<String, DateTime> ultimoPorGestante = {};
      for (final c in controles) {
        if (c.gestanteId == null) continue;
        final existing = ultimoPorGestante[c.gestanteId!];
        final fecha = c.fecha ?? c.fechaProgramada ?? DateTime.now();
        if (existing == null || fecha.isAfter(existing)) {
          ultimoPorGestante[c.gestanteId!] = fecha;
        }
      }
      int uc = 0, ua = 0, um = 0, ub = 0;
      final now = DateTime.now();
      for (final fecha in ultimoPorGestante.values) {
        final dias = now.difference(fecha).inDays;
        if (dias > 30) {
          uc++;
        } else if (dias >= 21) {
          ua++;
        } else if (dias >= 14) {
          um++;
        } else {
          ub++;
        }
      }
      if (mounted) {
        setState(() {
          _alertasCriticas = criticas;
          _urgenciaCritica = uc;
          _urgenciaAlta = ua;
          _urgenciaMedia = um;
          _urgenciaBaja = ub;
        });
      }
    } catch (_) {}
  }

  Future<void> _subscribeRealtime() async {
    final ws = ref.read(webSocketServiceProvider);
    await ws.connect();
    _alertCreatedSub = ws.stream<Map<String, dynamic>>('alerta:created').listen((_) async {
      await _loadStats();
      await _loadRealtime();
    });
    _controlCreatedSub = ws.stream<Map<String, dynamic>>('control:created').listen((_) async {
      await _loadStats();
      await _loadRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userRoleLower = authState.user?.role.toLowerCase();
    final authNotifier = ref.read(authProvider.notifier);
    
    // Verificar si hay error en la carga
    if (_error != null) {
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
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadStats,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Mostrar loading
    if (_loading) {
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
    
    AppLogger.debug('DEBUG usuario actual', context: {
      'email': authState.user?.email,
      'rol': authState.user?.role,
      'rolLower': userRoleLower,
      'isSuperAdmin': authState.user?.role == AppConstants.superAdminRole,
      'isAdmin': authState.user?.role == AppConstants.adminRole,
    });
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text(
          'Madres Digitales',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Alertas y controles importantes
              const SizedBox(height: 8),
              if (_alertasCriticas > 0)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Alertas críticas: $_alertasCriticas',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(AppConstants.alertsRoute),
                          child: const Text('Ver alertas'),
                        ),
                      ],
                    ),
                  ),
                ),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Próximos controles — Crítica: $_urgenciaCritica · Alta: $_urgenciaAlta · Media: $_urgenciaMedia · Baja: $_urgenciaBaja',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppConstants.controlsRoute),
                        child: const Text('Ver controles'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(_error!),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: _loadStats, child: const Text('Reintentar')),
                      ],
                    ),
                  ),
                )
              else if (_stats != null)
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard('Gestantes', (_stats!['totalGestantes'] ?? 0).toString(), Colors.pink, Icons.pregnant_woman),
                    _buildStatCard('Controles', (_stats!['controlesRealizados'] ?? 0).toString(), Colors.blue, Icons.assignment),
                    _buildStatCard('Alertas Activas', (_stats!['alertasActivas'] ?? 0).toString(), Colors.orange, Icons.warning),
                    _buildStatCard('Alto Riesgo', (_stats!['gestantesAltoRiesgo'] ?? 0).toString(), Colors.red, Icons.error),
                    _buildStatCard('Controles Hoy', (_stats!['controlesHoy'] ?? 0).toString(), Colors.teal, Icons.today),
                    _buildStatCard('Próximas Citas', (_stats!['proximosCitas'] ?? 0).toString(), Colors.deepPurple, Icons.calendar_month),
                    _buildStatCard('Médicos', (_stats!['totalMedicos'] ?? 0).toString(), Colors.indigo, Icons.medical_information),
                    _buildStatCard('IPS', (_stats!['totalIps'] ?? 0).toString(), Colors.brown, Icons.local_hospital),
                    if (userRoleLower == AppConstants.adminRole ||
                        userRoleLower == AppConstants.superAdminRole ||
                        userRoleLower == AppConstants.coordinatorRole) ...[
                      _buildStatCard('Usuarios', (_stats!['totalUsuarios'] ?? 0).toString(), Colors.purple, Icons.people),
                      _buildStatCard('Críticas Hoy', _alertasCriticas.toString(), Colors.red, Icons.priority_high),
                    ],
                  ],
                ),
              if (_topMunicipios.isNotEmpty || _topIps.isNotEmpty || _topMedicos.isNotEmpty) ...[
                const SizedBox(height: 16),
                if (_topMunicipios.isNotEmpty)
                  _buildTopList('Top Municipios', _topMunicipios, Icons.location_city, Colors.teal),
                if (_topIps.isNotEmpty)
                  _buildTopList('Top IPS', _topIps, Icons.local_hospital, Colors.brown),
                if (_topMedicos.isNotEmpty)
                  _buildTopList('Top Médicos', _topMedicos, Icons.medical_information, Colors.indigo),
              ],
              const SizedBox(height: 80), // Espacio para los botones flotantes
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingButtons(context, userRoleLower),
    );
  }

  Widget _buildFloatingButtons(BuildContext context, String? userRoleLower) {
    final buttons = <Widget>[];
    
    // Botón de Gestión de Contenidos (todos los usuarios)
    buttons.add(
      FloatingActionButton.extended(
        onPressed: () => context.go(AppConstants.contenidoListRoute),
        icon: const Icon(Icons.article),
        label: const Text('Contenidos'),
        backgroundColor: Colors.pink,
        heroTag: 'contenidos',
      ),
    );
    
    // Botón de Gestión de Usuarios (solo ADMIN y SUPERADMIN)
    if (userRoleLower == AppConstants.adminRole || 
        userRoleLower == AppConstants.superAdminRole) {
      buttons.add(
        FloatingActionButton.extended(
          onPressed: () => context.go('/usuarios'),
          icon: const Icon(Icons.people),
          label: const Text('Usuarios'),
          backgroundColor: Colors.indigo,
          heroTag: 'usuarios',
        ),
      );
    }
    
    // Botón de Gestión de Municipios (solo SUPERADMIN)
    if (userRoleLower == AppConstants.superAdminRole) {
      buttons.add(
        FloatingActionButton.extended(
          onPressed: () => context.go('/municipios-admin'),
          icon: const Icon(Icons.location_city),
          label: const Text('Municipios'),
          backgroundColor: Colors.teal,
          heroTag: 'municipios',
        ),
      );
    }
    
    // Si solo hay un botón, retornarlo directamente
    if (buttons.length == 1) {
      return buttons.first;
    }
    
    // Si hay múltiples botones, crear una columna con espaciado
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          buttons[i],
          if (i < buttons.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopList(String title, List<MapEntry<String, int>> items, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map((e) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(e.key, overflow: TextOverflow.ellipsis)),
                    Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.adminRole:
        return 'Administrador';
      case AppConstants.superAdminRole:
        return 'Super Administrador';
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
  Widget _buildStatCard(String titulo, String valor, Color color, IconData icono) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _alertCreatedSub?.cancel();
    _controlCreatedSub?.cancel();
    super.dispose();
  }
}
