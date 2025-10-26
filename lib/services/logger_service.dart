import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Servicio de Logging para la aplicación
/// Proporciona logging estructurado con diferentes niveles
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  /// Niveles de log
  static const String levelError = 'ERROR';
  static const String levelWarning = 'WARNING';
  static const String levelInfo = 'INFO';
  static const String levelDebug = 'DEBUG';

  /// Log de error
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(
      level: levelError,
      message: message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Log de advertencia
  void warning(
    String message, {
    Map<String, dynamic>? data,
  }) {
    _log(
      level: levelWarning,
      message: message,
      data: data,
    );
  }

  /// Log de información
  void info(
    String message, {
    Map<String, dynamic>? data,
  }) {
    _log(
      level: levelInfo,
      message: message,
      data: data,
    );
  }

  /// Log de debug (solo en modo debug)
  void debug(
    String message, {
    Map<String, dynamic>? data,
  }) {
    if (kDebugMode) {
      _log(
        level: levelDebug,
        message: message,
        data: data,
      );
    }
  }

  /// Log de autenticación
  void auth(
    String message, {
    String? userId,
    String? action,
    Map<String, dynamic>? data,
  }) {
    _log(
      level: levelInfo,
      message: '🔐 AUTH: $message',
      data: {
        if (userId != null) 'userId': userId,
        if (action != null) 'action': action,
        ...?data,
      },
    );
  }

  /// Log de API
  void api(
    String message, {
    String? method,
    String? endpoint,
    int? statusCode,
    Map<String, dynamic>? data,
  }) {
    _log(
      level: levelInfo,
      message: '🌐 API: $message',
      data: {
        if (method != null) 'method': method,
        if (endpoint != null) 'endpoint': endpoint,
        if (statusCode != null) 'statusCode': statusCode,
        ...?data,
      },
    );
  }

  /// Log de navegación
  void navigation(
    String message, {
    String? from,
    String? to,
    Map<String, dynamic>? data,
  }) {
    _log(
      level: levelDebug,
      message: '🧭 NAV: $message',
      data: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        ...?data,
      },
    );
  }

  /// Log de base de datos local
  void database(
    String message, {
    String? operation,
    String? table,
    Map<String, dynamic>? data,
  }) {
    _log(
      level: levelDebug,
      message: '💾 DB: $message',
      data: {
        if (operation != null) 'operation': operation,
        if (table != null) 'table': table,
        ...?data,
      },
    );
  }

  /// Log de performance
  void performance(
    String message, {
    int? durationMs,
    String? operation,
    Map<String, dynamic>? data,
  }) {
    _log(
      level: levelInfo,
      message: '⚡ PERF: $message',
      data: {
        if (durationMs != null) 'durationMs': durationMs,
        if (operation != null) 'operation': operation,
        ...?data,
      },
    );
  }

  /// Método interno de logging
  void _log({
    required String level,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] $message';

    // En modo debug, usar developer.log
    if (kDebugMode) {
      developer.log(
        logMessage,
        name: 'MadresDigitales',
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );

      // Imprimir datos adicionales si existen
      if (data != null && data.isNotEmpty) {
        developer.log(
          'Data: ${data.toString()}',
          name: 'MadresDigitales',
        );
      }
    }

    // En producción, enviar a servicio de logging remoto
    // TODO: Implementar envío a servicio de logging (Firebase Crashlytics, Sentry, etc.)
    if (kReleaseMode && level == levelError) {
      _sendToRemoteLogging(
        level: level,
        message: message,
        error: error,
        stackTrace: stackTrace,
        data: data,
      );
    }
  }

  /// Enviar logs a servicio remoto (placeholder)
  Future<void> _sendToRemoteLogging({
    required String level,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) async {
    // TODO: Implementar integración con Firebase Crashlytics o Sentry
    // Por ahora, solo registramos que se intentó enviar
    developer.log(
      'Log enviado a servicio remoto: $message',
      name: 'RemoteLogging',
    );
  }

  /// Limpiar logs antiguos (si se implementa persistencia local)
  Future<void> clearOldLogs() async {
    // TODO: Implementar limpieza de logs antiguos si se guardan localmente
  }
}

/// Helper para medir performance de operaciones
class PerformanceTimer {
  final String operation;
  final DateTime _startTime;
  final LoggerService _logger = LoggerService();

  PerformanceTimer(this.operation) : _startTime = DateTime.now();

  void stop({Map<String, dynamic>? data}) {
    final duration = DateTime.now().difference(_startTime);
    _logger.performance(
      '$operation completado',
      durationMs: duration.inMilliseconds,
      operation: operation,
      data: data,
    );
  }
}

/// Extension para facilitar el uso del logger
extension LoggerExtension on Object {
  void logError(String message, {StackTrace? stackTrace}) {
    LoggerService().error(
      message,
      error: this,
      stackTrace: stackTrace,
    );
  }
}

