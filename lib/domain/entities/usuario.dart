class Usuario {

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.documento,
    required this.email,
    required this.telefono,
    required this.rol,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      documento: json['documento'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      rol: json['rol'] ?? '',
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
  final String nombre;
  final String apellido;
  final String documento;
  final String email;
  final String telefono;
  final String rol;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'documento': documento,
      'email': email,
      'telefono': telefono,
      'rol': rol,
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Usuario copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? documento,
    String? email,
    String? telefono,
    String? rol,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      documento: documento ?? this.documento,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Usuario &&
        other.id == id &&
        other.nombre == nombre &&
        other.apellido == apellido &&
        other.documento == documento;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nombre.hashCode ^ apellido.hashCode ^ documento.hashCode;
  }

  @override
  String toString() {
    return 'Usuario(id: $id, nombre: $nombre $apellido)';
  }
}