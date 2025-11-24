class Notificacion {

  Notificacion({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    this.entidadId,
    this.entidadTipo,
    required this.fechaCreacion,
    required this.fechaLectura,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      tipo: json['tipo'] ?? '',
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      entidadId: json['entidadId'],
      entidadTipo: json['entidadTipo'],
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.parse(json['fechaCreacion']) 
          : DateTime.now(),
      fechaLectura: json['fechaLectura'] != null 
          ? DateTime.parse(json['fechaLectura']) 
          : DateTime.now(),
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
  final String usuarioId;
  final String tipo;
  final String titulo;
  final String mensaje;
  final String? entidadId;
  final String? entidadTipo;
  final DateTime fechaCreacion;
  final DateTime fechaLectura;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'tipo': tipo,
      'titulo': titulo,
      'mensaje': mensaje,
      'entidadId': entidadId,
      'entidadTipo': entidadTipo,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaLectura': fechaLectura.toIso8601String(),
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Notificacion copyWith({
    String? id,
    String? usuarioId,
    String? tipo,
    String? titulo,
    String? mensaje,
    String? entidadId,
    String? entidadTipo,
    DateTime? fechaCreacion,
    DateTime? fechaLectura,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Notificacion(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      entidadId: entidadId ?? this.entidadId,
      entidadTipo: entidadTipo ?? this.entidadTipo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaLectura: fechaLectura ?? this.fechaLectura,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notificacion &&
        other.id == id &&
        other.usuarioId == usuarioId &&
        other.tipo == tipo &&
        other.estado == estado;
  }

  @override
  int get hashCode {
    return id.hashCode ^ usuarioId.hashCode ^ tipo.hashCode ^ estado.hashCode;
  }

  @override
  String toString() {
    return 'Notificacion(id: $id, tipo: $tipo, titulo: $titulo)';
  }
}