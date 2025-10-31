import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contenido_unificado.dart';
import '../shared/theme/app_theme.dart';
import '../services/contenido_progreso_service.dart';

/// Widget reproductor multimedia unificado
class MultimediaPlayer extends StatefulWidget {
  final ContenidoUnificado contenido;
  final ContenidoProgresoService? progresoService;
  final Function(Duration)? onProgressUpdate;
  final Function()? onCompleted;

  const MultimediaPlayer({
    super.key,
    required this.contenido,
    this.progresoService,
    this.onProgressUpdate,
    this.onCompleted,
  });

  @override
  State<MultimediaPlayer> createState() => _MultimediaPlayerState();
}

class _MultimediaPlayerState extends State<MultimediaPlayer> {
  // Video
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  bool _showControls = true;
  final bool _isFullScreen = false;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  // General
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() => _isLoading = true);
      
      final tipo = widget.contenido.tipo.toLowerCase();
      
      if (tipo == 'video') {
        await _initializeVideo();
      } else if (tipo == 'audio') {
        await _initializeAudio();
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeVideo() async {
    final url = widget.contenido.urlContenido;
    if (url == null || url.isEmpty) {
      throw Exception('URL de video no disponible');
    }

    // Verificar si es una URL de YouTube u otros servicios no compatibles
    if (_isYouTubeUrl(url) || _isUnsupportedUrl(url)) {
      throw Exception('Las URLs de YouTube y otros servicios de streaming no son compatibles. Use URLs directas de archivos de video (.mp4, .webm, .mov, etc.)');
    }

    final fullUrl = url.startsWith('http') ? url : 'http://localhost:54112$url';
    _videoController = VideoPlayerController.networkUrl(Uri.parse(fullUrl));
    
    await _videoController!.initialize();
    
    _videoController!.addListener(() {
      if (mounted) {
        setState(() {
          _isVideoPlaying = _videoController!.value.isPlaying;
        });
        
        widget.onProgressUpdate?.call(_videoController!.value.position);
        
        if (_videoController!.value.position >= _videoController!.value.duration) {
          widget.onCompleted?.call();
        }
      }
    });

    setState(() => _isVideoInitialized = true);
  }

  Future<void> _initializeAudio() async {
    final url = widget.contenido.urlContenido;
    if (url == null || url.isEmpty) {
      throw Exception('URL de audio no disponible');
    }

    final fullUrl = url.startsWith('http') ? url : 'http://localhost:54112$url';
    await _audioPlayer.setSourceUrl(fullUrl);

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _audioDuration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _audioPosition = position);
        widget.onProgressUpdate?.call(position);
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isAudioPlaying = state == PlayerState.playing);
        if (state == PlayerState.completed) {
          widget.onCompleted?.call();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return _buildErrorWidget(_error!);
    }

    final tipo = widget.contenido.tipo.toLowerCase();
    
    switch (tipo) {
      case 'video':
        return _buildVideoPlayer();
      case 'audio':
        return _buildAudioPlayer();
      case 'imagen':
      case 'infografia':
        return _buildImageViewer();
      case 'documento':
      case 'pdf':
        return _buildDocumentViewer();
      default:
        return _buildGenericContent();
    }
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final videoWidget = Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Video player
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),
            
            // Controles
            _buildVideoControls(),
          ],
        ),
      ),
    );

    return videoWidget;
  }

  Widget _buildVideoControls() {
    return Stack(
      children: [
        // Controles principales
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              setState(() => _showControls = !_showControls);
            },
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // TÃ­tulo
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.contenido.titulo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // BotÃ³n play/pause central
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 40,
                            ),
                            onPressed: _toggleVideoPlayback,
                          ),
                        ),
                      ),
                    ),
                    
                    // Controles inferiores
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Barra de progreso
                          Row(
                            children: [
                              Text(
                                _formatDuration(_videoController!.value.position),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: VideoProgressIndicator(
                                    _videoController!,
                                    allowScrubbing: true,
                                    colors: VideoProgressColors(
                                      playedColor: AppTheme.primaryColor,
                                      bufferedColor: Colors.white.withOpacity(0.3),
                                      backgroundColor: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                _formatDuration(_videoController!.value.duration),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Botones de control
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_10, color: Colors.white),
                                onPressed: () => _seekVideo(-10),
                              ),
                              const SizedBox(width: 20),
                              Container(
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  onPressed: _toggleVideoPlayback,
                                ),
                              ),
                              const SizedBox(width: 20),
                              IconButton(
                                icon: const Icon(Icons.forward_10, color: Colors.white),
                                onPressed: () => _seekVideo(10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // BotÃ³n de pantalla completa siempre visible
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.fullscreen, color: Colors.white),
              onPressed: _enterFullScreen,
              tooltip: 'Pantalla completa',
            ),
          ),
        ),
      ],
    );
  }

  void _toggleVideoPlayback() {
    if (_videoController != null) {
      if (_isVideoPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    }
  }

  void _seekVideo(int seconds) {
    if (_videoController != null) {
      final currentPosition = _videoController!.value.position;
      final newPosition = currentPosition + Duration(seconds: seconds);
      final duration = _videoController!.value.duration;
      
      if (newPosition >= Duration.zero && newPosition <= duration) {
        _videoController!.seekTo(newPosition);
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _enterFullScreen() {
    // Guardar el estado actual de reproducciÃ³n
    final wasPlaying = _videoController!.value.isPlaying;
    final currentPosition = _videoController!.value.position;
    
    // Navegar a pantalla completa
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenVideoPlayer(
          videoController: _videoController!,
          title: widget.contenido.titulo,
          wasPlaying: wasPlaying,
          initialPosition: currentPosition,
        ),
      ),
    );
  }



  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || 
           url.contains('youtu.be') || 
           url.contains('m.youtube.com');
  }

  bool _isUnsupportedUrl(String url) {
    final unsupportedDomains = [
      'vimeo.com',
      'dailymotion.com',
      'twitch.tv',
      'facebook.com',
      'instagram.com',
      'tiktok.com',
    ];
    
    return unsupportedDomains.any((domain) => url.contains(domain));
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.audiotrack, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.contenido.titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(_formatDuration(_audioPosition)),
              Expanded(
                child: Slider(
                  value: _audioPosition.inSeconds.toDouble(),
                  max: _audioDuration.inSeconds.toDouble(),
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Text(_formatDuration(_audioDuration)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _isAudioPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                ),
                onPressed: () {
                  if (_isAudioPlaying) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.resume();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    final url = widget.contenido.urlContenido;
    if (url == null || url.isEmpty) {
      return _buildErrorWidget('Imagen no disponible');
    }

    final fullUrl = url.startsWith('http') ? url : 'http://localhost:54112$url';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: fullUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => _buildErrorWidget('Error cargando imagen'),
      ),
    );
  }

  Widget _buildDocumentViewer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.description, size: 48, color: Colors.blue[300]),
          const SizedBox(height: 8),
          Text(
            widget.contenido.titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openDocument,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir Documento'),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.help_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            widget.contenido.titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tipo de contenido: ${widget.contenido.tipo}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    final isUrlError = message.contains('YouTube') || message.contains('streaming');
    
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUrlError ? Icons.link_off : Icons.error, 
            color: Colors.red[300], 
            size: 48
          ),
          const SizedBox(height: 8),
          Text(
            message, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          if (isUrlError) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ðŸ’¡ Tip: Use URLs directas como:\nâ€¢ https://ejemplo.com/video.mp4\nâ€¢ https://ejemplo.com/video.webm',
                style: TextStyle(fontSize: 12, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openDocument() async {
    final url = widget.contenido.urlContenido;
    if (url == null || url.isEmpty) return;

    final fullUrl = url.startsWith('http') ? url : 'http://localhost:54112$url';
    final uri = Uri.parse(fullUrl);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el documento'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Widget para reproductor de video en pantalla completa
class _FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController videoController;
  final String title;
  final bool wasPlaying;
  final Duration initialPosition;

  const _FullScreenVideoPlayer({
    required this.videoController,
    required this.title,
    required this.wasPlaying,
    required this.initialPosition,
  });

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  bool _showControls = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.videoController.value.isPlaying;
    
    // Escuchar cambios en el controlador
    widget.videoController.addListener(_videoListener);
    
    // Inicializar de forma asÃ­ncrona despuÃ©s del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFullScreen();
    });
  }

  Future<void> _initializeFullScreen() async {
    try {
      // Asegurar que el video estÃ© en la posiciÃ³n correcta
      await widget.videoController.seekTo(widget.initialPosition);
      
      // Restaurar el estado de reproducciÃ³n si estaba reproduciÃ©ndose
      if (widget.wasPlaying) {
        await widget.videoController.play();
      }
      
      if (mounted) {
        setState(() {
          _isPlaying = widget.videoController.value.isPlaying;
        });
      }
    } catch (e) {
    }
  }

  @override
  void dispose() {
    widget.videoController.removeListener(_videoListener);
    super.dispose();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.videoController.value.isPlaying;
      });
    }
  }

  void _togglePlayback() {
    if (_isPlaying) {
      widget.videoController.pause();
    } else {
      widget.videoController.play();
    }
  }

  void _seekVideo(int seconds) {
    final currentPosition = widget.videoController.value.position;
    final newPosition = currentPosition + Duration(seconds: seconds);
    final duration = widget.videoController.value.duration;
    
    if (newPosition >= Duration.zero && newPosition <= duration) {
      widget.videoController.seekTo(newPosition);
    }
  }

  void _exitFullScreen() async {
    // Pausar el video antes de salir si estÃ¡ reproduciÃ©ndose
    final currentlyPlaying = widget.videoController.value.isPlaying;
    if (currentlyPlaying) {
      await widget.videoController.pause();
    }
    
    Navigator.of(context).pop();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video player centrado
          Center(
            child: AspectRatio(
              aspectRatio: widget.videoController.value.aspectRatio,
              child: VideoPlayer(widget.videoController),
            ),
          ),
          
          // BotÃ³n para salir (siempre visible)
          Positioned(
            top: 40,
            right: 20,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 30),
                  onPressed: _exitFullScreen,
                ),
              ),
            ),
          ),
          
          // Controles de video
          _buildFullScreenControls(),
        ],
      ),
    );
  }

  Widget _buildFullScreenControls() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() => _showControls = !_showControls);
        },
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              children: [
                // TÃ­tulo
                Padding(
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 60),
                  child: SafeArea(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // BotÃ³n central de play/pause
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 60,
                    ),
                    onPressed: _togglePlayback,
                  ),
                ),
                
                const Spacer(),
                
                // Controles inferiores
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Barra de progreso
                      Row(
                        children: [
                          Text(
                            _formatDuration(widget.videoController.value.position),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: VideoProgressIndicator(
                                widget.videoController,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                  playedColor: AppTheme.primaryColor,
                                  bufferedColor: Colors.white.withOpacity(0.3),
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(widget.videoController.value.duration),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Botones de control
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                            onPressed: () => _seekVideo(-10),
                          ),
                          const SizedBox(width: 40),
                          Container(
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 36,
                              ),
                              onPressed: _togglePlayback,
                            ),
                          ),
                          const SizedBox(width: 40),
                          IconButton(
                            icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                            onPressed: () => _seekVideo(10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
