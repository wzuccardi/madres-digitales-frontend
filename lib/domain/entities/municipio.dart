class Municipio {

  Municipio({
    required this.id,
    required this.nombre,
    required this.departamentoId,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      departamentoId: json['departamentoId'] ?? '',
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
  final String departamentoId;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'departamentoId': departamentoId,
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Municipio copyWith({
    String? id,
    String? nombre,
    String? departamentoId,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Municipio(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      departamentoId: departamentoId ?? this.departamentoId,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Municipio &&
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
    return 'Municipio(id: $id, nombre: $nombre, estado: $estado)';
  }
}