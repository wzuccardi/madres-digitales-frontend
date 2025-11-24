class SOSStatistics {

  const SOSStatistics({
    required this.totalAlertas,
    required this.alertasCriticas,
    required this.alertasAtendidas,
    required this.alertasActivas,
    required this.tiempoRespuestaPromedio,
  });

  factory SOSStatistics.fromJson(Map<String, dynamic> json) {
    return SOSStatistics(
      totalAlertas: json['totalAlertas'] ?? 0,
      alertasCriticas: json['alertasCriticas'] ?? 0,
      alertasAtendidas: json['alertasAtendidas'] ?? 0,
      alertasActivas: json['alertasActivas'] ?? 0,
      tiempoRespuestaPromedio: (json['tiempoRespuestaPromedio'] as num?)?.toDouble() ?? 0.0,
    );
  }
  final int totalAlertas;
  final int alertasCriticas;
  final int alertasAtendidas;
  final int alertasActivas;
  final double tiempoRespuestaPromedio;

  Map<String, dynamic> toJson() {
    return {
      'totalAlertas': totalAlertas,
      'alertasCriticas': alertasCriticas,
      'alertasAtendidas': alertasAtendidas,
      'alertasActivas': alertasActivas,
      'tiempoRespuestaPromedio': tiempoRespuestaPromedio,
    };
  }

  SOSStatistics copyWith({
    int? totalAlertas,
    int? alertasCriticas,
    int? alertasAtendidas,
    int? alertasActivas,
    double? tiempoRespuestaPromedio,
  }) {
    return SOSStatistics(
      totalAlertas: totalAlertas ?? this.totalAlertas,
      alertasCriticas: alertasCriticas ?? this.alertasCriticas,
      alertasAtendidas: alertasAtendidas ?? this.alertasAtendidas,
      alertasActivas: alertasActivas ?? this.alertasActivas,
      tiempoRespuestaPromedio: tiempoRespuestaPromedio ?? this.tiempoRespuestaPromedio,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SOSStatistics &&
        other.totalAlertas == totalAlertas &&
        other.alertasCriticas == alertasCriticas &&
        other.alertasAtendidas == alertasAtendidas &&
        other.alertasActivas == alertasActivas &&
        other.tiempoRespuestaPromedio == tiempoRespuestaPromedio;
  }

  @override
  int get hashCode {
    return totalAlertas.hashCode ^
        alertasCriticas.hashCode ^
        alertasAtendidas.hashCode ^
        alertasActivas.hashCode ^
        tiempoRespuestaPromedio.hashCode;
  }

  @override
  String toString() {
    return 'SOSStatistics(totalAlertas: $totalAlertas, críticas: $alertasCriticas, atendidas: $alertasAtendidas, activas: $alertasActivas, tiempoPromedio: $tiempoRespuestaPromedio)';
  }
}
