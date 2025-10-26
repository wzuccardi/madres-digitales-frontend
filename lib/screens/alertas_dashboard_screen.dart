import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/alerta_service.dart';
import '../providers/service_providers.dart';
import '../screens/alertas_screen.dart';
import '../utils/logger.dart';

class AlertasDashboardScreen extends ConsumerStatefulWidget {
  const AlertasDashboardScreen({super.key});

  @override
  ConsumerState<AlertasDashboardScreen> createState() => _AlertasDashboardScreenState();
}

class _AlertasDashboardScreenState extends ConsumerState<AlertasDashboardScreen> {
  bool _isLoading = true;
  String? _error;
  
  // Estadísticas
  Map<String, int> _estadisticasPrioridad = {};
  Map<String, int> _estadisticasTipo = {};
  List<Alerta> _alertasCriticasPendientes = [];
  Map<String, dynamic> _resumenGeneral = {};
  List<Map<String, dynamic>> _tendenciaSemanal = [];

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final alertaService = AlertaService(ref.read(apiServiceProvider));
      
      // Cargar todas las alertas para generar estadísticas
      final todasAlertas = await alertaService.obtenerAlertas(limit: 1000);
      
      // Calcular estadísticas por prioridad
      _estadisticasPrioridad = {
        'critica': todasAlertas.where((a) => a.nivelPrioridad == 'critica').length,
        'alta': todasAlertas.where((a) => a.nivelPrioridad == 'alta').length,
        'media': todasAlertas.where((a) => a.nivelPrioridad == 'media').length,
        'baja': todasAlertas.where((a) => a.nivelPrioridad == 'baja').length,
      };
      
      // Calcular estadísticas por tipo
      final tiposUnicos = todasAlertas.map((a) => a.tipoAlerta).toSet();
      _estadisticasTipo = {};
      for (final tipo in tiposUnicos) {
        _estadisticasTipo[tipo] = todasAlertas.where((a) => a.tipoAlerta == tipo).length;
      }
      
      // Alertas críticas pendientes
      _alertasCriticasPendientes = todasAlertas
          .where((a) => a.nivelPrioridad == 'critica' && !a.resuelta)
          .take(5)
          .toList();
      
      // Resumen general
      _resumenGeneral = {
        'total': todasAlertas.length,
        'pendientes': todasAlertas.where((a) => !a.resuelta).length,
        'resueltas': todasAlertas.where((a) => a.resuelta).length,
        'automaticas': todasAlertas.where((a) => a.esAutomatica).length,
        'manuales': todasAlertas.where((a) => !a.esAutomatica).length,
        'criticas_pendientes': _alertasCriticasPendientes.length,
      };
      
      // Tendencia semanal (últimos 7 días)
      _tendenciaSemanal = _calcularTendenciaSemanal(todasAlertas);
      
      setState(() {
        _isLoading = false;
      });
      
      appLogger.info('AlertasDashboard: Estadísticas cargadas - Total: ${todasAlertas.length}');
      
    } catch (e) {
      appLogger.error('AlertasDashboard: Error cargando estadísticas', error: e);
      setState(() {
        _error = 'Error cargando estadísticas: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _calcularTendenciaSemanal(List<Alerta> alertas) {
    final ahora = DateTime.now();
    final tendencia = <Map<String, dynamic>>[];
    
    for (int i = 6; i >= 0; i--) {
      final fecha = ahora.subtract(Duration(days: i));
      final inicioDelDia = DateTime(fecha.year, fecha.month, fecha.day);
      final finDelDia = inicioDelDia.add(const Duration(days: 1));
      
      final alertasDelDia = alertas.where((a) => 
        a.fechaCreacion.isAfter(inicioDelDia) && 
        a.fechaCreacion.isBefore(finDelDia)
      ).toList();
      
      tendencia.add({
        'fecha': fecha,
        'total': alertasDelDia.length,
        'criticas': alertasDelDia.where((a) => a.nivelPrioridad == 'critica').length,
        'automaticas': alertasDelDia.where((a) => a.esAutomatica).length,
      });
    }
    
    return tendencia;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Alertas'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarEstadisticas,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarEstadisticas,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarEstadisticas,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Alertas críticas pendientes (prominente)
                        if (_alertasCriticasPendientes.isNotEmpty)
                          _buildAlertasCriticasWidget(),
                        
                        const SizedBox(height: 16),
                        
                        // Resumen general
                        _buildResumenGeneral(),
                        
                        const SizedBox(height: 16),
                        
                        // Estadísticas por prioridad
                        _buildEstadisticasPrioridad(),
                        
                        const SizedBox(height: 16),
                        
                        // Gráfico de tendencia semanal
                        _buildTendenciaSemanal(),
                        
                        const SizedBox(height: 16),
                        
                        // Estadísticas por tipo
                        _buildEstadisticasTipo(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildAlertasCriticasWidget() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red[700], size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Alertas Críticas Pendientes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_alertasCriticasPendientes.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_alertasCriticasPendientes.take(3).map((alerta) => 
              _buildAlertaCriticaItem(alerta)
            )),
            if (_alertasCriticasPendientes.length > 3)
              TextButton(
                onPressed: () => _navegarAListaAlertas('criticas'),
                child: Text('Ver todas las ${_alertasCriticasPendientes.length} alertas críticas'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertaCriticaItem(Alerta alerta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: Colors.red[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerta.gestante?.nombre ?? 'Gestante desconocida',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  alerta.mensaje,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _formatearTiempo(alerta.fechaCreacion),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenGeneral() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Alertas',
                    '${_resumenGeneral['total'] ?? 0}',
                    Icons.notifications,
                    Colors.blue,
                    onTap: () => _navegarAListaAlertas('todas'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pendientes',
                    '${_resumenGeneral['pendientes'] ?? 0}',
                    Icons.pending,
                    Colors.orange,
                    onTap: () => _navegarAListaAlertas('pendientes'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Automáticas',
                    '${_resumenGeneral['automaticas'] ?? 0}',
                    Icons.smart_toy,
                    Colors.purple,
                    onTap: () => _navegarAListaAlertas('automaticas'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Resueltas',
                    '${_resumenGeneral['resueltas'] ?? 0}',
                    Icons.check_circle,
                    Colors.green,
                    onTap: () => _navegarAListaAlertas('resueltas'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String titulo, String valor, IconData icono, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasPrioridad() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alertas por Prioridad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLeyendaPrioridad(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final colores = {
      'critica': Colors.red,
      'alta': Colors.orange,
      'media': Colors.yellow[700]!,
      'baja': Colors.green,
    };

    return _estadisticasPrioridad.entries.map((entry) {
      final total = _estadisticasPrioridad.values.fold(0, (a, b) => a + b);
      final porcentaje = total > 0 ? (entry.value / total * 100) : 0;
      
      return PieChartSectionData(
        color: colores[entry.key],
        value: entry.value.toDouble(),
        title: '${porcentaje.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLeyendaPrioridad() {
    final colores = {
      'critica': Colors.red,
      'alta': Colors.orange,
      'media': Colors.yellow[700]!,
      'baja': Colors.green,
    };

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: _estadisticasPrioridad.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colores[entry.key],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text('${entry.key.toUpperCase()}: ${entry.value}'),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTendenciaSemanal() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tendencia Semanal',
              style: TextStyle(
                fontSize: 18,
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
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _tendenciaSemanal.length) {
                            final fecha = _tendenciaSemanal[value.toInt()]['fecha'] as DateTime;
                            return Text(
                              '${fecha.day}/${fecha.month}',
                              style: const TextStyle(fontSize: 10),
                            );
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
                      spots: _tendenciaSemanal.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['total'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: _tendenciaSemanal.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['criticas'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLeyendaLinea('Total', Colors.blue),
                const SizedBox(width: 16),
                _buildLeyendaLinea('Críticas', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeyendaLinea(String texto, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(texto, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildEstadisticasTipo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alertas por Tipo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._estadisticasTipo.entries.map((entry) {
              final total = _estadisticasTipo.values.fold(0, (a, b) => a + b);
              final porcentaje = total > 0 ? (entry.value / total) : 0;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: LinearProgressIndicator(
                        value: porcentaje.toDouble(),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getColorForTipo(entry.key),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  Color _getColorForTipo(String tipo) {
    switch (tipo) {
      case 'emergencia_obstetrica': return Colors.red;
      case 'hipertension': return Colors.orange;
      case 'preeclampsia': return Colors.red[700]!;
      case 'sepsis': return Colors.purple;
      case 'hemorragia': return Colors.red[900]!;
      case 'parto_prematuro': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _formatearTiempo(DateTime fecha) {
    final diferencia = DateTime.now().difference(fecha);
    if (diferencia.inMinutes < 60) {
      return '${diferencia.inMinutes}m';
    } else if (diferencia.inHours < 24) {
      return '${diferencia.inHours}h';
    } else {
      return '${diferencia.inDays}d';
    }
  }

  void _navegarAListaAlertas(String filtro) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AlertasScreen(),
      ),
    );
  }
}