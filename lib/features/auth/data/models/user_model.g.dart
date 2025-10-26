// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String?,
      nombre: json['nombre'] as String,
      documento: json['documento'] as String?,
      telefono: json['telefono'] as String?,
      rol: json['rol'] as String,
      municipioId: json['municipio_id'] as String?,
      direccion: json['direccion'] as String?,
      coordenadas: json['coordenadas'],
      zonaCobertura: json['zona_cobertura'],
      activo: json['activo'] as bool,
      ultimoAcceso: json['ultimo_acceso'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nombre': instance.nombre,
      'documento': instance.documento,
      'telefono': instance.telefono,
      'rol': instance.rol,
      'municipio_id': instance.municipioId,
      'direccion': instance.direccion,
      'coordenadas': instance.coordenadas,
      'zona_cobertura': instance.zonaCobertura,
      'activo': instance.activo,
      'ultimo_acceso': instance.ultimoAcceso,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
