import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:audioplayers/audioplayers.dart';

/// Servicio de reproducción de audio
class AudioPlayerService {
  
  AudioPlayerService() : _audioPlayer = AudioPlayer();
  final AudioPlayer _audioPlayer;
  
  /// Reproducir audio desde URL
  Future<void> playFromUrl(String url) async {
    try {
      AppLogger.debug('AudioPlayerService: Reproduciendo audio desde URL: $url');
      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();
      AppLogger.debug('AudioPlayerService: Audio reproduciéndose correctamente');
    } catch (e) {
      AppLogger.error('AudioPlayerService: Error reproduciendo audio desde URL', error: e);
      rethrow;
    }
  }
  
  /// Reproducir audio local
  Future<void> playFromLocalPath(String path) async {
    try {
      AppLogger.debug('AudioPlayerService: Reproduciendo audio local: $path');
      await _audioPlayer.setSourceDeviceFile(path);
      await _audioPlayer.resume();
      AppLogger.debug('AudioPlayerService: Audio local reproduciéndose correctamente');
    } catch (e) {
      AppLogger.error('AudioPlayerService: Error reproduciendo audio local', error: e);
      rethrow;
    }
  }
  
  /// Pausar reproducción
  Future<void> pause() async {
    try {
      AppLogger.debug('AudioPlayerService: Pausando reproducción');
      await _audioPlayer.pause();
      AppLogger.debug('AudioPlayerService: Reproducción pausada correctamente');
    } catch (e) {
      AppLogger.error('AudioPlayerService: Error pausando reproducción', error: e);
      rethrow;
    }
  }
  
  /// Detener reproducción
  Future<void> stop() async {
    try {
      AppLogger.debug('AudioPlayerService: Deteniendo reproducción');
      await _audioPlayer.stop();
      AppLogger.debug('AudioPlayerService: Reproducción detenida correctamente');
    } catch (e) {
      AppLogger.error('AudioPlayerService: Error deteniendo reproducción', error: e);
      rethrow;
    }
  }
  
  /// Obtener duración del audio
  Future<Duration?> getDuration() async {
    try {
      AppLogger.debug('AudioPlayerService: Obteniendo duración del audio');
      final duration = await _audioPlayer.getDuration();
      AppLogger.debug('AudioPlayerService: Duración obtenida: ${duration?.inSeconds} segundos');
      return duration;
    } catch (e) {
      AppLogger.error('AudioPlayerService: Error obteniendo duración', error: e);
      return null;
    }
  }
  
  /// Obtener posición actual del audio
  Future<Duration?> getCurrentPosition() async {
    try {
      AppLogger.debug('AudioPlayerService: Obteniendo posición actual del audio');
      final position = await _audioPlayer.getCurrentPosition();
      AppLogger.debug('AudioPlayerService: Posición actual obtenida: ${position?.inSeconds} segundos');
      return position;
    } catch (e) {
      AppLogger.error('AudioPlayerService: Error obteniendo posición actual', error: e);
      return null;
    }
  }
  
  /// Liberar recursos
  Future<void> dispose() async {
    try {
      AppLogger.debug('AudioPlayerService: Liberando recursos');
      await _audioPlayer.dispose();
      AppLogger.debug('AudioPlayerService: Recursos liberados correctamente');
    } catch (e) {
      AppLogger.error('AudioPlayerService: Error liberando recursos', error: e);
      rethrow;
    }
  }
}
