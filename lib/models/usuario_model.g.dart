// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsuarioModel _$UsuarioModelFromJson(Map<String, dynamic> json) => UsuarioModel(
      id: json['id'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      documento: json['documento'] as String,
      telefono: json['telefono'] as String?,
      rol: json['rol'] as String,
      ipsId: json['ipsId'] as String?,
      fechaNacimiento: json['fechaNacimiento'] == null
          ? null
          : DateTime.parse(json['fechaNacimiento'] as String),
      direccion: json['direccion'] as String?,
      ubicacionLatitud: (json['ubicacionLatitud'] as num?)?.toDouble(),
      ubicacionLongitud: (json['ubicacionLongitud'] as num?)?.toDouble(),
      activo: json['activo'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      ips: json['ips'] == null
          ? null
          : IpsModel.fromJson(json['ips'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UsuarioModelToJson(UsuarioModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nombre': instance.nombre,
      'apellido': instance.apellido,
      'documento': instance.documento,
      'telefono': instance.telefono,
      'rol': instance.rol,
      'ipsId': instance.ipsId,
      'fechaNacimiento': instance.fechaNacimiento?.toIso8601String(),
      'direccion': instance.direccion,
      'ubicacionLatitud': instance.ubicacionLatitud,
      'ubicacionLongitud': instance.ubicacionLongitud,
      'activo': instance.activo,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'ips': instance.ips,
    };

IpsModel _$IpsModelFromJson(Map<String, dynamic> json) => IpsModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      nivel: json['nivel'] as String,
      direccion: json['direccion'] as String,
      telefono: json['telefono'] as String,
      email: json['email'] as String?,
      ubicacionLatitud: (json['ubicacionLatitud'] as num).toDouble(),
      ubicacionLongitud: (json['ubicacionLongitud'] as num).toDouble(),
      activo: json['activo'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$IpsModelToJson(IpsModel instance) => <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'codigo': instance.codigo,
      'nivel': instance.nivel,
      'direccion': instance.direccion,
      'telefono': instance.telefono,
      'email': instance.email,
      'ubicacionLatitud': instance.ubicacionLatitud,
      'ubicacionLongitud': instance.ubicacionLongitud,
      'activo': instance.activo,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

MedicoModel _$MedicoModelFromJson(Map<String, dynamic> json) => MedicoModel(
      id: json['id'] as String,
      usuarioId: json['usuarioId'] as String,
      especialidad: json['especialidad'] as String,
      registroMedico: json['registroMedico'] as String,
      consultorio: json['consultorio'] as String?,
      horarioAtencion: json['horarioAtencion'] as String?,
      activo: json['activo'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      usuario: json['usuario'] == null
          ? null
          : UsuarioModel.fromJson(json['usuario'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MedicoModelToJson(MedicoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'usuarioId': instance.usuarioId,
      'especialidad': instance.especialidad,
      'registroMedico': instance.registroMedico,
      'consultorio': instance.consultorio,
      'horarioAtencion': instance.horarioAtencion,
      'activo': instance.activo,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'usuario': instance.usuario,
    };
