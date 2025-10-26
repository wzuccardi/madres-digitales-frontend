// lib/features/video_player/presentation/widgets/offline_video_player_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chewie/chewie.dart';
import '../providers/video_player_provider.dart';

class OfflineVideoPlayerWidget extends ConsumerStatefulWidget {
  final String videoUrl;
  final String? title;
  
  const OfflineVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.title,
  });

  @override
  ConsumerState<OfflineVideoPlayerWidget> createState() => _OfflineVideoPlayerWidgetState();
}

class _OfflineVideoPlayerWidgetState extends ConsumerState<OfflineVideoPlayerWidget> {
  @override
  void initState() {
    super.initState();
    // Cargar video después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(videoPlayerProvider(widget.videoUrl).notifier).loadVideo(widget.videoUrl);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoPlayerProvider(widget.videoUrl));
    final videoNotifier = ref.read(videoPlayerProvider(widget.videoUrl).notifier);
    
    return Column(
      children: [
        // Header con información de conexión
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[900],
          child: Row(
            children: [
              Icon(
                videoState.isOnline ? Icons.wifi : Icons.wifi_off,
                color: videoState.isOnline ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                videoState.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  color: videoState.isOnline ? Colors.green : Colors.red,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (videoState.isCached)
                const Row(
                  children: [
                    Icon(Icons.download_done, color: Colors.blue, size: 20),
                    SizedBox(width: 4),
                    Text(
                      'Disponible offline',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ],
                ),
              if (videoState.isDownloading)
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Descargando... ${videoState.downloadProgress.toInt()}%',
                      style: const TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ],
                ),
            ],
          ),
        ),
        
        // Reproductor de video
        Expanded(
          child: _buildVideoPlayer(context, videoState, videoNotifier),
        ),
      ],
    );
  }
  
  Widget _buildVideoPlayer(
    BuildContext context,
    VideoPlayerState state,
    VideoPlayerNotifier notifier,
  ) {
    if (state.isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Cargando video...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    
    if (state.error != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => notifier.retryLoad(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (state.chewieController != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(controller: state.chewieController!),
      );
    }
    
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'Reproductor no inicializado',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

