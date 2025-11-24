import 'package:intl/intl.dart';

/// Extensiones útiles para la clase DateTime
extension DateTimeExtensions on DateTime {
  /// Formatea la fecha en formato corto (dd/MM/yyyy)
  String toShortDateFormat() {
    return DateFormat('dd/MM/yyyy').format(this);
  }
  
  /// Formatea la fecha en formato largo (dd 'de' MMMM 'de' yyyy)
  String toLongDateFormat() {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${day.toString().padLeft(2, '0')} de ${months[month - 1]} de $year';
  }
  
  /// Formatea la fecha en formato ISO 8601
  String toIso8601String() {
    return toIso8601String();
  }
  
  /// Formatea la fecha en formato de hora (HH:mm:ss)
  String toTimeString() {
    return DateFormat('HH:mm:ss').format(this);
  }
  
  /// Formatea la fecha y hora (dd/MM/yyyy HH:mm)
  String toDateTimeFormat() {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }
  
  /// Formatea la fecha en formato americano (MM/dd/yyyy)
  String toUsDateFormat() {
    return DateFormat('MM/dd/yyyy').format(this);
  }
  
  /// Formatea la fecha con nombre del día (lunes, 25 de diciembre de 2023)
  String toDayNameFormat() {
    final days = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${days[weekday - 1]}, ${day.toString().padLeft(2, '0')} de ${months[month - 1]} de $year';
  }
  
  /// Verifica si la fecha es hoy
  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }
  
  /// Verifica si la fecha es ayer
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return day == yesterday.day && month == yesterday.month && year == yesterday.year;
  }
  
  /// Verifica si la fecha es mañana
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return day == tomorrow.day && month == tomorrow.month && year == tomorrow.year;
  }
  
  /// Verifica si la fecha es esta semana
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek) && isBefore(endOfWeek);
  }
  
  /// Verifica si la fecha es este mes
  bool get isThisMonth {
    final now = DateTime.now();
    return month == now.month && year == now.year;
  }
  
  /// Verifica si la fecha es este año
  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }
  
  /// Calcula la edad a partir de esta fecha
  int calculateAge([DateTime? currentDate]) {
    final now = currentDate ?? DateTime.now();
    int age = now.year - year;
    
    // Ajustar si aún no ha cumplido años este año
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    
    return age;
  }
  
  /// Obtiene el primer día del mes
  DateTime get firstDayOfMonth {
    return DateTime(year, month, 1);
  }
  
  /// Obtiene el último día del mes
  DateTime get lastDayOfMonth {
    final nextMonth = DateTime(year, month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1));
  }
  
  /// Obtiene el inicio del día (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day, 0, 0, 0);
  }
  
  /// Obtiene el fin del día (23:59:59)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }
  
  /// Obtiene el inicio de la semana (lunes)
  DateTime get startOfWeek {
    final daysToMonday = weekday - DateTime.monday;
    return subtract(Duration(days: daysToMonday));
  }
  
  /// Obtiene el fin de la semana (domingo)
  DateTime get endOfWeek {
    return startOfWeek.add(const Duration(days: 6));
  }
  
  /// Verifica si es fin de semana (sábado o domingo)
  bool get isWeekend {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }
  
  /// Verifica si es día laboral (lunes a viernes)
  bool get isWeekday {
    return !isWeekend;
  }
  
  /// Obtiene el número de semana del año
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysDifference = difference(firstDayOfYear).inDays;
    return (daysDifference / 7).ceil();
  }
  
  /// Obtiene el trimestre del año (1-4)
  int get quarter {
    return ((month - 1) ~/ 3) + 1;
  }
  
  /// Obtiene el nombre del mes en español
  String get monthName {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return months[month - 1];
  }
  
  /// Obtiene el nombre del día de la semana en español
  String get dayName {
    final days = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    return days[weekday - 1];
  }
  
  /// Verifica si el año es bisiesto
  bool get isLeapYear {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
  
  /// Obtiene los días del mes
  int get daysInMonth {
    if (month == DateTime.february) {
      return isLeapYear ? 29 : 28;
    } else if (month == DateTime.april || month == DateTime.june || 
               month == DateTime.september || month == DateTime.november) {
      return 30;
    } else {
      return 31;
    }
  }
  
  /// Agrega días hábiles (ignora fines de semana)
  DateTime addBusinessDays(int days) {
    var result = this;
    var remainingDays = days;
    
    while (remainingDays > 0) {
      result = result.add(const Duration(days: 1));
      if (!result.isWeekend) {
        remainingDays--;
      }
    }
    
    return result;
  }
  
  /// Calcula días hábiles entre dos fechas
  int businessDaysUntil(DateTime endDate) {
    var days = 0;
    var current = this;
    
    while (current.isBefore(endDate)) {
      if (current.isWeekday) {
        days++;
      }
      current = current.add(const Duration(days: 1));
    }
    
    return days;
  }
  
  /// Formatea la duración de forma legible
  String formatDuration([DateTime? endDate]) {
    final end = endDate ?? DateTime.now();
    final duration = end.difference(this);
    
    if (duration.inDays > 0) {
      return '${duration.inDays} día${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hora${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minuto${duration.inMinutes == 1 ? '' : 's'}';
    } else {
      return '${duration.inSeconds} segundo${duration.inSeconds == 1 ? '' : 's'}';
    }
  }
  
  /// Verifica si la fecha está en un rango determinado
  bool isInRange(DateTime start, DateTime end) {
    return isAfter(start) && isBefore(end);
  }
  
  /// Obtiene la fecha relativa (hace 2 horas, mañana, etc.)
  String toRelativeTime([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Ayer';
      if (difference.inDays < 7) return 'Hace ${difference.inDays} días';
      if (difference.inDays < 30) return 'Hace ${(difference.inDays / 7).floor()} semana${(difference.inDays / 7).floor() == 1 ? '' : 's'}';
      if (difference.inDays < 365) return 'Hace ${(difference.inDays / 30).floor()} mes${(difference.inDays / 30).floor() == 1 ? '' : 'es'}';
      return 'Hace ${(difference.inDays / 365).floor()} año${(difference.inDays / 365).floor() == 1 ? '' : 'os'}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Ahora';
    }
  }
}
