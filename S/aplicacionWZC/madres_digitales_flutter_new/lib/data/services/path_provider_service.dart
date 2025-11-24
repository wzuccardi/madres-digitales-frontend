import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

/// Servicio de proveedor de rutas
class PathProviderService {
  factory PathProviderService() => _instance;
  PathProviderService._internal();
  // Singleton pattern
  static final PathProviderService _instance = PathProviderService._internal();
  
  /// Obtener directorio de documentos
  Future<String?> getApplicationDocumentsDirectory() async {
    try {
      AppLogger.debug('PathProviderService: Obteniendo directorio de documentos');
      final directory = await path_provider.getApplicationDocumentsDirectory();
      AppLogger.debug('PathProviderService: Directorio de documentos obtenido: ${directory.path}');
      return directory.path;
    } catch (e) {
      AppLogger.error('PathProviderService: Error obteniendo directorio de documentos', error: e);
      return null;
    }
  }
  
  /// Obtener directorio temporal
  Future<String?> getTemporaryDirectory() async {
    try {
      AppLogger.debug('PathProviderService: Obteniendo directorio temporal');
      final directory = await path_provider.getTemporaryDirectory();
      AppLogger.debug('PathProviderService: Directorio temporal obtenido: ${directory.path}');
      return directory.path;
    } catch (e) {
      AppLogger.error('PathProviderService: Error obteniendo directorio temporal', error: e);
      return null;
    }
  }
  
  /// Obtener directorio de soporte de la aplicación
  Future<String?> getApplicationSupportDirectory() async {
    try {
      AppLogger.debug('PathProviderService: Obteniendo directorio de soporte de la aplicación');
      final directory = await path_provider.getApplicationSupportDirectory();
      AppLogger.debug('PathProviderService: Directorio de soporte obtenido: ${directory.path}');
      return directory.path;
    } catch (e) {
      AppLogger.error('PathProviderService: Error obteniendo directorio de soporte de la aplicación', error: e);
      return null;
    }
  }
  
  /// Obtener directorio de caché
  Future<String?> getApplicationCacheDirectory() async {
    try {
      AppLogger.debug('PathProviderService: Obteniendo directorio de caché');
      final directory = await path_provider.getApplicationCacheDirectory();
      AppLogger.debug('PathProviderService: Directorio de caché obtenido: ${directory.path}');
      return directory.path;
    } catch (e) {
      AppLogger.error('PathProviderService: Error obteniendo directorio de caché', error: e);
      return null;
    }
  }
  
  /// Obtener directorio de datos externos
  Future<String?> getExternalStorageDirectory() async {
    try {
      AppLogger.debug('PathProviderService: Obteniendo directorio de datos externos');
      final directory = await path_provider.getExternalStorageDirectory();
      AppLogger.debug('PathProviderService: Directorio de datos externos obtenido: ${directory?.path}');
      return directory?.path;
    } catch (e) {
      AppLogger.error('PathProviderService: Error obteniendo directorio de datos externos', error: e);
      return null;
    }
  }
  
  /// Obtener directorio de descargas
  Future<String?> getDownloadsDirectory() async {
    try {
      AppLogger.debug('PathProviderService: Obteniendo directorio de descargas');
      // Fallback a documentos en plataformas donde no esté disponible
      final directory = await path_provider.getApplicationDocumentsDirectory();
      AppLogger.debug('PathProviderService: Directorio de descargas (fallback) obtenido: ${directory.path}');
      return directory.path;
    } catch (e) {
      AppLogger.error('PathProviderService: Error obteniendo directorio de descargas', error: e);
      return null;
    }
  }
  
  /// Obtener directorio de música
  Future<String?> getMusicDirectory() async {
    try {
      AppLogger.debug('PathProviderService: Obteniendo directorio de música');
      final directory = await path_provider.getApplicationDocumentsDirectory();
      AppLogger.debug('PathProviderService: Directorio de música (fallback) obtenido: ${directory.path}');
      return directory.path;
    } catch (e) {
      AppLogger.error('PathProviderService: Error obteniendo directorio de música', error: e);
      return null;
    }
  }
  
  /// Obtener directorio de películas
  Future<String?> getMoviesDirectory() async {
    try {
      AppLogger.debug('PathProviderService: Obteniendo directorio de películas');
      final directory = await path_provider.getApplicationDocumentsDirectory();
      AppLogger.debug('PathProviderService: Directorio de películas (fallback) obtenido: ${directory.path}');
      return directory.path;
    } catch (e) {
      AppLogger.error('PathProviderService: Error obteniendo directorio de películas', error: e);
      return null;
    }
  }
  
  /// Obtener directorio de imágenes
  Future<String?> getPicturesDirectory() async {
    try {
      AppLogger.debug('PathProviderService: Obteniendo directorio de imágenes');
      final directory = await path_provider.getApplicationDocumentsDirectory();
      AppLogger.debug('PathProviderService: Directorio de imágenes (fallback) obtenido: ${directory.path}');
      return directory.path;
    } catch (e) {
      AppLogger.error('PathProviderService: Error obteniendo directorio de imágenes', error: e);
      return null;
    }
  }
}
