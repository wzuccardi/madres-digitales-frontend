import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/theme/app_theme.dart';
import '../utils/logger.dart';

class MediaFile {
  final String id;
  final String name;
  final String url;
  final String type;
  final int size;
  final DateTime createdAt;

  MediaFile({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'size': size,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      type: json['type'],
      size: json['size'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class MediaManagerWidget extends ConsumerStatefulWidget {
  final List<MediaFile> initialFiles;
  final Function(List<MediaFile>)? onFilesChanged;
  final bool allowMultiple;
  final List<String>? allowedTypes;
  final int? maxFileSize; // en MB

  const MediaManagerWidget({
    super.key,
    this.initialFiles = const [],
    this.onFilesChanged,
    this.allowMultiple = true,
    this.allowedTypes,
    this.maxFileSize = 50, // 50MB por defecto
  });

  @override
  ConsumerState<MediaManagerWidget> createState() => _MediaManagerWidgetState();
}

class _MediaManagerWidgetState extends ConsumerState<MediaManagerWidget> {
  List<MediaFile> _files = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _files = List.from(widget.initialFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.perm_media, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Gestión de Archivos Multimedia',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (widget.allowMultiple)
                  Text(
                    '${_files.length} archivo(s)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _seleccionarArchivo,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file),
                    label: Text(_isUploading ? 'Subiendo...' : 'Subir Archivo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (widget.allowMultiple) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _seleccionarMultiplesArchivos,
                    icon: const Icon(Icons.upload),
                    label: const Text('Subir Múltiples'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _agregarDesdeUrl,
                  icon: const Icon(Icons.link),
                  label: const Text('Agregar URL'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Lista de archivos
            if (_files.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Archivos cargados:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._files.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                return _buildFileItem(file, index);
              }),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No hay archivos cargados',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sube archivos o agrega URLs para comenzar',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(MediaFile file, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getFileColor(file.type),
          child: Icon(
            _getFileIcon(file.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          file.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${file.type.toUpperCase()} • ${_formatFileSize(file.size)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              'Cargado: ${_formatDate(file.createdAt)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'preview':
                _abrirArchivo(file);
                break;
              case 'copy':
                _copiarUrl(file);
                break;
              case 'download':
                _descargarArchivo(file);
                break;
              case 'delete':
                _eliminarArchivo(index);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'preview',
              child: Row(
                children: [
                  Icon(Icons.preview, size: 20),
                  SizedBox(width: 8),
                  Text('Vista previa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'copy',
              child: Row(
                children: [
                  Icon(Icons.copy, size: 20),
                  SizedBox(width: 8),
                  Text('Copiar URL'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download, size: 20),
                  SizedBox(width: 8),
                  Text('Descargar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarArchivo() async {
    await _seleccionarArchivos(allowMultiple: false);
  }

  Future<void> _seleccionarMultiplesArchivos() async {
    await _seleccionarArchivos(allowMultiple: true);
  }

  Future<void> _seleccionarArchivos({required bool allowMultiple}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _getAllowedExtensions(),
        allowMultiple: allowMultiple,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _isUploading = true;
        });

        try {
          for (final file in result.files) {
            // Validar tamaño del archivo
            if (widget.maxFileSize != null) {
              final fileSizeMB = file.size / (1024 * 1024);
              if (fileSizeMB > widget.maxFileSize!) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ El archivo ${file.name} excede el tamaño máximo de ${widget.maxFileSize}MB'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                continue;
              }
            }

            // Simular subida (en una app real, aquí subirías a un servidor)
            await Future.delayed(const Duration(seconds: 1));
            
            final mediaFile = MediaFile(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: file.name,
              url: 'https://ejemplo.com/uploads/${file.name}', // URL simulada
              type: _getFileType(file.extension ?? ''),
              size: file.size,
              createdAt: DateTime.now(),
            );

            setState(() {
              _files.add(mediaFile);
            });
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${result.files.length} archivo(s) subido(s) exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          }

          widget.onFilesChanged?.call(_files);
        } catch (e) {
          appLogger.error('Error subiendo archivos', error: e);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error al subir archivos: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          setState(() {
            _isUploading = false;
          });
        }
      }
    } catch (e) {
      appLogger.error('Error seleccionando archivos', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al seleccionar archivos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _agregarDesdeUrl() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar archivo desde URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'URL del archivo',
            hintText: 'https://ejemplo.com/archivo.pdf',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        final fileName = uri.pathSegments.isNotEmpty 
            ? uri.pathSegments.last 
            : 'archivo_${DateTime.now().millisecondsSinceEpoch}';

        final mediaFile = MediaFile(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: fileName,
          url: url,
          type: _getFileTypeFromUrl(fileName),
          size: 0, // Tamaño desconocido para URLs
          createdAt: DateTime.now(),
        );

        setState(() {
          _files.add(mediaFile);
        });

        widget.onFilesChanged?.call(_files);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ URL agregada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al agregar URL: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _abrirArchivo(MediaFile file) async {
    try {
      final uri = Uri.parse(file.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No se puede abrir el archivo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al abrir archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copiarUrl(MediaFile file) {
    // Aquí deberías copiar al portapapeles
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📋 URL copiada: ${file.url}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _descargarArchivo(MediaFile file) async {
    try {
      final uri = Uri.parse(file.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al descargar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _eliminarArchivo(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar archivo'),
        content: Text('¿Estás seguro de que deseas eliminar "${_files[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _files.removeAt(index);
              });
              widget.onFilesChanged?.call(_files);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Archivo eliminado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<String> _getAllowedExtensions() {
    if (widget.allowedTypes != null) {
      return widget.allowedTypes!;
    }
    
    // Extensiones permitidas por defecto
    return [
      'jpg', 'jpeg', 'png', 'gif', 'webp', // Imágenes
      'mp4', 'avi', 'mov', 'wmv', // Videos
      'mp3', 'wav', 'ogg', 'aac', // Audios
      'pdf', 'doc', 'docx', 'ppt', 'pptx', // Documentos
    ];
  }

  String _getFileType(String extension) {
    extension = extension.toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'avi', 'mov', 'wmv'].contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav', 'ogg', 'aac'].contains(extension)) {
      return 'audio';
    } else if (['pdf', 'doc', 'docx', 'ppt', 'pptx'].contains(extension)) {
      return 'document';
    }
    
    return 'other';
  }

  String _getFileTypeFromUrl(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return _getFileType(extension);
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      case 'document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String type) {
    switch (type) {
      case 'image':
        return Colors.green;
      case 'video':
        return Colors.blue;
      case 'audio':
        return Colors.purple;
      case 'document':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}