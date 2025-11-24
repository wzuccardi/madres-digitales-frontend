import 'package:flutter/material.dart';
import '../../domain/entities/contenido.dart';

class ContenidoCard extends StatelessWidget {

  const ContenidoCard({
    super.key,
    required this.contenido,
    required this.onTap,
    this.onToggleFavorito,
  });
  final Contenido contenido;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorito;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Imagen del contenido
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: contenido.thumbnailUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              contenido.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.image,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Información del contenido
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contenido.titulo,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          contenido.descripcion,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Tipo de contenido
                            Chip(
                              label: Text(
                                contenido.tipo.nombre,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: contenido.tipo.color.withOpacity(0.2),
                            ),
                            const SizedBox(width: 8),
                            // Nivel de dificultad
                            Chip(
                              label: Text(
                                _getNivelDificultadLabel(contenido.nivel),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: _getNivelDificultadColor(contenido.nivel),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Botón de favorito
                  if (onToggleFavorito != null)
                    IconButton(
                      icon: Icon(
                        contenido.favorito ? Icons.favorite : Icons.favorite_border,
                        color: contenido.favorito ? Colors.red : null,
                      ),
                      onPressed: onToggleFavorito,
                    ),
                ],
              ),
              if (contenido.duracion != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(contenido.duracion!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  

  String _getNivelDificultadLabel(NivelDificultad nivel) {
    switch (nivel) {
      case NivelDificultad.basico:
        return 'Básico';
      case NivelDificultad.intermedio:
        return 'Intermedio';
      case NivelDificultad.avanzado:
        return 'Avanzado';
    }
  }

  Color _getNivelDificultadColor(NivelDificultad nivel) {
    switch (nivel) {
      case NivelDificultad.basico:
        return Colors.green.withOpacity(0.2);
      case NivelDificultad.intermedio:
        return Colors.yellow.withOpacity(0.2);
      case NivelDificultad.avanzado:
        return Colors.red.withOpacity(0.2);
    }
  }

  String _formatDuration(int segundos) {
    final minutos = segundos ~/ 60;
    final seg = segundos % 60;
    return '$minutos:${seg.toString().padLeft(2, '0')}';
  }
}
