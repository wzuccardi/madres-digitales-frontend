// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ControlModel _$ControlModelFromJson(Map<String, dynamic> json) => ControlModel(
      id: json['id'] as String,
      gestanteId: json['gestante_id'] as String,
      fechaControl: DateTime.parse(json['fecha_control'] as String),
      semanasGestacion: (json['semanas_gestacion'] as num?)?.toInt(),
      peso: (json['peso'] as num?)?.toDouble(),
      presionSistolica: (json['presion_sistolica'] as num?)?.toDouble(),
      presionDiastolica: (json['presion_diastolica'] as num?)?.toDouble(),
      frecuenciaCardiaca: (json['frecuencia_cardiaca'] as num?)?.toInt(),
      temperatura: (json['temperatura'] as num?)?.toDouble(),
      alturaUterina: (json['altura_uterina'] as num?)?.toDouble(),
      movimientosFetales: json['movimientos_fetales'] as String?,
      edemas: json['edemas'] as String?,
      recomendaciones: json['recomendaciones'] as String?,
      medicoId: json['medico_id'] as String,
    );

Map<String, dynamic> _$ControlModelToJson(ControlModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gestante_id': instance.gestanteId,
      'fecha_control': instance.fechaControl.toIso8601String(),
      'semanas_gestacion': instance.semanasGestacion,
      'peso': instance.peso,
      'presion_sistolica': instance.presionSistolica,
      'presion_diastolica': instance.presionDiastolica,
      'frecuencia_cardiaca': instance.frecuenciaCardiaca,
      'temperatura': instance.temperatura,
      'altura_uterina': instance.alturaUterina,
      'movimientos_fetales': instance.movimientosFetales,
      'edemas': instance.edemas,
      'recomendaciones': instance.recomendaciones,
      'medico_id': instance.medicoId,
    };
