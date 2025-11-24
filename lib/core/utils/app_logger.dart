import 'dart:developer' as developer;

/// Clase para manejo de logging en la aplicación
class AppLogger {
  static const String _defaultTag = 'AppLogger';
  
  /// Log de nivel debug
  static void debug(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      time: DateTime.now(),
      level: 500,
    );
  }
  
  /// Log de nivel info
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      time: DateTime.now(),
      level: 800,
    );
  }
  
  /// Log de nivel warning
  static void warning(String message, {String? tag}) {
    developer.log(
      '⚠️ $message',
      name: tag ?? _defaultTag,
      time: DateTime.now(),
      level: 900,
    );
  }
  
  /// Log de nivel error
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      '❌ $message',
      name: tag ?? _defaultTag,
      time: DateTime.now(),
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void d(String message, {String? tag}) => debug(message, tag: tag);
  void i(String message, {String? tag}) => info(message, tag: tag);
  void w(String message, {String? tag}) => warning(message, tag: tag);
  void e(String message, {String? tag, Object? err, StackTrace? stackTrace}) => AppLogger.error(message, tag: tag, error: err, stackTrace: stackTrace);
}