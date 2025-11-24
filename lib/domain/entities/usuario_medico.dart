class UsuarioMedico {

  UsuarioMedico({
    required this.id,
    required this.usuarioId,
    required this.medicoId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UsuarioMedico.fromJson(Map<String, dynamic> json) {
    return UsuarioMedico(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      medicoId: json['medicoId'] ?? '',
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
  final String medicoId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'medicoId': medicoId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UsuarioMedico copyWith({
    String? id,
    String? usuarioId,
    String? medicoId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UsuarioMedico(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      medicoId: medicoId ?? this.medicoId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsuarioMedico &&
        other.id == id &&
        other.usuarioId == usuarioId &&
        other.medicoId == medicoId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ usuarioId.hashCode ^ medicoId.hashCode;
  }

  @override
  String toString() {
    return 'UsuarioMedico(id: $id, usuarioId: $usuarioId, medicoId: $medicoId)';
  }
}