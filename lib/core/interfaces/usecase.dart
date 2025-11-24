/// Clase base para todos los casos de uso.
///
/// Cada caso de uso debe implementar esta clase y especificar
/// el tipo de parámetros [Params] y el tipo de retorno [Type].
abstract class UseCase<T, Params> {
  /// Ejecuta el caso de uso con los parámetros proporcionados.
  ///
  /// Devuelve un valor de tipo [Type] o lanza una excepción en caso de error.
  Future<T> call(Params params);
}

/// Clase para casos de uso que no requieren parámetros.
abstract class NoParamsUseCase<T> {
  /// Ejecuta el caso de uso sin parámetros.
  ///
  /// Devuelve un valor de tipo [Type] o lanza una excepción en caso de error.
  Future<T> call();
}

/// Clase para casos de uso que son síncronos.
abstract class SyncUseCase<T, Params> {
  /// Ejecuta el caso de uso de forma síncrona con los parámetros proporcionados.
  ///
  /// Devuelve un valor de tipo [Type] o lanza una excepción en caso de error.
  T call(Params params);
}

/// Clase para casos de uso síncronos que no requieren parámetros.
abstract class SyncNoParamsUseCase<T> {
  /// Ejecuta el caso de uso de forma síncrona sin parámetros.
  ///
  /// Devuelve un valor de tipo [Type] o lanza una excepción en caso de error.
  T call();
}

/// Clase para casos de uso que devuelven un Stream.
abstract class StreamUseCase<T, Params> {
  /// Ejecuta el caso de uso con los parámetros proporcionados.
  ///
  /// Devuelve un [Stream] que emite valores de tipo [Type].
  Stream<T> call(Params params);
}

/// Clase para casos de uso que devuelven un Stream sin parámetros.
abstract class StreamNoParamsUseCase<T> {
  /// Ejecuta el caso de uso sin parámetros.
  ///
  /// Devuelve un [Stream] que emite valores de tipo [Type].
  Stream<T> call();
}
