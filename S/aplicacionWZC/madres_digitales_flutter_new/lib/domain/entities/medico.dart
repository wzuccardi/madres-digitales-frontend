class Medico {

  Medico({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.documento,
    required this.especialidad,
    this.registroMedico,
    this.telefono,
    this.email,
    this.ipsId,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medico.fromJson(Map<String, dynamic> json) {
    return Medico(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      documento: json['documento'] ?? '',
      especialidad: json['especialidad'] ?? '',
      registroMedico: json['registroMedico'],
      telefono: json['telefono'],
      email: json['email'],
      ipsId: json['ipsId'],
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
  final String especialidad;
  final String? registroMedico;
  final String? telefono;
  final String? email;
  final String? ipsId;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'documento': documento,
      'especialidad': especialidad,
      'registroMedico': registroMedico,
      'telefono': telefono,
      'email': email,
      'ipsId': ipsId,
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Medico copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? documento,
    String? especialidad,
    String? registroMedico,
    String? telefono,
    String? email,
    String? ipsId,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medico(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      documento: documento ?? this.documento,
      especialidad: especialidad ?? this.especialidad,
      registroMedico: registroMedico ?? this.registroMedico,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      ipsId: ipsId ?? this.ipsId,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medico &&
        other.id == id &&
        other.nombre == nombre &&
        other.apellido == apellido &&
        other.documento == documento &&
        other.estado == estado;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nombre.hashCode ^ apellido.hashCode ^ documento.hashCode ^ estado.hashCode;
  }

  @override
  String toString() {
    return 'Medico(id: $id, nombre: $nombre $apellido, estado: $estado)';
  }
}