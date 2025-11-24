/// Excepción lanzada cuando hay errores de validación en los argumentos
/// de un caso de uso o método.
class ArgumentValidationException implements Exception {
  
  /// Constructor
  const ArgumentValidationException(this.message, {this.fieldErrors});
  
  /// Crea una excepción para un campo específico
  factory ArgumentValidationException.forField(
    String field,
    String error,
  ) {
    return ArgumentValidationException(
      'Validation failed for field: $field',
      fieldErrors: {field: error},
    );
  }
  
  /// Crea una excepción para múltiples campos
  factory ArgumentValidationException.forFields(
    Map<String, String> fieldErrors,
  ) {
    return ArgumentValidationException(
      'Validation failed for multiple fields',
      fieldErrors: fieldErrors,
    );
  }
  
  /// Crea una excepción para un argumento nulo o vacío
  factory ArgumentValidationException.required(String argumentName) {
    return ArgumentValidationException.forField(
      argumentName,
      'This field is required',
    );
  }
  
  /// Crea una excepción para un argumento con formato inválido
  factory ArgumentValidationException.invalidFormat(
    String argumentName,
    String expectedFormat,
  ) {
    return ArgumentValidationException.forField(
      argumentName,
      'Invalid format. Expected: $expectedFormat',
    );
  }
  
  /// Crea una excepción para un argumento fuera de rango
  factory ArgumentValidationException.outOfRange(
    String argumentName,
    dynamic min,
    dynamic max,
  ) {
    return ArgumentValidationException.forField(
      argumentName,
      'Value must be between $min and $max',
    );
  }
  /// Mensaje descriptivo del error
  final String message;
  
  /// Mapa opcional con los errores por campo específico
  final Map<String, String>? fieldErrors;
  
  @override
  String toString() {
    final buffer = StringBuffer('ArgumentValidationException: $message');
    
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      buffer.write('\nField errors:');
      fieldErrors!.forEach((field, error) {
        buffer.write('\n  $field: $error');
      });
    }
    
    return buffer.toString();
  }
}
