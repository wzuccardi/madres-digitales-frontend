// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element

part of 'sos_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SOSLocation _$SOSLocationFromJson(Map<String, dynamic> json) => SOSLocation(
      id: json['id'] as String,
      alertaId: json['alertaId'] as String,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      precision: (json['precision'] as num?)?.toDouble(),
      direccion: json['direccion'] as String?,
      barrio: json['barrio'] as String?,
      municipio: json['municipio'] as String?,
      departamento: json['departamento'] as String?,
      fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SOSLocationToJson(SOSLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alertaId': instance.alertaId,
      'latitud': instance.latitud,
      'longitud': instance.longitud,
      'precision': instance.precision,
      'direccion': instance.direccion,
      'barrio': instance.barrio,
      'municipio': instance.municipio,
      'departamento': instance.departamento,
      'fechaRegistro': instance.fechaRegistro.toIso8601String(),
      'metadata': instance.metadata,
    };
