// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ControlModel _$ControlModelFromJson(Map<String, dynamic> json) => ControlModel(
  id: json['id'] as String,
  gestanteId: json['gestanteId'] as String,
  fechaControl: DateTime.parse(json['fechaControl'] as String),
  semanasGestacion: (json['semanasGestacion'] as num?)?.toInt(),
  peso: (json['peso'] as num?)?.toDouble(),
  talla: (json['talla'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ControlModelToJson(ControlModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gestanteId': instance.gestanteId,
      'fechaControl': instance.fechaControl.toIso8601String(),
      'semanasGestacion': instance.semanasGestacion,
      'peso': instance.peso,
      'talla': instance.talla,
    };
