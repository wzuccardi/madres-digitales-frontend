import 'package:equatable/equatable.dart';

// El enum TipoPermiso está definido en madrina_session_provider.dart
// para evitar duplicaciones

enum EstadoAsignacion {
  activa,
  inactiva,
  completada,
  cancelada,
}

enum TipoAsignacion {
  automatica,
  manual,
  transferencia,
}

class Gestante extends Equatable {
  final String id;
  final String nombres;
  final String apellidos;
  final String tipoDocumento;
  final String numeroDocumento;
  final String? email;
  final String telefono;
  final DateTime fechaNacimiento;
  final DateTime? fechaUltimaMestruacion;
  final DateTime? fechaProbableParto;
  final bool esAltoRiesgo;
  final List<String> factoresRiesgo;
  final String grupoSanguineo;
  final String? contactoEmergenciaNombre;
  final String? contactoEmergenciaTelefono;
  final String direccion;
  final String? barrio;
  final String eps;
  final String regimen;
  final String creadaPor;
  final List<String> madrinasAsignadas;
  final bool activa;
  final DateTime fechaCreacion;
  final String? fotoUrl;

  const Gestante({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.tipoDocumento,
    required this.numeroDocumento,
    this.email,
    required this.telefono,
    required this.fechaNacimiento,
    this.fechaUltimaMestruacion,
    this.fechaProbableParto,
    this.esAltoRiesgo = false,
    this.factoresRiesgo = const [],
    this.grupoSanguineo = 'O+',
    this.contactoEmergenciaNombre,
    this.contactoEmergenciaTelefono,
    required this.direccion,
    this.barrio,
    required this.eps,
    required this.regimen,
    required this.creadaPor,
    this.madrinasAsignadas = const [],
    this.activa = true,
    required this.fechaCreacion,
    this.fotoUrl,
  });

  String get nombreCompleto => '$nombres $apellidos';
  
  int get edad {
    final now = DateTime.now();
    int age = now.year - fechaNacimiento.year;
    if (now.month < fechaNacimiento.month || 
        (now.month == fechaNacimiento.month && now.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }
  
  int? get semanasGestacion {
    if (fechaUltimaMestruacion == null) return null;
    
    final now = DateTime.now();
    final difference = now.difference(fechaUltimaMestruacion!).inDays;
    return (difference / 7).floor();
  }

  Gestante copyWith({
    String? id,
    String? nombres,
    String? apellidos,
    String? tipoDocumento,
    String? numeroDocumento,
    String? email,
    String? telefono,
    DateTime? fechaNacimiento,
    DateTime? fechaUltimaMestruacion,
    DateTime? fechaProbableParto,
    bool? esAltoRiesgo,
    List<String>? factoresRiesgo,
    String? grupoSanguineo,
    String? contactoEmergenciaNombre,
    String? contactoEmergenciaTelefono,
    String? direccion,
    String? barrio,
    String? eps,
    String? regimen,
    String? creadaPor,
    List<String>? madrinasAsignadas,
    bool? activa,
    DateTime? fechaCreacion,
    String? fotoUrl,
  }) {
    return Gestante(
      id: id ?? this.id,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      fechaUltimaMestruacion: fechaUltimaMestruacion ?? this.fechaUltimaMestruacion,
      fechaProbableParto: fechaProbableParto ?? this.fechaProbableParto,
      esAltoRiesgo: esAltoRiesgo ?? this.esAltoRiesgo,
      factoresRiesgo: factoresRiesgo ?? this.factoresRiesgo,
      grupoSanguineo: grupoSanguineo ?? this.grupoSanguineo,
      contactoEmergenciaNombre: contactoEmergenciaNombre ?? this.contactoEmergenciaNombre,
      contactoEmergenciaTelefono: contactoEmergenciaTelefono ?? this.contactoEmergenciaTelefono,
      direccion: direccion ?? this.direccion,
      barrio: barrio ?? this.barrio,
      eps: eps ?? this.eps,
      regimen: regimen ?? this.regimen,
      creadaPor: creadaPor ?? this.creadaPor,
      madrinasAsignadas: madrinasAsignadas ?? this.madrinasAsignadas,
      activa: activa ?? this.activa,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombres,
    apellidos,
    tipoDocumento,
    numeroDocumento,
    email,
    telefono,
    fechaNacimiento,
    fechaUltimaMestruacion,
    fechaProbableParto,
    esAltoRiesgo,
    factoresRiesgo,
    grupoSanguineo,
    contactoEmergenciaNombre,
    contactoEmergenciaTelefono,
    direccion,
    barrio,
    eps,
    regimen,
    creadaPor,
    madrinasAsignadas,
    activa,
    fechaCreacion,
    fotoUrl,
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'tipoDocumento': tipoDocumento,
      'numeroDocumento': numeroDocumento,
      'email': email,
      'telefono': telefono,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'fechaUltimaMestruacion': fechaUltimaMestruacion?.toIso8601String(),
      'fechaProbableParto': fechaProbableParto?.toIso8601String(),
      'esAltoRiesgo': esAltoRiesgo,
      'factoresRiesgo': factoresRiesgo,
      'grupoSanguineo': grupoSanguineo,
      'contactoEmergenciaNombre': contactoEmergenciaNombre,
      'contactoEmergenciaTelefono': contactoEmergenciaTelefono,
      'direccion': direccion,
      'barrio': barrio,
      'eps': eps,
      'regimen': regimen,
      'creadaPor': creadaPor,
      'madrinasAsignadas': madrinasAsignadas,
      'activa': activa,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fotoUrl': fotoUrl,
    };
  }

  factory Gestante.fromMap(Map<String, dynamic> map) {
    return Gestante(
      id: map['id'],
      nombres: map['nombres'],
      apellidos: map['apellidos'],
      tipoDocumento: map['tipoDocumento'],
      numeroDocumento: map['numeroDocumento'],
      email: map['email'],
      telefono: map['telefono'],
      fechaNacimiento: DateTime.parse(map['fechaNacimiento']),
      fechaUltimaMestruacion: map['fechaUltimaMestruacion'] != null 
          ? DateTime.parse(map['fechaUltimaMestruacion']) 
          : null,
      fechaProbableParto: map['fechaProbableParto'] != null 
          ? DateTime.parse(map['fechaProbableParto']) 
          : null,
      esAltoRiesgo: map['esAltoRiesgo'] ?? false,
      factoresRiesgo: List<String>.from(map['factoresRiesgo'] ?? []),
      grupoSanguineo: map['grupoSanguineo'] ?? 'O+',
      contactoEmergenciaNombre: map['contactoEmergenciaNombre'],
      contactoEmergenciaTelefono: map['contactoEmergenciaTelefono'],
      direccion: map['direccion'],
      barrio: map['barrio'],
      eps: map['eps'],
      regimen: map['regimen'],
      creadaPor: map['creadaPor'],
      madrinasAsignadas: List<String>.from(map['madrinasAsignadas'] ?? []),
      activa: map['activa'] ?? true,
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
      fotoUrl: map['fotoUrl'],
    );
  }
}