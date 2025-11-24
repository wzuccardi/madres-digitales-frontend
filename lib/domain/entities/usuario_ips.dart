class UsuarioIps {

  UsuarioIps({
    required this.id,
    required this.usuarioId,
    required this.ipsId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UsuarioIps.fromJson(Map<String, dynamic> json) {
    return UsuarioIps(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      ipsId: json['ipsId'] ?? '',
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
  final String ipsId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'ipsId': ipsId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UsuarioIps copyWith({
    String? id,
    String? usuarioId,
    String? ipsId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UsuarioIps(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      ipsId: ipsId ?? this.ipsId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsuarioIps &&
        other.id == id &&
        other.usuarioId == usuarioId &&
        other.ipsId == ipsId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ usuarioId.hashCode ^ ipsId.hashCode;
  }

  @override
  String toString() {
    return 'UsuarioIps(id: $id, usuarioId: $usuarioId, ipsId: $ipsId)';
  }
}