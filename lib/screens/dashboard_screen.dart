import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../models/dashboard_models.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../providers/dashboard_provider.dart';
import '../services/auth_service.dart';
import '../shared/theme/app_theme.dart';
import 'contenido_crud_screen.dart';
import 'contenido_form_screen.dart';
// import '../features/usuarios/presentation/screens/crear_usuario_admin_screen.dart'; // ELIMINADO

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

// Modelo simple para estadísticas diarias
class EstadisticaDiariaModel {
  final DateTime fecha;
  final int nuevasGestantes;
  final int controlesRealizados;
  final int alertasGeneradas;
  final int alertasResueltas;
  final int usuariosActivos;

  EstadisticaDiariaModel({
    required this.fecha,
    required this.nuevasGestantes,
    required this.controlesRealizados,
    required this.alertasGeneradas,
    required this.alertasResueltas,
    required this.usuariosActivos,
  });
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DashboardStats? _estadisticasGenerales;

  @override
  void initState() {
    super.initState();
    developer.log('DashboardScreen: initState llamado', name: 'DashboardScreen');
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  List<EstadisticaDiariaModel> _generarEstadisticasDiarias() {
    final List<EstadisticaDiariaModel> estadisticas = [];
    final now = DateTime.now();
    
    for (int i = 29; i >= 0; i--) {
      final fecha = now.subtract(Duration(days: i));
      estadisticas.add(EstadisticaDiariaModel(
        fecha: fecha,
        nuevasGestantes: (i % 3 == 0) ? 1 : 0,
        controlesRealizados: 2 + (i % 4),
        alertasGeneradas: (i % 5 == 0) ? 2 : (i % 7 == 0) ? 1 : 0,
        alertasResueltas: (i % 6 == 0) ? 1 : 0,
        usuariosActivos: 10 + (i % 5),
      ));
    }
    
    return estadisticas;
  }

  @override
  Widget build(BuildContext context) {
    // Usar Riverpod para obtener las estadísticas
    final estadisticasAsync = ref.watch(estadisticasGeneralesProvider);
    
    return estadisticasAsync.when(
      loading: () => const Scaffold(
        body: LoadingWidget(message: 'Cargando estadísticas...'),
      ),
      error: (error, stack) {
        developer.log('Error en estadisticasGeneralesProvider: $error', 
          error: error, 
          stackTrace: stack, 
          name: 'DashboardScreen'
        );
        return Scaffold(
          body: CustomErrorWidget(
            message: 'Error al cargar los datos del dashboard: $error',
            onRetry: () => ref.invalidate(estadisticasGeneralesProvider),
          ),
        );
      },
      data: (estadisticas) {
        developer.log('Datos recibidos del provider: ${estadisticas.totalGestantes} gestantes', 
          name: 'DashboardScreen'
        );
        
        // Actualizar el estado local con los datos del provider
        _estadisticasGenerales = estadisticas;
        
        return Stack(
          children: [
            _buildDashboardContent(),
            _buildSuperAdminButtons(),
          ],
        );
      },
    );
  }

  Widget _buildDashboardContent() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(estadisticasGeneralesProvider);
            },
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = AuthService();
              await authService.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'General', icon: Icon(Icons.dashboard)),
            Tab(text: 'Tendencias', icon: Icon(Icons.trending_up)),
            Tab(text: 'Geográfico', icon: Icon(Icons.map)),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildGeneralTab(),
            _buildTendenciasTab(),
            _buildGeograficoTab(),
          ],
        ),
      ),

    );
  }

  Widget _buildGeneralTab() {
    if (_estadisticasGenerales == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: () async {
        // Invalidar el provider para forzar recarga
        ref.invalidate(estadisticasGeneralesProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResumenCards(),
            const SizedBox(height: 24),
            _buildAlertasSection(),
            const SizedBox(height: 24),
            _buildControlesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenCards() {
    final stats = _estadisticasGenerales!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen General',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Gestantes Totales',
              stats.totalGestantes.toString(),
              Icons.pregnant_woman,
              Colors.purple,
            ),
            _buildStatCard(
              'Controles Realizados',
              stats.controlesRealizados.toString(),
              Icons.favorite,
              Colors.green,
            ),
            _buildStatCard(
              'Alertas Activas',
              stats.alertasActivas.toString(),
              Icons.assignment_turned_in,
              Colors.blue,
            ),
            _buildStatCard(
              'Próximos Controles',
              stats.proximosControles.toString(),
              Icons.assignment_late,
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertasSection() {
    final stats = _estadisticasGenerales!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Estado de Alertas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAlertaIndicador(
                    'Activas',
                    stats.alertasActivas,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildAlertaIndicador(
                    'Próximos',
                    stats.proximosControles,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildAlertaIndicador(
                    'Contenidos',
                    stats.contenidosVistos,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertaIndicador(String label, int value, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildControlesSection() {
    final stats = _estadisticasGenerales!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Controles Prenatales',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: stats.tasaCumplimiento,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tasa de cumplimiento: ${(stats.tasaCumplimiento * 100).toStringAsFixed(1)}%'),
                Text('Contenidos vistos: ${stats.contenidosVistos}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTendenciasTab() {
    if (_estadisticasGenerales == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendencias (Últimos 30 días)',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildGraficoControles(),
          const SizedBox(height: 24),
          _buildGraficoAlertas(),
        ],
      ),
    );
  }

  Widget _buildGraficoControles() {
    // Usar datos de ejemplo para la gráfica
    final estadisticas = _generarEstadisticasDiarias();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Controles Realizados',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < estadisticas.length) {
                            final fecha = estadisticas[value.toInt()].fecha;
                            return Text('${fecha.day}/${fecha.month}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: estadisticas.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.controlesRealizados.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoAlertas() {
    // Usar datos de ejemplo para la gráfica
    final estadisticas = _generarEstadisticasDiarias();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas Generadas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < estadisticas.length) {
                            final fecha = estadisticas[value.toInt()].fecha;
                            return Text('${fecha.day}/${fecha.month}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: estadisticas.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.alertasGeneradas.toDouble(),
                          color: Colors.red,
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeograficoTab() {
    if (_estadisticasGenerales == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución Geográfica',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildGraficoGeografico(),
          const SizedBox(height: 24),
          _buildResumenGeografico(),
        ],
      ),
    );
  }

  Widget _buildGraficoGeografico() {
    final stats = _estadisticasGenerales!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Actividad',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: stats.controlesRealizados.toDouble(),
                      title: 'Controles\n${stats.controlesRealizados}',
                      color: Colors.blue,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: stats.alertasActivas.toDouble(),
                      title: 'Alertas\n${stats.alertasActivas}',
                      color: Colors.red,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: stats.contenidosVistos.toDouble(),
                      title: 'Contenidos\n${stats.contenidosVistos}',
                      color: Colors.green,
                      radius: 80,
                    ),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenGeografico() {
    final stats = _estadisticasGenerales!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen General',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(3, (index) {
              final data = [
                {'tipo': 'Gestantes', 'valor': stats.totalGestantes, 'color': Colors.purple},
                {'tipo': 'Controles', 'valor': stats.controlesRealizados, 'color': Colors.blue},
                {'tipo': 'Alertas', 'valor': stats.alertasActivas, 'color': Colors.red},
              ];
              final item = data[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item['tipo'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text('${item['valor']}'),
                    ),
                    Expanded(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: item['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Método para calcular progreso de forma segura evitando NaN
  double _calculateSafeProgress(int total, int ultimo) {
    if (total == 0) return 0.0;

    final numerator = total - ultimo;
    final denominator = total + numerator;

    if (denominator == 0) return 0.0;

    final progress = numerator / denominator;

    // Asegurar que el valor esté entre 0.0 y 1.0
    if (progress.isNaN || progress.isInfinite) return 0.0;
    return progress.clamp(0.0, 1.0);
  }



  Widget _buildSuperAdminButtons() {
    final authService = AuthService();
    final currentUser = authService.currentUser;
    final userRole = currentUser?['rol'];
    final isSuperAdmin = userRole == 'super_admin';
    final isAdmin = userRole == 'admin' || userRole == 'super_admin';
    
    // Debug: Verificar autenticación
    developer.log('🔍 Dashboard: === VERIFICACIÓN DE ROLES ===', name: 'DashboardScreen');
    developer.log('🔍 Dashboard: currentUser = $currentUser', name: 'DashboardScreen');
    developer.log('🔍 Dashboard: userRole = $userRole', name: 'DashboardScreen');
    developer.log('🔍 Dashboard: isSuperAdmin = $isSuperAdmin', name: 'DashboardScreen');
    developer.log('🔍 Dashboard: isAdmin = $isAdmin', name: 'DashboardScreen');
    developer.log('🔍 Dashboard: isAuthenticated = ${authService.isAuthenticated}', name: 'DashboardScreen');
    
    // Si no hay usuario autenticado, no mostrar botones
    if (currentUser == null || !authService.isAuthenticated) {
      developer.log('❌ Dashboard: No hay usuario autenticado, ocultando botones', name: 'DashboardScreen');
      return const SizedBox.shrink();
    }
    
    // Solo mostrar botones si es admin o super_admin
    if (!isAdmin) {
      developer.log('❌ Dashboard: Usuario ${currentUser['nombre']} con rol "$userRole" no tiene permisos de admin, ocultando botones', name: 'DashboardScreen');
      return const SizedBox.shrink();
    }

    developer.log('✅ Dashboard: Mostrando botones para usuario ${currentUser['nombre']} con rol "$userRole"', name: 'DashboardScreen');

    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón Contenidos - ADMIN y SUPER_ADMIN (arriba)
          if (isAdmin) ...[
            FloatingActionButton(
              onPressed: () {
                developer.log('📚 Dashboard: Navegando a gestión de contenidos', name: 'DashboardScreen');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ContenidoCrudScreen(),
                  ),
                );
              },
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
              heroTag: "admin_contenidos",
              tooltip: 'Gestión de Contenidos',
              mini: true,
              child: const Icon(Icons.video_library, size: 20),
            ),
            const SizedBox(height: 12),
          ],
          // Botón Usuarios - ADMIN y SUPER_ADMIN (medio)
          if (isAdmin) ...[
            FloatingActionButton(
              onPressed: () {
                developer.log('👥 Dashboard: Navegando a gestión de usuarios', name: 'DashboardScreen');
                context.go('/usuarios');
              },
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              heroTag: "admin_usuarios",
              tooltip: 'Gestión de Usuarios',
              mini: true,
              child: const Icon(Icons.people, size: 20),
            ),
          ],
          // Botón Municipios - Solo SUPER_ADMIN (abajo)
          if (isSuperAdmin) ...[
            const SizedBox(height: 12),
            FloatingActionButton(
              onPressed: () {
                developer.log('🏙️ Dashboard: Navegando a gestión de municipios', name: 'DashboardScreen');
                context.go('/municipios');
              },
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              heroTag: "superadmin_municipios",
              tooltip: 'Gestión de Municipios',
              mini: true,
              child: const Icon(Icons.location_city, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}