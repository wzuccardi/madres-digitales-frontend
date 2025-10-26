/// Clases de modelo para IPS y Médico (simplificadas para este ejemplo)
class IpsModel {
  final String id;
  final String nombre;
  final String codigo;
  final String direccion;
  final String telefono;
  final double ubicacionLatitud;
  final double ubicacionLongitud;
  
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
  final String id;
  final String usuarioId;
  final String registroMedico;
  final String especialidad;
  
  MedicoModel({
    required this.id,
    required this.usuarioId,
    required this.registroMedico,
    required this.especialidad,
  });
  
  factory MedicoModel.fromJson(Map<String, dynamic> json) {
    return MedicoModel(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      registroMedico: json['registroMedico'] ?? '',
      especialidad: json['especialidad'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'registroMedico': registroMedico,
      'especialidad': especialidad,
    };
  }
}