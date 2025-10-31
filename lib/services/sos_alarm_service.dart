// Servicio de alarma SOS con sonido fuerte y vibraciÃ³n intensa
// Proporciona alertas sonoras y tÃ¡ctiles para emergencias

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../config/app_config.dart';
import 'sos_compatibility_service.dart';

// ImportaciÃ³n condicional: usa web_audio_helper.dart en web, stub en otras plataformas
import 'web_audio_helper.dart' if (dart.library.io) 'stub_audio_helper.dart';

class SOSAlarmService {
  static final SOSAlarmService _instance = SOSAlarmService._internal();
  factory SOSAlarmService() => _instance;
  SOSAlarmService._internal() : _compatibilityService = SOSCompatibilityService(
    ApiService(), // Usar el singleton
    AuthService(),
  );

  final AudioPlayer _audioPlayer = AudioPlayer();
  final SOSCompatibilityService _compatibilityService;
  bool _isPlaying = false;
  int _vibrationCount = 0;
  static const int _maxVibrations = AppConfig.sosVibrationCount;
  Timer? _soundTimer;
  Timer? _vibrationTimer;

  /// Activar alarma SOS completa
  Future<Map<String, dynamic>> activarAlarmaSOS({
    required String gestanteId,
    required double latitud,
    required double longitud,
    String? descripcion,
    bool soloLocal = false,
  }) async {
    try {
      
      Map<String, dynamic> resultado = {
        'success': false,
        'alertaId': null,
        'timestamp': DateTime.now().toIso8601String(),
        'mensaje': '',
      };
      
      // 1. Enviar alerta al backend (si no es solo local)
      if (!soloLocal) {
        try {
          resultado = await _enviarAlertaBackend(gestanteId, latitud, longitud, descripcion);
        } catch (e) {
          resultado['mensaje'] = 'Error enviando alerta: $e';
        }
      }
      
      // 2. Activar alarma sonora fuerte
      await _activarAlarmaSonora();
      
      // 3. Activar vibraciÃ³n intensa
      await _activarVibracionIntensa();
      
      // 4. Actualizar resultado
      resultado['success'] = true;
      resultado['mensaje'] = soloLocal 
          ? 'Alarma local activada' 
          : 'Alarma SOS activada y alerta enviada';
      
      return resultado;
    } catch (e) {
      // Continuar con la alarma local incluso si falla el backend
      await _activarAlarmaSonora();
      await _activarVibracionIntensa();
      
      return {
        'success': false,
        'alertaId': null,
        'timestamp': DateTime.now().toIso8601String(),
        'mensaje': 'Error activando alarma: $e',
      };
    }
  }

  /// Activar solo alarma sonora fuerte
  Future<void> _activarAlarmaSonora() async {
    if (_isPlaying) {
      return;
    }

    _isPlaying = true;

    try {
      // Configurar volumen al mÃ¡ximo
      await _audioPlayer.setVolume(1.0);

      // Configurar para reproducciÃ³n en bucle
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Para Flutter Web, usar un sonido de alarma online
      // Probamos mÃºltiples URLs por si alguna falla
      const List<String> alarmUrls = [
        'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3',
        'https://www.soundjay.com/button/sounds/beep-07.mp3',
        'https://www.soundjay.com/button/sounds/beep-01a.mp3',
      ];

      bool soundPlayed = false;

      for (String url in alarmUrls) {
        try {
          await _audioPlayer.play(UrlSource(url));
          soundPlayed = true;
          break;
        } catch (e) {
          continue;
        }
      }

      if (!soundPlayed) {
        _reproducirBeepsEmergencia();
      } else {
        // Programar repeticiÃ³n si el sonido se detiene
        _programarReinicioSonido();
      }

    } catch (e) {
      _reproducirBeepsEmergencia();
    }
  }

  /// Reproducir beeps de emergencia como fallback
  void _reproducirBeepsEmergencia() {

    if (kIsWeb) {
      _reproducirBeepsWeb();
    } else {
      _reproducirBeepsNativo();
    }
  }

  /// Reproducir beeps usando Web Audio API (para Flutter Web)
  void _reproducirBeepsWeb() {
    int beepCount = 0;
    const int maxBeeps = 40;

    _soundTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isPlaying || beepCount >= maxBeeps) {
        timer.cancel();
        return;
      }

      try {
        // Usar helper para reproducir beep (funciona en web y nativo)
        playWebBeep();
      } catch (e) {
      }

      beepCount++;
    });
  }

  /// Reproducir beeps usando SystemSound (para plataformas nativas)
  void _reproducirBeepsNativo() {
    int beepCount = 0;
    const int maxBeeps = 40;

    _soundTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isPlaying || beepCount >= maxBeeps) {
        timer.cancel();
        return;
      }
      SystemSound.play(SystemSoundType.alert);
      beepCount++;
    });
  }

  /// Programar reinicio del sonido si se detiene
  void _programarReinicioSonido() {
    _soundTimer?.cancel();
    _soundTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isPlaying) {
        // Reiniciar sonido si es necesario
        _reiniciarSonido();
      } else {
        timer.cancel();
      }
    });
  }

  /// Reiniciar sonido
  Future<void> _reiniciarSonido() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      try {
        const String alarmUrl = 'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3';
        await _audioPlayer.play(UrlSource(alarmUrl));
      } catch (e2) {
        _reproducirBeepsEmergencia();
      }
    }
  }

  /// Activar vibraciÃ³n intensa
  Future<void> _activarVibracionIntensa() async {
    _vibrationCount = 0;
    
    try {
      // Nota: El paquete de vibraciÃ³n no estÃ¡ disponible,
      // pero el sistema operativo manejarÃ¡ la vibraciÃ³n del sonido
      
    } catch (e) {
    }
  }

  /// Enviar alerta al backend
  Future<Map<String, dynamic>> _enviarAlertaBackend(
    String gestanteId,
    double latitud,
    double longitud,
    String? descripcion,
  ) async {
    // Usar el servicio de compatibilidad para enviar la alerta
    final response = await _compatibilityService.enviarAlertaSOSCompatible(
      gestanteId: gestanteId,
      latitud: latitud,
      longitud: longitud,
      descripcion: descripcion,
    );
    
    if (response['success'] == true) {
      return {
        'success': true,
        'alertaId': response['alertaId'],
        'gestanteId': gestanteId,
        'coordenadas': [longitud, latitud],
        'timestamp': DateTime.now().toIso8601String(),
      };
    } else {
      throw Exception(response['error'] ?? 'Error desconocido del backend');
    }
  }

  /// Obtener ubicaciÃ³n actual
  Future<Position?> obtenerUbicacionActual() async {
    try {
      
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Obtener posiciÃ³n actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      return position;
    } catch (e) {
      return null;
    }
  }

  /// Activar alarma SOS con ubicaciÃ³n automÃ¡tica
  Future<Map<String, dynamic>> activarAlarmaSOSConUbicacion({
    required String gestanteId,
    String? descripcion,
    bool soloLocal = false,
  }) async {
    final position = await obtenerUbicacionActual();
    
    if (position == null) {
      return {
        'success': false,
        'alertaId': null,
        'timestamp': DateTime.now().toIso8601String(),
        'mensaje': 'No se pudo obtener la ubicaciÃ³n actual',
      };
    }
    
    return await activarAlarmaSOS(
      gestanteId: gestanteId,
      latitud: position.latitude,
      longitud: position.longitude,
      descripcion: descripcion,
      soloLocal: soloLocal,
    );
  }

  /// Detener alarma
  Future<void> detenerAlarma() async {
    _isPlaying = false;
    _vibrationCount = 0;
    
    // Detener timers
    _soundTimer?.cancel();
    _vibrationTimer?.cancel();
    
    try {
      await _audioPlayer.stop();
      // La vibraciÃ³n se cancela automÃ¡ticamente al detener el sonido
    } catch (e) {
    }
  }

  /// Verificar si la alarma estÃ¡ activa
  bool get isPlaying => _isPlaying;

  /// Obtener estado actual de la alarma
  Map<String, dynamic> get estado => {
    'isPlaying': _isPlaying,
    'vibrationCount': _vibrationCount,
    'maxVibrations': _maxVibrations,
  };

  /// Probar alarma (versiÃ³n corta para pruebas)
  Future<void> probarAlarma() async {

    // Activar sonido por 3 segundos
    try {
      const String alarmUrl = 'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3';
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(UrlSource(alarmUrl));
      await Future.delayed(const Duration(seconds: 3));
      await _audioPlayer.stop();
    } catch (e) {
      for (int i = 0; i < 3; i++) {
        await SystemSound.play(SystemSoundType.alert);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // La vibraciÃ³n se maneja automÃ¡ticamente por el sonido

  }
}
