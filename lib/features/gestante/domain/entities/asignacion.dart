import 'package:equatable/equatable.dart';
import 'gestante.dart';

class Asignacion extends Equatable {
  final String id;
  final String gestanteId;
  final String madrinaId;
  final EstadoAsignacion estado;
  final TipoAsignacion tipo;
  final DateTime fechaAsignacion;
  final String asignadoPor;
  final bool esPrincipal;
  final int prioridad;
  final String? motivoAsignacion;
  final DateTime? fechaDesactivacion;
  final String? desactivadoPor;

  const Asignacion({
    required this.id,
    required this.gestanteId,
    required this.madrinaId,
    required this.estado,
    required this.tipo,
    required this.fechaAsignacion,
    required this.asignadoPor,
    this.esPrincipal = false,
    this.prioridad = 3,
    this.motivoAsignacion,
    this.fechaDesactivacion,
    this.desactivadoPor,
  });

  Asignacion copyWith({
    String? id,
    String? gestanteId,
    String? madrinaId,
    EstadoAsignacion? estado,
    TipoAsignacion? tipo,
    DateTime? fechaAsignacion,
    String? asignadoPor,
    bool? esPrincipal,
    int? prioridad,
    String? motivoAsignacion,
    DateTime? fechaDesactivacion,
    String? desactivadoPor,
  }) {
    return Asignacion(
      id: id ?? this.id,
      gestanteId: gestanteId ?? this.gestanteId,
      madrinaId: madrinaId ?? this.madrinaId,
      estado: estado ?? this.estado,
      tipo: tipo ?? this.tipo,
      fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
      asignadoPor: asignadoPor ?? this.asignadoPor,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      prioridad: prioridad ?? this.prioridad,
      motivoAsignacion: motivoAsignacion ?? this.motivoAsignacion,
      fechaDesactivacion: fechaDesactivacion ?? this.fechaDesactivacion,
      desactivadoPor: desactivadoPor ?? this.desactivadoPor,
    );
  }

  @override
  List<Object?> get props => [
    id,
    gestanteId,
    madrinaId,
    estado,
    tipo,
    fechaAsignacion,
    asignadoPor,
    esPrincipal,
    prioridad,
    motivoAsignacion,
    fechaDesactivacion,
    desactivadoPor,
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gestanteId': gestanteId,
      'madrinaId': madrinaId,
      'estado': estado.toString(),
      'tipo': tipo.toString(),
      'fechaAsignacion': fechaAsignacion.toIso8601String(),
      'asignadoPor': asignadoPor,
      'esPrincipal': esPrincipal,
      'prioridad': prioridad,
      'motivoAsignacion': motivoAsignacion,
      'fechaDesactivacion': fechaDesactivacion?.toIso8601String(),
      'desactivadoPor': desactivadoPor,
    };
  }

  factory Asignacion.fromMap(Map<String, dynamic> map) {
    return Asignacion(
      id: map['id'],
      gestanteId: map['gestanteId'],
      madrinaId: map['madrinaId'],
      estado: _parseEstadoAsignacion(map['estado']),
      tipo: _parseTipoAsignacion(map['tipo']),
      fechaAsignacion: DateTime.parse(map['fechaAsignacion']),
      asignadoPor: map['asignadoPor'],
      esPrincipal: map['esPrincipal'] ?? false,
      prioridad: map['prioridad'] ?? 3,
      motivoAsignacion: map['motivoAsignacion'],
      fechaDesactivacion: map['fechaDesactivacion'] != null 
          ? DateTime.parse(map['fechaDesactivacion']) 
          : null,
      desactivadoPor: map['desactivadoPor'],
    );
  }

  static EstadoAsignacion _parseEstadoAsignacion(String estado) {
    switch (estado) {
      case 'EstadoAsignacion.activa':
        return EstadoAsignacion.activa;
      case 'EstadoAsignacion.inactiva':
        return EstadoAsignacion.inactiva;
      case 'EstadoAsignacion.completada':
        return EstadoAsignacion.completada;
      case 'EstadoAsignacion.cancelada':
        return EstadoAsignacion.cancelada;
      default:
        return EstadoAsignacion.activa;
    }
  }

  static TipoAsignacion _parseTipoAsignacion(String tipo) {
    switch (tipo) {
      case 'TipoAsignacion.automatica':
        return TipoAsignacion.automatica;
      case 'TipoAsignacion.manual':
        return TipoAsignacion.manual;
      case 'TipoAsignacion.transferencia':
        return TipoAsignacion.transferencia;
      default:
        return TipoAsignacion.manual;
    }
  }
}