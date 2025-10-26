import 'package:file_picker/file_picker.dart';
import 'logger.dart';

class FilePickerHelper {
  /// Seleccionar archivo de video
  static Future<PlatformFile?> pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true, // Importante para web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final sizeInMB = (file.size) / (1024 * 1024);

        if (sizeInMB > 100) {
          throw Exception('El video no debe superar los 100MB. Tamaño actual: ${sizeInMB.toStringAsFixed(2)}MB');
        }

        AppLogger.info('Video seleccionado: ${file.name}, Tamaño: ${sizeInMB.toStringAsFixed(2)}MB');
        return file;
      }

      return null;
    } catch (e) {
      AppLogger.error('Error seleccionando video: $e');
      rethrow;
    }
  }

  /// Seleccionar archivo de audio
  static Future<PlatformFile?> pickAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
        withData: true, // Importante para web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final sizeInMB = (file.size) / (1024 * 1024);

        if (sizeInMB > 50) {
          throw Exception('El audio no debe superar los 50MB. Tamaño actual: ${sizeInMB.toStringAsFixed(2)}MB');
        }

        AppLogger.info('Audio seleccionado: ${file.name}, Tamaño: ${sizeInMB.toStringAsFixed(2)}MB');
        return file;
      }
      
      return null;
    } catch (e) {
      AppLogger.error('Error seleccionando audio: $e');
      rethrow;
    }
  }

  /// Seleccionar archivo PDF
  static Future<PlatformFile?> pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true, // Importante para web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final sizeInMB = (file.size) / (1024 * 1024);

        if (sizeInMB > 20) {
          throw Exception('El PDF no debe superar los 20MB. Tamaño actual: ${sizeInMB.toStringAsFixed(2)}MB');
        }

        AppLogger.info('PDF seleccionado: ${file.name}, Tamaño: ${sizeInMB.toStringAsFixed(2)}MB');
        return file;
      }

      return null;
    } catch (e) {
      AppLogger.error('Error seleccionando PDF: $e');
      rethrow;
    }
  }

  /// Seleccionar imagen
  static Future<PlatformFile?> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Importante para web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final sizeInMB = (file.size) / (1024 * 1024);

        if (sizeInMB > 10) {
          throw Exception('La imagen no debe superar los 10MB. Tamaño actual: ${sizeInMB.toStringAsFixed(2)}MB');
        }

        AppLogger.info('Imagen seleccionada: ${file.name}, Tamaño: ${sizeInMB.toStringAsFixed(2)}MB');
        return file;
      }

      return null;
    } catch (e) {
      AppLogger.error('Error seleccionando imagen: $e');
      rethrow;
    }
  }

  /// Seleccionar archivo según tipo de contenido
  static Future<PlatformFile?> pickFileByType(String tipoContenido) async {
    switch (tipoContenido.toLowerCase()) {
      case 'video':
        return await pickVideo();
      case 'audio':
        return await pickAudio();
      case 'documento':
        return await pickPDF();
      case 'imagen':
        return await pickImage();
      default:
        throw Exception('Tipo de contenido no soportado: $tipoContenido');
    }
  }

  /// Obtener información del archivo
  static Map<String, dynamic> getFileInfo(PlatformFile file) {
    final fileName = file.name;
    final fileSize = file.size;
    final fileSizeMB = fileSize / (1024 * 1024);
    final extension = file.extension?.toLowerCase() ?? '';

    String mimeType;
    switch (extension) {
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'wmv':
      case 'webm':
        mimeType = 'video/$extension';
        break;
      case 'mp3':
      case 'wav':
      case 'ogg':
        mimeType = 'audio/$extension';
        break;
      case 'pdf':
        mimeType = 'application/pdf';
        break;
      case 'jpg':
      case 'jpeg':
        mimeType = 'image/jpeg';
        break;
      case 'png':
        mimeType = 'image/png';
        break;
      case 'gif':
        mimeType = 'image/gif';
        break;
      case 'webp':
        mimeType = 'image/webp';
        break;
      default:
        mimeType = 'application/octet-stream';
    }

    return {
      'nombre': fileName,
      'tamaño': fileSize,
      'tamañoMB': fileSizeMB,
      'extension': extension,
      'mimeType': mimeType,
      'path': file.path,
    };
  }

  /// Formatear tamaño de archivo
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Validar tipo de archivo
  static bool isValidFileType(String fileName, String tipoContenido) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (tipoContenido.toLowerCase()) {
      case 'video':
        return ['mp4', 'mov', 'avi', 'wmv', 'webm', 'mpeg'].contains(extension);
      case 'audio':
        return ['mp3', 'wav', 'ogg', 'webm'].contains(extension);
      case 'documento':
        return ['pdf', 'doc', 'docx'].contains(extension);
      case 'imagen':
        return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
      default:
        return false;
    }
  }

  /// Obtener icono según extensión
  static String getIconForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'wmv':
      case 'webm':
      case 'mpeg':
        return '🎬';
      case 'mp3':
      case 'wav':
      case 'ogg':
        return '🎵';
      case 'pdf':
      case 'doc':
      case 'docx':
        return '📄';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return '🖼️';
      default:
        return '📁';
    }
  }

  /// Obtener color según tipo de archivo
  static int getColorForType(String tipoContenido) {
    switch (tipoContenido.toLowerCase()) {
      case 'video':
        return 0xFFE91E63; // Pink
      case 'audio':
        return 0xFF9C27B0; // Purple
      case 'documento':
        return 0xFF2196F3; // Blue
      case 'imagen':
        return 0xFF4CAF50; // Green
      default:
        return 0xFF757575; // Grey
    }
  }
}

