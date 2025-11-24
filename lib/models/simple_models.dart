import 'package:json_annotation/json_annotation.dart';

part 'simple_models.g.dart';

@JsonSerializable()
class SimpleGestante {

  SimpleGestante({
    this.id,
    required this.nombre,
    required this.apellido,
    this.telefono,
    this.email,
    this.documento,
    this.direccion,
    this.eps,
    this.activa = true,
    this.riesgoAlto = false,
    this.fechaNacimiento,
    this.fechaProbableParto,
    this.fechaUltimoControl,
    this.tieneAccesoMadrina,
    this.madrinaId,
    this.createdAt,
    this.updatedAt,
  });

  factory SimpleGestante.fromJson(Map<String, dynamic> json) =>
      _$SimpleGestanteFromJson(json);
  final String? id;
  final String nombre;
  final String apellido;
  final String? telefono;
  final String? email;
  final String? documento;
  final String? direccion;
  final String? eps;
  final bool activa;
  final bool riesgoAlto;
  final DateTime? fechaNacimiento;
  final DateTime? fechaProbableParto;
  final String? fechaUltimoControl;
  final bool? tieneAccesoMadrina;
  final String? madrinaId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$SimpleGestanteToJson(this);

  /// Método para verificar si una madrina tiene acceso a esta gestante
  bool madrinaTieneAcceso(String madrinaId) {
    return this.madrinaId == madrinaId || (tieneAccesoMadrina == true);
  }

  /// Método para obtener nombre completo
  String get nombreCompleto => '$nombre $apellido'.trim();

  /// Método para verificar si está activa
  bool get estaActiva => activa;

  /// Método para verificar si es de alto riesgo
  bool get esAltoRiesgo => riesgoAlto;
}

@JsonSerializable()
class SimpleControl {

  SimpleControl({
    this.id,
    required this.gestanteId,
    required this.fechaControl,
    this.peso,
    this.tensionArterialSistolica,
    this.tensionArterialDiastolica,
    this.frecuenciaCardiaca,
    this.notas,
    this.medicoId,
    this.createdAt,
    this.updatedAt,
  });

  factory SimpleControl.fromJson(Map<String, dynamic> json) =>
      _$SimpleControlFromJson(json);
  final String? id;
  final String gestanteId;
  final DateTime fechaControl;
  final double? peso;
  final double? tensionArterialSistolica;
  final double? tensionArterialDiastolica;
  final double? frecuenciaCardiaca;
  final String? notas;
  final String? medicoId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$SimpleControlToJson(this);
}

enum TipoAlerta {
  @JsonValue(0)
  MEDICA,
  @JsonValue(1)
  NUTRICIONAL,
  @JsonValue(2)
  PSICOLOGICA,
  @JsonValue(3)
  SOCIAL,
  @JsonValue(4)
  OTRA
}

extension TipoAlertaExtension on TipoAlerta {
  String get backendValue {
    switch (this) {
      case TipoAlerta.MEDICA:
        return 'medica';
      case TipoAlerta.NUTRICIONAL:
        return 'nutricional';
      case TipoAlerta.PSICOLOGICA:
        return 'psicologica';
      case TipoAlerta.SOCIAL:
        return 'social';
      case TipoAlerta.OTRA:
        return 'otra';
    }
  }

  String get displayName {
    switch (this) {
      case TipoAlerta.MEDICA:
        return 'Médica';
      case TipoAlerta.NUTRICIONAL:
        return 'Nutricional';
      case TipoAlerta.PSICOLOGICA:
        return 'Psicológica';
      case TipoAlerta.SOCIAL:
        return 'Social';
      case TipoAlerta.OTRA:
        return 'Otra';
    }
  }
}

enum NivelPrioridad {
  @JsonValue(0)
  BAJA,
  @JsonValue(1)
  MEDIA,
  @JsonValue(2)
  ALTA,
  @JsonValue(3)
  URGENTE
}

extension NivelPrioridadExtension on NivelPrioridad {
  String get backendValue {
    switch (this) {
      case NivelPrioridad.BAJA:
        return 'baja';
      case NivelPrioridad.MEDIA:
        return 'media';
      case NivelPrioridad.ALTA:
        return 'alta';
      case NivelPrioridad.URGENTE:
        return 'urgente';
    }
  }

  String get displayName {
    switch (this) {
      case NivelPrioridad.BAJA:
        return 'Baja';
      case NivelPrioridad.MEDIA:
        return 'Media';
      case NivelPrioridad.ALTA:
        return 'Alta';
      case NivelPrioridad.URGENTE:
        return 'Urgente';
    }
  }
}

@JsonSerializable()
class SimpleAlerta {

  SimpleAlerta({
    this.id,
    required this.gestanteId,
    required this.tipo,
    required this.nivelPrioridad,
    required this.descripcion,
    this.resuelta = false,
    this.respuesta,
    this.fechaResolucion,
    this.medicoId,
    this.createdAt,
    this.updatedAt,
  });

  factory SimpleAlerta.fromJson(Map<String, dynamic> json) =>
      _$SimpleAlertaFromJson(json);
  final String? id;
  final String gestanteId;
  final String tipo;
  final String nivelPrioridad;
  final String descripcion;
  final bool resuelta;
  final String? respuesta;
  final DateTime? fechaResolucion;
  final String? medicoId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$SimpleAlertaToJson(this);
}

@JsonSerializable()
class SimpleUsuario {

  SimpleUsuario({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    this.activo = true,
    this.telefono,
    this.createdAt,
    this.updatedAt,
  });

  factory SimpleUsuario.fromJson(Map<String, dynamic> json) =>
      _$SimpleUsuarioFromJson(json);
  final String? id;
  final String nombre;
  final String apellido;
  final String email;
  final String rol;
  final bool activo;
  final String? telefono;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$SimpleUsuarioToJson(this);

  Map<String, dynamic> toCreateJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': rol,
      'activo': activo,
      if (telefono != null) 'telefono': telefono,
    };
  }
}

@JsonSerializable()
class SimpleIPS {

  SimpleIPS({
    this.id,
    required this.nombre,
    required this.direccion,
    this.telefono,
    this.email,
    this.nit,
    this.departamento,
    this.municipio,
    this.activa = true,
    this.createdAt,
    this.updatedAt,
  });

  factory SimpleIPS.fromJson(Map<String, dynamic> json) =>
      _$SimpleIPSFromJson(json);
  final String? id;
  final String nombre;
  final String direccion;
  final String? telefono;
  final String? email;
  final String? nit;
  final String? departamento;
  final String? municipio;
  final bool activa;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$SimpleIPSToJson(this);
}
