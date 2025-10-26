import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/contenido.dart';
import 'video_reproductor_widget.dart';
import 'audio_reproductor_widget.dart';

class ContenidoReproductorWidget extends ConsumerStatefulWidget {
  final Contenido contenido;
  final Function(int tiempoVisualizado, double porcentaje, bool completado)? onProgressUpdate;

  const ContenidoReproductorWidget({
    super.key,
    required this.contenido,
    this.onProgressUpdate,
  });

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
              _getTipoContenidoIcon(widget.contenido.tipo),
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              _getTipoContenidoLabel(widget.contenido.tipo),
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

  String _getTipoContenidoLabel(TipoContenido tipo) {
    switch (tipo) {
      case TipoContenido.articulo:
        return 'Artículo';
      case TipoContenido.video:
        return 'Video';
      case TipoContenido.podcast:
        return 'Podcast';
      case TipoContenido.infografia:
        return 'Infografía';
      case TipoContenido.guia:
        return 'Guía';
      case TipoContenido.curso:
        return 'Curso';
      case TipoContenido.webinar:
        return 'Webinar';
      case TipoContenido.evaluacion:
        return 'Evaluación';
    }
  }

  IconData _getTipoContenidoIcon(TipoContenido tipo) {
    switch (tipo) {
      case TipoContenido.articulo:
        return Icons.article;
      case TipoContenido.video:
        return Icons.videocam;
      case TipoContenido.podcast:
        return Icons.audiotrack;
      case TipoContenido.infografia:
        return Icons.info;
      case TipoContenido.guia:
        return Icons.book;
      case TipoContenido.curso:
        return Icons.school;
      case TipoContenido.webinar:
        return Icons.laptop;
      case TipoContenido.evaluacion:
        return Icons.quiz;
    }
  }
}