// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gestante_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GestanteModel _$GestanteModelFromJson(Map<String, dynamic> json) =>
    GestanteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      document: json['document'] as String?,
      documentType: json['documentType'] as String?,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      coordinates: json['coordinates'] as String?,
      lastMenstruation: json['lastMenstruation'] == null
          ? null
          : DateTime.parse(json['lastMenstruation'] as String),
      probableDelivery: json['probableDelivery'] == null
          ? null
          : DateTime.parse(json['probableDelivery'] as String),
      eps: json['eps'] as String?,
      healthRegime: json['healthRegime'] as String?,
      municipalityId: json['municipalityId'] as String?,
      madrinaId: json['madrinaId'] as String?,
      medicoTratanteId: json['medicoTratanteId'] as String?,
      ipsAsignadaId: json['ipsAsignadaId'] as String?,
      active: json['active'] as bool,
      highRisk: json['highRisk'] as bool? ?? false,
      lastControlDate: json['lastControlDate'] == null
          ? null
          : DateTime.parse(json['lastControlDate'] as String),
      nextControlDate: json['nextControlDate'] == null
          ? null
          : DateTime.parse(json['nextControlDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      municipalityName: json['municipalityName'] as String?,
      departmentName: json['departmentName'] as String?,
      madrinaName: json['madrinaName'] as String?,
      medicoTratanteName: json['medicoTratanteName'] as String?,
      ipsAsignadaName: json['ipsAsignadaName'] as String?,
      riskFactors: json['riskFactors'] as Map<String, dynamic>?,
      controls: json['controls'] as Map<String, dynamic>?,
      notes: json['notes'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GestanteModelToJson(GestanteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'document': instance.document,
      'documentType': instance.documentType,
      'birthDate': instance.birthDate?.toIso8601String(),
      'phone': instance.phone,
      'address': instance.address,
      'coordinates': instance.coordinates,
      'lastMenstruation': instance.lastMenstruation?.toIso8601String(),
      'probableDelivery': instance.probableDelivery?.toIso8601String(),
      'eps': instance.eps,
      'healthRegime': instance.healthRegime,
      'municipalityId': instance.municipalityId,
      'madrinaId': instance.madrinaId,
      'medicoTratanteId': instance.medicoTratanteId,
      'ipsAsignadaId': instance.ipsAsignadaId,
      'active': instance.active,
      'highRisk': instance.highRisk,
      'lastControlDate': instance.lastControlDate?.toIso8601String(),
      'nextControlDate': instance.nextControlDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'municipalityName': instance.municipalityName,
      'departmentName': instance.departmentName,
      'madrinaName': instance.madrinaName,
      'medicoTratanteName': instance.medicoTratanteName,
      'ipsAsignadaName': instance.ipsAsignadaName,
      'riskFactors': instance.riskFactors,
      'controls': instance.controls,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };
