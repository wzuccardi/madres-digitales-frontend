class GestanteModel {
  final String id;
  final String nombre;
  final String municipioId;
  final String? telefono;
  final String? email;
  final DateTime? fechaNacimiento;
  final DateTime? fechaUltimaMenstruacion;
  final DateTime? fechaProbableParto;

  const GestanteModel({
    required this.id,
    required this.nombre,
    required this.municipioId,
    this.telefono,
    this.email,
    this.fechaNacimiento,
    this.fechaUltimaMenstruacion,
    this.fechaProbableParto,
  });

  factory GestanteModel.fromJson(Map<String, dynamic> json) {
    return GestanteModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      municipioId: json['municipio_id']?.toString() ?? '',
      telefono: json['telefono']?.toString(),
      email: json['email']?.toString(),
      fechaNacimiento: json['fecha_nacimiento'] != null 
          ? DateTime.tryParse(json['fecha_nacimiento'].toString()) 
          : null,
      fechaUltimaMenstruacion: json['fecha_ultima_menstruacion'] != null 
          ? DateTime.tryParse(json['fecha_ultima_menstruacion'].toString()) 
          : null,
      fechaProbableParto: json['fecha_probable_parto'] != null 
          ? DateTime.tryParse(json['fecha_probable_parto'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'municipio_id': municipioId,
      'telefono': telefono,
      'email': email,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'fecha_ultima_menstruacion': fechaUltimaMenstruacion?.toIso8601String(),
      'fecha_probable_parto': fechaProbableParto?.toIso8601String(),
    };
  }
}