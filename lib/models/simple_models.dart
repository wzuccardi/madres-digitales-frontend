// Modelos simples que coinciden exactamente con la estructura del backend
// Estos modelos temporales solucionan el problema de mapeo de campos

import 'package:flutter/material.dart';

// Enums necesarios para la aplicación
enum TipoAlerta {
  riesgoAlto,
  controlVencido,
  sintomaAlarma,
  emergenciaObstetrica,
  trabajoParto,
  medicacion,
  laboratorio,
  sos; // Para el botón SOS

  // Método para convertir a string del backend
  String get backendValue {
    switch (this) {
      case TipoAlerta.riesgoAlto:
        return 'riesgo_alto';
      case TipoAlerta.controlVencido:
        return 'control_vencido';
      case TipoAlerta.sintomaAlarma:
        return 'sintoma_alarma';
      case TipoAlerta.emergenciaObstetrica:
        return 'emergencia_obstetrica';
      case TipoAlerta.trabajoParto:
        return 'trabajo_parto';
      case TipoAlerta.medicacion:
        return 'medicacion';
      case TipoAlerta.laboratorio:
        return 'laboratorio';
      case TipoAlerta.sos:
        return 'sos';
    }
  }

  // Método para crear desde string del backend
  static TipoAlerta fromBackendValue(String value) {
    switch (value) {
      case 'riesgo_alto':
        return TipoAlerta.riesgoAlto;
      case 'control_vencido':
        return TipoAlerta.controlVencido;
      case 'sintoma_alarma':
        return TipoAlerta.sintomaAlarma;
      case 'emergencia_obstetrica':
        return TipoAlerta.emergenciaObstetrica;
      case 'trabajo_parto':
        return TipoAlerta.trabajoParto;
      case 'medicacion':
        return TipoAlerta.medicacion;
      case 'laboratorio':
        return TipoAlerta.laboratorio;
      case 'sos':
        return TipoAlerta.sos;
      default:
        return TipoAlerta.sintomaAlarma;
    }
  }

  // Método para mostrar nombres amigables
  String get displayName {
    switch (this) {
      case TipoAlerta.riesgoAlto:
        return 'Riesgo Alto';
      case TipoAlerta.controlVencido:
        return 'Control Vencido';
      case TipoAlerta.sintomaAlarma:
        return 'Síntoma de Alarma';
      case TipoAlerta.emergenciaObstetrica:
        return 'Emergencia Obstétrica';
      case TipoAlerta.trabajoParto:
        return 'Trabajo de Parto';
      case TipoAlerta.medicacion:
        return 'Medicación';
      case TipoAlerta.laboratorio:
        return 'Laboratorio';
      case TipoAlerta.sos:
        return 'SOS';
    }
  }
}

enum TipoContenido {
  video,
  audio,
  documento,
  imagen,
  articulo,
  infografia;

  String get backendValue => name;

  static TipoContenido fromBackendValue(String value) {
    return TipoContenido.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TipoContenido.documento,
    );
  }
}

enum CategoriaContenido {
  nutricion,
  cuidadoPrenatal,
  signosAlarma,
  lactancia,
  parto,
  posparto,
  planificacion,
  saludMental,
  ejercicio,
  higiene,
  derechos,
  otros;

  String get backendValue {
    switch (this) {
      case CategoriaContenido.cuidadoPrenatal:
        return 'cuidado_prenatal';
      case CategoriaContenido.signosAlarma:
        return 'signos_alarma';
      case CategoriaContenido.saludMental:
        return 'salud_mental';
      default:
        return name;
    }
  }

  static CategoriaContenido fromBackendValue(String value) {
    switch (value) {
      case 'cuidado_prenatal':
        return CategoriaContenido.cuidadoPrenatal;
      case 'signos_alarma':
        return CategoriaContenido.signosAlarma;
      case 'salud_mental':
        return CategoriaContenido.saludMental;
      default:
        return CategoriaContenido.values.firstWhere(
          (e) => e.name == value,
          orElse: () => CategoriaContenido.otros,
        );
    }
  }
}


enum NivelDificultad {
  basico,
  intermedio,
  avanzado;

  String get backendValue => name;

  static NivelDificultad fromBackendValue(String value) {
    return NivelDificultad.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NivelDificultad.basico,
    );
  }

  String get displayName {
    switch (this) {
      case NivelDificultad.basico:
        return 'Básico';
      case NivelDificultad.intermedio:
        return 'Intermedio';
      case NivelDificultad.avanzado:
        return 'Avanzado';
    }
  }
}

enum NivelPrioridad {
  baja,
  media,
  alta,
  critica;

  String get backendValue => name;

  static NivelPrioridad fromBackendValue(String value) {
    return NivelPrioridad.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NivelPrioridad.media,
    );
  }

  // Método para mostrar nombres amigables
  String get displayName {
    switch (this) {
      case NivelPrioridad.baja:
        return 'Baja';
      case NivelPrioridad.media:
        return 'Media';
      case NivelPrioridad.alta:
        return 'Alta';
      case NivelPrioridad.critica:
        return 'Crítica';
    }
  }

  // Método para obtener colores
  Color get color {
    switch (this) {
      case NivelPrioridad.baja:
        return Colors.green;
      case NivelPrioridad.media:
        return Colors.orange;
      case NivelPrioridad.alta:
        return Colors.red;
      case NivelPrioridad.critica:
        return Colors.red.shade900;
    }
  }
}

enum DocumentoTipo {
  cedula,
  tarjetaIdentidad,
  pasaporte,
  registroCivil;

  String get backendValue {
    switch (this) {
      case DocumentoTipo.tarjetaIdentidad:
        return 'tarjeta_identidad';
      case DocumentoTipo.registroCivil:
        return 'registro_civil';
      default:
        return name;
    }
  }

  static DocumentoTipo fromBackendValue(String value) {
    switch (value) {
      case 'tarjeta_identidad':
        return DocumentoTipo.tarjetaIdentidad;
      case 'registro_civil':
        return DocumentoTipo.registroCivil;
      default:
        return DocumentoTipo.values.firstWhere(
          (e) => e.name == value,
          orElse: () => DocumentoTipo.cedula,
        );
    }
  }

  // Método para mostrar nombres amigables
  String get displayName {
    switch (this) {
      case DocumentoTipo.cedula:
        return 'Cédula de Ciudadanía';
      case DocumentoTipo.tarjetaIdentidad:
        return 'Tarjeta de Identidad';
      case DocumentoTipo.pasaporte:
        return 'Pasaporte';
      case DocumentoTipo.registroCivil:
        return 'Registro Civil';
    }
  }
}

enum RegimenTipo {
  subsidiado,
  contributivo,
  especial;

  String get backendValue => name;

  static RegimenTipo fromBackendValue(String value) {
    return RegimenTipo.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RegimenTipo.subsidiado,
    );
  }

  // Método para mostrar nombres amigables
  String get displayName {
    switch (this) {
      case RegimenTipo.subsidiado:
        return 'Subsidiado';
      case RegimenTipo.contributivo:
        return 'Contributivo';
      case RegimenTipo.especial:
        return 'Especial';
    }
  }
}

enum UsuarioRol {
  admin,
  coordinador,
  medico,
  madrina,
  gestante,
  super_admin;

  String get backendValue => name;

  static UsuarioRol fromBackendValue(String value) {
    return UsuarioRol.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UsuarioRol.gestante,
    );
  }

  String get displayName {
    switch (this) {
      case UsuarioRol.admin:
        return 'Administrador';
      case UsuarioRol.coordinador:
        return 'Coordinador';
      case UsuarioRol.medico:
        return 'Médico';
      case UsuarioRol.madrina:
        return 'Madrina Comunitaria';
      case UsuarioRol.gestante:
        return 'Gestante';
      case UsuarioRol.super_admin:
        return 'Super Administrador';
    }
  }
}

class SimpleUsuario {
  final String id;
  final String email;
  final String nombre;
  final String? documento;
  final String? telefono;
  final UsuarioRol rol;
  final String? municipio_id;
  final String? direccion;
  final bool activo;
  final DateTime? ultimo_acceso;
  final DateTime created_at;
  final DateTime updated_at;

  SimpleUsuario({
    required this.id,
    required this.email,
    required this.nombre,
    this.documento,
    this.telefono,
    required this.rol,
    this.municipio_id,
    this.direccion,
    required this.activo,
    this.ultimo_acceso,
    required this.created_at,
    required this.updated_at,
  });

  factory SimpleUsuario.fromJson(Map<String, dynamic> json) {
    return SimpleUsuario(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      documento: json['documento'],
      telefono: json['telefono'],
      rol: UsuarioRol.fromBackendValue(json['rol'] ?? 'gestante'),
      municipio_id: json['municipio_id'],
      direccion: json['direccion'],
      activo: json['activo'] ?? true,
      ultimo_acceso: json['ultimo_acceso'] != null
          ? DateTime.parse(json['ultimo_acceso'])
          : null,
      created_at: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updated_at: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'documento': documento,
      'telefono': telefono,
      'rol': rol.backendValue,
      'municipio_id': municipio_id,
      'direccion': direccion,
      'activo': activo,
      'ultimo_acceso': ultimo_acceso?.toIso8601String(),
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'email': email,
      'nombre': nombre,
      'documento': documento,
      'telefono': telefono,
      'rol': rol.backendValue,
      'municipio_id': municipio_id,
      'direccion': direccion,
    };
  }
}

class SimpleGestante {
  final String id;
  final String documento;
  final String nombre;
  final String? telefono;
  final String? direccion;
  final String? municipio_id;
  final String? eps;
  final bool activa;
  final bool riesgo_alto;
  final DateTime? fecha_probable_parto;
  final DateTime? fecha_nacimiento;
  final DateTime created_at;
  // Campos nuevos para sistema de aislamiento
  final String? creada_por; // ID de la madrina que la creó
  final List<String> madrinas_asignadas; // IDs de madrinas asignadas
  final DateTime? fecha_asignacion; // Fecha de asignación inicial

  SimpleGestante({
    required this.id,
    required this.documento,
    required this.nombre,
    this.telefono,
    this.direccion,
    this.municipio_id,
    this.eps,
    required this.activa,
    required this.riesgo_alto,
    this.fecha_probable_parto,
    this.fecha_nacimiento,
    required this.created_at,
    // Campos nuevos
    this.creada_por,
    this.madrinas_asignadas = const [],
    this.fecha_asignacion,
  });

  factory SimpleGestante.fromJson(Map<String, dynamic> json) {
    // Parsear madrinas_asignadas que puede venir como string o array
    List<String> madrinasAsignadas = [];
    if (json['madrinas_asignadas'] != null) {
      if (json['madrinas_asignadas'] is List) {
        madrinasAsignadas = (json['madrinas_asignadas'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else if (json['madrinas_asignadas'] is String) {
        // Soporte para formato string separado por comas
        madrinasAsignadas = (json['madrinas_asignadas'] as String)
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    return SimpleGestante(
      id: json['id'] as String,
      documento: json['documento'] as String,
      nombre: json['nombre'] as String,
      telefono: json['telefono'] as String?,
      direccion: json['direccion'] as String?,
      municipio_id: json['municipio_id'] as String?,
      eps: json['eps'] as String?,
      activa: json['activa'] as bool? ?? true,
      riesgo_alto: json['riesgo_alto'] as bool? ?? false,
      fecha_probable_parto: json['fecha_probable_parto'] != null
          ? DateTime.parse(json['fecha_probable_parto'] as String)
          : null,
      fecha_nacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'] as String)
          : null,
      created_at: DateTime.parse(json['created_at'] as String),
      // Campos nuevos
      creada_por: json['creada_por'] as String?,
      madrinas_asignadas: madrinasAsignadas,
      fecha_asignacion: json['fecha_asignacion'] != null
          ? DateTime.parse(json['fecha_asignacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documento': documento,
      'nombre': nombre,
      'telefono': telefono,
      'direccion': direccion,
      'municipio_id': municipio_id,
      'eps': eps,
      'activa': activa,
      'riesgo_alto': riesgo_alto,
      'fecha_probable_parto': fecha_probable_parto?.toIso8601String(),
      'fecha_nacimiento': fecha_nacimiento?.toIso8601String(),
      'created_at': created_at.toIso8601String(),
      // Campos nuevos
      'creada_por': creada_por,
      'madrinas_asignadas': madrinas_asignadas,
      'fecha_asignacion': fecha_asignacion?.toIso8601String(),
    };
  }

  // Getters para compatibilidad con la UI existente
  String get nombreCompleto => nombre;
  bool get embarazoAltoRiesgo => riesgo_alto;

  // Calcular edad basada en fecha de nacimiento
  int? get edad {
    if (fecha_nacimiento == null) return null;
    final now = DateTime.now();
    int age = now.year - fecha_nacimiento!.year;
    if (now.month < fecha_nacimiento!.month ||
        (now.month == fecha_nacimiento!.month && now.day < fecha_nacimiento!.day)) {
      age--;
    }
    return age;
  }

  // Métodos nuevos para sistema de aislamiento
  
  /// Verificar si una madrina tiene acceso a esta gestante
  bool tieneAccesoMadrina(String madrinaId) {
    return creada_por == madrinaId || madrinas_asignadas.contains(madrinaId);
  }

  /// Verificar si una madrina es la propietaria (creadora) de esta gestante
  bool esPropietaria(String madrinaId) {
    return creada_por == madrinaId;
  }

  /// Verificar si esta gestante está asignada (no creada) a una madrina
  bool esAsignada(String madrinaId) {
    return !esPropietaria(madrinaId) && madrinas_asignadas.contains(madrinaId);
  }

  /// Obtener el tipo de relación con una madrina
  String tipoRelacion(String madrinaId) {
    if (esPropietaria(madrinaId)) {
      return 'propietaria';
    } else if (esAsignada(madrinaId)) {
      return 'asignada';
    } else {
      return 'sin_acceso';
    }
  }

  /// Verificar si tiene alguna asignación (creada o asignada)
  bool tieneAsignaciones() {
    return creada_por != null || madrinas_asignadas.isNotEmpty;
  }
}

class SimpleControl {
  final String id;
  final String gestante_id;
  final String? medico_tratante_id;
  final DateTime fecha_control;
  final int? semanas_gestacion;
  final double? peso;
  final int? presion_sistolica;
  final int? presion_diastolica;
  final String? observaciones;
  final DateTime created_at;

  SimpleControl({
    required this.id,
    required this.gestante_id,
    this.medico_tratante_id,
    required this.fecha_control,
    this.semanas_gestacion,
    this.peso,
    this.presion_sistolica,
    this.presion_diastolica,
    this.observaciones,
    required this.created_at,
  });

  factory SimpleControl.fromJson(Map<String, dynamic> json) {
    return SimpleControl(
      id: json['id'] as String,
      gestante_id: json['gestante_id'] as String,
      medico_tratante_id: json['medico_tratante_id'] as String?,
      fecha_control: DateTime.parse(json['fecha_control'] as String),
      semanas_gestacion: json['semanas_gestacion'] as int?,
      peso: _parseDouble(json['peso']),
      presion_sistolica: json['presion_sistolica'] as int?,
      presion_diastolica: json['presion_diastolica'] as int?,
      observaciones: json['observaciones'] as String?,
      created_at: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gestante_id': gestante_id,
      'medico_tratante_id': medico_tratante_id,
      'fecha_control': fecha_control.toIso8601String(),
      'semanas_gestacion': semanas_gestacion,
      'peso': peso,
      'presion_sistolica': presion_sistolica,
      'presion_diastolica': presion_diastolica,
      'observaciones': observaciones,
      'created_at': created_at.toIso8601String(),
    };
  }

  // Getters para compatibilidad con la UI existente
  DateTime get fechaControl => fecha_control;
  String get gestanteId => gestante_id;
  int get numeroControl => semanas_gestacion ?? 0;
  String get estado => 'realizado';

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class SimpleAlerta {
  final String id;
  final String gestante_id;
  final String tipo;
  final String nivel_prioridad;
  final String mensaje;
  final String? descripcion_detallada;
  final bool resuelta;
  final DateTime? fecha_resolucion;
  final DateTime created_at;
  final Map<String, dynamic>? coordenadas_alerta;
  final String? gestanteNombre; // Nuevo campo del backend
  final String? gestanteDocumento; // Nuevo campo del backend

  SimpleAlerta({
    required this.id,
    required this.gestante_id,
    required this.tipo,
    required this.nivel_prioridad,
    required this.mensaje,
    this.descripcion_detallada,
    required this.resuelta,
    this.fecha_resolucion,
    required this.created_at,
    this.coordenadas_alerta,
    this.gestanteNombre,
    this.gestanteDocumento,
  });

  factory SimpleAlerta.fromJson(Map<String, dynamic> json) {
    return SimpleAlerta(
      id: json['id'] as String? ?? '',
      gestante_id: json['gestante_id'] as String? ?? '',
      tipo: json['tipo'] as String? ?? 'general',
      nivel_prioridad: json['nivel_prioridad'] as String? ?? 'medio',
      mensaje: json['mensaje'] as String? ?? 'Sin mensaje',
      descripcion_detallada: json['descripcion_detallada'] as String?,
      resuelta: json['resuelta'] as bool? ?? false,
      fecha_resolucion: json['fecha_resolucion'] != null
          ? DateTime.parse(json['fecha_resolucion'] as String)
          : null,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      coordenadas_alerta: json['coordenadas_alerta'] as Map<String, dynamic>?,
      gestanteNombre: json['gestante_nombre'] as String?,
      gestanteDocumento: json['gestante_documento'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gestante_id': gestante_id,
      'tipo': tipo,
      'nivel_prioridad': nivel_prioridad,
      'mensaje': mensaje,
      'descripcion_detallada': descripcion_detallada,
      'resuelta': resuelta,
      'fecha_resolucion': fecha_resolucion?.toIso8601String(),
      'created_at': created_at.toIso8601String(),
      'coordenadas_alerta': coordenadas_alerta,
    };
  }

  // Getters para compatibilidad con la UI existente
  String get gestanteId => gestante_id;
  String get tipoAlerta => tipo;
  String get nivelPrioridad => nivel_prioridad;
  bool get esUrgente => nivel_prioridad == 'critica' || nivel_prioridad == 'alta';
  DateTime get createdAt => created_at;
  String? get observaciones => descripcion_detallada;

  // Getters adicionales para centro_notificaciones_screen
  String get prioridad => nivel_prioridad;
  String get descripcion => descripcion_detallada ?? mensaje;
  String? get gestante_nombre => gestanteNombre; // Ahora usa el campo real del backend

  // Getter para obtener las coordenadas en formato legible
  String? get coordenadasTexto {
    if (coordenadas_alerta == null) return null;

    try {
      final coordinates = coordenadas_alerta!['coordinates'] as List<dynamic>?;
      if (coordinates != null && coordinates.length >= 2) {
        final lng = coordinates[0].toString();
        final lat = coordinates[1].toString();
        return '$lat, $lng';
      }
    } catch (e) {
      // Si hay error al parsear, devolver null
    }

    return null;
  }
}

// Modelo para IPS (Instituciones Prestadoras de Salud)
class SimpleIPS {
  final String id;
  final String nombre;
  final String direccion;
  final String? telefono;
  final String? email;
  final String nivel_atencion;
  final String? municipio_id;
  final double? latitud;
  final double? longitud;
  final bool activa;
  final DateTime created_at;

  SimpleIPS({
    required this.id,
    required this.nombre,
    required this.direccion,
    this.telefono,
    this.email,
    required this.nivel_atencion,
    this.municipio_id,
    this.latitud,
    this.longitud,
    required this.activa,
    required this.created_at,
  });

  factory SimpleIPS.fromJson(Map<String, dynamic> json) {
    // Extraer coordenadas si vienen en formato GeoJSON
    double? lat, lng;
    if (json['coordenadas'] != null) {
      final coordenadas = json['coordenadas'];
      if (coordenadas is Map && coordenadas['coordinates'] is List) {
        final coords = coordenadas['coordinates'] as List;
        if (coords.length >= 2) {
          lng = coords[0]?.toDouble();
          lat = coords[1]?.toDouble();
        }
      }
    }

    return SimpleIPS(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      nivel_atencion: json['nivel_atencion'] as String? ?? 'primario',
      municipio_id: json['municipio_id'] as String?,
      latitud: lat ?? json['latitud']?.toDouble(),
      longitud: lng ?? json['longitud']?.toDouble(),
      activa: json['activa'] as bool? ?? true,
      created_at: DateTime.parse(json['created_at'] as String),
    );
  }

  // Calcular distancia aproximada en km
  double? distanciaA(double? userLat, double? userLng) {
    if (latitud == null || longitud == null || userLat == null || userLng == null) {
      return null;
    }

    // Fórmula de Haversine simplificada para distancias cortas
    const double earthRadius = 6371; // Radio de la Tierra en km
    final double dLat = (latitud! - userLat) * (3.14159 / 180);
    final double dLng = (longitud! - userLng) * (3.14159 / 180);

    final double a = (dLat / 2) * (dLat / 2) + (dLng / 2) * (dLng / 2);
    final double c = 2 * (a < 1 ? a : 1); // Simplificación para distancias cortas

    return earthRadius * c;
  }

  // Getters para compatibilidad
  String get nivelAtencion => nivel_atencion;
  String? get municipioId => municipio_id;
}

// Aliases para compatibilidad con el código existente
typedef Alerta = SimpleAlerta;
typedef Control = SimpleControl;
typedef Gestante = SimpleGestante;

// Modelo para Contenido Educativo
class SimpleContenido {
  final String id;
  final String titulo;
  final String descripcion;
  final String tipo; // video, audio, pdf, imagen, texto
  final String categoria; // embarazo, parto, etc.
  final String? url;
  final String? archivo_path;
  final int? duracion_minutos;
  final int? semana_gestacion_inicio;
  final int? semana_gestacion_fin;
  final List<String> tags;
  final bool activo;
  final DateTime created_at;

  SimpleContenido({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.categoria,
    this.url,
    this.archivo_path,
    this.duracion_minutos,
    this.semana_gestacion_inicio,
    this.semana_gestacion_fin,
    required this.tags,
    required this.activo,
    required this.created_at,
  });

  factory SimpleContenido.fromJson(Map<String, dynamic> json) {
    // Parsear tags si vienen como string JSON
    List<String> tagsList = [];
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        tagsList = (json['tags'] as List).map((e) => e.toString()).toList();
      } else if (json['tags'] is String) {
        try {
          // Intentar parsear como JSON array
          final decoded = json['tags'] as String;
          if (decoded.startsWith('[') && decoded.endsWith(']')) {
            tagsList = decoded.substring(1, decoded.length - 1)
                .split(',')
                .map((e) => e.trim().replaceAll('"', ''))
                .toList();
          } else {
            tagsList = [decoded];
          }
        } catch (e) {
          tagsList = [json['tags'] as String];
        }
      }
    }

    return SimpleContenido(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      tipo: json['tipo'] as String,
      categoria: json['categoria'] as String,
      url: json['url'] as String?,
      archivo_path: json['archivo_path'] as String?,
      duracion_minutos: json['duracion_minutos'] as int?,
      semana_gestacion_inicio: json['semana_gestacion_inicio'] as int?,
      semana_gestacion_fin: json['semana_gestacion_fin'] as int?,
      tags: tagsList,
      activo: json['activo'] as bool? ?? true,
      created_at: DateTime.parse(json['created_at'] as String),
    );
  }

  // Getters para compatibilidad
  String get tipoContenido => tipo;
  String get categoriaContenido => categoria;
  int? get duracionMinutos => duracion_minutos;
  String? get archivoPath => archivo_path;
  bool get esVideo => tipo == 'video';
  bool get esAudio => tipo == 'audio';
  bool get esPDF => tipo == 'pdf';
  bool get esImagen => tipo == 'imagen';
  bool get esTexto => tipo == 'texto';
}
