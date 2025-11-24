import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:camera/camera.dart';
import 'dart:async';

/// Servicio de cámara
class CameraService {
  
  CameraService();
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  StreamController<CameraImage>? _streamController;
  
  /// Inicializar cámara
  Future<void> initialize() async {
    try {
      AppLogger.debug('CameraService: Inicializando cámara');
      
      // Obtener cámaras disponibles
      _cameras = await availableCameras();
      
      if (_cameras.isNotEmpty) {
        // Seleccionar la cámara trasera por defecto
        final camera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
        );
        
        _cameraController = CameraController(
          camera,
          ResolutionPreset.high,
        );
        await _cameraController!.initialize();
        
        _isInitialized = true;
        AppLogger.debug('CameraService: Cámara inicializada correctamente');
      } else {
        AppLogger.error('CameraService: No hay cámaras disponibles');
        throw Exception('No hay cámaras disponibles');
      }
    } catch (e) {
      AppLogger.error('CameraService: Error inicializando cámara', error: e);
      rethrow;
    }
  }
  
  /// Tomar foto
  Future<String?> takePicture() async {
    try {
      AppLogger.debug('CameraService: Tomando foto');
      
      if (!_isInitialized) {
        AppLogger.error('CameraService: La cámara no está inicializada');
        return null;
      }
      
      final image = await _cameraController!.takePicture();
      AppLogger.debug('CameraService: Foto tomada correctamente');
      return image.path;
    } catch (e) {
      AppLogger.error('CameraService: Error tomando foto', error: e);
      return null;
    }
  }
  
  /// Iniciar grabación de video
  Future<void> startVideoRecording() async {
    try {
      AppLogger.debug('CameraService: Iniciando grabación de video');
      
      if (!_isInitialized) {
        AppLogger.error('CameraService: La cámara no está inicializada');
        return;
      }
      
      await _cameraController!.startVideoRecording();
      AppLogger.debug('CameraService: Grabación de video iniciada');
    } catch (e) {
      AppLogger.error('CameraService: Error iniciando grabación de video', error: e);
      rethrow;
    }
  }
  
  /// Detener grabación de video
  Future<String?> stopVideoRecording() async {
    try {
      AppLogger.debug('CameraService: Deteniendo grabación de video');
      
      if (!_isInitialized) {
        AppLogger.error('CameraService: La cámara no está inicializada');
        return null;
      }
      
      final video = await _cameraController!.stopVideoRecording();
      AppLogger.debug('CameraService: Grabación de video detenida');
      return video.path;
    } catch (e) {
      AppLogger.error('CameraService: Error deteniendo grabación de video', error: e);
      return null;
    }
  }
  
  /// Cambiar entre cámara frontal y trasera
  Future<void> switchCamera() async {
    try {
      AppLogger.debug('CameraService: Cambiando entre cámara frontal y trasera');
      
      if (!_isInitialized || _cameras.length < 2) {
        AppLogger.error('CameraService: No se puede cambiar de cámara');
        return;
      }
      
      // Obtener el índice de la cámara actual
      if (_cameraController == null) return;
      
      final currentIndex = _cameras.indexOf(_cameraController!.description);
      
      // Cambiar a la siguiente cámara
      final nextIndex = (currentIndex + 1) % _cameras.length;
      await _cameraController!.dispose();
      _cameraController = CameraController(
        _cameras[nextIndex],
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      
      AppLogger.debug('CameraService: Cámara cambiada correctamente');
    } catch (e) {
      AppLogger.error('CameraService: Error cambiando de cámara', error: e);
      rethrow;
    }
  }
  
  /// Liberar recursos
  Future<void> dispose() async {
    try {
      AppLogger.debug('CameraService: Liberando recursos de cámara');
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }
      await _streamController?.close();
      _streamController = null;
      _isInitialized = false;
      AppLogger.debug('CameraService: Recursos de cámara liberados correctamente');
    } catch (e) {
      AppLogger.error('CameraService: Error liberando recursos de cámara', error: e);
      rethrow;
    }
  }
  
  Future<Stream<CameraImage>> startCameraStream() async {
    if (!_isInitialized || _cameraController == null) {
      return const Stream.empty();
    }
    _streamController?.close();
    _streamController = StreamController<CameraImage>.broadcast();
    await _cameraController!.startImageStream((image) {
      _streamController?.add(image);
    });
    return _streamController!.stream;
  }

  Future<void> stopCameraStream() async {
    if (_cameraController != null) {
      try {
        await _cameraController!.stopImageStream();
      } catch (_) {}
    }
    await _streamController?.close();
    _streamController = null;
  }
}
