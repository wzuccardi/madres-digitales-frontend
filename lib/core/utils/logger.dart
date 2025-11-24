import 'dart:developer' as developer;

// Alias para mantener compatibilidad con el código existente
typedef Logger = AppLogger;

class AppLogger {
  static void debug(String message, {Map<String, dynamic>? context, Object? error}) {
    final contextStr = context != null ? ' | Context: $context' : '';
    final errorStr = error != null ? ' | Error: $error' : '';
    developer.log('[DEBUG] $message$contextStr$errorStr', name: 'AppLogger');
  }
  
  static void info(String message, {Map<String, dynamic>? context, Object? error}) {
    final contextStr = context != null ? ' | Context: $context' : '';
    final errorStr = error != null ? ' | Error: $error' : '';
    developer.log('[INFO] $message$contextStr$errorStr', name: 'AppLogger');
  }
  
  static void warn(String message, {Map<String, dynamic>? context, Object? error}) {
    final contextStr = context != null ? ' | Context: $context' : '';
    final errorStr = error != null ? ' | Error: $error' : '';
    developer.log('[WARNING] $message$contextStr$errorStr', name: 'AppLogger');
  }
  
  static void warning(String message, {Map<String, dynamic>? context, Object? error}) {
    warn(message, context: context, error: error);
  }
  
  static void error(String message, {Map<String, dynamic>? context, Object? error}) {
    final contextStr = context != null ? ' | Context: $context' : '';
    final errorStr = error != null ? ' | Error: $error' : '';
    developer.log('[ERROR] $message$contextStr$errorStr', name: 'AppLogger');
  }
}

// Instancia global para compatibilidad
final appLogger = AppLogger();
