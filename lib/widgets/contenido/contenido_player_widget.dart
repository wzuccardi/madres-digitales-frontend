import 'package:flutter/material.dart';
import '../../models/contenido_unificado.dart';
import '../../utils/logger.dart';

/// Widget para reproducir contenido educativo
class ContenidoPlayerWidget extends StatefulWidget {
  final ContenidoUnificado contenido;
  final bool autoPlay;
  final Function()? onCompleted;
  final Function(Duration position)? onPositionChanged;

  const ContenidoPlayerWidget({
    super.key,
    required this.contenido,
    this.autoPlay = false,
    this.onCompleted,
    this.onPositionChanged,
  });

  @override
  State<ContenidoPlayerWidget> createState() => _ContenidoPlayerWidgetState();
}

class _ContenidoPlayerWidgetState extends State<ContenidoPlayerWidget> {
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.7;

  @override
  void initState() {
    super.initState();
    _inicializarReproductor();
  }

  @override
  void dispose() {
    // Liberar recursos del reproductor
    super.dispose();
  }

  Future<void> _inicializarReproductor() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Simular inicialización del reproductor
      await Future.delayed(const Duration(seconds: 1));

      // Simular duración del contenido
      if (widget.contenido.duracionMinutos != null) {
        _duration = Duration(minutes: widget.contenido.duracionMinutos!);
      } else {
        _duration = const Duration(minutes: 5);
      }

      setState(() {
        _isLoading = false;
      });

      if (widget.autoPlay) {
        _play();
      }
    } catch (e) {
      appLogger.error('Error inicializando reproductor', error: e);
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _play() async {
    try {
      setState(() {
        _isPlaying = true;
      });

      // Simular reproducción
      _simulatePlayback();
    } catch (e) {
      appLogger.error('Error reproduciendo contenido', error: e);
      setState(() {
        _isPlaying = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _pause() async {
    try {
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      appLogger.error('Error pausando contenido', error: e);
    }
  }

  Future<void> _stop() async {
    try {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    } catch (e) {
      appLogger.error('Error deteniendo contenido', error: e);
    }
  }

  Future<void> _seek(Duration position) async {
    try {
      setState(() {
        _position = position;
      });
    } catch (e) {
      appLogger.error('Error cambiando posición', error: e);
    }
  }

  Future<void> _setVolume(double volume) async {
    try {
      setState(() {
        _volume = volume;
      });
    } catch (e) {
      appLogger.error('Error ajustando volumen', error: e);
    }
  }

  void _simulatePlayback() {
    if (!_isPlaying) return;

    const tick = Duration(milliseconds: 100);
    Future.delayed(tick, () {
      if (_isPlaying && mounted) {
        setState(() {
          _position = _position + tick;
          if (_position >= _duration) {
            _position = _duration;
            _isPlaying = false;
            widget.onCompleted?.call();
          }
        });

        widget.onPositionChanged?.call(_position);

        if (_isPlaying) {
          _simulatePlayback();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_isLoading) {
      return _buildLoadingWidget();
    }

    return Column(
      children: [
        // Contenido principal del reproductor
        _buildPlayerContent(),
        
        // Controles del reproductor
        _buildPlayerControls(),
        
        // Barra de progreso
        _buildProgressBar(),
        
        // Controles adicionales
        _buildAdditionalControls(),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar el contenido',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Error desconocido',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _inicializarReproductor,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando contenido...'),
        ],
      ),
    );
  }

  Widget _buildPlayerContent() {
    switch (widget.contenido.tipo) { // Corrección: usar tipo
      case 'video':
        return _buildVideoPlayer();
      case 'audio':
        return _buildAudioPlayer();
      case 'imagen':
        return _buildImageViewer();
      case 'documento':
        return _buildDocumentViewer();
      default:
        return _buildDefaultPlayer();
    }
  }

  Widget _buildVideoPlayer() {
    return Container(
      height: 200,
      color: Colors.black,
      child: Stack(
        children: [
          // Placeholder para video
          if (widget.contenido.urlImagen != null) // Corrección: usar urlImagen
            Positioned.fill(
              child: Image.network(
                widget.contenido.urlImagen!, // Corrección: usar urlImagen
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
          
          // Controles de reproducción
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: _isPlaying ? _pause : _play,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                        trackHeight: 2,
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: _position.inSeconds.toDouble(),
                        max: _duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          _seek(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                  ),
                  Text(
                    '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Imagen o placeholder para audio
          if (widget.contenido.urlImagen != null) // Corrección: usar urlImagen
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.contenido.urlImagen!, // Corrección: usar urlImagen
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.audiotrack,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.audiotrack,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Información del audio
          Text(
            widget.contenido.titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            widget.contenido.descripcion ?? '', // Corrección: descripcion es nullable
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 16),
          
          // Barra de progreso
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 4,
            ),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) {
                _seek(Duration(seconds: value.toInt()));
              },
            ),
          ),
          
          // Tiempo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_position)),
              Text(_formatDuration(_duration)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.contenido.urlImagen != null) // Corrección: usar urlImagen
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.contenido.urlImagen!, // Corrección: usar urlImagen
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Información de la imagen
          Text(
            widget.contenido.titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            widget.contenido.descripcion ?? '', // Corrección: descripcion es nullable
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentViewer() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.description,
                size: 64,
                color: Colors.grey,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Información del documento
          Text(
            widget.contenido.titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            widget.contenido.descripcion ?? '', // Corrección: descripcion es nullable
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          ElevatedButton.icon(
            onPressed: () {
              // Implementar descarga o visualización del documento
            },
            icon: const Icon(Icons.download),
            label: const Text('Descargar documento'),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPlayer() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.library_books,
                size: 64,
                color: Colors.grey,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Información del contenido
          Text(
            widget.contenido.titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            widget.contenido.descripcion ?? '', // Corrección: descripcion es nullable
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón de retroceder
          IconButton(
            icon: const Icon(Icons.replay_10),
            onPressed: () {
              final newPosition = _position - const Duration(seconds: 10);
              _seek(newPosition < Duration.zero ? Duration.zero : newPosition);
            },
          ),
          
          const SizedBox(width: 16),
          
          // Botón de play/pause
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: _isPlaying ? _pause : _play,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Botón de adelantar
          IconButton(
            icon: const Icon(Icons.forward_10),
            onPressed: () {
              final newPosition = _position + const Duration(seconds: 10);
              _seek(newPosition > _duration ? _duration : newPosition);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          trackHeight: 4,
        ),
        child: Slider(
          value: _position.inSeconds.toDouble(),
          max: _duration.inSeconds.toDouble(),
          onChanged: (value) {
            _seek(Duration(seconds: value.toInt()));
          },
        ),
      ),
    );
  }

  Widget _buildAdditionalControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Tiempo transcurrido / total
          Text(
            '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          
          const Spacer(),
          
          // Control de volumen
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volume_down),
              SizedBox(
                width: 100,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                    trackHeight: 2,
                  ),
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      _setVolume(value);
                    },
                  ),
                ),
              ),
              const Icon(Icons.volume_up),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}