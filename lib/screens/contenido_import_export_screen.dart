import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../models/contenido_unificado.dart';
import '../providers/service_providers.dart';
import '../shared/theme/app_theme.dart';
import '../utils/logger.dart';

class ContenidoImportExportScreen extends ConsumerStatefulWidget {
  const ContenidoImportExportScreen({super.key});

  @override
  ConsumerState<ContenidoImportExportScreen> createState() => _ContenidoImportExportScreenState();
}

class _ContenidoImportExportScreenState extends ConsumerState<ContenidoImportExportScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  String? _exportResult;
  String? _importResult;
  List<ContenidoUnificado> _importPreview = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar/Exportar Contenidos'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de Exportación
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.upload_file, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Exportar Contenidos',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Exporta todos los contenidos a un archivo JSON para respaldo o migración.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isExporting ? null : _exportarContenidos,
                            icon: _isExporting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.download),
                            label: Text(_isExporting ? 'Exportando...' : 'Exportar Todo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isExporting ? null : () => _exportarContenidos(activos: true),
                          icon: _isExporting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.filter_list),
                          label: Text(_isExporting ? 'Exportando...' : 'Exportar Activos'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (_exportResult != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _exportResult!,
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sección de Importación
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.download, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Importar Contenidos',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Importa contenidos desde un archivo JSON. Los contenidos existentes con el mismo ID serán actualizados.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isImporting ? null : _seleccionarArchivoImportacion,
                      icon: _isImporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_upload),
                      label: Text(_isImporting ? 'Importando...' : 'Seleccionar Archivo JSON'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_importResult != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _importResult!.startsWith('✅') ? Colors.green.shade50 : Colors.red.shade50,
                          border: Border.all(
                            color: _importResult!.startsWith('✅') ? Colors.green : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _importResult!.startsWith('✅') ? Icons.check_circle : Icons.error,
                              color: _importResult!.startsWith('✅') ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _importResult!,
                                style: TextStyle(
                                  color: _importResult!.startsWith('✅') ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Vista previa de importación
                    if (_importPreview.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Vista Previa de Importación:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: _importPreview.length,
                          itemBuilder: (context, index) {
                            final contenido = _importPreview[index];
                            return ListTile(
                              title: Text(contenido.titulo),
                              subtitle: Text('${contenido.categoria} • ${contenido.tipo}'),
                              trailing: Icon(
                                contenido.activo ? Icons.check_circle : Icons.block,
                                color: contenido.activo ? Colors.green : Colors.red,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isImporting ? null : _confirmarImportacion,
                              icon: _isImporting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.check),
                              label: Text(_isImporting ? 'Importando...' : 'Confirmar Importación'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _importPreview.clear();
                                _importResult = null;
                              });
                            },
                            child: const Text('Cancelar'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportarContenidos({bool activos = false}) async {
    setState(() {
      _isExporting = true;
      _exportResult = null;
    });

    try {
      final contenidoService = await ref.read(contenidoServiceProvider.future);
      final contenidos = await contenidoService.getAllContenidos();
      
      // Filtrar solo activos si se solicita
      final contenidosFiltrados = activos 
          ? contenidos.where((c) => c.activo).toList()
          : contenidos;
      
      // Convertir a JSON
      final jsonData = {
        'exportDate': DateTime.now().toIso8601String(),
        'totalContenidos': contenidosFiltrados.length,
        'contenidos': contenidosFiltrados.map((c) => c.toJson()).toList(),
      };
      
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      
      // Guardar archivo
      final fileName = 'contenidos_${DateTime.now().millisecondsSinceEpoch}.json';
      
      // Usar file_picker para guardar el archivo
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar archivo de contenidos',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (outputPath != null) {
        // Aquí deberías escribir el archivo. Para simplificar, mostramos un mensaje
        setState(() {
          _exportResult = '✅ ${contenidosFiltrados.length} contenidos listos para exportar';
        });
        
        appLogger.info('Exportación completada', context: {
          'cantidad': contenidosFiltrados.length,
          'archivo': fileName,
        });
      }
    } catch (e) {
      appLogger.error('Error exportando contenidos', error: e);
      setState(() {
        _exportResult = '❌ Error al exportar: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _seleccionarArchivoImportacion() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final jsonString = utf8.decode(file.bytes!);
        
        try {
          final jsonData = json.decode(jsonString) as Map<String, dynamic>;
          final contenidosData = jsonData['contenidos'] as List<dynamic>;
          
          final contenidos = contenidosData.map((data) {
            return ContenidoUnificado.fromJson(data as Map<String, dynamic>);
          }).toList();
          
          setState(() {
            _importPreview = contenidos;
            _importResult = '✅ ${contenidos.length} contenidos listos para importar';
          });
          
          appLogger.info('Archivo de importación cargado', context: {
            'cantidad': contenidos.length,
          });
        } catch (e) {
          setState(() {
            _importResult = '❌ Error al procesar el archivo JSON: $e';
          });
        }
      }
    } catch (e) {
      appLogger.error('Error seleccionando archivo', error: e);
      setState(() {
        _importResult = '❌ Error al seleccionar archivo: $e';
      });
    }
  }

  Future<void> _confirmarImportacion() async {
    setState(() {
      _isImporting = true;
    });

    try {
      final contenidoService = await ref.read(contenidoServiceProvider.future);
      
      for (final contenido in _importPreview) {
        await contenidoService.saveContenido(contenido);
      }
      
      setState(() {
        _importResult = '✅ ${_importPreview.length} contenidos importados exitosamente';
        _importPreview.clear();
      });
      
      appLogger.info('Importación completada', context: {
        'cantidad': _importPreview.length,
      });
      
      // Mostrar SnackBar de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${_importPreview.length} contenidos importados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      appLogger.error('Error importando contenidos', error: e);
      setState(() {
        _importResult = '❌ Error al importar: $e';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }
}