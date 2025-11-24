// Excepciones personalizadas para la aplicación

// Excepciones de red
class NetworkException implements Exception {
  
  const NetworkException(this.message);
  final String message;
  
  @override
  String toString() => 'NetworkException: $message';
}

// Excepciones de servidor
class ServerException implements Exception {
  
  const ServerException(this.message);
  final String message;
  
  @override
  String toString() => 'ServerException: $message';
}

// Excepciones de caché
class CacheException implements Exception {
  
  const CacheException(this.message);
  final String message;
  
  @override
  String toString() => 'CacheException: $message';
}

// Excepciones de autenticación
class AuthenticationException implements Exception {
  
  const AuthenticationException(this.message);
  final String message;
  
  @override
  String toString() => 'AuthenticationException: $message';
}

// Excepciones de autorización
class AuthorizationException implements Exception {
  
  const AuthorizationException(this.message);
  final String message;
  
  @override
  String toString() => 'AuthorizationException: $message';
}

// Excepciones de validación
class ValidationException implements Exception {
  
  const ValidationException(this.message, {this.fieldErrors});
  final String message;
  final Map<String, String>? fieldErrors;
  
  @override
  String toString() => 'ValidationException: $message';
}

// Excepciones de base de datos
class DatabaseException implements Exception {
  
  const DatabaseException(this.message);
  final String message;
  
  @override
  String toString() => 'DatabaseException: $message';
}

// Excepciones de almacenamiento
class StorageException implements Exception {
  
  const StorageException(this.message);
  final String message;
  
  @override
  String toString() => 'StorageException: $message';
}

// Excepciones de sincronización
class SyncException implements Exception {
  
  const SyncException(this.message);
  final String message;
  
  @override
  String toString() => 'SyncException: $message';
}

// Excepciones de parseo
class ParseException implements Exception {
  
  const ParseException(this.message);
  final String message;
  
  @override
  String toString() => 'ParseException: $message';
}

// Excepciones de configuración
class ConfigurationException implements Exception {
  
  const ConfigurationException(this.message);
  final String message;
  
  @override
  String toString() => 'ConfigurationException: $message';
}
