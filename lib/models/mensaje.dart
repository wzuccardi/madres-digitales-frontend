/// Modelo de Conversación
class Conversacion {
  final String id;
  final String? titulo;
  final String tipo; // individual, grupo, soporte
  final List<String> participantes;
  final String? gestanteId;
  final String? ultimoMensaje;
  final DateTime? ultimoMensajeFecha;
  final Map<String, int>? mensajesNoLeidos;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Información adicional
  final List<Mensaje>? mensajes;
  final List<ParticipanteInfo>? participantesInfo;

  Conversacion({
    required this.id,
    this.titulo,
    required this.tipo,
    required this.participantes,
    this.gestanteId,
    this.ultimoMensaje,
    this.ultimoMensajeFecha,
    this.mensajesNoLeidos,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.mensajes,
    this.participantesInfo,
  });

  factory Conversacion.fromJson(Map<String, dynamic> json) {
    return Conversacion(
      id: json['id'],
      titulo: json['titulo'],
      tipo: json['tipo'],
      participantes: List<String>.from(json['participantes'] ?? []),
      gestanteId: json['gestanteId'],
      ultimoMensaje: json['ultimoMensaje'],
      ultimoMensajeFecha: json['ultimoMensajeFecha'] != null
          ? DateTime.parse(json['ultimoMensajeFecha'])
          : null,
      mensajesNoLeidos: json['mensajesNoLeidos'] != null
          ? Map<String, int>.from(json['mensajesNoLeidos'])
          : null,
      activo: json['activo'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      mensajes: json['mensajes'] != null
          ? (json['mensajes'] as List).map((m) => Mensaje.fromJson(m)).toList()
          : null,
      participantesInfo: json['participantesInfo'] != null
          ? (json['participantesInfo'] as List)
              .map((p) => ParticipanteInfo.fromJson(p))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'tipo': tipo,
      'participantes': participantes,
      'gestanteId': gestanteId,
      'ultimoMensaje': ultimoMensaje,
      'ultimoMensajeFecha': ultimoMensajeFecha?.toIso8601String(),
      'mensajesNoLeidos': mensajesNoLeidos,
      'activo': activo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Modelo de Mensaje
class Mensaje {
  final String id;
  final String conversacionId;
  final String remitenteId;
  final String remitenteNombre;
  final String tipo; // texto, imagen, archivo, ubicacion, alerta
  final String contenido;
  final String? archivoUrl;
  final String? archivoNombre;
  final String? archivoTipo;
  final int? archivoTamano;
  final Map<String, dynamic>? ubicacion;
  final Map<String, dynamic>? metadata;
  final String estado; // enviado, entregado, leido
  final List<String>? leidoPor;
  final DateTime? fechaLeido;
  final String? respondiendoA;
  final bool editado;
  final bool eliminado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Mensaje({
    required this.id,
    required this.conversacionId,
    required this.remitenteId,
    required this.remitenteNombre,
    required this.tipo,
    required this.contenido,
    this.archivoUrl,
    this.archivoNombre,
    this.archivoTipo,
    this.archivoTamano,
    this.ubicacion,
    this.metadata,
    required this.estado,
    this.leidoPor,
    this.fechaLeido,
    this.respondiendoA,
    required this.editado,
    required this.eliminado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['id'],
      conversacionId: json['conversacionId'],
      remitenteId: json['remitenteId'],
      remitenteNombre: json['remitenteNombre'],
      tipo: json['tipo'],
      contenido: json['contenido'],
      archivoUrl: json['archivoUrl'],
      archivoNombre: json['archivoNombre'],
      archivoTipo: json['archivoTipo'],
      archivoTamano: json['archivoTamano'],
      ubicacion: json['ubicacion'],
      metadata: json['metadata'],
      estado: json['estado'],
      leidoPor: json['leidoPor'] != null
          ? List<String>.from(json['leidoPor'])
          : null,
      fechaLeido: json['fechaLeido'] != null
          ? DateTime.parse(json['fechaLeido'])
          : null,
      respondiendoA: json['respondiendoA'],
      editado: json['editado'] ?? false,
      eliminado: json['eliminado'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversacionId': conversacionId,
      'remitenteId': remitenteId,
      'remitenteNombre': remitenteNombre,
      'tipo': tipo,
      'contenido': contenido,
      'archivoUrl': archivoUrl,
      'archivoNombre': archivoNombre,
      'archivoTipo': archivoTipo,
      'archivoTamano': archivoTamano,
      'ubicacion': ubicacion,
      'metadata': metadata,
      'estado': estado,
      'leidoPor': leidoPor,
      'fechaLeido': fechaLeido?.toIso8601String(),
      'respondiendoA': respondiendoA,
      'editado': editado,
      'eliminado': eliminado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get esPropio => false; // Se debe establecer comparando con userId actual
  
  bool get fueLeido => estado == 'leido';
  
  bool get esTexto => tipo == 'texto';
  bool get esImagen => tipo == 'imagen';
  bool get esArchivo => tipo == 'archivo';
  bool get esUbicacion => tipo == 'ubicacion';
  bool get esAlerta => tipo == 'alerta';
}

/// Información de participante
class ParticipanteInfo {
  final String id;
  final String nombre;
  final String rol;

  ParticipanteInfo({
    required this.id,
    required this.nombre,
    required this.rol,
  });

  factory ParticipanteInfo.fromJson(Map<String, dynamic> json) {
    return ParticipanteInfo(
      id: json['id'],
      nombre: json['nombre'],
      rol: json['rol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'rol': rol,
    };
  }
}

/// Estadísticas de mensajería
class EstadisticasMensajeria {
  final int totalConversaciones;
  final int conversacionesActivas;
  final int totalMensajes;
  final int mensajesNoLeidos;
  final DateTime? ultimaActividad;

  EstadisticasMensajeria({
    required this.totalConversaciones,
    required this.conversacionesActivas,
    required this.totalMensajes,
    required this.mensajesNoLeidos,
    this.ultimaActividad,
  });

  factory EstadisticasMensajeria.fromJson(Map<String, dynamic> json) {
    return EstadisticasMensajeria(
      totalConversaciones: json['totalConversaciones'] ?? 0,
      conversacionesActivas: json['conversacionesActivas'] ?? 0,
      totalMensajes: json['totalMensajes'] ?? 0,
      mensajesNoLeidos: json['mensajesNoLeidos'] ?? 0,
      ultimaActividad: json['ultimaActividad'] != null
          ? DateTime.parse(json['ultimaActividad'])
          : null,
    );
  }
}

