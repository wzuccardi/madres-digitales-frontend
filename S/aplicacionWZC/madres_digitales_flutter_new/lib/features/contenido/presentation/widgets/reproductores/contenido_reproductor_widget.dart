import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'video_reproductor_widget.dart';
import 'audio_reproductor_widget.dart';

class ContenidoReproductorWidget extends ConsumerStatefulWidget {

  const ContenidoReproductorWidget({
    super.key,
    required this.contenido,
    this.onProgressUpdate,
  });
  final Contenido contenido;
  final Function(int tiempoVisualizado, double porcentaje, bool completado)? onProgressUpdate;

  @override
  ConsumerState<ContenidoReproductorWidget> createState() => _ContenidoReproductorWidgetState();
}

class _ContenidoReproductorWidgetState extends ConsumerState<ContenidoReproductorWidget> {
  @override
  Widget build(BuildContext context) {
    switch (widget.contenido.tipo) {
      case TipoContenido.video:
        return VideoReproductorWidget(
          contenido: widget.contenido,
          onProgressUpdate: widget.onProgressUpdate,
          autoPlay: false,
          showControls: true,
          allowFullScreen: true,
        );
      case TipoContenido.podcast:
        return AudioReproductorWidget(
          contenido: widget.contenido,
          onProgressUpdate: widget.onProgressUpdate,
          autoPlay: false,
          showControls: true,
          showThumbnail: true,
        );
      case TipoContenido.infografia:
        return _buildImageViewer();
      case TipoContenido.articulo:
      case TipoContenido.guia:
      case TipoContenido.curso:
      case TipoContenido.webinar:
      case TipoContenido.evaluacion:
        return _buildDocumentViewer();
    }
  }

  Widget _buildImageViewer() {
    if (widget.contenido.url == null) {
      return _buildPlaceholder();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: InteractiveViewer(
        child: CachedNetworkImage(
          imageUrl: widget.contenido.url!,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildDocumentViewer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            widget.contenido.titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          if (widget.contenido.url != null)
            ElevatedButton(
              onPressed: () {
                // Abrir URL en navegador externo
                // launchUrl(Uri.parse(widget.contenido.url!));
              },
              child: const Text('Abrir documento'),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.contenido.tipo.icono,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              widget.contenido.tipo.nombre,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
}
