import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/logger.dart' show appLogger;
import '../../services/api_service.dart';

class PdfViewerWidget extends StatefulWidget {
  final String pdfPath; // Puede ser URL o path local
  final bool isLocal;
  final String? title;

  const PdfViewerWidget({
    super.key,
    required this.pdfPath,
    this.isLocal = false,
    this.title,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  String? _localPath;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  final int _currentPage = 0;
  final int _totalPages = 0;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      if (widget.isLocal) {
        // Ya es un archivo local
        setState(() {
          _localPath = widget.pdfPath;
          _isLoading = false;
        });
      } else {
        // Descargar PDF desde URL
        await _downloadPdf();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
      appLogger.error('Error cargando PDF: $e');
    }
  }

  Future<void> _downloadPdf() async {
    try {
      final dir = await getTemporaryDirectory();
      final fileName = 'temp_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${dir.path}/$fileName';

      final dio = Dio();
      // Configurar headers de autenticación si es necesario
      final apiService = ApiService();
      final token = await apiService.getToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      await dio.download(
        widget.pdfPath,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        _localPath = filePath;
        _isLoading = false;
      });

      appLogger.info('PDF descargado: $filePath');
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error descargando PDF: $e';
        _isLoading = false;
      });
      appLogger.error('Error descargando PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Documento PDF'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Error al cargar el PDF',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'Error desconocido',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _errorMessage = null;
                      _isLoading = true;
                    });
                    _loadPdf();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Documento PDF'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                widget.isLocal
                    ? 'Cargando PDF...'
                    : 'Descargando PDF...',
              ),
              if (!widget.isLocal && _downloadProgress > 0) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    value: _downloadProgress,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Documento PDF'),
        actions: [
          // Indicador de página
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '$_currentPage / $_totalPages',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: _localPath != null
          ? _buildPdfViewer()
          : const Center(
              child: Text('No se pudo cargar el PDF'),
            ),
    );
  }

  @override
  void dispose() {
    // Limpiar archivo temporal si no es local
    if (!widget.isLocal && _localPath != null) {
      try {
        final file = File(_localPath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        appLogger.error('Error eliminando archivo temporal: $e');
      }
    }
    super.dispose();
  }

  Widget _buildPdfViewer() {
    // En lugar de usar flutter_pdfview que no está disponible,
    // mostramos un mensaje con opciones para abrir el PDF
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 100,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'Visor de PDF',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'El visor de PDF no está disponible en esta versión. '
              'Puedes abrir el PDF en una aplicación externa.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            if (widget.isLocal) ...[
              ElevatedButton.icon(
                onPressed: () => _openPdfExternally(_localPath!),
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Abrir PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () => _openPdfExternally(widget.pdfPath),
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Abrir PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _downloadAndOpen,
                icon: const Icon(Icons.download),
                label: const Text('Descargar y abrir'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openPdfExternally(String path) async {
    try {
      final uri = Uri.parse(path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'No se puede abrir el PDF en esta plataforma';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error al abrir PDF: $e';
      });
      appLogger.error('Error abriendo PDF externamente: $e');
    }
  }

  Future<void> _downloadAndOpen() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final dir = await getTemporaryDirectory();
      final fileName = 'temp_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${dir.path}/$fileName';

      final dio = Dio();
      // Configurar headers de autenticación si es necesario
      final apiService = ApiService();
      final token = await apiService.getToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      await dio.download(
        widget.pdfPath,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        _isLoading = false;
      });

      await _openPdfExternally(filePath);
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error descargando PDF: $e';
        _isLoading = false;
      });
      appLogger.error('Error descargando PDF: $e');
    }
  }
}

/// Widget simplificado para mostrar miniatura de PDF
class PdfThumbnailWidget extends StatelessWidget {
  final String? thumbnailUrl;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final int? pageCount;

  const PdfThumbnailWidget({
    super.key,
    this.thumbnailUrl,
    this.onTap,
    this.width,
    this.height,
    this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Miniatura o placeholder
            if (thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
                ),
              )
            else
              _buildPlaceholder(),
            
            // Badge con número de páginas
            if (pageCount != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pageCount páginas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            // Icono de PDF
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  size: 32,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.description,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }
}

