import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'usuario_model.g.dart';

@JsonSerializable()
class UsuarioModel extends Equatable {
  final String id;
  final String email;
  final String nombre;
  final String apellido;
  final String documento;
  final String? telefono;
  final String rol;
  final String? ipsId;
  final DateTime? fechaNacimiento;
  final String? direccion;
  final double? ubicacionLatitud;
  final double? ubicacionLongitud;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relaciones
  final IpsModel? ips;
  
  const UsuarioModel({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.documento,
    this.telefono,
    required this.rol,
    this.ipsId,
    this.fechaNacimiento,
    this.direccion,
    this.ubicacionLatitud,
    this.ubicacionLongitud,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.ips,
  });
  
  factory UsuarioModel.fromJson(Map<String, dynamic> json) => _$UsuarioModelFromJson(json);
  Map<String, dynamic> toJson() => _$UsuarioModelToJson(this);
  
  UsuarioModel copyWith({
    String? id,
    String? email,
    String? nombre,
    String? apellido,
    String? documento,
    String? telefono,
    String? rol,
    String? ipsId,
    DateTime? fechaNacimiento,
    String? direccion,
    double? ubicacionLatitud,
    double? ubicacionLongitud,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    IpsModel? ips,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      documento: documento ?? this.documento,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      ipsId: ipsId ?? this.ipsId,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      direccion: direccion ?? this.direccion,
      ubicacionLatitud: ubicacionLatitud ?? this.ubicacionLatitud,
      ubicacionLongitud: ubicacionLongitud ?? this.ubicacionLongitud,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ips: ips ?? this.ips,
    );
  }
  
  String get nombreCompleto => '$nombre $apellido';
  
  // Getters para compatibilidad con código existente
  String get nombres => nombre;
  String get apellidos => apellido;
  String get numeroDocumento => documento;
  
  bool get tieneUbicacion => ubicacionLatitud != null && ubicacionLongitud != null;
  
  @override
  List<Object?> get props => [
    id,
    email,
    nombre,
    apellido,
    documento,
    telefono,
    rol,
    ipsId,
    fechaNacimiento,
    direccion,
    ubicacionLatitud,
    ubicacionLongitud,
    activo,
    createdAt,
    updatedAt,
  ];
}

@JsonSerializable()
class IpsModel extends Equatable {
  final String id;
  final String nombre;
  final String codigo;
  final String nivel;
  final String direccion;
  final String telefono;
  final String? email;
  final double ubicacionLatitud;
  final double ubicacionLongitud;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const IpsModel({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.nivel,
    required this.direccion,
    required this.telefono,
    this.email,
    required this.ubicacionLatitud,
    required this.ubicacionLongitud,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory IpsModel.fromJson(Map<String, dynamic> json) => _$IpsModelFromJson(json);
  Map<String, dynamic> toJson() => _$IpsModelToJson(this);
  
  @override
  List<Object?> get props => [
    id,
    nombre,
    codigo,
    nivel,
    direccion,
    telefono,
    email,
    ubicacionLatitud,
    ubicacionLongitud,
    activo,
    createdAt,
    updatedAt,
  ];
}

@JsonSerializable()
class MedicoModel extends Equatable {
  final String id;
  final String usuarioId;
  final String especialidad;
  final String registroMedico;
  final String? consultorio;
  final String? horarioAtencion;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relaciones
  final UsuarioModel? usuario;
  
  const MedicoModel({
    required this.id,
    required this.usuarioId,
    required this.especialidad,
    required this.registroMedico,
    this.consultorio,
    this.horarioAtencion,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.usuario,
  });
  
  factory MedicoModel.fromJson(Map<String, dynamic> json) => _$MedicoModelFromJson(json);
  Map<String, dynamic> toJson() => _$MedicoModelToJson(this);
  
  String get nombreCompleto => usuario?.nombreCompleto ?? '';
  
  @override
  List<Object?> get props => [
    id,
    usuarioId,
    especialidad,
    registroMedico,
    consultorio,
    horarioAtencion,
    activo,
    createdAt,
    updatedAt,
  ];
}

// Enums para roles
enum RolUsuario {
  @JsonValue('ADMIN')
  admin,
  @JsonValue('MEDICO')
  medico,
  @JsonValue('ENFERMERO')
  enfermero,
  @JsonValue('GESTANTE')
  gestante,
  @JsonValue('FAMILIAR')
  familiar,
}

// Enums para niveles de IPS
enum NivelIps {
  @JsonValue('PRIMARIO')
  primario,
  @JsonValue('SECUNDARIO')
  secundario,
  @JsonValue('TERCIARIO')
  terciario,
}