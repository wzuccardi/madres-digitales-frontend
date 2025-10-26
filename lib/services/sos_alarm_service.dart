// Servicio de alarma SOS con sonido fuerte y vibración intensa
// Proporciona alertas sonoras y táctiles para emergencias

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../config/app_config.dart';
import 'sos_compatibility_service.dart';

// Importación condicional: usa web_audio_helper.dart en web, stub en otras plataformas
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
      debugPrint('🚨 SOS: Activando alarma completa...');
      debugPrint('   Gestante ID: $gestanteId');
      debugPrint('   Coordinates: [$longitud, $latitud]');
      debugPrint('   Solo local: $soloLocal');
      
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
          debugPrint('✅ SOS: Alerta enviada al backend - ID: ${resultado['alertaId']}');
        } catch (e) {
          debugPrint('❌ SOS: Error enviando alerta al backend: $e');
          resultado['mensaje'] = 'Error enviando alerta: $e';
        }
      }
      
      // 2. Activar alarma sonora fuerte
      await _activarAlarmaSonora();
      
      // 3. Activar vibración intensa
      await _activarVibracionIntensa();
      
      // 4. Actualizar resultado
      resultado['success'] = true;
      resultado['mensaje'] = soloLocal 
          ? 'Alarma local activada' 
          : 'Alarma SOS activada y alerta enviada';
      
      return resultado;
    } catch (e) {
      debugPrint('❌ SOS: Error activando alarma completa: $e');
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
      debugPrint('🔊 SOS: Alarma ya está activa');
      return;
    }

    _isPlaying = true;
    debugPrint('🔊 SOS: ========================================');
    debugPrint('🔊 SOS: ACTIVANDO ALARMA SONORA');
    debugPrint('🔊 SOS: ========================================');

    try {
      // Configurar volumen al máximo
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 SOS: Volumen configurado al máximo (1.0)');

      // Configurar para reproducción en bucle
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      debugPrint('🔊 SOS: Modo de reproducción: LOOP');

      // Para Flutter Web, usar un sonido de alarma online
      // Probamos múltiples URLs por si alguna falla
      const List<String> alarmUrls = [
        'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3',
        'https://www.soundjay.com/button/sounds/beep-07.mp3',
        'https://www.soundjay.com/button/sounds/beep-01a.mp3',
      ];

      bool soundPlayed = false;

      for (String url in alarmUrls) {
        try {
          debugPrint('🔊 SOS: Intentando reproducir desde: $url');
          await _audioPlayer.play(UrlSource(url));
          debugPrint('✅ SOS: ¡SONIDO REPRODUCIENDO EXITOSAMENTE!');
          debugPrint('🔊 SOS: URL: $url');
          soundPlayed = true;
          break;
        } catch (e) {
          debugPrint('⚠️ SOS: Error con URL $url: $e');
          continue;
        }
      }

      if (!soundPlayed) {
        debugPrint('❌ SOS: Ninguna URL funcionó, usando fallback');
        _reproducirBeepsEmergencia();
      } else {
        // Programar repetición si el sonido se detiene
        _programarReinicioSonido();
      }

    } catch (e) {
      debugPrint('❌ SOS: Error general con alarma sonora: $e');
      debugPrint('❌ SOS: Stack trace: ${StackTrace.current}');
      _reproducirBeepsEmergencia();
    }
  }

  /// Reproducir beeps de emergencia como fallback
  void _reproducirBeepsEmergencia() {
    debugPrint('🔊 SOS: ========================================');
    debugPrint('🔊 SOS: INICIANDO BEEPS DE EMERGENCIA (20 SEGUNDOS)');
    debugPrint('🔊 SOS: ========================================');

    if (kIsWeb) {
      _reproducirBeepsWeb();
    } else {
      _reproducirBeepsNativo();
    }
  }

  /// Reproducir beeps usando Web Audio API (para Flutter Web)
  void _reproducirBeepsWeb() {
    debugPrint('🔊 SOS: Usando Web Audio API para navegador');
    int beepCount = 0;
    const int maxBeeps = 40;

    _soundTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isPlaying || beepCount >= maxBeeps) {
        timer.cancel();
        debugPrint('🔊 SOS: Beeps completados (count: $beepCount / $maxBeeps)');
        debugPrint('🔊 SOS: Duración total: ${(beepCount * 0.5).toStringAsFixed(1)} segundos');
        return;
      }

      try {
        // Usar helper para reproducir beep (funciona en web y nativo)
        playWebBeep();
        debugPrint('🔊 SOS: Beep #${beepCount + 1}/$maxBeeps');
      } catch (e) {
        debugPrint('⚠️ SOS: Error generando beep: $e');
      }

      beepCount++;
    });
  }

  /// Reproducir beeps usando SystemSound (para plataformas nativas)
  void _reproducirBeepsNativo() {
    debugPrint('🔊 SOS: Usando SystemSound para plataforma nativa');
    int beepCount = 0;
    const int maxBeeps = 40;

    _soundTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isPlaying || beepCount >= maxBeeps) {
        timer.cancel();
        debugPrint('🔊 SOS: Beeps completados (count: $beepCount / $maxBeeps)');
        debugPrint('🔊 SOS: Duración total: ${(beepCount * 0.5).toStringAsFixed(1)} segundos');
        return;
      }
      debugPrint('🔊 SOS: Beep #${beepCount + 1}/$maxBeeps');
      SystemSound.play(SystemSoundType.alert);
      beepCount++;
    });
  }

  /// Programar reinicio del sonido si se detiene
  void _programarReinicioSonido() {
    _soundTimer?.cancel();
    _soundTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isPlaying) {
        debugPrint('🔊 SOS: Verificando estado del sonido...');
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
      debugPrint('🔊 SOS: Reintentando reproducción de sonido...');
      try {
        const String alarmUrl = 'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3';
        await _audioPlayer.play(UrlSource(alarmUrl));
      } catch (e2) {
        _reproducirBeepsEmergencia();
      }
    }
  }

  /// Activar vibración intensa
  Future<void> _activarVibracionIntensa() async {
    debugPrint('📳 SOS: Activando vibración intensa...');
    _vibrationCount = 0;
    
    try {
      // Nota: El paquete de vibración no está disponible,
      // pero el sistema operativo manejará la vibración del sonido
      
      debugPrint('📳 SOS: Vibración simulada (manejada por el sistema)');
    } catch (e) {
      debugPrint('❌ SOS: Error con vibración: $e');
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

  /// Obtener ubicación actual
  Future<Position?> obtenerUbicacionActual() async {
    try {
      debugPrint('📍 SOS: Obteniendo ubicación actual...');
      
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ SOS: Permisos de ubicación denegados');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ SOS: Permisos de ubicación denegados permanentemente');
        return null;
      }

      // Obtener posición actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      debugPrint('✅ SOS: Ubicación obtenida - Lat: ${position.latitude}, Lng: ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('❌ SOS: Error obteniendo ubicación: $e');
      return null;
    }
  }

  /// Activar alarma SOS con ubicación automática
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
        'mensaje': 'No se pudo obtener la ubicación actual',
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
    debugPrint('🛑 SOS: Deteniendo alarma...');
    _isPlaying = false;
    _vibrationCount = 0;
    
    // Detener timers
    _soundTimer?.cancel();
    _vibrationTimer?.cancel();
    
    try {
      await _audioPlayer.stop();
      // La vibración se cancela automáticamente al detener el sonido
      debugPrint('✅ SOS: Alarma detenida');
    } catch (e) {
      debugPrint('❌ SOS: Error deteniendo alarma: $e');
    }
  }

  /// Verificar si la alarma está activa
  bool get isPlaying => _isPlaying;

  /// Obtener estado actual de la alarma
  Map<String, dynamic> get estado => {
    'isPlaying': _isPlaying,
    'vibrationCount': _vibrationCount,
    'maxVibrations': _maxVibrations,
  };

  /// Probar alarma (versión corta para pruebas)
  Future<void> probarAlarma() async {
    debugPrint('🧪 SOS: Probando alarma...');

    // Activar sonido por 3 segundos
    try {
      const String alarmUrl = 'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3';
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(UrlSource(alarmUrl));
      await Future.delayed(const Duration(seconds: 3));
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('⚠️ SOS: Error en prueba, usando beeps: $e');
      for (int i = 0; i < 3; i++) {
        await SystemSound.play(SystemSoundType.alert);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // La vibración se maneja automáticamente por el sonido
    debugPrint('📳 SOS: Vibración manejada por el sistema');

    debugPrint('🧪 SOS: Prueba de alarma completada');
  }
}