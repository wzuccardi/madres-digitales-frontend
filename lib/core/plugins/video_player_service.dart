import 'dart:io';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:video_player/video_player.dart';

/// Servicio de reproducción de video
class VideoPlayerService {
  
  VideoPlayerService();
  VideoPlayerController? _videoPlayerController;
  
  /// Reproducir video desde URL
  Future<void> playFromUrl(String url) async {
    try {
      AppLogger.debug('VideoPlayerService: Reproduciendo video desde URL: $url');
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController!.initialize();
      await _videoPlayerController!.play();
      AppLogger.debug('VideoPlayerService: Video reproduciéndose correctamente');
    } catch (e) {
      AppLogger.error('VideoPlayerService: Error reproduciendo video desde URL', error: e);
      rethrow;
    }
  }
  
  /// Reproducir video local
  Future<void> playFromLocalPath(String path) async {
    try {
      AppLogger.debug('VideoPlayerService: Reproduciendo video local: $path');
      _videoPlayerController = VideoPlayerController.file(File(path));
      await _videoPlayerController!.initialize();
      await _videoPlayerController!.play();
      AppLogger.debug('VideoPlayerService: Video local reproduciéndose correctamente');
    } catch (e) {
      AppLogger.error('VideoPlayerService: Error reproduciendo video local', error: e);
      rethrow;
    }
  }
  
  /// Pausar reproducción
  Future<void> pause() async {
    try {
      AppLogger.debug('VideoPlayerService: Pausando reproducción');
      await _videoPlayerController?.pause();
      AppLogger.debug('VideoPlayerService: Reproducción pausada correctamente');
    } catch (e) {
      AppLogger.error('VideoPlayerService: Error pausando reproducción', error: e);
      rethrow;
    }
  }
  
  /// Detener reproducción
  Future<void> stop() async {
    try {
      AppLogger.debug('VideoPlayerService: Deteniendo reproducción');
      if (_videoPlayerController != null) {
        await _videoPlayerController!.pause();
        await _videoPlayerController!.seekTo(Duration.zero);
      }
      AppLogger.debug('VideoPlayerService: Reproducción detenida correctamente');
    } catch (e) {
      AppLogger.error('VideoPlayerService: Error deteniendo reproducción', error: e);
      rethrow;
    }
  }
  
  /// Obtener duración del video
  Future<Duration?> getDuration() async {
    try {
      AppLogger.debug('VideoPlayerService: Obteniendo duración del video');
      final duration = _videoPlayerController?.value.duration;
      if (duration != null) {
        AppLogger.debug('VideoPlayerService: Duración obtenida: ${duration.inSeconds} segundos');
      }
      return duration;
    } catch (e) {
      AppLogger.error('VideoPlayerService: Error obteniendo duración', error: e);
      return null;
    }
  }
  
  /// Obtener posición actual del video
  Future<Duration?> getCurrentPosition() async {
    try {
      AppLogger.debug('VideoPlayerService: Obteniendo posición actual del video');
      final position = _videoPlayerController?.value.position;
      if (position != null) {
        AppLogger.debug('VideoPlayerService: Posición actual obtenida: ${position.inSeconds} segundos');
      }
      return position;
    } catch (e) {
      AppLogger.error('VideoPlayerService: Error obteniendo posición actual', error: e);
      return null;
    }
  }
  
  /// Liberar recursos
  Future<void> dispose() async {
    try {
      AppLogger.debug('VideoPlayerService: Liberando recursos');
      if (_videoPlayerController != null) {
        await _videoPlayerController!.dispose();
        _videoPlayerController = null;
      }
      AppLogger.debug('VideoPlayerService: Recursos liberados correctamente');
    } catch (e) {
      AppLogger.error('VideoPlayerService: Error liberando recursos', error: e);
      rethrow;
    }
  }
}
