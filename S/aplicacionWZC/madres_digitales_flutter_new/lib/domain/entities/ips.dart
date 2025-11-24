class Ips {

  Ips({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    this.email,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ips.fromJson(Map<String, dynamic> json) {
    return Ips(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'],
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
  final String direccion;
  final String telefono;
  final String? email;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Ips copyWith({
    String? id,
    String? nombre,
    String? direccion,
    String? telefono,
    String? email,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ips(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ips &&
        other.id == id &&
        other.nombre == nombre &&
        other.estado == estado;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nombre.hashCode ^ estado.hashCode;
  }

  @override
  String toString() {
    return 'Ips(id: $id, nombre: $nombre, estado: $estado)';
  }
}