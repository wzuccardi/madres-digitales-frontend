import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'dashboard_model.g.dart';

@JsonSerializable()
class EstadisticasGeneralesModel extends Equatable {
  final int totalGestantes;
  final int gestantesActivas;
  final int gestantesAltoRiesgo;
  final int totalControles;
  final int controlesUltimoMes;
  final int alertasActivas;
  final int alertasCriticas;
  final int totalMedicos;
  final int totalIps;
  final double promedioControlesPorGestante;
  final DateTime fechaActualizacion;
  
  const EstadisticasGeneralesModel({
    required this.totalGestantes,
    required this.gestantesActivas,
    required this.gestantesAltoRiesgo,
    required this.totalControles,
    required this.controlesUltimoMes,
    required this.alertasActivas,
    required this.alertasCriticas,
    required this.totalMedicos,
    required this.totalIps,
    required this.promedioControlesPorGestante,
    required this.fechaActualizacion,
  });
  
  factory EstadisticasGeneralesModel.fromJson(Map<String, dynamic> json) => _$EstadisticasGeneralesModelFromJson(json);
  Map<String, dynamic> toJson() => _$EstadisticasGeneralesModelToJson(this);
  
  double get porcentajeAltoRiesgo => 
    totalGestantes > 0 ? (gestantesAltoRiesgo / totalGestantes) * 100 : 0;
  
  double get porcentajeAlertasCriticas => 
    alertasActivas > 0 ? (alertasCriticas / alertasActivas) * 100 : 0;
  
  @override
  List<Object?> get props => [
    totalGestantes,
    gestantesActivas,
    gestantesAltoRiesgo,
    totalControles,
    controlesUltimoMes,
    alertasActivas,
    alertasCriticas,
    totalMedicos,
    totalIps,
    promedioControlesPorGestante,
    fechaActualizacion,
  ];
}

@JsonSerializable()
class EstadisticasPorPeriodoModel extends Equatable {
  final String periodo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int nuevasGestantes;
  final int controlesRealizados;
  final int alertasGeneradas;
  final int alertasResueltas;
  final List<EstadisticaDiariaModel> datosDiarios;
  
  const EstadisticasPorPeriodoModel({
    required this.periodo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.nuevasGestantes,
    required this.controlesRealizados,
    required this.alertasGeneradas,
    required this.alertasResueltas,
    required this.datosDiarios,
  });
  
  factory EstadisticasPorPeriodoModel.fromJson(Map<String, dynamic> json) => _$EstadisticasPorPeriodoModelFromJson(json);
  Map<String, dynamic> toJson() => _$EstadisticasPorPeriodoModelToJson(this);
  
  double get promedioControlesDiarios => 
    datosDiarios.isNotEmpty ? controlesRealizados / datosDiarios.length : 0;
  
  double get tasaResolucionAlertas => 
    alertasGeneradas > 0 ? (alertasResueltas / alertasGeneradas) * 100 : 0;
  
  @override
  List<Object?> get props => [
    periodo,
    fechaInicio,
    fechaFin,
    nuevasGestantes,
    controlesRealizados,
    alertasGeneradas,
    alertasResueltas,
    datosDiarios,
  ];
}

@JsonSerializable()
class EstadisticaDiariaModel extends Equatable {
  final DateTime fecha;
  final int nuevasGestantes;
  final int controlesRealizados;
  final int alertasGeneradas;
  final int alertasResueltas;
  
  const EstadisticaDiariaModel({
    required this.fecha,
    required this.nuevasGestantes,
    required this.controlesRealizados,
    required this.alertasGeneradas,
    required this.alertasResueltas,
  });
  
  factory EstadisticaDiariaModel.fromJson(Map<String, dynamic> json) => _$EstadisticaDiariaModelFromJson(json);
  Map<String, dynamic> toJson() => _$EstadisticaDiariaModelToJson(this);
  
  @override
  List<Object?> get props => [
    fecha,
    nuevasGestantes,
    controlesRealizados,
    alertasGeneradas,
    alertasResueltas,
  ];
}

@JsonSerializable()
class EstadisticasGeograficasModel extends Equatable {
  final String region;
  final String departamento;
  final String municipio;
  final double latitud;
  final double longitud;
  final int totalGestantes;
  final int gestantesAltoRiesgo;
  final int controlesRealizados;
  final int alertasActivas;
  final double cobertura;
  
  const EstadisticasGeograficasModel({
    required this.region,
    required this.departamento,
    required this.municipio,
    required this.latitud,
    required this.longitud,
    required this.totalGestantes,
    required this.gestantesAltoRiesgo,
    required this.controlesRealizados,
    required this.alertasActivas,
    required this.cobertura,
  });
  
  factory EstadisticasGeograficasModel.fromJson(Map<String, dynamic> json) => _$EstadisticasGeograficasModelFromJson(json);
  Map<String, dynamic> toJson() => _$EstadisticasGeograficasModelToJson(this);
  
  String get ubicacionCompleta => '$municipio, $departamento';
  
  bool get esZonaAltoRiesgo => 
    (gestantesAltoRiesgo / totalGestantes) > 0.3 || cobertura < 0.7;
  
  @override
  List<Object?> get props => [
    region,
    departamento,
    municipio,
    latitud,
    longitud,
    totalGestantes,
    gestantesAltoRiesgo,
    controlesRealizados,
    alertasActivas,
    cobertura,
  ];
}

@JsonSerializable()
class ReporteModel extends Equatable {
  final String id;
  final String titulo;
  final String descripcion;
  final String tipoReporte;
  final Map<String, dynamic> parametros;
  final Map<String, dynamic> datos;
  final String estado;
  final DateTime fechaGeneracion;
  final DateTime? fechaCompletado;
  final String? urlArchivo;
  final String formatoArchivo;
  final String creadoPor;
  
  const ReporteModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipoReporte,
    required this.parametros,
    required this.datos,
    required this.estado,
    required this.fechaGeneracion,
    this.fechaCompletado,
    this.urlArchivo,
    required this.formatoArchivo,
    required this.creadoPor,
  });
  
  factory ReporteModel.fromJson(Map<String, dynamic> json) => _$ReporteModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReporteModelToJson(this);
  
  bool get estaCompleto => estado == 'COMPLETADO';
  bool get estaEnProceso => estado == 'EN_PROCESO';
  bool get tieneError => estado == 'ERROR';
  
  Duration? get tiempoGeneracion {
    if (fechaCompletado != null) {
      return fechaCompletado!.difference(fechaGeneracion);
    }
    return null;
  }
  
  @override
  List<Object?> get props => [
    id,
    titulo,
    descripcion,
    tipoReporte,
    parametros,
    datos,
    estado,
    fechaGeneracion,
    fechaCompletado,
    urlArchivo,
    formatoArchivo,
    creadoPor,
  ];
}

// Enums para tipos de reporte
enum TipoReporte {
  @JsonValue('ESTADISTICAS_GENERALES')
  estadisticasGenerales,
  @JsonValue('GESTANTES_ALTO_RIESGO')
  gestantesAltoRiesgo,
  @JsonValue('CONTROLES_PRENATALES')
  controlesPrenatales,
  @JsonValue('ALERTAS_MEDICAS')
  alertasMedicas,
  @JsonValue('COBERTURA_GEOGRAFICA')
  coberturaGeografica,
  @JsonValue('RENDIMIENTO_MEDICOS')
  rendimientoMedicos,
  @JsonValue('SEGUIMIENTO_EMBARAZOS')
  seguimientoEmbarazos,
}

// Enums para estado de reporte
enum EstadoReporte {
  @JsonValue('PENDIENTE')
  pendiente,
  @JsonValue('EN_PROCESO')
  enProceso,
  @JsonValue('COMPLETADO')
  completado,
  @JsonValue('ERROR')
  error,
}

// Enums para formato de archivo
enum FormatoArchivo {
  @JsonValue('PDF')
  pdf,
  @JsonValue('EXCEL')
  excel,
  @JsonValue('CSV')
  csv,
  @JsonValue('JSON')
  json,
}