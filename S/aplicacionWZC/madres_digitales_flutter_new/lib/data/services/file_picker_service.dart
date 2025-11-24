import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:file_picker/file_picker.dart';

/// Servicio de selección de archivos
class FilePickerService {
  
  /// Seleccionar imagen
  Future<String?> pickImage() async {
    try {
      AppLogger.debug('FilePickerService: Seleccionando imagen');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        AppLogger.debug('FilePickerService: Imagen seleccionada: $path');
        return path;
      }
      
      AppLogger.debug('FilePickerService: No se seleccionó ninguna imagen');
      return null;
    } catch (e) {
      AppLogger.error('FilePickerService: Error seleccionando imagen', error: e);
      return null;
    }
  }
  
  /// Seleccionar múltiples imágenes
  Future<List<String>?> pickMultipleImages() async {
    try {
      AppLogger.debug('FilePickerService: Seleccionando múltiples imágenes');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final paths = result.files.map((file) => file.path!).toList();
        AppLogger.debug('FilePickerService: ${paths.length} imágenes seleccionadas');
        return paths;
      }
      
      AppLogger.debug('FilePickerService: No se seleccionó ninguna imagen');
      return [];
    } catch (e) {
      AppLogger.error('FilePickerService: Error seleccionando múltiples imágenes', error: e);
      return [];
    }
  }
  
  /// Seleccionar archivo
  Future<String?> pickFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      AppLogger.debug('FilePickerService: Seleccionando archivo');
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: false,
        allowedExtensions: allowedExtensions,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        AppLogger.debug('FilePickerService: Archivo seleccionado: $path');
        return path;
      }
      
      AppLogger.debug('FilePickerService: No se seleccionó ningún archivo');
      return null;
    } catch (e) {
      AppLogger.error('FilePickerService: Error seleccionando archivo', error: e);
      return null;
    }
  }
  
  /// Seleccionar múltiples archivos
  Future<List<String>?> pickMultipleFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      AppLogger.debug('FilePickerService: Seleccionando múltiples archivos');
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: true,
        allowedExtensions: allowedExtensions,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final paths = result.files.map((file) => file.path!).toList();
        AppLogger.debug('FilePickerService: ${paths.length} archivos seleccionados');
        return paths;
      }
      
      AppLogger.debug('FilePickerService: No se seleccionó ningún archivo');
      return [];
    } catch (e) {
      AppLogger.error('FilePickerService: Error seleccionando múltiples archivos', error: e);
      return [];
    }
  }
}