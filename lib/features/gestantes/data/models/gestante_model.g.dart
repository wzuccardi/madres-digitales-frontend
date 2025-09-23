// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gestante_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GestanteModel _$GestanteModelFromJson(Map<String, dynamic> json) =>
    GestanteModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      municipioId: json['municipioId'] as String,
    );

Map<String, dynamic> _$GestanteModelToJson(GestanteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'municipioId': instance.municipioId,
    };
