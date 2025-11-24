import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';

/// Sistema de métricas de rendimiento para Madres Digitales
/// Monitorea FPS, memoria, CPU y experiencia de usuario
class PerformanceMetrics {
  
  PerformanceMetrics._internal();
  static PerformanceMetrics? _instance;
  static PerformanceMetrics get instance => _instance ??= PerformanceMetrics._internal();

  // Configuración
  bool _isMonitoring = false;
  Timer? _metricsTimer;
  final Duration _samplingInterval = const Duration(seconds: 1);
  
  // Métricas actuales
  double _currentFPS = 0.0;
  double _averageFPS = 0.0;
  int _frameCount = 0;
  final int _droppedFrames = 0;
  final Stopwatch _frameStopwatch = Stopwatch();
  
  // Métricas de memoria
  int _currentMemoryUsage = 0;
  int _peakMemoryUsage = 0;
  int _memorySamples = 0;
  
  // Métricas de rendimiento
  final Map<String, Duration> _widgetBuildTimes = {};
  final Map<String, int> _widgetRebuildCounts = {};
  
  // Callbacks para reporting
  Function(PerformanceReport)? onReportGenerated;
  Function(String, dynamic)? onMetricAlert;
  
  // Dispositivo info
  DeviceInfo? _deviceInfo;
  
  /// Inicia el monitoreo de rendimiento
  Future<void> startMonitoring({
    Function(PerformanceReport)? onReportGenerated,
    Function(String, dynamic)? onMetricAlert,
  }) async {
    if (_isMonitoring) return;
    
    this.onReportGenerated = onReportGenerated;
    this.onMetricAlert = onMetricAlert;
    
    // Obtener información del dispositivo
    await _initializeDeviceInfo();
    
    _isMonitoring = true;
    _frameStopwatch.start();
    
    // Iniciar monitoreo de frames
    WidgetsBinding.instance.addTimingsCallback(_onFrameReported);
    
    // Iniciar muestreo periódico
    _metricsTimer = Timer.periodic(_samplingInterval, (_) => _collectMetrics());
    
    developer.log('Performance monitoring started', name: 'PerformanceMetrics');
  }
  
  /// Detiene el monitoreo de rendimiento
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _frameStopwatch.stop();
    _metricsTimer?.cancel();
    
    WidgetsBinding.instance.removeTimingsCallback(_onFrameReported);
    
    developer.log('Performance monitoring stopped', name: 'PerformanceMetrics');
  }
  
  /// Registra tiempo de construcción de un widget
  void trackWidgetBuild(String widgetName, Duration duration) {
    _widgetBuildTimes[widgetName] = duration;
    
    // Alerta si el widget tarda más de 16ms
    if (duration.inMilliseconds > 16) {
      onMetricAlert?.call(
        'Slow Widget Build',
        {
          'widget': widgetName,
          'duration': '${duration.inMilliseconds}ms',
          'threshold': '16ms',
        }
      );
    }
  }
  
  /// Registra reconstrucción de widget
  void trackWidgetRebuild(String widgetName) {
    _widgetRebuildCounts[widgetName] = (_widgetRebuildCounts[widgetName] ?? 0) + 1;
    
    // Alerta si hay demasiadas reconstrucciones
    if (_widgetRebuildCounts[widgetName]! > 60) { // Más de 60 por segundo
      onMetricAlert?.call(
        'Excessive Widget Rebuilds',
        {
          'widget': widgetName,
          'rebuilds': _widgetRebuildCounts[widgetName],
          'threshold': '60/second',
        }
      );
    }
  }
  
  /// Obtiene reporte actual de rendimiento
  PerformanceReport getCurrentReport() {
    return PerformanceReport(
      timestamp: DateTime.now(),
      deviceInfo: _deviceInfo!,
      fps: _currentFPS,
      averageFPS: _averageFPS,
      droppedFrames: _droppedFrames,
      memoryUsage: _currentMemoryUsage,
      peakMemoryUsage: _peakMemoryUsage,
      widgetBuildTimes: Map.from(_widgetBuildTimes),
      widgetRebuildCounts: Map.from(_widgetRebuildCounts),
    );
  }
  
  /// Reinicia contadores de widgets
  void resetWidgetCounters() {
    _widgetBuildTimes.clear();
    _widgetRebuildCounts.clear();
  }
  
  /// Callback para reportes de frames de Flutter
  void _onFrameReported(List<dynamic> timings) {
    if (!_isMonitoring) return;
    
    for (final _ in timings) {
      _frameCount++;
      
      // Calcular FPS actual (simulado - en producción usar FrameTiming real)
      const frameDuration = 16.0; // Valor promedio para simulación
      _currentFPS = 1000.0 / frameDuration;
      
      // Actualizar promedio
      _averageFPS = (_averageFPS * (_frameCount - 1) + _currentFPS) / _frameCount;
    }
  }
  
  /// Recolección periódica de métricas
  void _collectMetrics() async {
    if (!_isMonitoring) return;
    
    // Recolectar métricas de memoria
    await _collectMemoryMetrics();
    
    // Reiniciar contadores de widgets cada segundo
    resetWidgetCounters();
    
    // Generar reporte periódico
    final report = getCurrentReport();
    onReportGenerated?.call(report);
    
    // Verificar umbrales críticos
    _checkThresholds(report);
  }
  
  /// Recolecta métricas de memoria
  Future<void> _collectMemoryMetrics() async {
    try {
      // En Android/iOS
      if (Platform.isAndroid || Platform.isIOS) {
        final info = await _getMemoryInfo();
        _currentMemoryUsage = info['current'] ?? 0;
        _peakMemoryUsage = _peakMemoryUsage < _currentMemoryUsage 
            ? _currentMemoryUsage 
            : _peakMemoryUsage;
        _memorySamples++;
      }
    } catch (e) {
      developer.log('Error collecting memory metrics: $e', name: 'PerformanceMetrics');
    }
  }
  
  /// Obtiene información de memoria del dispositivo
  Future<Map<String, int>> _getMemoryInfo() async {
    // Implementación simplificada - en producción usar plugins específicos
    if (Platform.isAndroid) {
      // Simulación para Android
      return {
        'current': 150 * 1024 * 1024, // 150MB simulado
        'peak': _peakMemoryUsage,
      };
    } else if (Platform.isIOS) {
      // Simulación para iOS
      return {
        'current': 120 * 1024 * 1024, // 120MB simulado
        'peak': _peakMemoryUsage,
      };
    }
    
    return {'current': 0, 'peak': 0};
  }
  
  /// Inicializa información del dispositivo
  Future<void> _initializeDeviceInfo() async {
    try {
      // Simulación de información del dispositivo
      _deviceInfo = DeviceInfo(
        platform: Platform.operatingSystem,
        version: Platform.operatingSystemVersion,
        model: 'Simulated Device',
        manufacturer: 'Simulated',
        totalMemory: 200 * 1024 * 1024, // 200MB simulado
        appVersion: '1.0.0',
        buildNumber: '1',
      );
    } catch (e) {
      developer.log('Error initializing device info: $e', name: 'PerformanceMetrics');
      _deviceInfo = const DeviceInfo(
        platform: 'Unknown',
        version: 'Unknown',
        model: 'Unknown',
        manufacturer: 'Unknown',
        totalMemory: 0,
        appVersion: 'Unknown',
        buildNumber: 'Unknown',
      );
    }
  }
  
  /// Verifica umbrales críticos y genera alertas
  void _checkThresholds(PerformanceReport report) {
    // Alerta de FPS bajo
    if (report.fps < 30) {
      onMetricAlert?.call(
        'Low FPS Detected',
        {
          'current_fps': report.fps.toStringAsFixed(1),
          'threshold': '30 fps',
          'average_fps': report.averageFPS.toStringAsFixed(1),
        }
      );
    }
    
    // Alerta de uso de memoria alto
    if (report.memoryUsage > 150 * 1024 * 1024) { // 150MB
      onMetricAlert?.call(
        'High Memory Usage',
        {
          'current_usage': '${(report.memoryUsage / 1024 / 1024).toStringAsFixed(1)}MB',
          'threshold': '150MB',
          'peak_usage': '${(report.peakMemoryUsage / 1024 / 1024).toStringAsFixed(1)}MB',
        }
      );
    }
    
    // Alerta de frames caídos
    if (report.droppedFrames > 10) {
      onMetricAlert?.call(
        'Excessive Dropped Frames',
        {
          'dropped_frames': report.droppedFrames.toString(),
          'threshold': '10 frames',
          'total_frames': _frameCount.toString(),
        }
      );
    }
  }
}

/// Información del dispositivo para métricas
class DeviceInfo {
  
  const DeviceInfo({
    required this.platform,
    required this.version,
    required this.model,
    required this.manufacturer,
    required this.totalMemory,
    required this.appVersion,
    required this.buildNumber,
  });
  final String platform;
  final String version;
  final String model;
  final String manufacturer;
  final int totalMemory;
  final String appVersion;
  final String buildNumber;
  
  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'version': version,
      'model': model,
      'manufacturer': manufacturer,
      'totalMemory': totalMemory,
      'appVersion': appVersion,
      'buildNumber': buildNumber,
    };
  }
}

/// Reporte de rendimiento completo
class PerformanceReport {
  
  const PerformanceReport({
    required this.timestamp,
    required this.deviceInfo,
    required this.fps,
    required this.averageFPS,
    required this.droppedFrames,
    required this.memoryUsage,
    required this.peakMemoryUsage,
    required this.widgetBuildTimes,
    required this.widgetRebuildCounts,
  });
  final DateTime timestamp;
  final DeviceInfo deviceInfo;
  final double fps;
  final double averageFPS;
  final int droppedFrames;
  final int memoryUsage;
  final int peakMemoryUsage;
  final Map<String, Duration> widgetBuildTimes;
  final Map<String, int> widgetRebuildCounts;
  
  /// Obtiene widgets más lentos
  List<Map<String, dynamic>> get slowestWidgets {
    final sorted = widgetBuildTimes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(5).map((entry) => {
      'widget': entry.key,
      'buildTime': '${entry.value.inMilliseconds}ms',
    }).toList();
  }
  
  /// Obtiene widgets más reconstruidos
  List<Map<String, dynamic>> get mostRebuiltWidgets {
    final sorted = widgetRebuildCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(5).map((entry) => {
      'widget': entry.key,
      'rebuilds': entry.value,
    }).toList();
  }
  
  /// Calcula puntaje de rendimiento (0-100)
  double get performanceScore {
    double score = 100.0;
    
    // Penalización por FPS bajo
    if (fps < 30) {
      score -= 40;
    } else if (fps < 45) {
      score -= 20;
    } else if (fps < 55) {
      score -= 10;
    }
    
    // Penalización por memoria alta
    final memoryMB = memoryUsage / 1024 / 1024;
    if (memoryMB > 200) {
      score -= 30;
    } else if (memoryMB > 150) {
      score -= 15;
    } else if (memoryMB > 100) {
      score -= 5;
    }
    
    // Penalización por frames caídos
    if (droppedFrames > 20) {
      score -= 20;
    } else if (droppedFrames > 10) {
      score -= 10;
    } else if (droppedFrames > 5) {
      score -= 5;
    }
    
    return score.clamp(0.0, 100.0);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'deviceInfo': deviceInfo.toJson(),
      'fps': fps.toStringAsFixed(2),
      'averageFPS': averageFPS.toStringAsFixed(2),
      'droppedFrames': droppedFrames,
      'memoryUsage': memoryUsage,
      'memorySamples': PerformanceMetrics.instance._memorySamples,
      'peakMemoryUsage': peakMemoryUsage,
      'memoryUsageMB': (memoryUsage / 1024 / 1024).toStringAsFixed(1),
      'peakMemoryUsageMB': (peakMemoryUsage / 1024 / 1024).toStringAsFixed(1),
      'performanceScore': performanceScore.toStringAsFixed(1),
      'slowestWidgets': slowestWidgets,
      'mostRebuiltWidgets': mostRebuiltWidgets,
      'widgetBuildTimes': widgetBuildTimes.map((k, v) => MapEntry(k, v.inMilliseconds)),
      'widgetRebuildCounts': widgetRebuildCounts,
    };
  }
}

/// Widget helper para medir rendimiento de construcción de widgets
class PerformanceWidget extends StatefulWidget {
  
  const PerformanceWidget({
    super.key,
    required this.name,
    required this.child,
  });
  final String name;
  final Widget child;
  
  @override
  State<PerformanceWidget> createState() => _PerformanceWidgetState();
}

class _PerformanceWidgetState extends State<PerformanceWidget> {
  @override
  Widget build(BuildContext context) {
    final stopwatch = Stopwatch()..start();
    
    // Registrar reconstrucción
    PerformanceMetrics.instance.trackWidgetRebuild(widget.name);
    
    final result = widget.child;
    
    stopwatch.stop();
    
    // Registrar tiempo de construcción
    PerformanceMetrics.instance.trackWidgetBuild(widget.name, stopwatch.elapsed);
    
    return result;
  }
}

/// Mixin para fácil integración de métricas en widgets
mixin PerformanceTrackingMixin<T extends StatefulWidget> on State<T> {
  String get widgetName => widget.runtimeType.toString();
  
  @override
  Widget build(BuildContext context) {
    final stopwatch = Stopwatch()..start();
    
    PerformanceMetrics.instance.trackWidgetRebuild(widgetName);
    
    final result = buildWithPerformance(context);
    
    stopwatch.stop();
    PerformanceMetrics.instance.trackWidgetBuild(widgetName, stopwatch.elapsed);
    
    return result;
  }
  
  /// Método que debe ser implementado en lugar de build()
  Widget buildWithPerformance(BuildContext context);
}