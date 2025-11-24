/// Extensiones útiles para la clase String
extension StringExtensions on String {
  /// Verifica si el string es nulo o vacío
  bool get isNullOrEmpty => isEmpty;
  
  /// Verifica si el string NO es nulo ni vacío
  bool get isNotNullOrEmpty => isNotEmpty;
  
  /// Capitaliza la primera letra del string
  String capitalizeFirst() {
    if (isNullOrEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  /// Convierte el string a formato título (primera letra de cada palabra en mayúscula)
  String toTitleCase() {
    if (isNullOrEmpty) return '';
    return split(' ')
        .map((word) => word.capitalizeFirst())
        .join(' ');
  }
  
  /// Trunca el string a una longitud máxima y añade sufijo si es necesario
  String truncate(int maxLength, {String suffix = '...'}) {
    if (isNullOrEmpty || length <= maxLength) return '';
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }
  
  /// Elimina todos los espacios en blanco al inicio y final
  String trimAll() {
    if (isNullOrEmpty) return '';
    return trim();
  }
  
  /// Elimina espacios extra múltiples dejando solo uno
  String removeExtraSpaces() {
    if (isNullOrEmpty) return '';
    return replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// Verifica si el string es un email válido
  bool get isEmail {
    if (isNullOrEmpty) return false;
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }
  
  /// Verifica si el string es un número de teléfono válido (formato colombiano)
  bool get isPhoneNumber {
    if (isNullOrEmpty) return false;
    // Formato: +57 3XX XXX XXXX o 3XX XXX XXXX
    return RegExp(r'^(\+57\s?)?(\d{3})\s?(\d{3})\s?(\d{4})$').hasMatch(this);
  }
  
  /// Verifica si el string contiene solo números
  bool get isNumeric {
    if (isNullOrEmpty) return false;
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }
  
  /// Verifica si el string contiene solo letras
  bool get isAlphabetic {
    if (isNullOrEmpty) return false;
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }
  
  /// Verifica si el string es alfanumérico
  bool get isAlphanumeric {
    if (isNullOrEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }
  
  /// Formatea el string como moneda (peso colombiano)
  String toCurrency({String symbol = '\$'}) {
    if (isNullOrEmpty) return '${symbol}0';
    try {
      final number = double.parse(this);
      return '$symbol${number.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      )}';
    } catch (e) {
      return this;
    }
  }
  
  /// Convierte el string a un entero seguro
  int toIntSafe({int defaultValue = 0}) {
    if (isNullOrEmpty) return defaultValue;
    try {
      return int.parse(this);
    } catch (e) {
      return defaultValue;
    }
  }
  
  /// Convierte el string a un double seguro
  double toDoubleSafe({double defaultValue = 0.0}) {
    if (isNullOrEmpty) return defaultValue;
    try {
      return double.parse(this);
    } catch (e) {
      return defaultValue;
    }
  }
  
  /// Elimina caracteres especiales dejando solo letras y números
  String removeSpecialCharacters() {
    if (isNullOrEmpty) return '';
    return replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }
  
  /// Convierte el string a formato slug (URL-friendly)
  String toSlug() {
    if (isNullOrEmpty) return '';
    return toLowerCase()
        .removeSpecialCharacters()
        .removeExtraSpaces()
        .replaceAll(' ', '-');
  }
  
  /// Verifica si el string contiene una subcadena (ignorando mayúsculas/minúsculas)
  bool containsIgnoreCase(String substring) {
    if (isNullOrEmpty || substring.isNullOrEmpty) return false;
    return toLowerCase().contains(substring.toLowerCase());
  }
  
  /// Reemplaza todas las ocurrencias de una subcadena (ignorando mayúsculas/minúsculas)
  String replaceAllIgnoreCase(String from, String to) {
    if (isNullOrEmpty) return '';
    return replaceAll(RegExp(from, caseSensitive: false), to);
  }
  
  /// Verifica si el string es una URL válida
  bool get isUrl {
    if (isNullOrEmpty) return false;
    try {
      final uri = Uri.parse(this);
      return uri.hasScheme && (uri.hasAuthority || uri.path.isNotEmpty);
    } catch (e) {
      return false;
    }
  }
  
  /// Extrae los números de un string
  String extractNumbers() {
    if (isNullOrEmpty) return '';
    return replaceAll(RegExp(r'[^0-9]'), '');
  }
  
  /// Verifica la longitud del string y devuelve un mensaje descriptivo
  String lengthDescription() {
    if (isNullOrEmpty) return 'String vacío';
    final length = this.length;
    if (length < 10) return 'Corto ($length caracteres)';
    if (length < 50) return 'Mediano ($length caracteres)';
    if (length < 100) return 'Largo ($length caracteres)';
    return 'Muy largo ($length caracteres)';
  }
}
