class Permission {

  Permission({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
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
  final String descripcion;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Permission copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Permission(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Permission &&
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
    return 'Permission(id: $id, nombre: $nombre, estado: $estado)';
  }
}
