// lib/core/utils/url_utils.dart

/// Utilidades para manejo de URLs en la aplicación
class UrlUtils {
  // URL base del backend
  static const String backendBaseUrl = 'http://localhost:54112';
  
  /// Construir URL completa para recursos del backend
  /// 
  /// Si la URL ya es completa (empieza con http), la retorna sin cambios.
  /// Si es una ruta relativa (empieza con /), la concatena con la URL base del backend.
  /// 
  /// Ejemplos:
  /// - '/uploads/video.mp4' -> 'http://localhost:54112/uploads/video.mp4'
  /// - 'https://youtube.com/watch?v=xxx' -> 'https://youtube.com/watch?v=xxx'
  static String buildFullUrl(String? url) {
    if (url == null || url.isEmpty) {
      return '';
    }
    
    // Si ya es una URL completa, retornarla sin cambios
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    // Si es una ruta relativa, construir URL completa
    if (url.startsWith('/')) {
      return '$backendBaseUrl$url';
    }
    
    // Si no tiene prefijo, asumir que es relativa y agregar /
    return '$backendBaseUrl/$url';
  }
  
  /// Verificar si una URL es de YouTube
  static bool isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }
  
  /// Verificar si una URL es de un video local (del backend)
  static bool isLocalVideo(String url) {
    return url.startsWith('/uploads/') || 
           url.contains('localhost:54112/uploads/');
  }
  
  /// Extraer ID de video de YouTube
  static String? getYouTubeVideoId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
  
  /// Construir URL de miniatura de YouTube
  static String getYouTubeThumbnail(String videoId, {String quality = 'maxresdefault'}) {
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }
  
  /// Verificar si una URL es válida
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}

