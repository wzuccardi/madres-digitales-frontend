// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      municipalityId: json['municipalityId'] as String?,
      phone: json['phone'] as String?,
      document: json['document'] as String?,
      documentType: json['documentType'] as String?,
      active: json['active'] as bool,
      lastAccess: json['lastAccess'] == null
          ? null
          : DateTime.parse(json['lastAccess'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      municipalityName: json['municipalityName'] as String?,
      departmentName: json['departmentName'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': instance.role,
      'municipalityId': instance.municipalityId,
      'phone': instance.phone,
      'document': instance.document,
      'documentType': instance.documentType,
      'active': instance.active,
      'lastAccess': instance.lastAccess?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'municipalityName': instance.municipalityName,
      'departmentName': instance.departmentName,
      'profileImageUrl': instance.profileImageUrl,
      'preferences': instance.preferences,
      'metadata': instance.metadata,
    };
