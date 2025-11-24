class UsuarioRol {

  UsuarioRol({
    required this.id,
    required this.usuarioId,
    required this.rolId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UsuarioRol.fromJson(Map<String, dynamic> json) {
    return UsuarioRol(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      rolId: json['rolId'] ?? '',
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
  final String rolId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'rolId': rolId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UsuarioRol copyWith({
    String? id,
    String? usuarioId,
    String? rolId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UsuarioRol(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      rolId: rolId ?? this.rolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsuarioRol &&
        other.id == id &&
        other.usuarioId == usuarioId &&
        other.rolId == rolId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ usuarioId.hashCode ^ rolId.hashCode;
  }

  @override
  String toString() {
    return 'UsuarioRol(id: $id, usuarioId: $usuarioId, rolId: $rolId)';
  }
}