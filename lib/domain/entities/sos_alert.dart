enum SOSPriority {
  critica,
  alta,
  media,
  baja;
}

enum SOSAlertStatus {
  activa,
  atendida,
  falsaAlarma,
  cancelada,
}

class SOSAlert {

  SOSAlert({
    required this.id,
    required this.gestanteNombre,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.fechaCreacion,
    required this.nivelPrioridad,
    required this.estado,
    this.madrinaId,
    this.medicoId,
    this.ipsId,
    this.tiempoRespuesta,
  });

  factory SOSAlert.fromJson(Map<String, dynamic> json) {
    return SOSAlert(
      id: json['id'] ?? '',
      gestanteNombre: json['gestanteNombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'])
          : DateTime.now(),
      nivelPrioridad: json['nivelPrioridad'] != null
          ? SOSPriority.values.firstWhere(
              (p) => p.toString() == json['nivelPrioridad'].toString(),
            )
          : SOSPriority.media,
      estado: json['estado'] != null
          ? SOSAlertStatus.values.firstWhere(
              (s) => s.toString() == json['estado'].toString(),
            )
          : SOSAlertStatus.activa,
      madrinaId: json['madrinaId'],
      medicoId: json['medicoId'],
      ipsId: json['ipsId'],
      tiempoRespuesta: json['tiempoRespuesta'] != null
          ? Duration(milliseconds: json['tiempoRespuesta'] as int)
          : null,
    );
  }
  final String id;
  final String gestanteNombre;
  final String descripcion;
  final double latitud;
  final double longitud;
  final DateTime fechaCreacion;
  final SOSPriority nivelPrioridad;
  final SOSAlertStatus estado;
  final String? madrinaId;
  final String? medicoId;
  final String? ipsId;
  final Duration? tiempoRespuesta;

  SOSAlert copyWith({
    String? id,
    String? gestanteNombre,
    String? descripcion,
    double? latitud,
    double? longitud,
    DateTime? fechaCreacion,
    SOSPriority? nivelPrioridad,
    SOSAlertStatus? estado,
    String? madrinaId,
    String? medicoId,
    String? ipsId,
    Duration? tiempoRespuesta,
  }) {
    return SOSAlert(
      id: id ?? this.id,
      gestanteNombre: gestanteNombre ?? this.gestanteNombre,
      descripcion: descripcion ?? this.descripcion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      nivelPrioridad: nivelPrioridad ?? this.nivelPrioridad,
      estado: estado ?? this.estado,
      madrinaId: madrinaId ?? this.madrinaId,
      medicoId: medicoId ?? this.medicoId,
      ipsId: ipsId ?? this.ipsId,
      tiempoRespuesta: tiempoRespuesta ?? this.tiempoRespuesta,
    );
  }

  String get tiempoTranscurridoFormateado {
    if (tiempoRespuesta == null) return 'N/A';
    
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaCreacion);
    
    if (diferencia.inHours < 1) {
      return 'Hace ${diferencia.inMinutes} minutos';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} horas';
    } else {
      return 'Hace ${diferencia.inDays} días';
    }
  }

  String get estadoFormateado {
    switch (estado) {
      case SOSAlertStatus.activa:
        return 'Activa';
      case SOSAlertStatus.atendida:
        return 'Atendida';
      case SOSAlertStatus.falsaAlarma:
        return 'Falsa Alarma';
      case SOSAlertStatus.cancelada:
        return 'Cancelada';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gestanteNombre': gestanteNombre,
      'descripcion': descripcion,
      'latitud': latitud,
      'longitud': longitud,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'nivelPrioridad': nivelPrioridad.toString(),
      'estado': estado.toString(),
      'madrinaId': madrinaId,
      'medicoId': medicoId,
      'ipsId': ipsId,
      'tiempoRespuesta': tiempoRespuesta?.inMilliseconds,
    };
  }
}
