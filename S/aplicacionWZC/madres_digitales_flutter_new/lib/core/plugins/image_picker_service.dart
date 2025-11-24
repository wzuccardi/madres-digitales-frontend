import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:image_picker/image_picker.dart';

/// Servicio de selección de imágenes
class ImagePickerService {
  
  ImagePickerService() : _imagePicker = ImagePicker();
  final ImagePicker _imagePicker;
  
  /// Seleccionar imagen desde galería
  Future<String?> pickImageFromGallery() async {
    try {
      AppLogger.debug('ImagePickerService: Seleccionando imagen desde galería');
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      AppLogger.debug('ImagePickerService: Imagen seleccionada: ${image?.path}');
      return image?.path;
    } catch (e) {
      AppLogger.error('ImagePickerService: Error seleccionando imagen desde galería', error: e);
      return null;
    }
  }
  
  /// Seleccionar imagen desde cámara
  Future<String?> pickImageFromCamera() async {
    try {
      AppLogger.debug('ImagePickerService: Seleccionando imagen desde cámara');
      final image = await _imagePicker.pickImage(source: ImageSource.camera);
      AppLogger.debug('ImagePickerService: Imagen seleccionada: ${image?.path}');
      return image?.path;
    } catch (e) {
      AppLogger.error('ImagePickerService: Error seleccionando imagen desde cámara', error: e);
      return null;
    }
  }
  
  /// Seleccionar múltiples imágenes
  Future<List<String>?> pickMultipleImages() async {
    try {
      AppLogger.debug('ImagePickerService: Seleccionando múltiples imágenes');
      final images = await _imagePicker.pickMultiImage();
      final paths = images.map((image) => image.path).toList();
      AppLogger.debug('ImagePickerService: ${paths.length} imágenes seleccionadas');
      return paths;
    } catch (e) {
      AppLogger.error('ImagePickerService: Error seleccionando múltiples imágenes', error: e);
      return [];
    }
  }
}
