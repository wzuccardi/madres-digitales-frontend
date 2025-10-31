import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../providers/service_providers.dart';

class ReportesListPage extends ConsumerStatefulWidget {
  const ReportesListPage({super.key});
  @override
  ConsumerState<ReportesListPage> createState() => _ReportesListPageState();
}

class _ReportesListPageState extends ConsumerState<ReportesListPage> {
  List<dynamic> reportes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchReportes();
  }

  Future<void> fetchReportes() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/reportes');
      
      // Manejar diferentes tipos de respuesta
      dynamic responseData = response.data;
      List<dynamic> reportesList = [];
      
      if (responseData is List) {
        // Si ya es una lista, usarla directamente
        reportesList = responseData;
      } else if (responseData is Map<String, dynamic>) {
        // Si es un mapa, buscar la lista en diferentes claves posibles
        if (responseData['data'] != null && responseData['data'] is List) {
          reportesList = responseData['data'];
        } else if (responseData['reportes'] != null && responseData['reportes'] is List) {
          reportesList = responseData['reportes'];
        } else if (responseData['items'] != null && responseData['items'] is List) {
          reportesList = responseData['items'];
        } else {
          // Si no encuentra una lista, mostrar el error
          throw Exception('Formato de respuesta no reconocido: ${responseData.keys}');
        }
      } else {
        throw Exception('Tipo de respuesta no esperado: ${responseData.runtimeType}');
      }
      
      setState(() {
        reportes = reportesList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar reportes: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    
    // Si la URL es un endpoint relativo, convertirla a URL de descarga pÃºblica
    if (url.startsWith('/api/reportes/')) {
      url = url.replaceAll('/api/reportes/', 'http://localhost:54112/api/reportes/descargar/');
    } else if (url.startsWith('/api/')) {
      url = url.replaceAll('/api/', 'http://localhost:54112/api/');
    }
    
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: reportes.length,
                  itemBuilder: (context, index) {
                    final reporte = reportes[index];
                    return ListTile(
                      title: Text(reporte['titulo'] ?? 'Sin tÃ­tulo'),
                      subtitle: Text(reporte['fecha'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () async {
                          final url = reporte['url'];
                          if (url != null) {
                            await _launchUrl(url);
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

