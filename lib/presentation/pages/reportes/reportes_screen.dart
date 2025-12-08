import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/data/services/reportes_service.dart';
import '../widgets/reporte_card.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html show Blob, Url, AnchorElement, document;

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
    _reportesService = ReportesService.fromApiService(apiService);
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
      final tieneMensual = mensual.isNotEmpty;
      final tieneResumen = resumen.isNotEmpty;
      setState(() {
        resumenGeneral = tieneResumen ? resumen : null;
        reporteMensual = tieneMensual ? mensual : null;
        errorMessage = null;
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
      body: Column(
        children: [
          Expanded(
            child: isLoading
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
                              _buildPeriodoSelector(),
                              if (resumenGeneral != null) _buildResumenGeneral(),
                              if (reporteMensual != null) _buildReporteMensual(),
                              _buildReportesDisponibles(),
                            ],
                          ),
                        ),
          ),
        ],
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
                'Gestantes Activas',
                data['gestantes_activas']?.toString() ?? '0',
                Colors.pink,
                Icons.pregnant_woman,
              ),
              _buildStatCard(
                'Nuevas (Este Mes)',
                data['gestantes_nuevas']?.toString() ?? '0',
                Colors.purple,
                Icons.person_add,
              ),
              _buildStatCard(
                'Controles Realizados',
                data['controles_realizados']?.toString() ?? '0',
                Colors.green,
                Icons.check_circle,
              ),
              _buildStatCard(
                'Controles Pendientes',
                data['controles_pendientes']?.toString() ?? '0',
                Colors.blue,
                Icons.pending,
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
          _buildReporteCardWithDownload(
            titulo: 'Resumen General',
            descripcion: 'Resumen completo del sistema',
            icono: Icons.dashboard,
            color: Colors.purple,
            endpoint: 'resumen-general',
          ),
          _buildReporteCardWithDownload(
            titulo: 'Estadísticas de Gestantes',
            descripcion: 'Análisis detallado de gestantes por municipio',
            icono: Icons.people,
            color: Colors.pink,
            endpoint: 'estadisticas-gestantes',
          ),
          _buildReporteCardWithDownload(
            titulo: 'Estadísticas de Controles',
            descripcion: 'Controles prenatales realizados',
            icono: Icons.assignment_turned_in,
            color: Colors.blue,
            endpoint: 'estadisticas-controles',
          ),
          _buildReporteCardWithDownload(
            titulo: 'Estadísticas de Alertas',
            descripcion: 'Alertas generadas y resueltas',
            icono: Icons.notifications_active,
            color: Colors.orange,
            endpoint: 'estadisticas-alertas',
          ),

        ],
      ),
    );
  }

  Widget _buildReporteCardWithDownload({
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color color,
    required String endpoint,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icono, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          descripcion,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _descargarReporte(endpoint, 'pdf'),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _descargarReporte(endpoint, 'excel'),
                    icon: const Icon(Icons.table_chart, size: 18),
                    label: const Text('Excel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _descargarReporte(String endpoint, String formato) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Descargando reporte en $formato...'),
          duration: const Duration(seconds: 2),
        ),
      );

      List<int> bytes;
      String fileName;
      String mimeType;

      if (formato == 'pdf') {
        bytes = await _reportesService.descargarPDF(endpoint);
        fileName = '${endpoint}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        mimeType = 'application/pdf';
      } else {
        bytes = await _reportesService.descargarExcel(endpoint);
        fileName = '${endpoint}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      }

      if (kIsWeb) {
        // En web, usar descarga directa
        _descargarArchivoWeb(bytes, fileName, mimeType);
      } else {
        // En móvil, guardar y compartir
        await _guardarYCompartirArchivo(bytes, fileName);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reporte descargado exitosamente'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar: El servidor aún no tiene implementada la generación de reportes en $formato. Por favor contacte al administrador.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _descargarArchivoWeb(List<int> bytes, String fileName, String mimeType) {
    // Implementación para web usando universal_html
    try {
      // Crear blob con los bytes
      final blob = html.Blob([bytes], mimeType);
      
      // Crear URL del blob
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Crear elemento anchor para descargar
      final anchor = html.document.createElement('a') as html.AnchorElement;
      anchor.href = url;
      anchor.download = fileName;
      anchor.style.display = 'none';
      
      // Agregar al DOM, hacer click y remover
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      
      // Liberar URL del blob
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar archivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _guardarYCompartirArchivo(List<int> bytes, String fileName) async {
    try {
      // Solicitar permisos de almacenamiento
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Permiso de almacenamiento denegado');
        }
      }

      // Obtener directorio de descargas
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('No se pudo acceder al directorio de descargas');
      }

      // Crear archivo
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Compartir archivo
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Reporte generado desde Madres Digitales',
      );
    } catch (e) {
      throw Exception('Error al guardar archivo: $e');
    }
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
}

