import 'package:flutter/material.dart';

class MunicipioIntegrado {

  factory MunicipioIntegrado.fromJson(Map<String, dynamic> json) {
    return MunicipioIntegrado(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      codigo: json['codigo'] as String? ?? json['codigo_municipio'] as String? ?? '',
      departamento: json['departamento'] as String? ?? json['departamento_nombre'] as String? ?? '',
      activo: (json['activo'] as bool?) ?? (json['activo'] as bool?) ?? true,
      totalGestantes: _parseInt(json['total_gestantes']),
      totalIPS: _parseInt(json['total_ips']),
      totalMedicos: _parseInt(json['total_medicos']),
      alertasActivas: _parseInt(json['alertas_activas']),
      gestantesRiesgoAlto: _parseInt(json['gestantes_riesgo_alto']),
      nivelCobertura: json['nivel_cobertura'] as String? ?? 'Baja',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }
  MunicipioIntegrado({
    required this.id,
    required this.nombre,
    this.codigo = '',
    this.departamento = '',
    this.activo = true,
    this.totalGestantes = 0,
    this.totalIPS = 0,
    this.totalMedicos = 0,
    this.alertasActivas = 0,
    this.gestantesRiesgoAlto = 0,
    this.nivelCobertura = 'Baja',
    DateTime? createdAt,
  }) : created_at = createdAt ?? DateTime.now();
  final String id;
  final String nombre;
  final String codigo;
  final String departamento;
  final bool activo;
  final int totalGestantes;
  final int totalIPS;
  final int totalMedicos;
  final int alertasActivas;
  final int gestantesRiesgoAlto;
  final String nivelCobertura;
  final DateTime created_at;

  Color get estadoColor => activo ? Colors.green : Colors.grey;
  String get estadoTexto => activo ? 'ACTIVO' : 'INACTIVO';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'departamento': departamento,
      'activo': activo,
      'totalGestantes': totalGestantes,
      'totalIPS': totalIPS,
      'totalMedicos': totalMedicos,
      'alertasActivas': alertasActivas,
      'gestantesRiesgoAlto': gestantesRiesgoAlto,
      'nivelCobertura': nivelCobertura,
      'created_at': created_at.toIso8601String(),
    };
  }

  MunicipioIntegrado copyWith({
    String? id,
    String? nombre,
    String? codigo,
    String? departamento,
    bool? activo,
    int? totalGestantes,
    int? totalIPS,
    int? totalMedicos,
    int? alertasActivas,
    int? gestantesRiesgoAlto,
    String? nivelCobertura,
    DateTime? createdAt,
  }) {
    return MunicipioIntegrado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      departamento: departamento ?? this.departamento,
      activo: activo ?? this.activo,
      totalGestantes: totalGestantes ?? this.totalGestantes,
      totalIPS: totalIPS ?? this.totalIPS,
      totalMedicos: totalMedicos ?? this.totalMedicos,
      alertasActivas: alertasActivas ?? this.alertasActivas,
      gestantesRiesgoAlto: gestantesRiesgoAlto ?? this.gestantesRiesgoAlto,
      nivelCobertura: nivelCobertura ?? this.nivelCobertura,
      createdAt: createdAt ?? created_at,
    );
  }
}

class ResumenIntegrado {

  factory ResumenIntegrado.fromJson(Map<String, dynamic> json) {
    return ResumenIntegrado(
      totalUsuarios: _parseInt(json['total_usuarios']),
      totalMunicipios: _parseInt(json['total_municipios']),
    );
  }
  ResumenIntegrado({required this.totalUsuarios, required this.totalMunicipios});
  final int totalUsuarios;
  final int totalMunicipios;
}

class UsuarioModel {
  UsuarioModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.rol = 'USER',
    this.activo = true,
  });
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final bool activo;

  String get nombreCompleto => nombre;

  UsuarioModel copyWith({
    String? id,
    String? nombre,
    String? email,
    String? rol,
    bool? activo,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
    );
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}


class IPSIntegrada {

  IPSIntegrada({
    required this.id,
    required this.nombre,
    required this.direccion,
    this.telefono,
    this.email,
    required this.nivelAtencion,
    this.municipioId,
    this.municipioNombre,
    this.latitud,
    this.longitud,
    required this.activa,
    required this.createdAt,
    required this.updatedAt,
    this.totalMedicos = 0,
    this.totalGestantesAsignadas = 0,
    this.controlesRealizados = 0,
    this.especialidades = const [],
    this.medicos,
  });

  factory IPSIntegrada.fromJson(Map<String, dynamic> json) {
    double? lat;
    double? lng;
    if (json['coordenadas'] != null) {
      final coordenadas = json['coordenadas'];
      if (coordenadas is Map) {
        lat = coordenadas['latitud']?.toDouble();
        lng = coordenadas['longitud']?.toDouble();
      }
    }

    final estadisticas = json['estadisticas'] as Map<String, dynamic>? ?? {};
    return IPSIntegrada(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      nivelAtencion: json['nivel'] as String? ?? json['nivel_atencion'] as String? ?? 'I',
      municipioId: json['municipio_id'] as String?,
      municipioNombre: json['municipio'] as String? ?? json['municipio_nombre'] as String?,
      latitud: lat ?? json['latitud']?.toDouble(),
      longitud: lng ?? json['longitud']?.toDouble(),
      activa: json['activa'] as bool? ?? json['activo'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
      totalMedicos: _parseInt(json['medicosAsignados']) != 0 ? _parseInt(json['medicosAsignados']) : _parseInt(estadisticas['medicos']),
      totalGestantesAsignadas: _parseInt(json['gestantesAsignadas']) != 0 ? _parseInt(json['gestantesAsignadas']) : _parseInt(estadisticas['gestantes_asignadas']),
      controlesRealizados: _parseInt(estadisticas['controles_realizados']),
      especialidades: json['especialidades'] != null ? List<String>.from(json['especialidades']) : [],
      medicos: json['medicos'] != null ? (json['medicos'] as List).map((e) => MedicoIntegrado.fromJson(e)).toList() : null,
    );
  }

  final String id;
  final String nombre;
  final String direccion;
  final String? telefono;
  final String? email;
  final String nivelAtencion;
  final String? municipioId;
  final String? municipioNombre;
  final double? latitud;
  final double? longitud;
  final bool activa;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalMedicos;
  final int totalGestantesAsignadas;
  final int controlesRealizados;
  final List<String> especialidades;
  final List<MedicoIntegrado>? medicos;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'nivel_atencion': nivelAtencion,
      'municipio_id': municipioId,
      'latitud': latitud,
      'longitud': longitud,
      'activa': activa,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get estadoTexto => activa ? 'ACTIVA' : 'INACTIVA';
  Color get estadoColor => activa ? Colors.green : Colors.red;

  String get nivelAtencionTexto {
    switch (nivelAtencion.toLowerCase()) {
      case 'primario':
        return 'Primario';
      case 'secundario':
        return 'Secundario';
      case 'terciario':
        return 'Terciario';
      default:
        return nivelAtencion;
    }
  }
}

class MedicoIntegrado {

  MedicoIntegrado({
    required this.id,
    required this.usuarioId,
    required this.registroMedico,
    required this.especialidad,
    this.ipsId,
    this.ipsNombre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicoIntegrado.fromJson(Map<String, dynamic> json) {
    return MedicoIntegrado(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? json['usuario_id'] ?? '',
      registroMedico: json['registroMedico'] ?? json['registro_medico'] ?? '',
      especialidad: json['especialidad'] ?? json['especialidad'] ?? '',
      ipsId: json['ipsId'] ?? json['ips_id'] ?? '',
      ipsNombre: json['ipsNombre'] ?? json['ips_nombre'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  final String id;
  final String usuarioId;
  final String registroMedico;
  final String especialidad;
  final String? ipsId;
  final String? ipsNombre;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'registroMedico': registroMedico,
      'especialidad': especialidad,
      'ipsId': ipsId,
      'ipsNombre': ipsNombre,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}