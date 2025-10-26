// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EstadisticasGeneralesModel _$EstadisticasGeneralesModelFromJson(
        Map<String, dynamic> json) =>
    EstadisticasGeneralesModel(
      totalGestantes: (json['totalGestantes'] as num).toInt(),
      gestantesActivas: (json['gestantesActivas'] as num).toInt(),
      gestantesInactivas: (json['gestantesInactivas'] as num).toInt(),
      gestantesAltoRiesgo: (json['gestantesAltoRiesgo'] as num).toInt(),
      totalControles: (json['totalControles'] as num).toInt(),
      controlesUltimoMes: (json['controlesUltimoMes'] as num).toInt(),
      totalAlertas: (json['totalAlertas'] as num).toInt(),
      alertasActivas: (json['alertasActivas'] as num).toInt(),
      alertasResueltas: (json['alertasResueltas'] as num).toInt(),
      alertasUrgentes: (json['alertasUrgentes'] as num).toInt(),
      promedioEdadGestacional:
          (json['promedioEdadGestacional'] as num?)?.toDouble(),
      porcentajeControlCompleto:
          (json['porcentajeControlCompleto'] as num?)?.toDouble(),
      totalMedicos: (json['totalMedicos'] as num).toInt(),
      totalIps: (json['totalIps'] as num).toInt(),
      promedioControlesPorGestante:
          (json['promedioControlesPorGestante'] as num).toDouble(),
      fechaActualizacion: DateTime.parse(json['fechaActualizacion'] as String),
    );

Map<String, dynamic> _$EstadisticasGeneralesModelToJson(
        EstadisticasGeneralesModel instance) =>
    <String, dynamic>{
      'totalGestantes': instance.totalGestantes,
      'gestantesActivas': instance.gestantesActivas,
      'gestantesInactivas': instance.gestantesInactivas,
      'gestantesAltoRiesgo': instance.gestantesAltoRiesgo,
      'totalControles': instance.totalControles,
      'controlesUltimoMes': instance.controlesUltimoMes,
      'totalAlertas': instance.totalAlertas,
      'alertasActivas': instance.alertasActivas,
      'alertasResueltas': instance.alertasResueltas,
      'alertasUrgentes': instance.alertasUrgentes,
      'promedioEdadGestacional': instance.promedioEdadGestacional,
      'porcentajeControlCompleto': instance.porcentajeControlCompleto,
      'totalMedicos': instance.totalMedicos,
      'totalIps': instance.totalIps,
      'promedioControlesPorGestante': instance.promedioControlesPorGestante,
      'fechaActualizacion': instance.fechaActualizacion.toIso8601String(),
    };

EstadisticasPorPeriodoModel _$EstadisticasPorPeriodoModelFromJson(
        Map<String, dynamic> json) =>
    EstadisticasPorPeriodoModel(
      periodo: json['periodo'] as String,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: DateTime.parse(json['fechaFin'] as String),
      nuevasGestantes: (json['nuevasGestantes'] as num).toInt(),
      controlesRealizados: (json['controlesRealizados'] as num).toInt(),
      alertasGeneradas: (json['alertasGeneradas'] as num).toInt(),
      alertasResueltas: (json['alertasResueltas'] as num).toInt(),
      promedioTiempoResolucion:
          (json['promedioTiempoResolucion'] as num?)?.toDouble(),
      satisfaccionPromedio: (json['satisfaccionPromedio'] as num?)?.toDouble(),
      datosDiarios: (json['datosDiarios'] as List<dynamic>)
          .map(
              (e) => EstadisticaDiariaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EstadisticasPorPeriodoModelToJson(
        EstadisticasPorPeriodoModel instance) =>
    <String, dynamic>{
      'periodo': instance.periodo,
      'fechaInicio': instance.fechaInicio.toIso8601String(),
      'fechaFin': instance.fechaFin.toIso8601String(),
      'nuevasGestantes': instance.nuevasGestantes,
      'controlesRealizados': instance.controlesRealizados,
      'alertasGeneradas': instance.alertasGeneradas,
      'alertasResueltas': instance.alertasResueltas,
      'promedioTiempoResolucion': instance.promedioTiempoResolucion,
      'satisfaccionPromedio': instance.satisfaccionPromedio,
      'datosDiarios': instance.datosDiarios,
    };

EstadisticaDiariaModel _$EstadisticaDiariaModelFromJson(
        Map<String, dynamic> json) =>
    EstadisticaDiariaModel(
      fecha: DateTime.parse(json['fecha'] as String),
      nuevasGestantes: (json['nuevasGestantes'] as num).toInt(),
      controlesRealizados: (json['controlesRealizados'] as num).toInt(),
      alertasGeneradas: (json['alertasGeneradas'] as num).toInt(),
      alertasResueltas: (json['alertasResueltas'] as num).toInt(),
      usuariosActivos: (json['usuariosActivos'] as num).toInt(),
    );

Map<String, dynamic> _$EstadisticaDiariaModelToJson(
        EstadisticaDiariaModel instance) =>
    <String, dynamic>{
      'fecha': instance.fecha.toIso8601String(),
      'nuevasGestantes': instance.nuevasGestantes,
      'controlesRealizados': instance.controlesRealizados,
      'alertasGeneradas': instance.alertasGeneradas,
      'alertasResueltas': instance.alertasResueltas,
      'usuariosActivos': instance.usuariosActivos,
    };

EstadisticasGeograficasModel _$EstadisticasGeograficasModelFromJson(
        Map<String, dynamic> json) =>
    EstadisticasGeograficasModel(
      region: json['region'] as String,
      departamento: json['departamento'] as String,
      municipio: json['municipio'] as String,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      totalGestantes: (json['totalGestantes'] as num).toInt(),
      gestantesAltoRiesgo: (json['gestantesAltoRiesgo'] as num).toInt(),
      controlesRealizados: (json['controlesRealizados'] as num).toInt(),
      alertasActivas: (json['alertasActivas'] as num).toInt(),
      totalControles: (json['totalControles'] as num).toInt(),
      totalAlertas: (json['totalAlertas'] as num).toInt(),
      alertasUrgentes: (json['alertasUrgentes'] as num).toInt(),
      gestantesActivas: (json['gestantesActivas'] as num).toInt(),
      cobertura: (json['cobertura'] as num).toDouble(),
      ubicacionLatitud: (json['ubicacionLatitud'] as num?)?.toDouble(),
      ubicacionLongitud: (json['ubicacionLongitud'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$EstadisticasGeograficasModelToJson(
        EstadisticasGeograficasModel instance) =>
    <String, dynamic>{
      'region': instance.region,
      'departamento': instance.departamento,
      'municipio': instance.municipio,
      'latitud': instance.latitud,
      'longitud': instance.longitud,
      'totalGestantes': instance.totalGestantes,
      'gestantesAltoRiesgo': instance.gestantesAltoRiesgo,
      'controlesRealizados': instance.controlesRealizados,
      'alertasActivas': instance.alertasActivas,
      'totalControles': instance.totalControles,
      'totalAlertas': instance.totalAlertas,
      'alertasUrgentes': instance.alertasUrgentes,
      'gestantesActivas': instance.gestantesActivas,
      'cobertura': instance.cobertura,
      'ubicacionLatitud': instance.ubicacionLatitud,
      'ubicacionLongitud': instance.ubicacionLongitud,
    };

ReporteModel _$ReporteModelFromJson(Map<String, dynamic> json) => ReporteModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      tipoReporte: json['tipoReporte'] as String,
      parametros: json['parametros'] as Map<String, dynamic>,
      datos: json['datos'] as Map<String, dynamic>,
      estado: json['estado'] as String,
      fechaGeneracion: DateTime.parse(json['fechaGeneracion'] as String),
      fechaCompletado: json['fechaCompletado'] == null
          ? null
          : DateTime.parse(json['fechaCompletado'] as String),
      urlArchivo: json['urlArchivo'] as String?,
      formatoArchivo: json['formatoArchivo'] as String,
      creadoPor: json['creadoPor'] as String,
      fechaInicio: json['fechaInicio'] == null
          ? null
          : DateTime.parse(json['fechaInicio'] as String),
      fechaFin: json['fechaFin'] == null
          ? null
          : DateTime.parse(json['fechaFin'] as String),
      archivoUrl: json['archivoUrl'] as String?,
      formato: json['formato'] as String?,
      usuarioId: json['usuarioId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ReporteModelToJson(ReporteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titulo': instance.titulo,
      'descripcion': instance.descripcion,
      'tipoReporte': instance.tipoReporte,
      'parametros': instance.parametros,
      'datos': instance.datos,
      'estado': instance.estado,
      'fechaGeneracion': instance.fechaGeneracion.toIso8601String(),
      'fechaCompletado': instance.fechaCompletado?.toIso8601String(),
      'urlArchivo': instance.urlArchivo,
      'formatoArchivo': instance.formatoArchivo,
      'creadoPor': instance.creadoPor,
      'fechaInicio': instance.fechaInicio?.toIso8601String(),
      'fechaFin': instance.fechaFin?.toIso8601String(),
      'archivoUrl': instance.archivoUrl,
      'formato': instance.formato,
      'usuarioId': instance.usuarioId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
