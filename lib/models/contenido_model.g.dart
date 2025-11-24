// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contenido_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContenidoModel _$ContenidoModelFromJson(Map<String, dynamic> json) =>
    ContenidoModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      tipo: json['tipo'] as String,
      categoria: json['categoria'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      url: json['url'] as String,
      activo: json['activo'] as bool? ?? true,
      fechaPublicacion: json['fechaPublicacion'] == null
          ? null
          : DateTime.parse(json['fechaPublicacion'] as String),
      fechaExpiracion: json['fechaExpiracion'] == null
          ? null
          : DateTime.parse(json['fechaExpiracion'] as String),
      autorId: json['autorId'] as String?,
      autorNombre: json['autorNombre'] as String?,
      orden: (json['orden'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ContenidoModelToJson(ContenidoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titulo': instance.titulo,
      'descripcion': instance.descripcion,
      'tipo': instance.tipo,
      'categoria': instance.categoria,
      'tags': instance.tags,
      'url': instance.url,
      'activo': instance.activo,
      'fechaPublicacion': instance.fechaPublicacion?.toIso8601String(),
      'fechaExpiracion': instance.fechaExpiracion?.toIso8601String(),
      'autorId': instance.autorId,
      'autorNombre': instance.autorNombre,
      'orden': instance.orden,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
