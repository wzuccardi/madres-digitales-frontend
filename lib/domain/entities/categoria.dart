class Categoria {

  Categoria({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.imagenUrl,
    required this.orden,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      imagenUrl: json['imagenUrl'],
      orden: json['orden'] ?? 0,
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
  final String? imagenUrl;
  final int orden;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'orden': orden,
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Categoria copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? imagenUrl,
    int? orden,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      orden: orden ?? this.orden,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Categoria &&
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
    return 'Categoria(id: $id, nombre: $nombre, estado: $estado)';
  }
}