import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/reportes_service.dart';
import '../widgets/reporte_card.dart';
import '../providers/service_providers.dart';

class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen> {
  late ReportesService _reportesService;
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? resumenGeneral;
  Map<String, dynamic>? reporteMensual;
  int selectedMes = DateTime.now().month;
  int selectedAnio = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() {
    final apiService = ref.read(apiServiceProvider);
    _reportesService = ReportesService(apiService.dioInstance);
    _loadReportes();
  }

  Future<void> _loadReportes() async {
    try {
      setState(() => isLoading = true);

      final resumen = await _reportesService.getResumenGeneral();
      final mensual = await _reportesService.getReporteMensual(
        mes: selectedMes,
        anio: selectedAnio,
      );

      setState(() {
        resumenGeneral = resumen;
        reporteMensual = mensual;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar reportes: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportes,
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
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReportes,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Selector de período
                      _buildPeriodoSelector(),
                      // Resumen general
                      if (resumenGeneral != null) _buildResumenGeneral(),
                      // Reporte mensual
                      if (reporteMensual != null) _buildReporteMensual(),
                      // Reportes disponibles
                      _buildReportesDisponibles(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPeriodoSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<int>(
              value: selectedMes,
              isExpanded: true,
              items: List.generate(12, (i) => i + 1)
                  .map((mes) => DropdownMenuItem(
                        value: mes,
                        child: Text('Mes $mes'),
                      ))
                  .toList(),
              onChanged: (mes) {
                if (mes != null) {
                  setState(() => selectedMes = mes);
                  _loadReportes();
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<int>(
              value: selectedAnio,
              isExpanded: true,
              items: List.generate(5, (i) => DateTime.now().year - i)
                  .map((anio) => DropdownMenuItem(
                        value: anio,
                        child: Text('Año $anio'),
                      ))
                  .toList(),
              onChanged: (anio) {
                if (anio != null) {
                  setState(() => selectedAnio = anio);
                  _loadReportes();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenGeneral() {
    final data = resumenGeneral!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen General',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Gestantes',
                data['total_gestantes']?.toString() ?? '0',
                Colors.pink,
                Icons.pregnant_woman,
              ),
              _buildStatCard(
                'Controles',
                data['total_controles']?.toString() ?? '0',
                Colors.blue,
                Icons.assignment,
              ),
              _buildStatCard(
                'Alertas Activas',
                data['total_alertas_activas']?.toString() ?? '0',
                Colors.orange,
                Icons.warning,
              ),
              _buildStatCard(
                'Alto Riesgo',
                data['gestantes_alto_riesgo']?.toString() ?? '0',
                Colors.red,
                Icons.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReporteMensual() {
    final data = reporteMensual!;
    return ReporteCard(
      titulo: 'Reporte Mensual',
      descripcion: 'Consolidado del mes ${data['periodo'] ?? 'actual'}',
      icono: Icons.calendar_month,
      color: Colors.purple,
      onTap: () {},
      datos: {
        'Gestantes Activas': data['gestantes']?['activas'] ?? 0,
        'Gestantes Nuevas': data['gestantes']?['nuevas'] ?? 0,
        'Controles Realizados': data['controles']?['realizados'] ?? 0,
        'Alertas Generadas': data['alertas']?['generadas'] ?? 0,
      },
    );
  }

  Widget _buildReportesDisponibles() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reportes Disponibles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ReporteCard(
            titulo: 'Estadísticas de Gestantes',
            descripcion: 'Análisis detallado de gestantes por municipio',
            icono: Icons.people,
            color: Colors.pink,
            onTap: () {},
          ),
          ReporteCard(
            titulo: 'Estadísticas de Controles',
            descripcion: 'Controles prenatales realizados',
            icono: Icons.assignment_turned_in,
            color: Colors.blue,
            onTap: () {},
          ),
          ReporteCard(
            titulo: 'Estadísticas de Alertas',
            descripcion: 'Alertas generadas y resueltas',
            icono: Icons.notifications_active,
            color: Colors.orange,
            onTap: () {},
          ),
          ReporteCard(
            titulo: 'Reporte Anual',
            descripcion: 'Consolidado del año $selectedAnio',
            icono: Icons.calendar_today,
            color: Colors.green,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String titulo,
    String valor,
    Color color,
    IconData icono,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}

