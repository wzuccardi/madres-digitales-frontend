import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';
import '../shared/theme/app_theme.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/error_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EstadisticasGeneralesModel? _estadisticasGenerales;
  EstadisticasPorPeriodoModel? _estadisticasPeriodo;
  EstadisticasGeograficasModel? _estadisticasGeograficas;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Aquí normalmente obtendrías el servicio del provider
      // final dashboardService = ref.read(dashboardServiceProvider);
      
      // Por ahora simulamos datos
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _estadisticasGenerales = EstadisticasGeneralesModel(
          totalGestantes: 150,
          gestantesActivas: 142,
          totalControles: 450,
          controlesPendientes: 23,
          totalAlertas: 45,
          alertasCriticas: 8,
          alertasResueltas: 37,
          promedioControlesPorGestante: 3.2,
          porcentajeGestantesRiesgo: 15.5,
          fechaActualizacion: DateTime.now(),
        );
        
        _estadisticasPeriodo = EstadisticasPorPeriodoModel(
          fechaInicio: DateTime.now().subtract(const Duration(days: 30)),
          fechaFin: DateTime.now(),
          estadisticasDiarias: _generarEstadisticasDiarias(),
          totalGestantesNuevas: 12,
          totalControlesRealizados: 89,
          totalAlertasGeneradas: 15,
          promedioControlesPorDia: 2.9,
        );
        
        _estadisticasGeograficas = EstadisticasGeograficasModel(
          centroLatitud: 4.6097,
          centroLongitud: -74.0817,
          radio: 10.0,
          totalGestantesEnArea: 85,
          gestantesPorZona: {
            'Norte': 25,
            'Sur': 20,
            'Este': 22,
            'Oeste': 18,
          },
          alertasPorZona: {
            'Norte': 8,
            'Sur': 5,
            'Este': 7,
            'Oeste': 4,
          },
        );
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<EstadisticaDiariaModel> _generarEstadisticasDiarias() {
    final List<EstadisticaDiariaModel> estadisticas = [];
    final now = DateTime.now();
    
    for (int i = 29; i >= 0; i--) {
      final fecha = now.subtract(Duration(days: i));
      estadisticas.add(EstadisticaDiariaModel(
        fecha: fecha,
        gestantesNuevas: (i % 3 == 0) ? 1 : 0,
        controlesRealizados: 2 + (i % 4),
        alertasGeneradas: (i % 5 == 0) ? 2 : (i % 7 == 0) ? 1 : 0,
      ));
    }
    
    return estadisticas;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Cargando estadísticas...'),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: CustomErrorWidget(
          message: _error!,
          onRetry: _cargarDatos,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          _buildTendenciasTab(),
          _buildGeograficoTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    if (_estadisticasGenerales == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: _cargarDatos,
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
              AppTheme.primaryColor,
            ),
            _buildStatCard(
              'Gestantes Activas',
              stats.gestantesActivas.toString(),
              Icons.favorite,
              Colors.green,
            ),
            _buildStatCard(
              'Controles Realizados',
              stats.totalControles.toString(),
              Icons.assignment_turned_in,
              Colors.blue,
            ),
            _buildStatCard(
              'Controles Pendientes',
              stats.controlesPendientes.toString(),
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
                Icon(Icons.warning, color: Colors.red),
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
                    'Críticas',
                    stats.alertasCriticas,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildAlertaIndicador(
                    'Total',
                    stats.totalAlertas,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildAlertaIndicador(
                    'Resueltas',
                    stats.alertasResueltas,
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
              value: stats.controlesPendientes / (stats.totalControles + stats.controlesPendientes),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Promedio por gestante: ${stats.promedioControlesPorGestante.toStringAsFixed(1)}'),
                Text('${stats.porcentajeGestantesRiesgo.toStringAsFixed(1)}% en riesgo'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTendenciasTab() {
    if (_estadisticasPeriodo == null) return const SizedBox();

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
    final estadisticas = _estadisticasPeriodo!.estadisticasDiarias;
    
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
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
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
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
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
    final estadisticas = _estadisticasPeriodo!.estadisticasDiarias;
    
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
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
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
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
    if (_estadisticasGeograficas == null) return const SizedBox();

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
    final stats = _estadisticasGeograficas!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestantes por Zona',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: stats.gestantesPorZona.entries.map((entry) {
                    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
                    final index = stats.gestantesPorZona.keys.toList().indexOf(entry.key);
                    
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n${entry.value}',
                      color: colors[index % colors.length],
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
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
    final stats = _estadisticasGeograficas!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen por Zona',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...stats.gestantesPorZona.entries.map((entry) {
              final alertas = stats.alertasPorZona[entry.key] ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text('${entry.value} gestantes'),
                    ),
                    Expanded(
                      child: Text(
                        '$alertas alertas',
                        style: TextStyle(
                          color: alertas > 5 ? Colors.red : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}