import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/reportes_service.dart';
import '../widgets/reporte_chart.dart';
import '../providers/service_providers.dart';

class ReportesDetalleScreen extends ConsumerStatefulWidget {
  final String tipoReporte;
  final int? mes;
  final int? anio;

  const ReportesDetalleScreen({
    super.key,
    required this.tipoReporte,
    this.mes,
    this.anio,
  });

  @override
  ConsumerState<ReportesDetalleScreen> createState() =>
      _ReportesDetalleScreenState();
}

class _ReportesDetalleScreenState extends ConsumerState<ReportesDetalleScreen> {
  late ReportesService _reportesService;
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? reporteData;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() {
    final apiService = ref.read(apiServiceProvider);
    _reportesService = ReportesService(apiService.dioInstance);
    _loadReporte();
  }

  Future<void> _loadReporte() async {
    try {
      setState(() => isLoading = true);

      Map<String, dynamic> data;
      switch (widget.tipoReporte) {
        case 'mensual':
          data = await _reportesService.getReporteMensual(
            mes: widget.mes,
            anio: widget.anio,
          );
          break;
        case 'anual':
          data = await _reportesService.getReporteAnual(
            anio: widget.anio,
          );
          break;
        case 'gestantes':
          data = await _reportesService.getEstadisticasGestantes();
          break;
        default:
          data = {};
      }

      setState(() {
        reporteData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar reporte: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitulo()),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReporte,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _descargarReporte(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReporte,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      if (reporteData != null) ...[
                        _buildResumenSection(),
                        _buildGraficosSection(),
                        _buildDetallesSection(),
                      ],
                    ],
                  ),
                ),
    );
  }

  String _getTitulo() {
    switch (widget.tipoReporte) {
      case 'mensual':
        return 'Reporte Mensual';
      case 'anual':
        return 'Reporte Anual';
      case 'gestantes':
        return 'Estadísticas de Gestantes';
      default:
        return 'Reporte';
    }
  }

  Widget _buildResumenSection() {
    final data = reporteData!;
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildStatItem('Gestantes', data['total_gestantes'] ?? 0),
              _buildStatItem('Controles', data['total_controles'] ?? 0),
              _buildStatItem('Alertas', data['total_alertas'] ?? 0),
              _buildStatItem('Alto Riesgo', data['alto_riesgo'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String titulo, dynamic valor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              valor.toString(),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficosSection() {
    final data = reporteData!;
    final chartData = <ChartData>[
      ChartData(
        label: 'Gestantes',
        valor: (data['total_gestantes'] ?? 0).toDouble(),
        color: Colors.pink,
      ),
      ChartData(
        label: 'Controles',
        valor: (data['total_controles'] ?? 0).toDouble(),
        color: Colors.blue,
      ),
      ChartData(
        label: 'Alertas',
        valor: (data['total_alertas'] ?? 0).toDouble(),
        color: Colors.orange,
      ),
    ];

    return Column(
      children: [
        ReporteChart(
          titulo: 'Distribución de Actividades',
          datos: chartData,
          tipo: ChartType.bar,
        ),
        ReporteChart(
          titulo: 'Proporción de Casos',
          datos: chartData,
          tipo: ChartType.pie,
        ),
      ],
    );
  }

  Widget _buildDetallesSection() {
    final data = reporteData!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: data.entries
                    .map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _descargarReporte() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Descarga iniciada...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

