class SyncConflict {

  SyncConflict({
    required this.id,
    required this.entidadId,
    required this.entidadTipo,
    required this.campo,
    required this.valorLocal,
    this.valorRemoto,
    required this.fechaDeteccion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SyncConflict.fromJson(Map<String, dynamic> json) {
    return SyncConflict(
      id: json['id'] ?? '',
      entidadId: json['entidadId'] ?? '',
      entidadTipo: json['entidadTipo'] ?? '',
      campo: json['campo'] ?? '',
      valorLocal: json['valorLocal'] ?? '',
      valorRemoto: json['valorRemoto'],
      fechaDeteccion: json['fechaDeteccion'] != null 
          ? DateTime.parse(json['fechaDeteccion']) 
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
  final String entidadId;
  final String entidadTipo;
  final String campo;
  final String valorLocal;
  final String? valorRemoto;
  final DateTime fechaDeteccion;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entidadId': entidadId,
      'entidadTipo': entidadTipo,
      'campo': campo,
      'valorLocal': valorLocal,
      'valorRemoto': valorRemoto,
      'fechaDeteccion': fechaDeteccion.toIso8601String(),
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SyncConflict copyWith({
    String? id,
    String? entidadId,
    String? entidadTipo,
    String? campo,
    String? valorLocal,
    String? valorRemoto,
    DateTime? fechaDeteccion,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SyncConflict(
      id: id ?? this.id,
      entidadId: entidadId ?? this.entidadId,
      entidadTipo: entidadTipo ?? this.entidadTipo,
      campo: campo ?? this.campo,
      valorLocal: valorLocal ?? this.valorLocal,
      valorRemoto: valorRemoto ?? this.valorRemoto,
      fechaDeteccion: fechaDeteccion ?? this.fechaDeteccion,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncConflict &&
        other.id == id &&
        other.entidadId == entidadId &&
        other.entidadTipo == entidadTipo &&
        other.campo == campo &&
        other.valorLocal == valorLocal &&
        other.estado == estado;
  }

  @override
  int get hashCode {
    return id.hashCode ^ entidadId.hashCode ^ entidadTipo.hashCode ^ campo.hashCode ^ valorLocal.hashCode ^ estado.hashCode;
  }

  @override
  String toString() {
    return 'SyncConflict(id: $id, entidad: $entidadTipo, campo: $campo)';
  }
}