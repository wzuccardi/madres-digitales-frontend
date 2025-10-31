// Modelos integrados para IPS, Médicos y Municipios
// Estos modelos incluyen las relaciones entre entidades

import 'package:flutter/material.dart';

// Métodos de parsing seguro para evitar errores de tipo
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

// Modelo para Municipio con estadísticas integradas
class MunicipioIntegrado {
  final String id;
  final String codigo;
  final String nombre;
  final String departamento;
  final bool activo;
  final int? poblacion;
  final double? latitud;
  final double? longitud;
  final DateTime created_at;
  final DateTime updated_at;
  
  // Estadísticas integradas
  final int totalGestantes;
  final int totalMedicos;
  final int totalIPS;
  final int totalMadrinas;
  final int gestantesActivas;
  final int gestantesRiesgoAlto;
  final int alertasActivas;
  
  // Listas relacionadas (opcionales para carga completa)
  final List<IPSIntegrada>? ips;
  final List<MedicoIntegrado>? medicos;

  MunicipioIntegrado({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.departamento,
    required this.activo,
    this.poblacion,
    this.latitud,
    this.longitud,
    required this.created_at,
    required this.updated_at,
    this.totalGestantes = 0,
    this.totalMedicos = 0,
    this.totalIPS = 0,
    this.totalMadrinas = 0,
    this.gestantesActivas = 0,
    this.gestantesRiesgoAlto = 0,
    this.alertasActivas = 0,
    this.ips,
    this.medicos,
  });

  factory MunicipioIntegrado.fromJson(Map<String, dynamic> json) {
    final estadisticas = json['estadisticas'] as Map<String, dynamic>? ?? {};
    
    return MunicipioIntegrado(
      id: json['id'] as String,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      departamento: json['departamento'] as String? ?? 'BOLÍVAR',
      activo: json['activo'] as bool? ?? true,
      poblacion: json['poblacion'] as int?,
      latitud: json['latitud']?.toDouble(),
      longitud: json['longitud']?.toDouble(),
      created_at: DateTime.parse(json['created_at'] as String),
      updated_at: DateTime.parse(json['updated_at'] as String? ?? json['created_at'] as String),
      totalGestantes: _parseInt(estadisticas['gestantes']),
      totalMedicos: _parseInt(estadisticas['medicos']),
      totalIPS: _parseInt(estadisticas['ips']),
      totalMadrinas: _parseInt(estadisticas['madrinas']),
      gestantesActivas: _parseInt(estadisticas['gestantes_activas']),
      gestantesRiesgoAlto: _parseInt(estadisticas['gestantes_riesgo_alto']),
      alertasActivas: _parseInt(estadisticas['alertas_activas']),
      ips: json['ips'] != null 
          ? (json['ips'] as List).map((e) => IPSIntegrada.fromJson(e)).toList()
          : null,
      medicos: json['medicos'] != null 
          ? (json['medicos'] as List).map((e) => MedicoIntegrado.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'departamento': departamento,
      'activo': activo,
      'poblacion': poblacion,
      'latitud': latitud,
      'longitud': longitud,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }

  // Getters para UI
  String get estadoTexto => activo ? 'ACTIVO' : 'INACTIVO';
  Color get estadoColor => activo ? Colors.green : Colors.red;
  
  // Indicadores de salud del municipio
  double get porcentajeRiesgoAlto => 
      totalGestantes > 0 ? (gestantesRiesgoAlto / totalGestantes) * 100 : 0;
  
  bool get tieneRecursosAdecuados => totalMedicos > 0 && totalIPS > 0;
  
  String get nivelCobertura {
    if (totalMedicos == 0 || totalIPS == 0) return 'Sin cobertura';
    if (totalMedicos < 3 || totalIPS < 2) return 'Cobertura baja';
    if (totalMedicos < 10 || totalIPS < 5) return 'Cobertura media';
    return 'Cobertura alta';
  }
}

// Modelo para IPS con información del municipio
class IPSIntegrada {
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
  final DateTime created_at;
  final DateTime updated_at;
  
  // Estadísticas de la IPS
  final int totalMedicos;
  final int totalGestantesAsignadas;
  final int controlesRealizados;
  final List<String> especialidades;
  
  // Médicos asignados (opcional)
  final List<MedicoIntegrado>? medicos;

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
    required this.created_at,
    required this.updated_at,
    this.totalMedicos = 0,
    this.totalGestantesAsignadas = 0,
    this.controlesRealizados = 0,
    this.especialidades = const [],
    this.medicos,
  });

  factory IPSIntegrada.fromJson(Map<String, dynamic> json) {
    // Extraer coordenadas del formato del backend
    double? lat, lng;
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
      // CORREGIDO: El backend envía 'nivel' no 'nivel_atencion'
      nivelAtencion: json['nivel'] as String? ?? json['nivel_atencion'] as String? ?? 'I',
      municipioId: json['municipio_id'] as String?,
      // CORREGIDO: El backend envía 'municipio' como string
      municipioNombre: json['municipio'] as String? ?? json['municipio_nombre'] as String?,
      latitud: lat ?? json['latitud']?.toDouble(),
      longitud: lng ?? json['longitud']?.toDouble(),
      // CORREGIDO: El backend puede usar 'activo' en lugar de 'activa'
      activa: json['activa'] as bool? ?? json['activo'] as bool? ?? true,
      created_at: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updated_at: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      // CORREGIDO: El backend envía 'medicosAsignados' y 'gestantesAsignadas'
      totalMedicos: _parseInt(json['medicosAsignados']) != 0 ? _parseInt(json['medicosAsignados']) : _parseInt(estadisticas['medicos']),
      totalGestantesAsignadas: _parseInt(json['gestantesAsignadas']) != 0 ? _parseInt(json['gestantesAsignadas']) : _parseInt(estadisticas['gestantes_asignadas']),
      controlesRealizados: _parseInt(estadisticas['controles_realizados']),
      especialidades: json['especialidades'] != null 
          ? List<String>.from(json['especialidades'])
          : [],
      medicos: json['medicos'] != null 
          ? (json['medicos'] as List).map((e) => MedicoIntegrado.fromJson(e)).toList()
          : null,
    );
  }

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
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }

  // Getters para UI
  String get estadoTexto => activa ? 'ACTIVA' : 'INACTIVA';
  Color get estadoColor => activa ? Colors.green : Colors.red;
  
  String get nivelAtencionTexto {
    switch (nivelAtencion.toLowerCase()) {
      case 'primario':
        return 'Nivel I - Primario';
      case 'secundario':
        return 'Nivel II - Secundario';
      case 'terciario':
        return 'Nivel III - Terciario';
      default:
        return 'Nivel $nivelAtencion';
    }
  }

  // Calcular distancia aproximada en km
  double? distanciaA(double? userLat, double? userLng) {
    if (latitud == null || longitud == null || userLat == null || userLng == null) {
      return null;
    }

    const double earthRadius = 6371;
    final double dLat = (latitud! - userLat) * (3.14159 / 180);
    final double dLng = (longitud! - userLng) * (3.14159 / 180);

    final double a = (dLat / 2) * (dLat / 2) + (dLng / 2) * (dLng / 2);
    final double c = 2 * (a < 1 ? a : 1);

    return earthRadius * c;
  }
}

// Modelo para Médico con información de IPS y municipio
class MedicoIntegrado {
  final String id;
  final String nombre;
  final String documento;
  final String? telefono;
  final String? email;
  final String especialidad;
  final String? registroMedico;
  final String? ipsId;
  final String? ipsNombre;
  final String? municipioId;
  final String? municipioNombre;
  final bool activo;
  final DateTime created_at;
  final DateTime updated_at;
  
  // Estadísticas del médico
  final int totalGestantesAsignadas;
  final int controlesRealizados;
  final int controlesEsteMes;
  final double? promedioControlesPorGestante;
  
  // Horarios de atención (opcional)
  final Map<String, dynamic>? horariosAtencion;

  MedicoIntegrado({
    required this.id,
    required this.nombre,
    required this.documento,
    this.telefono,
    this.email,
    required this.especialidad,
    this.registroMedico,
    this.ipsId,
    this.ipsNombre,
    this.municipioId,
    this.municipioNombre,
    required this.activo,
    required this.created_at,
    required this.updated_at,
    this.totalGestantesAsignadas = 0,
    this.controlesRealizados = 0,
    this.controlesEsteMes = 0,
    this.promedioControlesPorGestante,
    this.horariosAtencion,
  });

  factory MedicoIntegrado.fromJson(Map<String, dynamic> json) {
    final estadisticas = json['estadisticas'] as Map<String, dynamic>? ?? {};
    
    return MedicoIntegrado(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      documento: json['documento'] as String,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      especialidad: json['especialidad'] as String? ?? 'Medicina General',
      // CORREGIDO: El backend envía 'registroMedico' (camelCase)
      registroMedico: json['registroMedico'] as String? ?? json['registro_medico'] as String?,
      ipsId: json['ips_id'] as String?,
      // CORREGIDO: El backend envía 'ips' como string, no objeto
      ipsNombre: json['ips'] as String? ?? json['ips_nombre'] as String?,
      municipioId: json['municipio_id'] as String?,
      // CORREGIDO: El backend envía 'municipio' como string, no objeto
      municipioNombre: json['municipio'] as String? ?? json['municipio_nombre'] as String?,
      activo: json['activo'] as bool? ?? true,
      // CORREGIDO: El backend envía 'fechaCreacion' (camelCase)
      created_at: json['fechaCreacion'] != null 
          ? DateTime.parse(json['fechaCreacion'] as String)
          : json['created_at'] != null 
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updated_at: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      // CORREGIDO: El backend envía 'gestantesAsignadas' (camelCase)
      totalGestantesAsignadas: _parseInt(json['gestantesAsignadas']) != 0 ? _parseInt(json['gestantesAsignadas']) : _parseInt(estadisticas['gestantes_asignadas']),
      controlesRealizados: _parseInt(estadisticas['controles_realizados']),
      controlesEsteMes: _parseInt(estadisticas['controles_este_mes']),
      promedioControlesPorGestante: _parseDouble(estadisticas['promedio_controles']),
      horariosAtencion: json['horarios_atencion'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'documento': documento,
      'telefono': telefono,
      'email': email,
      'especialidad': especialidad,
      'registro_medico': registroMedico,
      'ips_id': ipsId,
      'municipio_id': municipioId,
      'activo': activo,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }

  // Getters para UI
  String get estadoTexto => activo ? 'ACTIVO' : 'INACTIVO';
  Color get estadoColor => activo ? Colors.green : Colors.red;
  
  String get especialidadTexto {
    switch (especialidad.toLowerCase()) {
      case 'ginecologia':
      case 'ginecología':
        return 'Ginecología y Obstetricia';
      case 'medicina_general':
      case 'medicina general':
        return 'Medicina General';
      case 'pediatria':
      case 'pediatría':
        return 'Pediatría';
      default:
        return especialidad;
    }
  }

  // Indicadores de rendimiento
  String get nivelCarga {
    if (totalGestantesAsignadas == 0) return 'Sin asignaciones';
    if (totalGestantesAsignadas <= 10) return 'Carga baja';
    if (totalGestantesAsignadas <= 25) return 'Carga normal';
    if (totalGestantesAsignadas <= 40) return 'Carga alta';
    return 'Sobrecarga';
  }

  Color get colorCarga {
    if (totalGestantesAsignadas == 0) return Colors.grey;
    if (totalGestantesAsignadas <= 10) return Colors.green;
    if (totalGestantesAsignadas <= 25) return Colors.blue;
    if (totalGestantesAsignadas <= 40) return Colors.orange;
    return Colors.red;
  }
}

// Modelo para resumen estadístico integrado
class ResumenIntegrado {
  final int totalMunicipios;
  final int municipiosActivos;
  final int totalIPS;
  final int ipsActivas;
  final int totalMedicos;
  final int medicosActivos;
  final int totalGestantes;
  final int gestantesActivas;
  final int alertasActivas;
  final int controlesEsteMes;
  
  // Distribución por nivel de atención
  final Map<String, int> distribucionNivelesAtencion;
  
  // Distribución por especialidades
  final Map<String, int> distribucionEspecialidades;
  
  // Municipios con mayor actividad
  final List<MunicipioIntegrado> municipiosTopActividad;

  ResumenIntegrado({
    required this.totalMunicipios,
    required this.municipiosActivos,
    required this.totalIPS,
    required this.ipsActivas,
    required this.totalMedicos,
    required this.medicosActivos,
    required this.totalGestantes,
    required this.gestantesActivas,
    required this.alertasActivas,
    required this.controlesEsteMes,
    this.distribucionNivelesAtencion = const {},
    this.distribucionEspecialidades = const {},
    this.municipiosTopActividad = const [],
  });

  factory ResumenIntegrado.fromJson(Map<String, dynamic> json) {
    return ResumenIntegrado(
      totalMunicipios: _parseInt(json['total_municipios']),
      municipiosActivos: _parseInt(json['municipios_activos']),
      totalIPS: _parseInt(json['total_ips']),
      ipsActivas: _parseInt(json['ips_activas']),
      totalMedicos: _parseInt(json['total_medicos']),
      medicosActivos: _parseInt(json['medicos_activos']),
      totalGestantes: _parseInt(json['total_gestantes']),
      gestantesActivas: _parseInt(json['gestantes_activas']),
      alertasActivas: _parseInt(json['alertas_activas']),
      controlesEsteMes: _parseInt(json['controles_este_mes']),
      distribucionNivelesAtencion: Map<String, int>.from(
        json['distribucion_niveles_atencion'] as Map<String, dynamic>? ?? {}
      ),
      distribucionEspecialidades: Map<String, int>.from(
        json['distribucion_especialidades'] as Map<String, dynamic>? ?? {}
      ),
      municipiosTopActividad: json['municipios_top_actividad'] != null
          ? (json['municipios_top_actividad'] as List)
              .map((e) => MunicipioIntegrado.fromJson(e))
              .toList()
          : [],
    );
  }

  // Getters para indicadores
  double get porcentajeMunicipiosActivos => 
      totalMunicipios > 0 ? (municipiosActivos / totalMunicipios) * 100 : 0;
  
  double get porcentajeIPSActivas => 
      totalIPS > 0 ? (ipsActivas / totalIPS) * 100 : 0;
  
  double get porcentajeMedicosActivos => 
      totalMedicos > 0 ? (medicosActivos / totalMedicos) * 100 : 0;
  
  double get porcentajeGestantesActivas => 
      totalGestantes > 0 ? (gestantesActivas / totalGestantes) * 100 : 0;
  
  double get promedioGestantesPorMedico => 
      medicosActivos > 0 ? gestantesActivas / medicosActivos : 0;
  
  double get promedioMedicosPorIPS => 
      ipsActivas > 0 ? medicosActivos / ipsActivas : 0;
}