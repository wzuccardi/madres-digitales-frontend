import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'performance_metrics.dart';

/// Dashboard para visualizar métricas de rendimiento en tiempo real
class PerformanceDashboard extends ConsumerStatefulWidget {
  const PerformanceDashboard({super.key});

  @override
  ConsumerState<PerformanceDashboard> createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends ConsumerState<PerformanceDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PerformanceReport> _reports = [];
  PerformanceReport? _currentReport;
  bool _isMonitoring = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHistoricalReports();
    _startMonitoring();
  }

  @override
  void dispose() {
    _tabController.dispose();
    PerformanceMetrics.instance.stopMonitoring();
    super.dispose();
  }

  void _startMonitoring() {
    setState(() => _isMonitoring = true);
    
    PerformanceMetrics.instance.startMonitoring(
      onReportGenerated: (report) {
        setState(() {
          _currentReport = report;
          _reports.add(report);
          // Mantener solo los últimos 100 reportes
          if (_reports.length > 100) {
            _reports.removeAt(0);
          }
        });
        _saveReport(report);
      },
      onMetricAlert: (type, data) {
        _showMetricAlert(type, data);
      },
    );
  }

  void _stopMonitoring() {
    setState(() => _isMonitoring = false);
    PerformanceMetrics.instance.stopMonitoring();
  }

  Future<void> _loadHistoricalReports() async {
    try {
      final file = File('performance_reports.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = json.decode(content);
        _reports = jsonList.map((json) => PerformanceReportJson.fromJson(json)).toList();
        if (_reports.isNotEmpty) {
          _currentReport = _reports.last;
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading historical reports: $e');
    }
  }

  Future<void> _saveReport(PerformanceReport report) async {
    try {
      final file = File('performance_reports.json');
      final jsonList = _reports.map((r) => r.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving report: $e');
    }
  }

  void _showMetricAlert(String type, Map<String, dynamic> data) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ $type',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...data.entries.map((entry) => Text(
              '${entry.key}: ${entry.value}',
              style: const TextStyle(fontSize: 12),
            )),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () => _showDetailedAlert(type, data),
        ),
      ),
    );
  }

  void _showDetailedAlert(String type, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alerta de Rendimiento: $type'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${entry.key}:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entry.value.toString())),
                ],
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Rendimiento'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isMonitoring ? Icons.stop : Icons.play_arrow),
            onPressed: _isMonitoring ? _stopMonitoring : _startMonitoring,
            tooltip: _isMonitoring ? 'Detener monitoreo' : 'Iniciar monitoreo',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReports,
            tooltip: 'Exportar reportes',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Métricas Actuales', icon: Icon(Icons.speed)),
            Tab(text: 'Historial', icon: Icon(Icons.history)),
            Tab(text: 'Análisis', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentMetricsTab(),
          _buildHistoryTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildCurrentMetricsTab() {
    if (_currentReport == null) {
      return const Center(
        child: Text('No hay datos disponibles. Inicia el monitoreo.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score de rendimiento
          _buildPerformanceScoreCard(_currentReport!),
          
          const SizedBox(height: 16),
          
          // Métricas principales
          Row(
            children: [
              Expanded(child: _buildMetricCard('FPS', _currentReport!.fps.toStringAsFixed(1), '60')),
              Expanded(child: _buildMetricCard('Memoria', '${(_currentReport!.memoryUsage / 1024 / 1024).toStringAsFixed(1)}MB', '150MB')),
              Expanded(child: _buildMetricCard('Frames Caídos', _currentReport!.droppedFrames.toString(), '0')),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Widgets lentos
          _buildSlowWidgetsCard(_currentReport!),
          
          const SizedBox(height: 16),
          
          // Widgets reconstruidos
          _buildRebuiltWidgetsCard(_currentReport!),
          
          const SizedBox(height: 16),
          
          // Información del dispositivo
          _buildDeviceInfoCard(_currentReport!),
        ],
      ),
    );
  }

  Widget _buildPerformanceScoreCard(PerformanceReport report) {
    final score = report.performanceScore;
    Color color;
    String status;
    
    if (score >= 80) {
      color = Colors.green;
      status = 'Excelente';
    } else if (score >= 60) {
      color = Colors.orange;
      status = 'Bueno';
    } else {
      color = Colors.red;
      status = 'Necesita Mejora';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: color,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Puntaje de Rendimiento',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  score.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: score / 100.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String threshold) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Umbral: $threshold',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlowWidgetsCard(PerformanceReport report) {
    final slowWidgets = report.slowestWidgets;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Widgets Más Lentos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (slowWidgets.isEmpty)
              const Text('No hay widgets lentos detectados')
            else
              ...slowWidgets.map((widget) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(widget['widget'])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget['buildTime'],
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildRebuiltWidgetsCard(PerformanceReport report) {
    final rebuiltWidgets = report.mostRebuiltWidgets;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.refresh, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Widgets Más Reconstruidos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (rebuiltWidgets.isEmpty)
              const Text('No hay reconstrucciones excesivas')
            else
              ...rebuiltWidgets.map((widget) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(widget['widget'])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget['rebuilds']}x',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard(PerformanceReport report) {
    final device = report.deviceInfo;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.devices, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Información del Dispositivo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Plataforma', device.platform),
            _buildInfoRow('Modelo', device.model),
            _buildInfoRow('Versión', device.version),
            _buildInfoRow('App Version', '${device.appVersion} (${device.buildNumber})'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_reports.isEmpty) {
      return const Center(
        child: Text('No hay datos históricos disponibles.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[_reports.length - 1 - index]; // Más reciente primero
        return _buildHistoryItem(report);
      },
    );
  }

  Widget _buildHistoryItem(PerformanceReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getScoreColor(report.performanceScore),
          child: Text(
            report.performanceScore.toStringAsFixed(0),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text('Score: ${report.performanceScore.toStringAsFixed(1)}'),
        subtitle: Text(
          'FPS: ${report.fps.toStringAsFixed(1)} | '
          'Memoria: ${(report.memoryUsage / 1024 / 1024).toStringAsFixed(1)}MB | '
          'Frames caídos: ${report.droppedFrames}',
        ),
        trailing: Text(
          '${report.timestamp.hour}:${report.timestamp.minute.toString().padLeft(2, '0')}',
        ),
        onTap: () => _showReportDetails(report),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildAnalysisTab() {
    if (_reports.isEmpty) {
      return const Center(
        child: Text('No hay suficientes datos para análisis.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisCard(
            'Tendencia de Rendimiento',
            Icons.trending_up,
            _buildPerformanceTrend(),
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            'Problemas Frecuentes',
            Icons.warning,
            _buildFrequentIssues(),
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            'Recomendaciones',
            Icons.lightbulb,
            _buildRecommendations(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String title, IconData icon, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTrend() {
    if (_reports.length < 2) {
      return const Text('Se necesitan más datos para mostrar tendencias.');
    }

    // Calcular tendencia simple
    final recent = _reports.take(10).toList();
    final avgScore = recent.map((r) => r.performanceScore).reduce((a, b) => a + b) / recent.length;
    
    return Column(
      children: [
        Text(
          'Puntaje promedio reciente: ${avgScore.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Basado en los últimos ${recent.length} reportes',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildFrequentIssues() {
    // Analizar problemas comunes
    int lowFpsCount = 0;
    int highMemoryCount = 0;
    int droppedFramesCount = 0;

    for (final report in _reports) {
      if (report.fps < 30) lowFpsCount++;
      if (report.memoryUsage > 150 * 1024 * 1024) highMemoryCount++;
      if (report.droppedFrames > 10) droppedFramesCount++;
    }

    return Column(
      children: [
        _buildIssueItem('FPS bajo', lowFpsCount, _reports.length),
        _buildIssueItem('Memoria alta', highMemoryCount, _reports.length),
        _buildIssueItem('Frames caídos', droppedFramesCount, _reports.length),
      ],
    );
  }

  Widget _buildIssueItem(String issue, int count, int total) {
    final percentage = (count / total * 100).toStringAsFixed(1);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(issue)),
          Text('$count veces ($percentage%)'),
          if (count > total * 0.3) // Más del 30% del tiempo
            const Icon(Icons.warning, color: Colors.orange, size: 20),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = <String>[];
    
    if (_reports.isNotEmpty) {
      final lastReport = _reports.last;
      
      if (lastReport.fps < 45) {
        recommendations.add('Optimizar widgets con reconstrucciones frecuentes');
      }
      
      if (lastReport.memoryUsage > 120 * 1024 * 1024) {
        recommendations.add('Implementar liberación de recursos no utilizados');
      }
      
      if (lastReport.droppedFrames > 5) {
        recommendations.add('Reducir complejidad de animaciones');
      }
      
      if (lastReport.slowestWidgets.isNotEmpty) {
        recommendations.add('Optimizar widgets más lentos identificados');
      }
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('El rendimiento es óptimo. Continuar monitoreando.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: recommendations.map((rec) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(rec)),
          ],
        ),
      )).toList(),
    );
  }

  void _showReportDetails(PerformanceReport report) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(report: report),
      ),
    );
  }

  Future<void> _exportReports() async {
    try {
      final jsonList = _reports.map((r) => r.toJson()).toList();
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);
      
      final file = File('performance_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reportes exportados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exportando reportes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Pantalla de detalles de un reporte específico
class ReportDetailScreen extends StatelessWidget {

  const ReportDetailScreen({super.key, required this.report});
  final PerformanceReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte - ${report.timestamp.toString().substring(0, 19)}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              'Métricas Principales',
              [
                _buildDetailRow('FPS', '${report.fps.toStringAsFixed(2)} fps'),
                _buildDetailRow('FPS Promedio', '${report.averageFPS.toStringAsFixed(2)} fps'),
                _buildDetailRow('Frames Caídos', report.droppedFrames.toString()),
                _buildDetailRow('Memoria Actual', '${(report.memoryUsage / 1024 / 1024).toStringAsFixed(1)} MB'),
                _buildDetailRow('Pico Memoria', '${(report.peakMemoryUsage / 1024 / 1024).toStringAsFixed(1)} MB'),
                _buildDetailRow('Score Rendimiento', '${report.performanceScore.toStringAsFixed(1)}/100'),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              'Widgets Lentos',
              report.slowestWidgets.map((w) => _buildDetailRow(w['widget'], w['buildTime'])).toList(),
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              'Widgets Reconstruidos',
              report.mostRebuiltWidgets.map((w) => _buildDetailRow(w['widget'], '${w['rebuilds']} veces')).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// Extensión para crear PerformanceReport desde JSON
extension PerformanceReportJson on PerformanceReport {
  static PerformanceReport fromJson(Map<String, dynamic> json) {
    // Implementación simplificada - en producción usar serialización completa
    return PerformanceReport(
      timestamp: DateTime.parse(json['timestamp']),
      deviceInfo: DeviceInfo(
        platform: json['deviceInfo']['platform'] ?? 'Unknown',
        version: json['deviceInfo']['version'] ?? 'Unknown',
        model: json['deviceInfo']['model'] ?? 'Unknown',
        manufacturer: json['deviceInfo']['manufacturer'] ?? 'Unknown',
        totalMemory: json['deviceInfo']['totalMemory'] ?? 0,
        appVersion: json['deviceInfo']['appVersion'] ?? 'Unknown',
        buildNumber: json['deviceInfo']['buildNumber'] ?? 'Unknown',
      ),
      fps: double.parse(json['fps']),
      averageFPS: double.parse(json['averageFPS']),
      droppedFrames: json['droppedFrames'],
      memoryUsage: json['memoryUsage'],
      peakMemoryUsage: json['peakMemoryUsage'],
      widgetBuildTimes: {},
      widgetRebuildCounts: {},
    );
  }
}