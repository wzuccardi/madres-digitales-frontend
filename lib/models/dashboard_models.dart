/// Modelo para estadísticas del dashboard
class DashboardStats {
  final int totalGestantes;
  final int controlesRealizados;
  final int alertasActivas;
  final int contenidosVistos;
  final int proximosControles;
  final double tasaCumplimiento;
  final int totalMedicos;
  final int totalIps;
  final DateTime? lastUpdated;
  final Map<String, dynamic>? datosAdicionales;

  DashboardStats({
    required this.totalGestantes,
    required this.controlesRealizados,
    required this.alertasActivas,
    required this.contenidosVistos,
    required this.proximosControles,
    required this.tasaCumplimiento,
    required this.totalMedicos,
    required this.totalIps,
    this.lastUpdated,
    this.datosAdicionales,
  });

  /// Crear estadísticas vacías
  factory DashboardStats.empty() {
    return DashboardStats(
      totalGestantes: 0,
      controlesRealizados: 0,
      alertasActivas: 0,
      contenidosVistos: 0,
      proximosControles: 0,
      tasaCumplimiento: 0.0,
      totalMedicos: 0,
      totalIps: 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Crear desde JSON
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalGestantes: _parseInt(json['totalGestantes']),
      controlesRealizados: _parseInt(json['controlesRealizados']) ?? _parseInt(json['controles']) ?? 0,
      alertasActivas: _parseInt(json['alertasActivas']),
      contenidosVistos: _parseInt(json['contenidosVistos']),
      proximosControles: _parseInt(json['proximosControles']),
      tasaCumplimiento: _parseDouble(json['tasaCumplimiento']),
      totalMedicos: _parseInt(json['totalMedicos']),
      totalIps: _parseInt(json['totalIps']),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : DateTime.now(),
      datosAdicionales: json['datosAdicionales'],
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'totalGestantes': totalGestantes,
      'controlesRealizados': controlesRealizados,
      'alertasActivas': alertasActivas,
      'contenidosVistos': contenidosVistos,
      'proximosControles': proximosControles,
      'tasaCumplimiento': tasaCumplimiento,
      'totalMedicos': totalMedicos,
      'totalIps': totalIps,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'datosAdicionales': datosAdicionales,
    };
  }

  /// Crear una copia con valores actualizados
  DashboardStats copyWith({
    int? totalGestantes,
    int? controlesRealizados,
    int? alertasActivas,
    int? contenidosVistos,
    int? proximosControles,
    double? tasaCumplimiento,
    int? totalMedicos,
    int? totalIps,
    DateTime? lastUpdated,
    Map<String, dynamic>? datosAdicionales,
  }) {
    return DashboardStats(
      totalGestantes: totalGestantes ?? this.totalGestantes,
      controlesRealizados: controlesRealizados ?? this.controlesRealizados,
      alertasActivas: alertasActivas ?? this.alertasActivas,
      contenidosVistos: contenidosVistos ?? this.contenidosVistos,
      proximosControles: proximosControles ?? this.proximosControles,
      tasaCumplimiento: tasaCumplimiento ?? this.tasaCumplimiento,
      totalMedicos: totalMedicos ?? this.totalMedicos,
      totalIps: totalIps ?? this.totalIps,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      datosAdicionales: datosAdicionales ?? this.datosAdicionales,
    );
  }

  @override
  String toString() {
    return 'DashboardStats{totalGestantes: $totalGestantes, controlesRealizados: $controlesRealizados, alertasActivas: $alertasActivas, contenidosVistos: $contenidosVistos, proximosControles: $proximosControles, tasaCumplimiento: $tasaCumplimiento, totalMedicos: $totalMedicos, totalIps: $totalIps}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DashboardStats &&
      other.totalGestantes == totalGestantes &&
      other.controlesRealizados == controlesRealizados &&
      other.alertasActivas == alertasActivas &&
      other.contenidosVistos == contenidosVistos &&
      other.proximosControles == proximosControles &&
      other.tasaCumplimiento == tasaCumplimiento &&
      other.totalMedicos == totalMedicos &&
      other.totalIps == totalIps;
  }

  @override
  int get hashCode {
    return totalGestantes.hashCode ^
      controlesRealizados.hashCode ^
      alertasActivas.hashCode ^
      contenidosVistos.hashCode ^
      proximosControles.hashCode ^
      tasaCumplimiento.hashCode ^
      totalMedicos.hashCode ^
      totalIps.hashCode;
  }
}

/// Modelo para datos de tendencia del dashboard
class DashboardTrend {
  final String metric;
  final List<DashboardTrendPoint> points;
  final String period;
  final DateTime startDate;
  final DateTime endDate;

  DashboardTrend({
    required this.metric,
    required this.points,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  /// Crear desde JSON
  factory DashboardTrend.fromJson(Map<String, dynamic> json) {
    return DashboardTrend(
      metric: json['metric'] ?? '',
      points: (json['points'] as List?)
          ?.map((point) => DashboardTrendPoint.fromJson(point))
          .toList() ?? [],
      period: json['period'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'metric': metric,
      'points': points.map((point) => point.toJson()).toList(),
      'period': period,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

/// Modelo para un punto de datos en una tendencia
class DashboardTrendPoint {
  final DateTime date;
  final double value;
  final Map<String, dynamic>? metadata;

  DashboardTrendPoint({
    required this.date,
    required this.value,
    this.metadata,
  });

  /// Crear desde JSON
  factory DashboardTrendPoint.fromJson(Map<String, dynamic> json) {
    return DashboardTrendPoint(
      date: DateTime.parse(json['date']),
      value: (json['value'] ?? 0.0).toDouble(),
      metadata: json['metadata'],
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'metadata': metadata,
    };
  }
}

/// Modelo para datos de comparación entre períodos
class DashboardComparison {
  final String metric;
  final double currentValue;
  final double previousValue;
  final double percentageChange;
  final String period;
  final bool isPositive;

  DashboardComparison({
    required this.metric,
    required this.currentValue,
    required this.previousValue,
    required this.percentageChange,
    required this.period,
    required this.isPositive,
  });

  /// Crear desde JSON
  factory DashboardComparison.fromJson(Map<String, dynamic> json) {
    final percentageChange = (json['percentageChange'] ?? 0.0).toDouble();
    final isPositive = percentageChange >= 0;
    
    return DashboardComparison(
      metric: json['metric'] ?? '',
      currentValue: (json['currentValue'] ?? 0.0).toDouble(),
      previousValue: (json['previousValue'] ?? 0.0).toDouble(),
      percentageChange: percentageChange,
      period: json['period'] ?? '',
      isPositive: isPositive,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'metric': metric,
      'currentValue': currentValue,
      'previousValue': previousValue,
      'percentageChange': percentageChange,
      'period': period,
      'isPositive': isPositive,
    };
  }
}

/// Modelo para datos de municipio
class MunicipioData {
  final String id;
  final String nombre;
  final DashboardStats stats;
  final double? latitud;
  final double? longitud;

  MunicipioData({
    required this.id,
    required this.nombre,
    required this.stats,
    this.latitud,
    this.longitud,
  });

  /// Crear desde JSON
  factory MunicipioData.fromJson(Map<String, dynamic> json) {
    return MunicipioData(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      stats: DashboardStats.fromJson(json['stats'] ?? {}),
      latitud: json['latitud']?.toDouble(),
      longitud: json['longitud']?.toDouble(),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'stats': stats.toJson(),
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}

/// Modelo para datos de resumen de alertas
class AlertasResumen {
  final int total;
  final int criticas;
  final int altas;
  final int medias;
  final int bajas;
  final Map<String, int> porTipo;

  AlertasResumen({
    required this.total,
    required this.criticas,
    required this.altas,
    required this.medias,
    required this.bajas,
    required this.porTipo,
  });

  /// Crear desde JSON
  factory AlertasResumen.fromJson(Map<String, dynamic> json) {
    return AlertasResumen(
      total: json['total'] ?? 0,
      criticas: json['criticas'] ?? 0,
      altas: json['altas'] ?? 0,
      medias: json['medias'] ?? 0,
      bajas: json['bajas'] ?? 0,
      porTipo: Map<String, int>.from(json['porTipo'] ?? {}),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'criticas': criticas,
      'altas': altas,
      'medias': medias,
      'bajas': bajas,
      'porTipo': porTipo,
    };
  }
}