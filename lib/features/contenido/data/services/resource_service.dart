import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ResourceService {
  
  // Mapa de categorías a colores para placeholders
  static const Map<String, Color> _categoryColors = {
    'nutricion': Color(0xFF4CAF50),
    'ejercicio': Color(0xFF2196F3),
    'salud_mental': Color(0xFF9C27B0),
    'preparacion_parto': Color(0xFFFF9800),
    'cuidado_bebe': Color(0xFFE91E63),
    'lactancia': Color(0xFF00BCD4),
    'desarrollo_infantil': Color(0xFF8BC34A),
    'seguridad': Color(0xFFF44336),
  };
  
  // Mapa de tipos a iconos para placeholders
  static const Map<String, String> _typeIcons = {
    'video': '🎥',
    'articulo': '📄',
    'podcast': '🎧',
    'infografia': '📊',
    'guia': '📖',
    'curso': '🎓',
    'webinar': '💻',
    'evaluacion': '📝',
  };
  
  // Método para obtener URL de imagen con fallback
  static String getImageUrlWithFallback(String? imageUrl, {
    String? categoria,
    String? tipo,
    String? titulo,
    int width = 640,
    int height = 360,
  }) {
    // Si no hay URL, generar un placeholder
    if (imageUrl == null || imageUrl.isEmpty) {
      return _generatePlaceholderUrl(categoria, tipo, titulo, width, height);
    }
    
    // Si la URL es un asset local, verificar que exista
    if (imageUrl.startsWith('assets/')) {
      return imageUrl; // Mantener el asset, el manejo de errores se hará en el widget
    }
    
    // Si es una URL externa, verificar que sea válida
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    
    // Si no es ninguno de los casos anteriores, generar un placeholder
    return _generatePlaceholderUrl(categoria, tipo, titulo, width, height);
  }
  
  // Método para generar URL de placeholder
  static String _generatePlaceholderUrl(
    String? categoria,
    String? tipo,
    String? titulo,
    int width,
    int height,
  ) {
    // Obtener color basado en la categoría
    final color = _categoryColors[categoria?.toLowerCase()] ?? Colors.grey;
    
    // Obtener icono basado en el tipo
    final icon = _typeIcons[tipo?.toLowerCase()] ?? '📄';
    
    // Generar texto para el placeholder
    String text = icon;
    if (titulo != null && titulo.isNotEmpty) {
      // Limitar longitud del texto y codificar para URL
      final truncatedTitle = titulo.length > 20 
          ? '${titulo.substring(0, 20)}...' 
          : titulo;
      text = '$icon $truncatedTitle';
    } else if (categoria != null && categoria.isNotEmpty) {
      text = '$icon ${_capitalizeFirst(categoria)}';
    }
    
    // Convertir color a hexadecimal
    final colorHex = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    
    // Generar URL del placeholder
    return 'https://via.placeholder.com/${width}x$height/$colorHex/FFFFFF?text=${Uri.encodeComponent(text)}';
  }
  
  // Método para capitalizar la primera letra
  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  // Widget para mostrar imagen con manejo de errores
  static Widget buildCachedImageWithFallback(
    String? imageUrl, {
    String? categoria,
    String? tipo,
    String? titulo,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    final url = getImageUrlWithFallback(
      imageUrl,
      categoria: categoria,
      tipo: tipo,
      titulo: titulo,
      width: width?.toInt() ?? 640,
      height: height?.toInt() ?? 360,
    );
    
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(width, height),
      errorWidget: (context, url, error) => errorWidget ?? _buildDefaultErrorWidget(width, height),
      httpHeaders: const {
        'User-Agent': 'Madres-Digitales-Flutter/1.0',
      },
    );
  }
  
  // Widget para mostrar imagen local con manejo de errores
  static Widget buildAssetImageWithFallback(
    String assetPath, {
    String? categoria,
    String? tipo,
    String? titulo,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildDefaultErrorWidget(width, height);
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
  
  // Widget placeholder predeterminado
  static Widget _buildDefaultPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.grey,
        ),
      ),
    );
  }
  
  // Widget de error predeterminado
  static Widget _buildDefaultErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Imagen no disponible',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Método para verificar si un asset existe
  static Future<bool> doesAssetExist(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Método para obtener el logo de la aplicación con fallback
  static Widget buildAppLogo({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    const String logoPath = 'assets/images/logo.png';
    
    return FutureBuilder<bool>(
      future: doesAssetExist(logoPath),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          // El logo existe, mostrarlo
          return Image.asset(
            logoPath,
            width: width,
            height: height,
            fit: fit,
          );
        } else {
          // El logo no existe, mostrar un placeholder
          return Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'MD',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}