class Mensaje {

  Mensaje({
    required this.id,
    required this.remitenteId,
    required this.destinatarioId,
    required this.asunto,
    required this.contenido,
    required this.fechaEnvio,
    required this.fechaLectura,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.conversacionId,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['id'] ?? '',
      remitenteId: json['remitenteId'] ?? '',
      destinatarioId: json['destinatarioId'] ?? '',
      asunto: json['asunto'] ?? '',
      contenido: json['contenido'] ?? '',
      fechaEnvio: json['fechaEnvio'] != null 
          ? DateTime.parse(json['fechaEnvio']) 
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
      conversacionId: json['conversacionId'] as String?,
    );
  }
  final String id;
  final String remitenteId;
  final String destinatarioId;
  final String asunto;
  final String contenido;
  final DateTime fechaEnvio;
  final DateTime fechaLectura;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? conversacionId;
  String get remitenteNombre => remitenteId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remitenteId': remitenteId,
      'destinatarioId': destinatarioId,
      'asunto': asunto,
      'contenido': contenido,
      'fechaEnvio': fechaEnvio.toIso8601String(),
      'fechaLectura': fechaLectura.toIso8601String(),
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Mensaje copyWith({
    String? id,
    String? remitenteId,
    String? destinatarioId,
    String? asunto,
    String? contenido,
    DateTime? fechaEnvio,
    DateTime? fechaLectura,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? conversacionId,
  }) {
    return Mensaje(
      id: id ?? this.id,
      remitenteId: remitenteId ?? this.remitenteId,
      destinatarioId: destinatarioId ?? this.destinatarioId,
      asunto: asunto ?? this.asunto,
      contenido: contenido ?? this.contenido,
      fechaEnvio: fechaEnvio ?? this.fechaEnvio,
      fechaLectura: fechaLectura ?? this.fechaLectura,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      conversacionId: conversacionId ?? this.conversacionId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mensaje &&
        other.id == id &&
        other.asunto == asunto &&
        other.estado == estado;
  }

  @override
  int get hashCode {
    return id.hashCode ^ remitenteId.hashCode ^ destinatarioId.hashCode ^ asunto.hashCode ^ estado.hashCode;
  }

  @override
  String toString() {
    return 'Mensaje(id: $id, asunto: $asunto, estado: $estado)';
  }
}
