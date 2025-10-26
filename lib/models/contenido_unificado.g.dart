// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contenido_unificado.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContenidoUnificado _$ContenidoUnificadoFromJson(Map<String, dynamic> json) =>
    ContenidoUnificado(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      categoria: json['categoria'] as String,
      tipo: json['tipo'] as String,
      urlContenido: json['url_contenido'] as String?,
      urlImagen: json['url_imagen'] as String?,
      duracionMinutos: (json['duracion_minutos'] as num?)?.toInt(),
      nivel: json['nivel'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaActualizacion: DateTime.parse(json['fecha_actualizacion'] as String),
      activo: json['activo'] as bool,
      destacado: json['destacado'] as bool? ?? false,
      destacadoEnSemanaGestacion:
          json['destacado_en_semana_gestacion'] as bool?,
      semanaGestacionInicio: (json['semana_gestacion_inicio'] as num?)?.toInt(),
      semanaGestacionFin: (json['semana_gestacion_fin'] as num?)?.toInt(),
      urlVideo: json['url_video'] as String?,
    );

Map<String, dynamic> _$ContenidoUnificadoToJson(ContenidoUnificado instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titulo': instance.titulo,
      'descripcion': instance.descripcion,
      'categoria': instance.categoria,
      'tipo': instance.tipo,
      'url_contenido': instance.urlContenido,
      'url_imagen': instance.urlImagen,
      'duracion_minutos': instance.duracionMinutos,
      'nivel': instance.nivel,
      'tags': instance.tags,
      'fecha_creacion': instance.fechaCreacion.toIso8601String(),
      'fecha_actualizacion': instance.fechaActualizacion.toIso8601String(),
      'activo': instance.activo,
      'destacado': instance.destacado,
      'destacado_en_semana_gestacion': instance.destacadoEnSemanaGestacion,
      'semana_gestacion_inicio': instance.semanaGestacionInicio,
      'semana_gestacion_fin': instance.semanaGestacionFin,
      'url_video': instance.urlVideo,
    };
