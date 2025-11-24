class Progress {

  Progress({
    required this.id,
    this.gestanteId,
    this.contenidoId,
    required this.porcentaje,
    required this.fechaRegistro,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'] ?? '',
      gestanteId: json['gestanteId'],
      contenidoId: json['contenidoId'],
      porcentaje: json['porcentaje']?.toDouble() ?? 0.0,
      fechaRegistro: json['fechaRegistro'] != null 
          ? DateTime.parse(json['fechaRegistro']) 
          : DateTime.now(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
  final String id;
  final String? gestanteId;
  final String? contenidoId;
  final double porcentaje;
  final DateTime fechaRegistro;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gestanteId': gestanteId,
      'contenidoId': contenidoId,
      'porcentaje': porcentaje,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Progress copyWith({
    String? id,
    String? gestanteId,
    String? contenidoId,
    double? porcentaje,
    DateTime? fechaRegistro,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Progress(
      id: id ?? this.id,
      gestanteId: gestanteId ?? this.gestanteId,
      contenidoId: contenidoId ?? this.contenidoId,
      porcentaje: porcentaje ?? this.porcentaje,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Progress &&
        other.id == id &&
        other.gestanteId == gestanteId &&
        other.contenidoId == contenidoId &&
        other.porcentaje == porcentaje;
  }

  @override
  int get hashCode {
    return id.hashCode ^ gestanteId.hashCode ^ contenidoId.hashCode ^ porcentaje.hashCode;
  }

  @override
  String toString() {
    return 'Progress(id: $id, porcentaje: $porcentaje%)';
  }
}