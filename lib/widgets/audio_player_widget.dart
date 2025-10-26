import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../utils/logger.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath; // Puede ser URL o path local
  final bool isLocal;
  final bool autoPlay;
  final Function(Duration)? onPositionChanged;
  final Function()? onCompleted;

  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
    this.isLocal = false,
    this.autoPlay = false,
    this.onPositionChanged,
    this.onCompleted,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  // bool _isPaused = false; // No utilizado, eliminando advertencia
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _audioPlayer = AudioPlayer();

      // Escuchar cambios de duración
      _audioPlayer.onDurationChanged.listen((duration) {
        setState(() {
          _duration = duration;
        });
      });

      // Escuchar cambios de posición
      _audioPlayer.onPositionChanged.listen((position) {
        setState(() {
          _position = position;
        });
        if (widget.onPositionChanged != null) {
          widget.onPositionChanged!(position);
        }
      });

      // Escuchar cuando termina
      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          _isPlaying = false;
          // _isPaused = false; // No utilizado, eliminando advertencia
          _position = Duration.zero;
        });
        if (widget.onCompleted != null) {
          widget.onCompleted!();
        }
      });

      // Escuchar estado del reproductor
      _audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          // _isPaused = state == PlayerState.paused; // No utilizado, eliminando advertencia
        });
      });

      // Cargar audio
      if (widget.isLocal) {
        await _audioPlayer.setSourceDeviceFile(widget.audioPath);
      } else {
        await _audioPlayer.setSourceUrl(widget.audioPath);
      }

      setState(() {
        _isLoading = false;
      });

      // Auto play si está habilitado
      if (widget.autoPlay) {
        await _audioPlayer.resume();
      }

      AppLogger.info('Audio inicializado: ${widget.audioPath}');
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
      AppLogger.error('Error inicializando audio: $e');
    }
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      AppLogger.error('Error reproduciendo/pausando audio: $e');
    }
  }

  Future<void> _stop() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _position = Duration.zero;
      });
    } catch (e) {
      AppLogger.error('Error deteniendo audio: $e');
    }
  }

  Future<void> _seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      AppLogger.error('Error buscando posición: $e');
    }
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar el audio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Error desconocido',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = null;
                    _isLoading = true;
                  });
                  _initializePlayer();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando audio...'),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de audio
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.audiotrack,
                size: 48,
                color: Color(0xFF9C27B0),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Slider de progreso
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: _position.inSeconds.toDouble(),
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) {
                  _seek(Duration(seconds: value.toInt()));
                },
                activeColor: const Color(0xFF9C27B0),
                inactiveColor: Colors.grey[300],
              ),
            ),
            
            // Tiempos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_position),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    _formatDuration(_duration),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Controles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón de retroceder 10 segundos
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  iconSize: 32,
                  onPressed: () {
                    final newPosition = _position - const Duration(seconds: 10);
                    _seek(newPosition < Duration.zero ? Duration.zero : newPosition);
                  },
                ),
                
                const SizedBox(width: 16),
                
                // Botón de play/pause
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF9C27B0),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    iconSize: 40,
                    onPressed: _playPause,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Botón de adelantar 10 segundos
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  iconSize: 32,
                  onPressed: () {
                    final newPosition = _position + const Duration(seconds: 10);
                    _seek(newPosition > _duration ? _duration : newPosition);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

