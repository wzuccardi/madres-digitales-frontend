// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ControlModel _$ControlModelFromJson(Map<String, dynamic> json) => ControlModel(
      id: json['id'] as String,
      gestante_id: json['gestante_id'] as String,
      fecha_control: DateTime.parse(json['fecha_control'] as String),
      semanas_gestacion: (json['semanas_gestacion'] as num?)?.toInt(),
      peso: (json['peso'] as num?)?.toDouble(),
      presion_sistolica: (json['presion_sistolica'] as num?)?.toDouble(),
      presion_diastolica: (json['presion_diastolica'] as num?)?.toDouble(),
      frecuencia_cardiaca: (json['frecuencia_cardiaca'] as num?)?.toInt(),
      temperatura: (json['temperatura'] as num?)?.toDouble(),
      altura_uterina: (json['altura_uterina'] as num?)?.toDouble(),
      movimientos_fetales: json['movimientos_fetales'] as String?,
      edemas: json['edemas'] as String?,
      recomendaciones: json['recomendaciones'] as String?,
      medico_id: json['medico_id'] as String,
    );

Map<String, dynamic> _$ControlModelToJson(ControlModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gestante_id': instance.gestante_id,
      'fecha_control': instance.fecha_control.toIso8601String(),
      'semanas_gestacion': instance.semanas_gestacion,
      'peso': instance.peso,
      'presion_sistolica': instance.presion_sistolica,
      'presion_diastolica': instance.presion_diastolica,
      'frecuencia_cardiaca': instance.frecuencia_cardiaca,
      'temperatura': instance.temperatura,
      'altura_uterina': instance.altura_uterina,
      'movimientos_fetales': instance.movimientos_fetales,
      'edemas': instance.edemas,
      'recomendaciones': instance.recomendaciones,
      'medico_id': instance.medico_id,
    };
