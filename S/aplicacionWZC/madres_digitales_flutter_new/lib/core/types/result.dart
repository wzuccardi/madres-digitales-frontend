/// Clase para manejar resultados de operaciones que pueden tener éxito o fallo
/// Similar a Either de dartz pero con una implementación más simple
class Result<T, E> {
  
  /// Constructor para éxito
  const Result.success(this.data) : error = null;
  
  /// Constructor para fallo
  const Result.failure(this.error) : data = null;
  final T? data;
  final E? error;
  
  /// Verifica si el resultado es exitoso
  bool get isSuccess => error == null;
  
  /// Verifica si el resultado es un fallo
  bool get isFailure => error != null;
  
  /// Obtiene el valor de éxito o lanza excepción si es fallo
  T get dataOrThrow {
    if (error != null) {
      throw Exception('Result is a failure: $error');
    }
    return data!;
  }
  
  /// Obtiene el valor de fallo o lanza excepción si es éxito
  E get errorOrThrow {
    if (error == null) {
      throw Exception('Result is a success, no error available');
    }
    return error!;
  }
  
  /// Ejecuta una función basada en el resultado
  R fold<R>(R Function(T data) onSuccess, R Function(E error) onFailure) {
    if (isSuccess) {
      return onSuccess(data as T);
    } else {
      return onFailure(error as E);
    }
  }
  
  /// Ejecuta una función solo si el resultado es exitoso
  R? mapSuccess<R>(R Function(T data) onSuccess) {
    if (isSuccess && data != null) {
      return onSuccess(data as T);
    }
    return null;
  }
  
  /// Ejecuta una función solo si el resultado es un fallo
  R? mapFailure<R>(R Function(E error) onFailure) {
    if (isFailure && error != null) {
      return onFailure(error as E);
    }
    return null;
  }
  
  @override
  String toString() {
    if (isSuccess) {
      return 'Result.success(data: $data)';
    } else {
      return 'Result.failure(error: $error)';
    }
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Result<T, E> &&
        other.data == data &&
        other.error == error;
  }
  
  @override
  int get hashCode {
    return data.hashCode ^ error.hashCode;
  }
}
