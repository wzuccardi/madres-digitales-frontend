// lib/features/video_player/presentation/providers/video_player_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../services/cache_service.dart';
import '../../../../services/connectivity_service.dart';
import '../../../../core/utils/url_utils.dart';

class VideoPlayerState {
  final bool isLoading;
  final bool isOnline;
  final bool isCached;
  final bool isDownloading;
  final double downloadProgress;
  final String? error;
  final ChewieController? chewieController;
  final VideoPlayerController? videoPlayerController;
  final String? currentVideoUrl;
  
  const VideoPlayerState({
    this.isLoading = false,
    this.isOnline = true,
    this.isCached = false,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.error,
    this.chewieController,
    this.videoPlayerController,
    this.currentVideoUrl,
  });
  
  VideoPlayerState copyWith({
    bool? isLoading,
    bool? isOnline,
    bool? isCached,
    bool? isDownloading,
    double? downloadProgress,
    String? error,
    ChewieController? chewieController,
    VideoPlayerController? videoPlayerController,
    String? currentVideoUrl,
  }) {
    return VideoPlayerState(
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      isCached: isCached ?? this.isCached,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      error: error,
      chewieController: chewieController ?? this.chewieController,
      videoPlayerController: videoPlayerController ?? this.videoPlayerController,
      currentVideoUrl: currentVideoUrl ?? this.currentVideoUrl,
    );
  }
}

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  final Ref ref;
  final CacheService _cacheService;
  
  VideoPlayerNotifier(this.ref, this._cacheService) : super(const VideoPlayerState()) {
    _initializeConnectivity();
  }
  
  void _initializeConnectivity() {
    ref.listen(connectivityStreamProvider, (previous, next) {
      next.when(
        data: (results) {
          final isOnline = results.contains(ConnectivityResult.mobile) || 
                         results.contains(ConnectivityResult.wifi);
          state = state.copyWith(isOnline: isOnline);
        },
        loading: () => state = state.copyWith(isOnline: true),
        error: (_, __) => state = state.copyWith(isOnline: false),
      );
    });
  }
  
  Future<void> loadVideo(String videoUrl) async {
    if (state.currentVideoUrl == videoUrl && state.chewieController != null) {
      return; // El video ya está cargado
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      currentVideoUrl: videoUrl,
    );

    try {
      // Liberar controladores anteriores
      await _disposeControllers();

      // Construir URL completa si es necesario
      final fullVideoUrl = UrlUtils.buildFullUrl(videoUrl);

      String videoPath;
      bool isLocal = false;

      // Verificar si hay conexión
      final connectivityService = ref.read(connectivityServiceProvider);
      final isConnected = await connectivityService.isConnected;

      if (isConnected) {
        // Intentar obtener del caché
        final cachedPath = await _cacheService.getCachedVideoPath(fullVideoUrl);

        if (cachedPath != null) {
          videoPath = cachedPath;
          isLocal = true;
          state = state.copyWith(isCached: true);
        } else {
          // Usar URL remota completa y descargar en segundo plano
          videoPath = fullVideoUrl;
          isLocal = false;
          state = state.copyWith(isCached: false);

          // Iniciar descarga en segundo plano
          _downloadVideoInBackground(fullVideoUrl);
        }
      } else {
        // Sin conexión, buscar en caché
        final cachedPath = await _cacheService.getCachedVideoPath(fullVideoUrl);

        if (cachedPath != null) {
          videoPath = cachedPath;
          isLocal = true;
          state = state.copyWith(isCached: true);
        } else {
          throw Exception('No hay conexión y el video no está disponible offline');
        }
      }

      // Crear controlador de video
      final videoController = isLocal
          ? VideoPlayerController.file(File(videoPath))
          : VideoPlayerController.networkUrl(Uri.parse(videoPath));

      await videoController.initialize();
      
      // Crear controlador Chewie
      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
      
      state = state.copyWith(
        isLoading: false,
        chewieController: chewieController,
        videoPlayerController: videoController,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> _downloadVideoInBackground(String videoUrl) async {
    try {
      state = state.copyWith(isDownloading: true, downloadProgress: 0.0);
      
      await _cacheService.cacheVideo(
        videoUrl,
        onProgress: (progress) {
          state = state.copyWith(downloadProgress: progress * 100);
        },
      );
      
      state = state.copyWith(
        isDownloading: false,
        isCached: true,
      );
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        error: 'Error al descargar video: $e',
      );
    }
  }
  
  Future<void> retryLoad() async {
    if (state.currentVideoUrl != null) {
      await loadVideo(state.currentVideoUrl!);
    }
  }
  
  Future<void> _disposeControllers() async {
    state.chewieController?.dispose();
    state.videoPlayerController?.dispose();
  }
  
  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }
}

// Providers
final cacheServiceProvider = Provider<CacheService>((ref) {
  final service = CacheService();
  service.init();
  return service;
});

final videoPlayerProvider = StateNotifierProvider.family<VideoPlayerNotifier, VideoPlayerState, String>(
  (ref, videoUrl) {
    final cacheService = ref.watch(cacheServiceProvider);
    return VideoPlayerNotifier(ref, cacheService);
  },
);

