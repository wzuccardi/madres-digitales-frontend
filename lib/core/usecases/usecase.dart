
/// Clase base para todos los casos de uso.
///
/// Cada caso de uso debe implementar esta clase y especificar
/// el tipo de parámetros [Params] y el tipo de retorno [Type].
abstract class UseCase<Type, Params> {
  /// Ejecuta el caso de uso con los parámetros proporcionados.
  ///
  /// Devuelve un valor de tipo [Type] o lanza una excepción en caso de error.
  Future<Type> call(Params params);
}

/// Clase para casos de uso que no requieren parámetros.
abstract class NoParamsUseCase<Type> {
  /// Ejecuta el caso de uso sin parámetros.
  ///
  /// Devuelve un valor de tipo [Type] o lanza una excepción en caso de error.
  Future<Type> call();
}

/// Clase para casos de uso que son síncronos.
abstract class SyncUseCase<Type, Params> {
  /// Ejecuta el caso de uso de forma síncrona con los parámetros proporcionados.
  ///
  /// Devuelve un valor de tipo [Type] o lanza una excepción en caso de error.
  Type call(Params params);
}

/// Clase para casos de uso síncronos que no requieren parámetros.
abstract class SyncNoParamsUseCase<Type> {
  /// Ejecuta el caso de uso de forma síncrona sin parámetros.
  ///
  /// Devuelve un valor de tipo [Type] o lanza una excepción en caso de error.
  Type call();
}

/// Clase para casos de uso que devuelven un Stream.
abstract class StreamUseCase<Type, Params> {
  /// Ejecuta el caso de uso con los parámetros proporcionados.
  ///
  /// Devuelve un [Stream] que emite valores de tipo [Type].
  Stream<Type> call(Params params);
}

/// Clase para casos de uso que devuelven un Stream sin parámetros.
abstract class StreamNoParamsUseCase<Type> {
  /// Ejecuta el caso de uso sin parámetros.
  ///
  /// Devuelve un [Stream] que emite valores de tipo [Type].
  Stream<Type> call();
}