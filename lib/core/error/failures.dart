abstract class Failure {
  final String message;
  
  const Failure(this.message);
  
  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error en el servidor']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Error de conexión']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error en la caché']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Error de validación']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permiso denegado']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Error en la base de datos']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Error desconocido']);
}