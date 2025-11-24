class AuthToken {

  AuthToken({
    required this.id,
    required this.token,
    required this.refreshToken,
    required this.fechaExpiracion,
    required this.usuarioId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      id: json['id'] ?? '',
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      fechaExpiracion: json['fechaExpiracion'] != null 
          ? DateTime.parse(json['fechaExpiracion']) 
          : DateTime.now(),
      usuarioId: json['usuarioId'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
  final String id;
  final String token;
  final String refreshToken;
  final DateTime fechaExpiracion;
  final String usuarioId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'refreshToken': refreshToken,
      'fechaExpiracion': fechaExpiracion.toIso8601String(),
      'usuarioId': usuarioId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AuthToken copyWith({
    String? id,
    String? token,
    String? refreshToken,
    DateTime? fechaExpiracion,
    String? usuarioId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthToken(
      id: id ?? this.id,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      fechaExpiracion: fechaExpiracion ?? this.fechaExpiracion,
      usuarioId: usuarioId ?? this.usuarioId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthToken &&
        other.id == id &&
        other.token == token &&
        other.usuarioId == usuarioId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ token.hashCode ^ usuarioId.hashCode;
  }

  @override
  String toString() {
    return 'AuthToken(id: $id, usuarioId: $usuarioId)';
  }
}