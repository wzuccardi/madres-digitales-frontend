// Excepciones personalizadas para la aplicación

// Excepciones de red
class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

// Excepciones de servidor
class ServerException implements Exception {
  final String message;
  
  const ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
}

// Excepciones de caché
class CacheException implements Exception {
  final String message;
  
  const CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

// Excepciones de autenticación
class AuthenticationException implements Exception {
  final String message;
  
  const AuthenticationException(this.message);
  
  @override
  String toString() => 'AuthenticationException: $message';
}

// Excepciones de autorización
class AuthorizationException implements Exception {
  final String message;
  
  const AuthorizationException(this.message);
  
  @override
  String toString() => 'AuthorizationException: $message';
}

// Excepciones de validación
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;
  
  const ValidationException(this.message, {this.fieldErrors});
  
  @override
  String toString() => 'ValidationException: $message';
}

// Excepciones de base de datos
class DatabaseException implements Exception {
  final String message;
  
  const DatabaseException(this.message);
  
  @override
  String toString() => 'DatabaseException: $message';
}

// Excepciones de almacenamiento
class StorageException implements Exception {
  final String message;
  
  const StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}

// Excepciones de sincronización
class SyncException implements Exception {
  final String message;
  
  const SyncException(this.message);
  
  @override
  String toString() => 'SyncException: $message';
}

// Excepciones de parseo
class ParseException implements Exception {
  final String message;
  
  const ParseException(this.message);
  
  @override
  String toString() => 'ParseException: $message';
}

// Excepciones de configuración
class ConfigurationException implements Exception {
  final String message;
  
  const ConfigurationException(this.message);
  
  @override
  String toString() => 'ConfigurationException: $message';
}