class ContenidoGestante {

  ContenidoGestante({
    required this.id,
    required this.contenidoId,
    required this.gestanteId,
    required this.fechaVisualizacion,
    required this.progreso,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContenidoGestante.fromJson(Map<String, dynamic> json) {
    return ContenidoGestante(
      id: json['id'] ?? '',
      contenidoId: json['contenidoId'] ?? '',
      gestanteId: json['gestanteId'] ?? '',
      fechaVisualizacion: json['fechaVisualizacion'] != null 
          ? DateTime.parse(json['fechaVisualizacion']) 
          : DateTime.now(),
      progreso: json['progreso']?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
  final String id;
  final String contenidoId;
  final String gestanteId;
  final DateTime fechaVisualizacion;
  final double progreso;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contenidoId': contenidoId,
      'gestanteId': gestanteId,
      'fechaVisualizacion': fechaVisualizacion.toIso8601String(),
      'progreso': progreso,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ContenidoGestante copyWith({
    String? id,
    String? contenidoId,
    String? gestanteId,
    DateTime? fechaVisualizacion,
    double? progreso,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContenidoGestante(
      id: id ?? this.id,
      contenidoId: contenidoId ?? this.contenidoId,
      gestanteId: gestanteId ?? this.gestanteId,
      fechaVisualizacion: fechaVisualizacion ?? this.fechaVisualizacion,
      progreso: progreso ?? this.progreso,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContenidoGestante &&
        other.id == id &&
        other.contenidoId == contenidoId &&
        other.gestanteId == gestanteId &&
        other.fechaVisualizacion == fechaVisualizacion &&
        other.progreso == progreso;
  }

  @override
  int get hashCode {
    return id.hashCode ^ contenidoId.hashCode ^ gestanteId.hashCode ^ fechaVisualizacion.hashCode ^ progreso.hashCode;
  }

  @override
  String toString() {
    return 'ContenidoGestante(id: $id, contenidoId: $contenidoId, gestanteId: $gestanteId, progreso: $progreso%)';
  }
}