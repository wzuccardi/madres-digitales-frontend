import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../domain/entities/contenido.dart';

class VideoReproductorWidget extends ConsumerStatefulWidget {
  final Contenido contenido;
  final Function(int tiempoVisualizado, double porcentaje, bool completado)? onProgressUpdate;
  final Function()? onVideoEnd;
  final bool autoPlay;
  final bool showControls;
  final bool allowFullScreen;
  final Map<String, String>? headers;

  const VideoReproductorWidget({
    super.key,
    required this.contenido,
    this.onProgressUpdate,
    this.onVideoEnd,
    this.autoPlay = false,
    this.showControls = true,
    this.allowFullScreen = true,
    this.headers,
  });

  @override
  ConsumerState<VideoReproductorWidget> createState() => _VideoReproductorWidgetState();
}

class _VideoReproductorWidgetState extends ConsumerState<VideoReproductorWidget> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;
  Timer? _progresoTimer;
  int _tiempoVisto = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _inicializarVideo();
    _iniciarTimerProgreso();
  }

  @override
  void dispose() {
    _progresoTimer?.cancel();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _inicializarVideo() async {
    if (widget.contenido.url == null) {
      setState(() {
        _isLoading = false;
        _error = 'No hay URL de video disponible';
      });
      return;
    }

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.contenido.url!),
        httpHeaders: widget.headers ?? {},
      );

      // Restaurar posición si hay progreso
      if (widget.contenido.progreso != null) {
        final posicion = Duration(seconds: widget.contenido.progreso!.tiempoVisualizado);
        await _videoController!.seekTo(posicion);
      }

      await _videoController!.initialize();

      // Configurar listener para detectar fin del video
      _videoController!.addListener(() {
        if (_videoController!.value.isCompleted && widget.onVideoEnd != null) {
          widget.onVideoEnd!();
        }
      });

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: widget.autoPlay,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        showControls: widget.showControls,
        allowFullScreen: widget.allowFullScreen,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error al cargar el video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _reiniciarVideo,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _reiniciarVideo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    await _inicializarVideo();
  }

  void _iniciarTimerProgreso() {
    _progresoTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _actualizarProgreso();
    });
  }

  void _actualizarProgreso() {
    if (widget.onProgressUpdate == null || _videoController == null || !_isInitialized) return;

    final posicion = _videoController!.value.position.inSeconds;
    final duracion = _videoController!.value.duration.inSeconds;
    
    if (duracion > 0) {
      final porcentaje = (posicion / duracion) * 100;
      _tiempoVisto += 5; // Incrementar tiempo visto
      
      final completado = porcentaje >= 95;
      
      widget.onProgressUpdate!(_tiempoVisto, porcentaje, completado);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar el video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _reiniciarVideo,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController != null) {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}