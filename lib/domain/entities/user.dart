
class User {
  
  const User({
    required this.id,
    required this.email,
    required this.nombre,
    this.apellido,
    this.telefono,
    required this.rol,
    this.fechaCreacion,
    this.ultimoAcceso,
    required this.activo,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String?,
      telefono: json['telefono'] as String?,
      rol: json['rol'] as String,
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.parse(json['fechaCreacion']) 
          : null,
      ultimoAcceso: json['ultimoAcceso'] != null 
          ? DateTime.parse(json['ultimoAcceso']) 
          : null,
      activo: json['activo'] as bool? ?? true,
    );
  }
  final String id;
  final String email;
  final String nombre;
  final String? apellido;
  final String? telefono;
  final String rol;
  final DateTime? fechaCreacion;
  final DateTime? ultimoAcceso;
  final bool activo;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'rol': rol,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'ultimoAcceso': ultimoAcceso?.toIso8601String(),
      'activo': activo,
    };
  }
  
  User copyWith({
    String? id,
    String? email,
    String? nombre,
    String? apellido,
    String? telefono,
    String? rol,
    DateTime? fechaCreacion,
    DateTime? ultimoAcceso,
    bool? activo,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
      activo: activo ?? this.activo,
    );
  }
  
  String get nombreCompleto => apellido != null ? '$nombre $apellido' : nombre;
  String get name => nombreCompleto;
  String get role => rol;
  
  bool get esAdmin => rol == 'admin' || rol == 'super_admin';
  bool get esMadrina => rol == 'madrina';
  bool get esGestante => rol == 'gestante';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'User(id: $id, email: $email, nombre: $nombreCompleto, rol: $rol)';
  }
}
