class UsuarioGestante {

  UsuarioGestante({
    required this.id,
    required this.usuarioId,
    required this.gestanteId,
    required this.fechaAsignacion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UsuarioGestante.fromJson(Map<String, dynamic> json) {
    return UsuarioGestante(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      gestanteId: json['gestanteId'] ?? '',
      fechaAsignacion: json['fechaAsignacion'] != null 
          ? DateTime.parse(json['fechaAsignacion']) 
          : DateTime.now(),
      estado: json['estado'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
  final String id;
  final String usuarioId;
  final String gestanteId;
  final DateTime fechaAsignacion;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'gestanteId': gestanteId,
      'fechaAsignacion': fechaAsignacion.toIso8601String(),
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UsuarioGestante copyWith({
    String? id,
    String? usuarioId,
    String? gestanteId,
    DateTime? fechaAsignacion,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UsuarioGestante(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      gestanteId: gestanteId ?? this.gestanteId,
      fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsuarioGestante &&
        other.id == id &&
        other.usuarioId == usuarioId &&
        other.gestanteId == gestanteId &&
        other.estado == estado;
  }

  @override
  int get hashCode {
    return id.hashCode ^ usuarioId.hashCode ^ gestanteId.hashCode ^ estado.hashCode;
  }

  @override
  String toString() {
    return 'UsuarioGestante(id: $id, usuarioId: $usuarioId, gestanteId: $gestanteId)';
  }
}