import 'package:flutter/material.dart';
import '../../models/contenido_unificado.dart';
import '../../screens/reproductor_screen.dart';

/// Widget para mostrar una tarjeta de contenido educativo
class ContenidoCardWidget extends StatelessWidget {
  final ContenidoUnificado contenido;
  final double? width;
  final double? height;
  final bool showProgress;
  final bool showStats;
  final Function(ContenidoUnificado)? onTap;
  final Function(ContenidoUnificado)? onFavoriteTap;
  final bool isFavorite;

  const ContenidoCardWidget({
    super.key,
    required this.contenido,
    this.width,
    this.height,
    this.showProgress = true,
    this.showStats = true,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleTap(context),
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen o placeholder
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    if (contenido.urlImagen != null) // Corrección: usar urlImagen
                      Positioned.fill(
                        child: Image.network(
                          contenido.urlImagen!, // Corrección: usar urlImagen
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: Icon(
                                  _getIconoTipo(contenido.tipo), // Corrección: usar tipo
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            _getIconoTipo(contenido.tipo), // Corrección: usar tipo
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    
                    // Botón de favorito
                    if (onFavoriteTap != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => onFavoriteTap!(contenido),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    
                    // Tipo de contenido
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getColorTipo(contenido.tipo), // Corrección: usar tipo
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getNombreTipo(contenido.tipo), // Corrección: usar tipo
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Información del contenido
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        contenido.titulo,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Categoría
                      Text(
                        _getNombreCategoria(contenido.categoria),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const Spacer(),
                      
                      // Duración
                      if (contenido.duracionMinutos != null) // Corrección: usar duracionMinutos
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${contenido.duracionMinutos} min', // Corrección: usar duracionMinutos
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      
                      // Estadísticas
                      if (showStats) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '0',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '0.0',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      // Progreso
                      if (showProgress) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.0, // TODO: Implementar progreso real
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!(contenido);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReproductorScreen(contenido: contenido),
      ),
    );
  }

  IconData _getIconoTipo(String tipo) {
    switch (tipo) {
      case 'video':
        return Icons.play_circle;
      case 'audio':
        return Icons.audiotrack;
      case 'documento':
        return Icons.description;
      case 'imagen':
        return Icons.image;
      case 'articulo':
        return Icons.article;
      case 'infografia':
        return Icons.info;
      default:
        return Icons.library_books;
    }
  }

  String _getNombreTipo(String tipo) {
    switch (tipo) {
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'documento':
        return 'Documento';
      case 'imagen':
        return 'Imagen';
      case 'articulo':
        return 'Artículo';
      case 'infografia':
        return 'Infografía';
      default:
        return 'Otro';
    }
  }

  String _getNombreCategoria(String categoria) {
    switch (categoria) {
      case 'nutricion':
        return 'Nutrición';
      case 'cuidado_prenatal':
        return 'Cuidado Prenatal';
      case 'signos_alarma':
        return 'Signos de Alarma';
      case 'lactancia':
        return 'Lactancia';
      case 'parto':
        return 'Parto';
      case 'posparto':
        return 'Posparto';
      case 'planificacion':
        return 'Planificación';
      case 'salud_mental':
        return 'Salud Mental';
      case 'ejercicio':
        return 'Ejercicio';
      case 'higiene':
        return 'Higiene';
      case 'derechos':
        return 'Derechos';
      case 'otros':
        return 'Otros';
      default:
        return 'Otro';
    }
  }

  Color _getColorTipo(String tipo) {
    switch (tipo) {
      case 'video':
        return Colors.red;
      case 'audio':
        return Colors.purple;
      case 'documento':
        return Colors.blue;
      case 'imagen':
        return Colors.green;
      case 'articulo':
        return Colors.orange;
      case 'infografia':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}