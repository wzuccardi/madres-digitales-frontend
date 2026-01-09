import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/reportes_service.dart';
import '../../models/reporte_model.dart';

class DashboardReportesPage extends ConsumerStatefulWidget {
  const DashboardReportesPage({super.key});

  @override
  ConsumerState<DashboardReportesPage> createState() => _DashboardReportesPageState();
}

class _DashboardReportesPageState extends ConsumerState<DashboardReportesPage> {
  String? selectedMunicipioId;
  String? selectedMadrinaId;
  DateTime? fechaInicio;
  DateTime? fechaFin;
  bool isLoading = false;
  ReporteCompleto? reporte;
  List<Municipio> municipios = [];
  List<Madrina> madrinas = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() => isLoading = true);
    try {
      final reportesService = ReportesService();
      municipios = await reportesService.obtenerMunicipios();
      await _generarReporte();
    } catch (e) {
      _mostrarError('Error cargando datos: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _cargarMadrinas() async {
    if (selectedMunicipioId == null) {
      setState(() => madrinas = []);
      return;
    }

    try {
      final reportesService = ReportesService();
      madrinas = await reportesService.obtenerMadrinas(selectedMunicipioId);
      setState(() {});
    } catch (e) {
      _mostrarError('Error cargando madrinas: $e');
    }
  }

  Future<void> _generarReporte() async {
    setState(() => isLoading = true);
    try {
      final reportesService = ReportesService();
      reporte = await reportesService.generarReporte(
        municipioId: selectedMunicipioId,
        madrinaId: selectedMadrinaId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      setState(() {});
    } catch (e) {
      _mostrarError('Error generando reporte: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _descargarReporte(String formato) async {
    if (reporte == null) {
      _mostrarError('No hay reporte generado para descargar');
      return;
    }

    try {
      final reportesService = ReportesService();
      await reportesService.descargarReporte(
        formato: formato,
        municipioId: selectedMunicipioId,
        madrinaId: selectedMadrinaId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Descarga de $formato iniciada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _mostrarError('Error descargando reporte: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Reportes'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFiltros(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : reporte == null
                    ? const Center(child: Text('No hay datos disponibles'))
                    : _buildReporte(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedMunicipioId,
                  decoration: const InputDecoration(
                    labelText: 'Municipio',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todos los municipios'),
                    ),
                    ...municipios.map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.nombre),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMunicipioId = value;
                      selectedMadrinaId = null;
                    });
                    _cargarMadrinas();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedMadrinaId,
                  decoration: const InputDecoration(
                    labelText: 'Madrina',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todas las madrinas'),
                    ),
                    ...madrinas.map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.nombre),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() => selectedMadrinaId = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Fecha inicio',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: fechaInicio ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (fecha != null) {
                      setState(() => fechaInicio = fecha);
                    }
                  },
                  controller: TextEditingController(
                    text: fechaInicio?.toString().split(' ')[0] ?? '',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Fecha fin',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: fechaFin ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (fecha != null) {
                      setState(() => fechaFin = fecha);
                    }
                  },
                  controller: TextEditingController(
                    text: fechaFin?.toString().split(' ')[0] ?? '',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _generarReporte,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Generar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: reporte != null ? () => _descargarReporte('pdf') : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.picture_as_pdf, size: 16),
                label: const Text('PDF'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: reporte != null ? () => _descargarReporte('excel') : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.table_chart, size: 16),
                label: const Text('Excel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReporte() {
    if (reporte == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResumen(),
          const SizedBox(height: 24),
          _buildIndicadoresPorcentaje(),
          const SizedBox(height: 24),
          _buildIndicadoresNumericos(),
        ],
      ),
    );
  }

  Widget _buildResumen() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen General',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Gestantes',
                    reporte!.totalGestantes.toString(),
                    Icons.pregnant_woman,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Fecha Generación',
                    reporte!.fechaGeneracion.toString().split(' ')[0],
                    Icons.calendar_today,
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicadoresPorcentaje() {
    final indicadoresPorcentaje = reporte!.indicadores
        .where((i) => i.tipo == 'porcentaje')
        .toList();

    if (indicadoresPorcentaje.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Indicadores de Calidad (%)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...indicadoresPorcentaje.map((indicador) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildIndicadorPorcentaje(indicador),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicadorPorcentaje(IndicadorReporte indicador) {
    final porcentaje = indicador.porcentaje.clamp(0.0, 100.0);
    final color = _getColorPorcentaje(porcentaje);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                indicador.nombre,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              '${indicador.valor}/${indicador.total} (${porcentaje.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: porcentaje / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildIndicadoresNumericos() {
    final indicadoresNumericos = reporte!.indicadores
        .where((i) => i.tipo == 'numero')
        .toList();

    if (indicadoresNumericos.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Indicadores Demográficos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: indicadoresNumericos.length,
              itemBuilder: (context, index) {
                final indicador = indicadoresNumericos[index];
                return _buildIndicadorNumerico(indicador);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicadorNumerico(IndicadorReporte indicador) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            indicador.valor.toString(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            indicador.nombre,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getColorPorcentaje(double porcentaje) {
    if (porcentaje >= 80) return Colors.green;
    if (porcentaje >= 60) return Colors.orange;
    return Colors.red;
  }
}