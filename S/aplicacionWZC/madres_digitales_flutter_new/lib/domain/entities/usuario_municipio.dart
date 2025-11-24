class UsuarioMunicipio {

  UsuarioMunicipio({
    required this.id,
    required this.usuarioId,
    required this.municipioId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UsuarioMunicipio.fromJson(Map<String, dynamic> json) {
    return UsuarioMunicipio(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      municipioId: json['municipioId'] ?? '',
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
  final String municipioId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'municipioId': municipioId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UsuarioMunicipio copyWith({
    String? id,
    String? usuarioId,
    String? municipioId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UsuarioMunicipio(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      municipioId: municipioId ?? this.municipioId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsuarioMunicipio &&
        other.id == id &&
        other.usuarioId == usuarioId &&
        other.municipioId == municipioId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ usuarioId.hashCode ^ municipioId.hashCode;
  }

  @override
  String toString() {
    return 'UsuarioMunicipio(id: $id, usuarioId: $usuarioId, municipioId: $municipioId)';
  }
}