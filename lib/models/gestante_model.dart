import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'usuario_model.dart';

part 'gestante_model.g.dart';

@JsonSerializable()
class GestanteModel extends Equatable {
  final String id;
  final String usuarioId;
  final DateTime fechaUltimaMenstruacion;
  final DateTime? fechaProbableParto;
  final int? numeroEmbarazos;
  final int? numeroPartos;
  final int? numeroAbortos;
  final String? grupoSanguineo;
  final String? factorRh;
  final double? pesoPregestacional;
  final double? talla;
  final String? antecedentesPersonales;
  final String? antecedentesFamiliares;
  final String? medicamentosActuales;
  final String? alergias;
  final String? observaciones;
  final bool embarazoAltoRiesgo;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relaciones
  final UsuarioModel? usuario;
  final List<ControlPrenatalModel>? controles;
  final List<AlertaModel>? alertas;
  
  const GestanteModel({
    required this.id,
    required this.usuarioId,
    required this.fechaUltimaMenstruacion,
    this.fechaProbableParto,
    this.numeroEmbarazos,
    this.numeroPartos,
    this.numeroAbortos,
    this.grupoSanguineo,
    this.factorRh,
    this.pesoPregestacional,
    this.talla,
    this.antecedentesPersonales,
    this.antecedentesFamiliares,
    this.medicamentosActuales,
    this.alergias,
    this.observaciones,
    required this.embarazoAltoRiesgo,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.usuario,
    this.controles,
    this.alertas,
  });
  
  factory GestanteModel.fromJson(Map<String, dynamic> json) => _$GestanteModelFromJson(json);
  Map<String, dynamic> toJson() => _$GestanteModelToJson(this);
  
  GestanteModel copyWith({
    String? id,
    String? usuarioId,
    DateTime? fechaUltimaMenstruacion,
    DateTime? fechaProbableParto,
    int? numeroEmbarazos,
    int? numeroPartos,
    int? numeroAbortos,
    String? grupoSanguineo,
    String? factorRh,
    double? pesoPregestacional,
    double? talla,
    String? antecedentesPersonales,
    String? antecedentesFamiliares,
    String? medicamentosActuales,
    String? alergias,
    String? observaciones,
    bool? embarazoAltoRiesgo,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    UsuarioModel? usuario,
    List<ControlPrenatalModel>? controles,
    List<AlertaModel>? alertas,
  }) {
    return GestanteModel(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      fechaUltimaMenstruacion: fechaUltimaMenstruacion ?? this.fechaUltimaMenstruacion,
      fechaProbableParto: fechaProbableParto ?? this.fechaProbableParto,
      numeroEmbarazos: numeroEmbarazos ?? this.numeroEmbarazos,
      numeroPartos: numeroPartos ?? this.numeroPartos,
      numeroAbortos: numeroAbortos ?? this.numeroAbortos,
      grupoSanguineo: grupoSanguineo ?? this.grupoSanguineo,
      factorRh: factorRh ?? this.factorRh,
      pesoPregestacional: pesoPregestacional ?? this.pesoPregestacional,
      talla: talla ?? this.talla,
      antecedentesPersonales: antecedentesPersonales ?? this.antecedentesPersonales,
      antecedentesFamiliares: antecedentesFamiliares ?? this.antecedentesFamiliares,
      medicamentosActuales: medicamentosActuales ?? this.medicamentosActuales,
      alergias: alergias ?? this.alergias,
      observaciones: observaciones ?? this.observaciones,
      embarazoAltoRiesgo: embarazoAltoRiesgo ?? this.embarazoAltoRiesgo,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usuario: usuario ?? this.usuario,
      controles: controles ?? this.controles,
      alertas: alertas ?? this.alertas,
    );
  }
  
  String get nombreCompleto => usuario?.nombreCompleto ?? '';
  
  int get semanasGestacion {
    final now = DateTime.now();
    final diferencia = now.difference(fechaUltimaMenstruacion);
    return (diferencia.inDays / 7).floor();
  }
  
  String get trimestreActual {
    final semanas = semanasGestacion;
    if (semanas <= 12) return 'Primer trimestre';
    if (semanas <= 28) return 'Segundo trimestre';
    return 'Tercer trimestre';
  }
  
  bool get esEmbarazoTermino => semanasGestacion >= 37;
  
  double? get imcPregestacional {
    if (pesoPregestacional != null && talla != null && talla! > 0) {
      return pesoPregestacional! / (talla! * talla!);
    }
    return null;
  }
  
  @override
  List<Object?> get props => [
    id,
    usuarioId,
    fechaUltimaMenstruacion,
    fechaProbableParto,
    numeroEmbarazos,
    numeroPartos,
    numeroAbortos,
    grupoSanguineo,
    factorRh,
    pesoPregestacional,
    talla,
    antecedentesPersonales,
    antecedentesFamiliares,
    medicamentosActuales,
    alergias,
    observaciones,
    embarazoAltoRiesgo,
    activo,
    createdAt,
    updatedAt,
  ];
}

@JsonSerializable()
class ControlPrenatalModel extends Equatable {
  final String id;
  final String gestanteId;
  final String? medicoId;
  final DateTime fechaControl;
  final int semanasGestacion;
  final double? peso;
  final int? presionSistolica;
  final int? presionDiastolica;
  final int? frecuenciaCardiaca;
  final double? temperatura;
  final double? alturaUterina;
  final int? frecuenciaCardiacaFetal;
  final String? presentacionFetal;
  final String? movimientosFetales;
  final String? edemas;
  final String? proteinuria;
  final String? glucosuria;
  final String? observaciones;
  final String? recomendaciones;
  final DateTime? proximoControl;
  final double? ubicacionLatitud;
  final double? ubicacionLongitud;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relaciones
  final GestanteModel? gestante;
  final MedicoModel? medico;
  
  const ControlPrenatalModel({
    required this.id,
    required this.gestanteId,
    this.medicoId,
    required this.fechaControl,
    required this.semanasGestacion,
    this.peso,
    this.presionSistolica,
    this.presionDiastolica,
    this.frecuenciaCardiaca,
    this.temperatura,
    this.alturaUterina,
    this.frecuenciaCardiacaFetal,
    this.presentacionFetal,
    this.movimientosFetales,
    this.edemas,
    this.proteinuria,
    this.glucosuria,
    this.observaciones,
    this.recomendaciones,
    this.proximoControl,
    this.ubicacionLatitud,
    this.ubicacionLongitud,
    required this.createdAt,
    required this.updatedAt,
    this.gestante,
    this.medico,
  });
  
  factory ControlPrenatalModel.fromJson(Map<String, dynamic> json) => _$ControlPrenatalModelFromJson(json);
  Map<String, dynamic> toJson() => _$ControlPrenatalModelToJson(this);
  
  bool get tienePresionAlta => 
    presionSistolica != null && presionDiastolica != null &&
    (presionSistolica! >= 140 || presionDiastolica! >= 90);
  
  bool get tienePresionBaja => 
    presionSistolica != null && presionDiastolica != null &&
    (presionSistolica! < 90 || presionDiastolica! < 60);
  
  bool get tieneFiebre => temperatura != null && temperatura! >= 37.5;
  
  bool get tieneUbicacion => ubicacionLatitud != null && ubicacionLongitud != null;
  
  @override
  List<Object?> get props => [
    id,
    gestanteId,
    medicoId,
    fechaControl,
    semanasGestacion,
    peso,
    presionSistolica,
    presionDiastolica,
    frecuenciaCardiaca,
    temperatura,
    alturaUterina,
    frecuenciaCardiacaFetal,
    presentacionFetal,
    movimientosFetales,
    edemas,
    proteinuria,
    glucosuria,
    observaciones,
    recomendaciones,
    proximoControl,
    ubicacionLatitud,
    ubicacionLongitud,
    createdAt,
    updatedAt,
  ];
}

@JsonSerializable()
class AlertaModel extends Equatable {
  final String id;
  final String gestanteId;
  final String? controlId;
  final String tipoAlerta;
  final String nivelPrioridad;
  final String mensaje;
  final String? descripcionDetallada;
  final bool resuelta;
  final DateTime? fechaResolucion;
  final String? resolucionComentarios;
  final double? ubicacionLatitud;
  final double? ubicacionLongitud;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relaciones
  final GestanteModel? gestante;
  final ControlPrenatalModel? control;
  
  const AlertaModel({
    required this.id,
    required this.gestanteId,
    this.controlId,
    required this.tipoAlerta,
    required this.nivelPrioridad,
    required this.mensaje,
    this.descripcionDetallada,
    required this.resuelta,
    this.fechaResolucion,
    this.resolucionComentarios,
    this.ubicacionLatitud,
    this.ubicacionLongitud,
    required this.createdAt,
    required this.updatedAt,
    this.gestante,
    this.control,
  });
  
  factory AlertaModel.fromJson(Map<String, dynamic> json) => _$AlertaModelFromJson(json);
  Map<String, dynamic> toJson() => _$AlertaModelToJson(this);
  
  bool get esUrgente => nivelPrioridad == 'CRITICA' || nivelPrioridad == 'ALTA';
  
  bool get tieneUbicacion => ubicacionLatitud != null && ubicacionLongitud != null;
  
  Duration get tiempoTranscurrido => DateTime.now().difference(createdAt);
  
  @override
  List<Object?> get props => [
    id,
    gestanteId,
    controlId,
    tipoAlerta,
    nivelPrioridad,
    mensaje,
    descripcionDetallada,
    resuelta,
    fechaResolucion,
    resolucionComentarios,
    ubicacionLatitud,
    ubicacionLongitud,
    createdAt,
    updatedAt,
  ];
}

// Enums para tipos de alerta
enum TipoAlerta {
  @JsonValue('PRESION_ALTA')
  presionAlta,
  @JsonValue('PRESION_BAJA')
  presionBaja,
  @JsonValue('FIEBRE')
  fiebre,
  @JsonValue('PESO_ANORMAL')
  pesoAnormal,
  @JsonValue('FRECUENCIA_CARDIACA_ANORMAL')
  frecuenciaCardiacaAnormal,
  @JsonValue('CONTROL_VENCIDO')
  controlVencido,
  @JsonValue('EMBARAZO_ALTO_RIESGO')
  embarazoAltoRiesgo,
  @JsonValue('OTROS')
  otros,
}

// Enums para nivel de prioridad
enum NivelPrioridad {
  @JsonValue('BAJA')
  baja,
  @JsonValue('MEDIA')
  media,
  @JsonValue('ALTA')
  alta,
  @JsonValue('CRITICA')
  critica,
}