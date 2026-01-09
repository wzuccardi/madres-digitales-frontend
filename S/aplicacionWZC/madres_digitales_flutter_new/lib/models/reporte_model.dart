class ReporteCompleto {
  final List<IndicadorReporte> indicadores;
  final FiltrosReporte filtrosAplicados;
  final DateTime fechaGeneracion;
  final int totalGestantes;

  ReporteCompleto({
    required this.indicadores,
    required this.filtrosAplicados,
    required this.fechaGeneracion,
    required this.totalGestantes,
  });

  factory ReporteCompleto.fromJson(Map<String, dynamic> json) {
    return ReporteCompleto(
      indicadores: (json['indicadores'] as List)
          .map((i) => IndicadorReporte.fromJson(i))
          .toList(),
      filtrosAplicados: FiltrosReporte.fromJson(json['filtrosAplicados'] ?? {}),
      fechaGeneracion: DateTime.parse(json['fechaGeneracion']),
      totalGestantes: json['totalGestantes'] ?? 0,
    );
  }
}

class IndicadorReporte {
  final String nombre;
  final int valor;
  final int total;
  final double porcentaje;
  final String tipo; // 'porcentaje' o 'numero'

  IndicadorReporte({
    required this.nombre,
    required this.valor,
    required this.total,
    required this.porcentaje,
    required this.tipo,
  });

  factory IndicadorReporte.fromJson(Map<String, dynamic> json) {
    return IndicadorReporte(
      nombre: json['nombre'] ?? '',
      valor: json['valor'] ?? 0,
      total: json['total'] ?? 0,
      porcentaje: (json['porcentaje'] ?? 0).toDouble(),
      tipo: json['tipo'] ?? 'numero',
    );
  }
}

class FiltrosReporte {
  final String? municipioId;
  final String? madrinaId;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  FiltrosReporte({
    this.municipioId,
    this.madrinaId,
    this.fechaInicio,
    this.fechaFin,
  });

  factory FiltrosReporte.fromJson(Map<String, dynamic> json) {
    return FiltrosReporte(
      municipioId: json['municipioId'],
      madrinaId: json['madrinaId'],
      fechaInicio: json['fechaInicio'] != null 
          ? DateTime.parse(json['fechaInicio'])
          : null,
      fechaFin: json['fechaFin'] != null 
          ? DateTime.parse(json['fechaFin'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'municipioId': municipioId,
      'madrinaId': madrinaId,
      'fechaInicio': fechaInicio?.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
    };
  }
}

class Municipio {
  final String id;
  final String nombre;

  Municipio({
    required this.id,
    required this.nombre,
  });

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
    );
  }
}

class Madrina {
  final String id;
  final String nombre;
  final String? email;

  Madrina({
    required this.id,
    required this.nombre,
    this.email,
  });

  factory Madrina.fromJson(Map<String, dynamic> json) {
    return Madrina(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'],
    );
  }
}