// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleGestante _$SimpleGestanteFromJson(Map<String, dynamic> json) =>
    SimpleGestante(
      id: json['id'] as String?,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      documento: json['documento'] as String?,
      direccion: json['direccion'] as String?,
      eps: json['eps'] as String?,
      activa: json['activa'] as bool? ?? true,
      riesgoAlto: json['riesgoAlto'] as bool? ?? false,
      fechaNacimiento: json['fechaNacimiento'] == null
          ? null
          : DateTime.parse(json['fechaNacimiento'] as String),
      fechaProbableParto: json['fechaProbableParto'] == null
          ? null
          : DateTime.parse(json['fechaProbableParto'] as String),
      fechaUltimoControl: json['fechaUltimoControl'] as String?,
      tieneAccesoMadrina: json['tieneAccesoMadrina'] as bool?,
      madrinaId: json['madrinaId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SimpleGestanteToJson(SimpleGestante instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'apellido': instance.apellido,
      'telefono': instance.telefono,
      'email': instance.email,
      'documento': instance.documento,
      'direccion': instance.direccion,
      'eps': instance.eps,
      'activa': instance.activa,
      'riesgoAlto': instance.riesgoAlto,
      'fechaNacimiento': instance.fechaNacimiento?.toIso8601String(),
      'fechaProbableParto': instance.fechaProbableParto?.toIso8601String(),
      'fechaUltimoControl': instance.fechaUltimoControl,
      'tieneAccesoMadrina': instance.tieneAccesoMadrina,
      'madrinaId': instance.madrinaId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

SimpleControl _$SimpleControlFromJson(Map<String, dynamic> json) =>
    SimpleControl(
      id: json['id'] as String?,
      gestanteId: json['gestanteId'] as String,
      fechaControl: DateTime.parse(json['fechaControl'] as String),
      peso: (json['peso'] as num?)?.toDouble(),
      tensionArterialSistolica:
          (json['tensionArterialSistolica'] as num?)?.toDouble(),
      tensionArterialDiastolica:
          (json['tensionArterialDiastolica'] as num?)?.toDouble(),
      frecuenciaCardiaca: (json['frecuenciaCardiaca'] as num?)?.toDouble(),
      notas: json['notas'] as String?,
      medicoId: json['medicoId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SimpleControlToJson(SimpleControl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gestanteId': instance.gestanteId,
      'fechaControl': instance.fechaControl.toIso8601String(),
      'peso': instance.peso,
      'tensionArterialSistolica': instance.tensionArterialSistolica,
      'tensionArterialDiastolica': instance.tensionArterialDiastolica,
      'frecuenciaCardiaca': instance.frecuenciaCardiaca,
      'notas': instance.notas,
      'medicoId': instance.medicoId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

SimpleAlerta _$SimpleAlertaFromJson(Map<String, dynamic> json) => SimpleAlerta(
      id: json['id'] as String?,
      gestanteId: json['gestanteId'] as String,
      tipo: json['tipo'] as String,
      nivelPrioridad: json['nivelPrioridad'] as String,
      descripcion: json['descripcion'] as String,
      resuelta: json['resuelta'] as bool? ?? false,
      respuesta: json['respuesta'] as String?,
      fechaResolucion: json['fechaResolucion'] == null
          ? null
          : DateTime.parse(json['fechaResolucion'] as String),
      medicoId: json['medicoId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SimpleAlertaToJson(SimpleAlerta instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gestanteId': instance.gestanteId,
      'tipo': instance.tipo,
      'nivelPrioridad': instance.nivelPrioridad,
      'descripcion': instance.descripcion,
      'resuelta': instance.resuelta,
      'respuesta': instance.respuesta,
      'fechaResolucion': instance.fechaResolucion?.toIso8601String(),
      'medicoId': instance.medicoId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

SimpleUsuario _$SimpleUsuarioFromJson(Map<String, dynamic> json) =>
    SimpleUsuario(
      id: json['id'] as String?,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
      activo: json['activo'] as bool? ?? true,
      telefono: json['telefono'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SimpleUsuarioToJson(SimpleUsuario instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'apellido': instance.apellido,
      'email': instance.email,
      'rol': instance.rol,
      'activo': instance.activo,
      'telefono': instance.telefono,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

SimpleIPS _$SimpleIPSFromJson(Map<String, dynamic> json) => SimpleIPS(
      id: json['id'] as String?,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      nit: json['nit'] as String?,
      departamento: json['departamento'] as String?,
      municipio: json['municipio'] as String?,
      activa: json['activa'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SimpleIPSToJson(SimpleIPS instance) => <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'direccion': instance.direccion,
      'telefono': instance.telefono,
      'email': instance.email,
      'nit': instance.nit,
      'departamento': instance.departamento,
      'municipio': instance.municipio,
      'activa': instance.activa,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
