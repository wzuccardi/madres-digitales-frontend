
import 'dart:convert';

class Alerta {
  
  const Alerta({
    required this.id,
    required this.titulo,
    required this.descripcion,
    this.descripcionDetallada = '',
    required this.tipoAlerta,
    required this.nivelPrioridad,
    required this.estado,
    this.gestanteId,
    this.madrinaId,
    this.creadoPor,
    required this.fechaCreacion,
    this.fechaAtencion,
    this.fechaResolucion,
    this.esAutomatica = false,
    this.requiereAccionInmediata = false,
    this.datosAdicionales = const {},
    this.etiquetas = const [],
    this.ubicacion,
  });
  
  factory Alerta.fromJson(Map<String, dynamic> json) {
    try {
      return Alerta(
        id: parseString(json['id'], 'id'),
        titulo: parseString(json['titulo'], 'titulo'),
        descripcion: parseString(json['descripcion'], 'descripcion'),
        descripcionDetallada: parseStringNullable(json['descripcionDetallada']) ?? '',
        tipoAlerta: alertaTipoFromString(parseString(json['tipoAlerta'], 'tipoAlerta')),
        nivelPrioridad: alertaNivelFromString(parseString(json['nivelPrioridad'], 'nivelPrioridad')),
        estado: alertaEstadoFromString(parseString(json['estado'], 'estado')),
        gestanteId: parseStringNullable(json['gestanteId']),
        madrinaId: parseStringNullable(json['madrinaId']),
        creadoPor: parseStringNullable(json['creadoPor']),
        fechaCreacion: parseDateTime(json['fechaCreacion'], 'fechaCreacion'),
        fechaAtencion: parseDateTimeNullable(json['fechaAtencion']),
        fechaResolucion: parseDateTimeNullable(json['fechaResolucion']),
        esAutomatica: parseBool(json['esAutomatica']) ?? false,
        requiereAccionInmediata: parseBool(json['requiereAccionInmediata']) ?? false,
        datosAdicionales: parseDatosAdicionales(json['datosAdicionales']),
        etiquetas: parseEtiquetas(json['etiquetas']),
        ubicacion: json['ubicacion'] != null 
            ? AlertaUbicacion.fromJson(json['ubicacion'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      throw FormatException('Error al parsear Alerta: $e. JSON recibido: $json');
    }
  }
  final String id;
  final String titulo;
  final String descripcion;
  final String descripcionDetallada;
  final AlertaTipo tipoAlerta;
  final AlertaNivel nivelPrioridad;
  final AlertaEstado estado;
  final String? gestanteId;
  final String? madrinaId;
  final String? creadoPor;
  final DateTime fechaCreacion;
  final DateTime? fechaAtencion;
  final DateTime? fechaResolucion;
  final bool esAutomatica;
  final bool requiereAccionInmediata;
  final Map<String, dynamic> datosAdicionales;
  final List<String> etiquetas;
  final AlertaUbicacion? ubicacion;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'descripcionDetallada': descripcionDetallada,
      'tipoAlerta': tipoAlerta.toString().split('.').last,
      'nivelPrioridad': nivelPrioridad.toString().split('.').last,
      'estado': estado.toString().split('.').last,
      'gestanteId': gestanteId,
      'madrinaId': madrinaId,
      'creadoPor': creadoPor,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaAtencion': fechaAtencion?.toIso8601String(),
      'fechaResolucion': fechaResolucion?.toIso8601String(),
      'esAutomatica': esAutomatica,
      'requiereAccionInmediata': requiereAccionInmediata,
      'datosAdicionales': datosAdicionales,
      'etiquetas': etiquetas,
      'ubicacion': ubicacion?.toJson(),
    };
  }
  
  Alerta copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? descripcionDetallada,
    AlertaTipo? tipoAlerta,
    AlertaNivel? nivelPrioridad,
    AlertaEstado? estado,
    String? gestanteId,
    String? madrinaId,
    String? creadoPor,
    DateTime? fechaCreacion,
    DateTime? fechaAtencion,
    DateTime? fechaResolucion,
    bool? esAutomatica,
    bool? requiereAccionInmediata,
    Map<String, dynamic>? datosAdicionales,
    List<String>? etiquetas,
    AlertaUbicacion? ubicacion,
  }) {
    return Alerta(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      descripcionDetallada: descripcionDetallada ?? this.descripcionDetallada,
      tipoAlerta: tipoAlerta ?? this.tipoAlerta,
      nivelPrioridad: nivelPrioridad ?? this.nivelPrioridad,
      estado: estado ?? this.estado,
      gestanteId: gestanteId ?? this.gestanteId,
      madrinaId: madrinaId ?? this.madrinaId,
      creadoPor: creadoPor ?? this.creadoPor,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaAtencion: fechaAtencion ?? this.fechaAtencion,
      fechaResolucion: fechaResolucion ?? this.fechaResolucion,
      esAutomatica: esAutomatica ?? this.esAutomatica,
      requiereAccionInmediata: requiereAccionInmediata ?? this.requiereAccionInmediata,
      datosAdicionales: datosAdicionales ?? this.datosAdicionales,
      etiquetas: etiquetas ?? this.etiquetas,
      ubicacion: ubicacion ?? this.ubicacion,
    );
  }
  
  bool get esPendiente => estado == AlertaEstado.pendiente;
  bool get esEnProgreso => estado == AlertaEstado.enProgreso;
  bool get esResuelta => estado == AlertaEstado.resuelta;
  bool get esCancelada => estado == AlertaEstado.cancelada;
  
  bool get esCritica => nivelPrioridad == AlertaNivel.critica;
  bool get esAlta => nivelPrioridad == AlertaNivel.alta;
  bool get esMedia => nivelPrioridad == AlertaNivel.media;
  bool get esBaja => nivelPrioridad == AlertaNivel.baja;
  
  Duration? get tiempoRespuesta {
    if (fechaAtencion == null) return null;
    return fechaAtencion!.difference(fechaCreacion);
  }
  
  Duration? get tiempoResolucion {
    if (fechaResolucion == null) return null;
    return fechaResolucion!.difference(fechaCreacion);
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alerta && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Alerta(id: $id, titulo: $titulo, nivel: $nivelPrioridad, estado: $estado)';
  }
}

// Métodos auxiliares para parsing
String parseString(dynamic value, String fieldName) {
  if (value == null) {
    throw FormatException('Campo requerido nulo: $fieldName');
  }
  if (value is String) {
    return value;
  }
  // Si es otro tipo, convertir a String
  return value.toString();
}

String? parseStringNullable(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

Map<String, dynamic> parseDatosAdicionales(dynamic value) {
  if (value == null) return {};
  if (value is Map<String, dynamic>) return value;
  if (value is String) {
    // Manejar casos como "[]" o "{}"
    if (value.trim() == '[]' || value.trim() == '{}') {
      return {};
    }
    try {
      // Intentar parsear como JSON
      final decoded = json.decode(value);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      // Si falla, retornar vacío
      return {};
    }
  }
  return {};
}

List<String> parseEtiquetas(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  if (value is String) {
    // Manejar casos como "[]"
    if (value.trim() == '[]') {
      return [];
    }
    try {
      // Intentar parsear como JSON
      final decoded = json.decode(value);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      // Si falla, retornar vacío
      return [];
    }
  }
  return [];
}

bool? parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is String) {
    return value.toLowerCase() == 'true';
  }
  if (value is int) {
    return value != 0;
  }
  return null;
}

DateTime parseDateTime(dynamic value, String fieldName) {
  if (value == null) {
    throw FormatException('Campo fecha requerido nulo: $fieldName');
  }
  if (value is DateTime) return value;
  if (value is String) {
    try {
      // Intentar parsear el formato ISO primero
      return DateTime.parse(value);
    } catch (e) {
      try {
        // Intentar parsear formato "2025-11-16 23:19:04.712"
        final parts = value.split(' ');
        if (parts.length == 2) {
          final datePart = parts[0];
          final timePart = parts[1];
          return DateTime.parse('${datePart}T${timePart}Z');
        }
      } catch (e2) {
        throw FormatException('Formato de fecha inválido en $fieldName: $value');
      }
      throw FormatException('Formato de fecha inválido en $fieldName: $value');
    }
  }
  throw FormatException('Tipo de dato inválido para fecha en $fieldName: ${value.runtimeType}');
}

DateTime? parseDateTimeNullable(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }
  return null;
}

double parseDouble(dynamic value, String fieldName) {
  if (value == null) {
    throw FormatException('Campo requerido nulo: $fieldName');
  }
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('Tipo de dato inválido para double en $fieldName: ${value.runtimeType}');
}

enum AlertaTipo {
  sos,
  medica,
  control,
  recordatorio,
  sistema,
  informacion,
}

AlertaTipo alertaTipoFromString(String value) {
  final normalizedValue = value.toLowerCase().trim();
  switch (normalizedValue) {
    case 'sos':
      return AlertaTipo.sos;
    case 'medica':
    case 'médica':
      return AlertaTipo.medica;
    case 'control':
      return AlertaTipo.control;
    case 'recordatorio':
      return AlertaTipo.recordatorio;
    case 'sistema':
      return AlertaTipo.sistema;
    case 'informacion':
    case 'información':
      return AlertaTipo.informacion;
    default:
      // En lugar de lanzar un error, usar un valor por defecto
      return AlertaTipo.informacion;
  }
}

enum AlertaNivel {
  critica,
  alta,
  media,
  baja,
}

AlertaNivel alertaNivelFromString(String value) {
  final normalizedValue = value.toLowerCase().trim();
  switch (normalizedValue) {
    case 'critica':
    case 'crítica':
      return AlertaNivel.critica;
    case 'alta':
      return AlertaNivel.alta;
    case 'media':
      return AlertaNivel.media;
    case 'baja':
      return AlertaNivel.baja;
    default:
      // En lugar de lanzar un error, usar un valor por defecto
      return AlertaNivel.media;
  }
}

enum AlertaEstado {
  pendiente,
  enProgreso,
  resuelta,
  cancelada,
}

AlertaEstado alertaEstadoFromString(String value) {
  final normalizedValue = value.toLowerCase().trim();
  switch (normalizedValue) {
    case 'pendiente':
      return AlertaEstado.pendiente;
    case 'enprogreso':
    case 'en_progreso':
    case 'en progreso':
      return AlertaEstado.enProgreso;
    case 'resuelta':
      return AlertaEstado.resuelta;
    case 'cancelada':
      return AlertaEstado.cancelada;
    default:
      // En lugar de lanzar un error, usar un valor por defecto
      return AlertaEstado.pendiente;
  }
}

class AlertaUbicacion {
  
  const AlertaUbicacion({
    required this.latitud,
    required this.longitud,
    this.direccion,
    this.timestamp,
  });
  
  factory AlertaUbicacion.fromJson(Map<String, dynamic> json) {
    try {
      return AlertaUbicacion(
        latitud: parseDouble(json['latitud'], 'latitud'),
        longitud: parseDouble(json['longitud'], 'longitud'),
        direccion: parseStringNullable(json['direccion']),
        timestamp: parseDateTimeNullable(json['timestamp']),
      );
    } catch (e) {
      throw FormatException('Error al parsear AlertaUbicacion: $e. JSON recibido: $json');
    }
  }
  final double latitud;
  final double longitud;
  final String? direccion;
  final DateTime? timestamp;
  
  Map<String, dynamic> toJson() {
    return {
      'latitud': latitud,
      'longitud': longitud,
      'direccion': direccion,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlertaUbicacion && 
           other.latitud == latitud && 
           other.longitud == longitud;
  }
  
  @override
  int get hashCode => latitud.hashCode ^ longitud.hashCode;
  
  @override
  String toString() {
    return 'AlertaUbicacion(lat: $latitud, lng: $longitud, dir: $direccion)';
  }
}