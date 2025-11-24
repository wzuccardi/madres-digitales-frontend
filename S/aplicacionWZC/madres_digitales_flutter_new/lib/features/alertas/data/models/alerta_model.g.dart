// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerta_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertaModel _$AlertaModelFromJson(Map<String, dynamic> json) => AlertaModel(
      id: json['id'] as String,
      gestanteId: json['gestanteId'] as String,
      tipoAlerta: json['tipoAlerta'] as String,
      nivelPrioridad: json['nivelPrioridad'] as String,
      mensaje: json['mensaje'] as String,
    );

Map<String, dynamic> _$AlertaModelToJson(AlertaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gestanteId': instance.gestanteId,
      'tipoAlerta': instance.tipoAlerta,
      'nivelPrioridad': instance.nivelPrioridad,
      'mensaje': instance.mensaje,
    };
