class UsuarioPermission {

  UsuarioPermission({
    required this.id,
    required this.usuarioId,
    required this.permissionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UsuarioPermission.fromJson(Map<String, dynamic> json) {
    return UsuarioPermission(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      permissionId: json['permissionId'] ?? '',
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
  final String permissionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'permissionId': permissionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UsuarioPermission copyWith({
    String? id,
    String? usuarioId,
    String? permissionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UsuarioPermission(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      permissionId: permissionId ?? this.permissionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsuarioPermission &&
        other.id == id &&
        other.usuarioId == usuarioId &&
        other.permissionId == permissionId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ usuarioId.hashCode ^ permissionId.hashCode;
  }

  @override
  String toString() {
    return 'UsuarioPermission(id: $id, usuarioId: $usuarioId, permissionId: $permissionId)';
  }
}