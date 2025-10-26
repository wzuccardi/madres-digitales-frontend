import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/contenido.dart';
import '../../../../../shared/theme/app_theme.dart';

class AudioReproductorWidget extends ConsumerStatefulWidget {
  final Contenido contenido;
  final Function(int tiempoVisualizado, double porcentaje, bool completado)? onProgressUpdate;
  final Function()? onAudioEnd;
  final bool autoPlay;
  final bool showControls;
  final bool showThumbnail;
  final Map<String, String>? headers;

  const AudioReproductorWidget({
    super.key,
    required this.contenido,
    this.onProgressUpdate,
    this.onAudioEnd,
    this.autoPlay = false,
    this.showControls = true,
    this.showThumbnail = true,
    this.headers,
  });

  @override
  ConsumerState<AudioReproductorWidget> createState() => _AudioReproductorWidgetState();
}

class _AudioReproductorWidgetState extends ConsumerState<AudioReproductorWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _error;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  double _playbackSpeed = 1.0;
  Timer? _progresoTimer;
  int _tiempoVisto = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _inicializarAudio();
    _iniciarTimerProgreso();
  }

  @override
  void dispose() {
    _progresoTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _inicializarAudio() async {
    if (widget.contenido.url == null) {
      setState(() {
        _isLoading = false;
        _error = 'No hay URL de audio disponible';
      });
      return;
    }

    try {
      await _audioPlayer.setSourceUrl(widget.contenido.url!);

      _audioPlayer.onDurationChanged.listen((duration) {
        setState(() => _audioDuration = duration);
      });

      _audioPlayer.onPositionChanged.listen((position) {
        setState(() => _audioPosition = position);
        _actualizarProgreso();
      });

      _audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() => _isPlaying = state == PlayerState.playing);
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() => _isPlaying = false);
        if (widget.onAudioEnd != null) {
          widget.onAudioEnd!();
        }
      });

      // Restaurar posición si hay progreso
      if (widget.contenido.progreso != null) {
        final posicion = Duration(seconds: widget.contenido.progreso!.tiempoVisualizado);
        await _audioPlayer.seek(posicion);
      }

      // Auto play si se especificó
      if (widget.autoPlay) {
        await _audioPlayer.resume();
      }

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

  Future<void> _reiniciarAudio() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    await _inicializarAudio();
  }

  void _iniciarTimerProgreso() {
    _progresoTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _actualizarProgreso();
    });
  }

  void _actualizarProgreso() {
    if (widget.onProgressUpdate == null || !_isInitialized) return;

    final posicion = _audioPosition.inSeconds;
    final duracion = _audioDuration.inSeconds;
    
    if (duracion > 0) {
      final porcentaje = (posicion / duracion) * 100;
      _tiempoVisto += 5; // Incrementar tiempo visto
      
      final completado = porcentaje >= 95;
      
      widget.onProgressUpdate!(_tiempoVisto, porcentaje, completado);
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    await _audioPlayer.setPlaybackRate(speed);
    setState(() {
      _playbackSpeed = speed;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar el audio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _reiniciarAudio,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Imagen o icono del podcast
          if (widget.showThumbnail) ...[
            if (widget.contenido.thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.contenido.thumbnailUrl!,
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.audiotrack,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
            
            const SizedBox(height: 16),
          ],
          
          // Título
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
          
          // Barra de progreso
          Slider(
            value: _audioPosition.inSeconds.toDouble(),
            max: _audioDuration.inSeconds.toDouble(),
            onChanged: (value) {
              _seekTo(Duration(seconds: value.toInt()));
            },
          ),
          
          // Tiempo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_audioPosition)),
              Text(_formatDuration(_audioDuration)),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Controles
          if (widget.showControls) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón de retroceder 10 segundos
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: () {
                    final newPosition = _audioPosition - const Duration(seconds: 10);
                    _seekTo(newPosition);
                  },
                ),
                
                // Botón de play/pause
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 64,
                  onPressed: _togglePlayPause,
                ),
                
                // Botón de avanzar 10 segundos
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: () {
                    final newPosition = _audioPosition + const Duration(seconds: 10);
                    _seekTo(newPosition);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Control de velocidad de reproducción
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Velocidad:'),
                const SizedBox(width: 8),
                DropdownButton<double>(
                  value: _playbackSpeed,
                  items: const [
                    DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                    DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                    DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                    DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                    DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                    DropdownMenuItem(value: 2.0, child: Text('2.0x')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _setPlaybackSpeed(value);
                    }
                  },
                ),
              ],
            ),
          ],
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
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}