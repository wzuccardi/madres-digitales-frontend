import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/services/file_service.dart';

enum ContenidoFileType {
  image,
  video,
  audio,
  document,
}

class FilePickerWidget extends ConsumerStatefulWidget {
  final ContenidoFileType fileType;
  final String? initialUrl;
  final Function(String url) onFileSelected;
  final bool enabled;
  final String? labelText;
  final String? hintText;
  final double? maxHeight;
  final int? maxSizeBytes;

  const FilePickerWidget({
    super.key,
    required this.fileType,
    this.initialUrl,
    required this.onFileSelected,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.maxHeight,
    this.maxSizeBytes,
  });

  @override
  ConsumerState<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends ConsumerState<FilePickerWidget> {
  final TextEditingController _urlController = TextEditingController();
  File? _selectedFile;
  bool _isUploading = false;
  String? _errorMessage;
  String? _fileUrl;

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.initialUrl ?? '';
    _fileUrl = widget.initialUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    if (!widget.enabled) return;

    setState(() {
      _errorMessage = null;
    });

    File? file;
    
    try {
      switch (widget.fileType) {
        case ContenidoFileType.image:
          final picker = ImagePicker();
          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
          if (pickedFile != null) {
            file = File(pickedFile.path);
          }
          break;
        case ContenidoFileType.video:
          final picker = ImagePicker();
          final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
          if (pickedFile != null) {
            file = File(pickedFile.path);
          }
          break;
        case ContenidoFileType.audio:
        case ContenidoFileType.document:
          final result = await FilePicker.platform.pickFiles(
            type: widget.fileType == ContenidoFileType.document
                ? FileType.custom
                : FileType.custom,
            allowedExtensions: widget.fileType == ContenidoFileType.document
                ? ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt', 'csv']
                : widget.fileType == ContenidoFileType.audio
                    ? ['mp3', 'wav', 'ogg', 'm4a', 'webm']
                    : [],
          );
          if (result != null && result.files.single.path != null) {
            file = File(result.files.single.path!);
          }
          break;
      }

      if (file != null) {
        _validateAndUploadFile(file);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al seleccionar archivo: ${e.toString()}';
      });
    }
  }

  void _validateAndUploadFile(File file) {
    // Validar archivo según el tipo
    FileValidationResult validation;
    
    switch (widget.fileType) {
      case ContenidoFileType.image:
        validation = FileService.validateImage(file, maxSizeBytes: widget.maxSizeBytes);
        break;
      case ContenidoFileType.video:
        validation = FileService.validateVideo(file, maxSizeBytes: widget.maxSizeBytes);
        break;
      case ContenidoFileType.audio:
        validation = FileService.validateAudio(file, maxSizeBytes: widget.maxSizeBytes);
        break;
      case ContenidoFileType.document:
        validation = FileService.validateDocument(file, maxSizeBytes: widget.maxSizeBytes);
        break;
    }

    if (!validation.isValid) {
      setState(() {
        _errorMessage = validation.errorMessage;
      });
      return;
    }

    setState(() {
      _selectedFile = file;
      _errorMessage = null;
    });

    // Subir archivo
    _uploadFile(file);
  }

  Future<void> _uploadFile(File file) async {
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final result = await FileService.uploadFile(
        file,
        additionalFields: {
          'type': widget.fileType.name,
        },
      );

      if (result.success && result.fileUrl != null) {
        setState(() {
          _fileUrl = result.fileUrl;
          _urlController.text = result.fileUrl!;
          _isUploading = false;
        });
        
        widget.onFileSelected(result.fileUrl!);
      } else {
        setState(() {
          _errorMessage = result.errorMessage ?? 'Error desconocido al subir el archivo';
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al subir archivo: ${e.toString()}';
        _isUploading = false;
      });
    }
  }

  void _onUrlChanged(String value) {
    setState(() {
      _fileUrl = value.isEmpty ? null : value;
    });
    widget.onFileSelected(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.labelText!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        
        // Vista previa del archivo
        if (_fileUrl != null || _selectedFile != null)
          _buildFilePreview(),
        
        const SizedBox(height: 8),
        
        // Campo de URL
        TextFormField(
          controller: _urlController,
          enabled: widget.enabled && !_isUploading,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Ingrese la URL del archivo',
            border: const OutlineInputBorder(),
            suffixIcon: widget.enabled
                ? IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: _isUploading ? null : _pickFile,
                    tooltip: 'Seleccionar archivo',
                  )
                : null,
          ),
          onChanged: _onUrlChanged,
        ),
        
        // Mensaje de error
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        
        // Indicador de carga
        if (_isUploading)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildFilePreview() {
    final maxHeight = widget.maxHeight ?? 200.0;
    
    if (_selectedFile != null) {
      // Vista previa de archivo local
      return _buildLocalFilePreview(maxHeight);
    } else if (_fileUrl != null) {
      // Vista previa de archivo desde URL
      return _buildRemoteFilePreview(maxHeight);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildLocalFilePreview(double maxHeight) {
    switch (widget.fileType) {
      case ContenidoFileType.image:
        return Container(
          height: maxHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.file(
              _selectedFile!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            ),
          ),
        );
      case ContenidoFileType.video:
      case ContenidoFileType.audio:
      case ContenidoFileType.document:
        return Container(
          height: maxHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getFileIcon(),
                size: 48,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFile != null 
                    ? _selectedFile!.path.split('/').last 
                    : 'Archivo seleccionado',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (_selectedFile != null)
                Text(
                  _formatFileSize(_selectedFile!.lengthSync()),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        );
    }
  }

  Widget _buildRemoteFilePreview(double maxHeight) {
    switch (widget.fileType) {
      case ContenidoFileType.image:
        return Container(
          height: maxHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(
              _fileUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
        );
      case ContenidoFileType.video:
      case ContenidoFileType.audio:
      case ContenidoFileType.document:
        return Container(
          height: maxHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getFileIcon(),
                size: 48,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                'Archivo desde URL',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _fileUrl!,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      height: widget.maxHeight ?? 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'No se pudo cargar la imagen',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    switch (widget.fileType) {
      case ContenidoFileType.image:
        return Icons.image;
      case ContenidoFileType.video:
        return Icons.videocam;
      case ContenidoFileType.audio:
        return Icons.audiotrack;
      case ContenidoFileType.document:
        return Icons.description;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}