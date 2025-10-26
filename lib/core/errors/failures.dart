import 'package:equatable/equatable.dart';

// Clase base para todos los fallos
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
  
  @override
  String toString() => 'Failure: $message';
}

// Fallos de red
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
  
  @override
  String toString() => 'NetworkFailure: $message';
}

// Fallos de servidor
class ServerFailure extends Failure {
  const ServerFailure(super.message);
  
  @override
  String toString() => 'ServerFailure: $message';
}

// Fallos de caché
class CacheFailure extends Failure {
  const CacheFailure(super.message);
  
  @override
  String toString() => 'CacheFailure: $message';
}

// Fallos de autenticación
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
  
  @override
  String toString() => 'AuthenticationFailure: $message';
}

// Fallos de autorización
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(super.message);
  
  @override
  String toString() => 'AuthorizationFailure: $message';
}

// Fallos de validación
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  
  const ValidationFailure(super.message, {this.fieldErrors});
  
  @override
  List<Object> get props => [message, fieldErrors ?? {}];
  
  @override
  String toString() => 'ValidationFailure: $message';
}

// Fallos de base de datos
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
  
  @override
  String toString() => 'DatabaseFailure: $message';
}

// Fallos de almacenamiento
class StorageFailure extends Failure {
  const StorageFailure(super.message);
  
  @override
  String toString() => 'StorageFailure: $message';
}

// Fallos de sincronización
class SyncFailure extends Failure {
  const SyncFailure(super.message);
  
  @override
  String toString() => 'SyncFailure: $message';
}

// Fallos de parseo
class ParseFailure extends Failure {
  const ParseFailure(super.message);
  
  @override
  String toString() => 'ParseFailure: $message';
}

// Fallos de configuración
class ConfigurationFailure extends Failure {
  const ConfigurationFailure(super.message);
  
  @override
  String toString() => 'ConfigurationFailure: $message';
}

// Fallos de no encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
  
  @override
  String toString() => 'NotFoundFailure: $message';
}

// Fallos de permisos
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
  
  @override
  String toString() => 'PermissionFailure: $message';
}

// Fallos de tiempo de espera
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message);
  
  @override
  String toString() => 'TimeoutFailure: $message';
}

// Fallos desconocidos
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
  
  @override
  String toString() => 'UnknownFailure: $message';
}