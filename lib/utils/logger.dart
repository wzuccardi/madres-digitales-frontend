import 'dart:developer' as developer;
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// NUEVO: Niveles de log
enum LogLevel {
  debug,
  info,
  warn,
  error,
  fatal,
}

/// NUEVO: Clase para representar un evento de log
class LogEvent {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;

  LogEvent({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    this.context,
  });

  /// Convertir a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.toString(),
      'message': message,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
      'context': context,
    };
  }

  @override
  String toString() {
    final timestampStr = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(timestamp);
    final contextStr = context != null ? ' | $context' : '';
    final errorStr = error != null ? ' | Error: $error' : '';
    return '[$timestampStr] [${level.name.toUpperCase()}] $message$contextStr$errorStr';
  }
}

/// NUEVO: Interfaz para salida de log
abstract class LogOutput {
  void write(LogEvent event);
  void close();
}

/// NUEVO: Salida de log para consola
class ConsoleLogOutput implements LogOutput {
  @override
  void write(LogEvent event) {
    if (kDebugMode) {
      final logMessage = event.toString();
      
      switch (event.level) {
        case LogLevel.debug:
          developer.log(logMessage, name: 'DEBUG');
          break;
        case LogLevel.info:
          developer.log(logMessage, name: 'INFO');
          break;
        case LogLevel.warn:
          developer.log(logMessage, name: 'WARN', error: event.error);
          break;
        case LogLevel.error:
          developer.log(logMessage, name: 'ERROR', error: event.error, stackTrace: event.stackTrace);
          break;
        case LogLevel.fatal:
          developer.log(logMessage, name: 'FATAL', error: event.error, stackTrace: event.stackTrace);
          break;
      }
    }
  }

  @override
  void close() {
    // No hay nada que cerrar para la salida de consola
  }
}

/// NUEVO: Salida de log para archivo
class FileLogOutput implements LogOutput {
  late final IOSink _sink;
  final String _filePath;
  final int _maxFileSize;
  final int _maxBackupFiles;

  FileLogOutput({
    String filePath = 'logs/app.log',
    int maxFileSize = 10 * 1024 * 1024, // 10 MB
    int maxBackupFiles = 5,
  }) : _filePath = filePath,
       _maxFileSize = maxFileSize,
       _maxBackupFiles = maxBackupFiles;

  Future<void> initialize() async {
    try {
      final file = File(_filePath);
      
      // Crear directorio si no existe
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      
      // Verificar si es necesario rotar el archivo
      if (await file.exists()) {
        final stat = await file.stat();
        if (stat.size > _maxFileSize) {
          await _rotateLogFiles();
        }
      }
      
      _sink = file.openWrite(mode: FileMode.append);
    } catch (e) {
      'Error inicializando FileLogOutput'.error(error: e);
      // Fallback a una salida nula si no se puede abrir el archivo
      _sink = IOSink(StreamController<List<int>>().sink);
    }
  }

  Future<void> _rotateLogFiles() async {
    try {
      // Eliminar el archivo de backup más antiguo si excede el límite
      for (int i = _maxBackupFiles - 1; i >= 1; i--) {
        final oldFile = File('$_filePath.$i');
        if (await oldFile.exists()) {
          if (i == _maxBackupFiles - 1) {
            await oldFile.delete();
          } else {
            await oldFile.rename('$_filePath.${i + 1}');
          }
        }
      }
      
      // Renombrar el archivo actual
      final currentFile = File(_filePath);
      await currentFile.rename('$_filePath.1');
    } catch (e) {
      'Error rotando archivos de log'.error(error: e);
    }
  }

  @override
  void write(LogEvent event) {
    try {
      String logMessage = '${event.timestamp.toIso8601String()} [${event.level.name}] ${event.message}';
      
      if (event.context != null && event.context!.isNotEmpty) {
        logMessage += ' | Context: ${event.context}';
      }
      
      if (event.error != null) {
        logMessage += ' | Error: ${event.error}';
      }
      
      if (event.stackTrace != null) {
        logMessage += ' | StackTrace: ${event.stackTrace}';
      }
      
      _sink.writeln(logMessage);
    } catch (e) {
      // Si hay error escribiendo al archivo, al menos imprimir en consola
      if (kDebugMode) {
        developer.log('Error escribiendo al archivo de log: $e', name: 'ERROR');
      }
    }
  }

  @override
  void close() {
    _sink.close();
  }
}

/// NUEVO: Salida de log remota (para enviar a un servidor)
class RemoteLogOutput implements LogOutput {
  final String _endpoint;
  final Duration _timeout;
  final int _maxRetries;
  final List<LogEvent> _buffer = [];
  final int _bufferSize;
  Timer? _flushTimer;

  RemoteLogOutput({
    required String endpoint,
    Duration timeout = const Duration(seconds: 10),
    int maxRetries = 3,
    int bufferSize = 100,
    Duration flushInterval = const Duration(seconds: 30),
  }) : _endpoint = endpoint,
       _timeout = timeout,
       _maxRetries = maxRetries,
       _bufferSize = bufferSize {
    
    // Iniciar timer para flush automático
    _flushTimer = Timer.periodic(flushInterval, (_) => _flush());
  }

  @override
  void write(LogEvent event) {
    _buffer.add(event);
    
    // Si el buffer está lleno, hacer flush
    if (_buffer.length >= _bufferSize) {
      _flush();
    }
  }

  Future<void> _flush() async {
    if (_buffer.isEmpty) return;
    
    final events = List<LogEvent>.from(_buffer);
    _buffer.clear();
    
    try {
      // En una implementación real, aquí se enviarían los eventos al servidor
      // Por ahora, solo simulamos el envío
      
      'Enviando ${events.length} eventos de log al servidor remoto'.debug();
      
      // Simulación de envío
      await Future.delayed(const Duration(milliseconds: 100));
      
      'Eventos de log enviados exitosamente al servidor remoto'.debug();
    } catch (e) {
      'Error enviando eventos de log al servidor remoto'.error(error: e);
      
      // Si hay error, volver a agregar los eventos al buffer para reintentar
      _buffer.insertAll(0, events);
    }
  }

  @override
  void close() {
    _flushTimer?.cancel();
    _flush();
  }
}

/// NUEVO: Extensiones para facilitar el logging
extension StringExtensions on String {
  void debug({dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    AppLogger.instance.debug(this, error: error, stackTrace: stackTrace, context: context);
  }

  void info({dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    AppLogger.instance.info(this, error: error, stackTrace: stackTrace, context: context);
  }

  void warn({dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    AppLogger.instance.warn(this, error: error, stackTrace: stackTrace, context: context);
  }

  void error({dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    AppLogger.instance.error(this, error: error, stackTrace: stackTrace, context: context);
  }

  void fatal({dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    AppLogger.instance.fatal(this, error: error, stackTrace: stackTrace, context: context);
  }
}

/// NUEVO: Logger principal de la aplicación
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  static AppLogger get instance => _instance;

  final List<LogOutput> _outputs = [];
  LogLevel _minLevel = LogLevel.debug;
  final List<LogEvent> _history = [];
  final int _maxHistorySize = 1000;

  /// NUEVO: Configurar el logger
  void configure({
    LogLevel? minLevel,
    List<LogOutput>? outputs,
    bool enableConsole = true,
    bool enableFile = false,
    String filePath = 'logs/app.log',
    bool enableRemote = false,
    String? remoteEndpoint,
  }) {
    if (minLevel != null) {
      _minLevel = minLevel;
    }

    _outputs.clear();

    // Agregar salida de consola
    if (enableConsole) {
      _outputs.add(ConsoleLogOutput());
    }

    // Agregar salida de archivo
    if (enableFile) {
      final fileOutput = FileLogOutput(filePath: filePath);
      fileOutput.initialize();
      _outputs.add(fileOutput);
    }

    // Agregar salida remota
    if (enableRemote && remoteEndpoint != null) {
      _outputs.add(RemoteLogOutput(endpoint: remoteEndpoint));
    }
  }

  /// NUEVO: Cerrar todos los outputs
  void dispose() {
    for (final output in _outputs) {
      output.close();
    }
    _outputs.clear();
  }

  /// NUEVO: Obtener el historial de logs
  List<LogEvent> getHistory({LogLevel? minLevel}) {
    if (minLevel == null) {
      return List.from(_history);
    }
    
    return _history.where((event) => event.level.index >= minLevel.index).toList();
  }

  /// NUEVO: Limpiar el historial de logs
  void clearHistory() {
    _history.clear();
  }

  /// NUEVO: Escribir un evento de log
  void log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    // Verificar si el nivel es suficiente para loggear
    if (level.index < _minLevel.index) {
      return;
    }

    final event = LogEvent(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );

    // Agregar al historial
    _history.add(event);
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }

    // Escribir a todos los outputs
    for (final output in _outputs) {
      try {
        output.write(event);
      } catch (e) {
        // Si hay error en un output, al menos imprimir en consola
        if (kDebugMode) {
          developer.log('Error en output de log: $e', name: 'ERROR');
        }
      }
    }
  }

  /// NUEVO: Métodos de conveniencia para cada nivel de log
  void debug(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    log(LogLevel.debug, message, error: error, stackTrace: stackTrace, context: context);
  }

  void info(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    log(LogLevel.info, message, error: error, stackTrace: stackTrace, context: context);
  }

  void warn(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    log(LogLevel.warn, message, error: error, stackTrace: stackTrace, context: context);
  }

  void error(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    log(LogLevel.error, message, error: error, stackTrace: stackTrace, context: context);
  }

  void fatal(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    log(LogLevel.fatal, message, error: error, stackTrace: stackTrace, context: context);
  }
}

/// NUEVO: Logger global para usar en toda la aplicación
final appLogger = AppLogger.instance;