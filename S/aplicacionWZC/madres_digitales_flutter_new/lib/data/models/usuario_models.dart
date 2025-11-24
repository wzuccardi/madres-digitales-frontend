/// Clases de modelo para IPS y Médico (simplificadas para este ejemplo)
class IpsModel {
  
  IpsModel({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.direccion,
    required this.telefono,
    required this.ubicacionLatitud,
    required this.ubicacionLongitud,
  });
  
  factory IpsModel.fromJson(Map<String, dynamic> json) {
    return IpsModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      ubicacionLatitud: (json['ubicacionLatitud'] ?? 0.0).toDouble(),
      ubicacionLongitud: (json['ubicacionLongitud'] ?? 0.0).toDouble(),
    );
  }
  final String id;
  final String nombre;
  final String codigo;
  final String direccion;
  final String telefono;
  final double ubicacionLatitud;
  final double ubicacionLongitud;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'direccion': direccion,
      'telefono': telefono,
      'ubicacionLatitud': ubicacionLatitud,
      'ubicacionLongitud': ubicacionLongitud,
    };
  }
}

class MedicoModel {
  
  MedicoModel({
    required this.id,
    required this.usuarioId,
    required this.registroMedico,
    required this.especialidad,
    this.ipsId,
    this.ipsNombre,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory MedicoModel.fromJson(Map<String, dynamic> json) {
    return MedicoModel(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? json['usuario_id'] ?? '',
      registroMedico: json['registroMedico'] ?? json['registro_medico'] ?? '',
      especialidad: json['especialidad'] ?? json['especialidad'] ?? '',
      ipsId: json['ipsId'] ?? json['ips_id'] ?? '',
      ipsNombre: json['ipsNombre'] ?? json['ips_nombre'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
  final String id;
  final String usuarioId;
  final String registroMedico;
  final String especialidad;
  final String? ipsId;
  final String? ipsNombre;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'registroMedico': registroMedico,
      'especialidad': especialidad,
      'ipsId': ipsId,
      'ipsNombre': ipsNombre,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
