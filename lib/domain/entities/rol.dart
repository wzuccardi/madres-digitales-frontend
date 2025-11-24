class Rol {

  Rol({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.permisos,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      permisos: List<String>.from(json['permisos'] ?? []),
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
  final List<String> permisos;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'permisos': permisos,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Rol copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    List<String>? permisos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Rol(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      permisos: permisos ?? this.permisos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Rol &&
        other.id == id &&
        other.nombre == nombre &&
        other.descripcion == descripcion;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nombre.hashCode ^ descripcion.hashCode;
  }

  @override
  String toString() {
    return 'Rol(id: $id, nombre: $nombre)';
  }
}