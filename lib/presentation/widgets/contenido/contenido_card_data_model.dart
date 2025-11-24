import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:madres_digitales_flutter_new/data/models/contenido_unificado.dart';

class ContenidoCardDataModel extends StatelessWidget {
  const ContenidoCardDataModel({super.key, required this.contenido, this.onTap});
  final ContenidoUnificado contenido;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contenido.urlImagen != null && contenido.urlImagen!.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: contenido.urlImagen!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contenido.titulo,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contenido.descripcion ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChip(_labelTipo(contenido.tipo), _colorTipo(contenido.tipo)),
                      const SizedBox(width: 8),
                      _buildChip(_labelCategoria(contenido.categoria), Colors.blue),
                      const Spacer(),
                      if (contenido.duracionMinutos != null)
                        Text('${contenido.duracionMinutos} min', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }

  String _labelTipo(String tipo) {
    switch (tipo) {
      case 'video': return 'Video';
      case 'audio': return 'Audio';
      case 'documento': return 'Documento';
      case 'imagen': return 'Imagen';
      case 'articulo': return 'Artículo';
      case 'infografia': return 'Infografía';
      default: return 'Otro';
    }
  }

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'video': return Colors.red;
      case 'audio': return Colors.purple;
      case 'documento': return Colors.blue;
      case 'imagen': return Colors.green;
      case 'articulo': return Colors.orange;
      case 'infografia': return Colors.teal;
      default: return Colors.grey;
    }
  }

  String _labelCategoria(String categoria) {
    switch (categoria) {
      case 'nutricion': return 'Nutrición';
      case 'cuidado_prenatal': return 'Cuidado Prenatal';
      case 'signos_alarma': return 'Signos de Alarma';
      case 'lactancia': return 'Lactancia';
      case 'parto': return 'Parto';
      case 'posparto': return 'Posparto';
      case 'planificacion': return 'Planificación';
      case 'salud_mental': return 'Salud Mental';
      case 'ejercicio': return 'Ejercicio';
      case 'derechos': return 'Derechos';
      default: return 'Otros';
    }
  }
}
