class Gestante {

  Gestante({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.documento,
    required this.telefono,
    required this.direccion,
    required this.email,
    this.fechaNacimiento,
    this.eps,
    this.activa = true,
    this.riesgoAlto = false,
    this.fechaProbableParto,
    this.madrinaId,
    this.ipsId,
    this.medicoId,
    this.fechaUltimoControl,
    this.semanasGestacion,
    this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.municipio,
    this.municipioId,
    this.tipoDocumento,
    this.fechaUltimaMestruacion,
    this.barrio,
    this.regimen,
    this.coordenadas,
    this.numeroEmbarazo = 1,
    String? nombres,
    String? apellidos,
    String? numeroDocumento,
    bool? esAltoRiesgo,
    List<String>? factoresRiesgo,
    String? grupoSanguineo,
    String? contactoEmergenciaNombre,
    String? contactoEmergenciaTelefono,
    DateTime? fechaCreacion,
    this.creadaPor,
    List<String>? madrinasAsignadas,
    String? fotoUrl,
  });

  factory Gestante.fromJson(Map<String, dynamic> json) {
    return Gestante(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      documento: json['documento'] ?? '',
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
      email: json['email'] ?? '',
      fechaNacimiento: json['fechaNacimiento'] != null
          ? DateTime.parse(json['fechaNacimiento'])
          : null,
      eps: json['eps'],
      activa: json['activa'] ?? true,
      riesgoAlto: json['riesgoAlto'] ?? false,
      fechaProbableParto: json['fechaProbableParto'] != null
          ? DateTime.parse(json['fechaProbableParto'])
          : null,
      madrinaId: json['madrinaId'],
      ipsId: json['ipsId'],
      medicoId: json['medicoId'],
      fechaUltimoControl: json['fechaUltimoControl'] != null
          ? DateTime.parse(json['fechaUltimoControl'])
          : null,
      semanasGestacion: json['semanasGestacion'],
      estado: json['estado'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      municipio: json['municipio'],
      municipioId: json['municipio_id']?.toString(),
      tipoDocumento: json['tipoDocumento'] ?? json['tipo_documento'],
      fechaUltimaMestruacion: json['fechaUltimaMestruacion'] != null
          ? DateTime.parse(json['fechaUltimaMestruacion'])
          : null,
      barrio: json['barrio'],
      regimen: json['regimen'] ?? json['regimen_salud'],
      coordenadas: json['coordenadas'],
      numeroEmbarazo: json['numeroEmbarazo'] ?? json['numero_embarazo'] ?? 1,
    );
  }
  final String id;
  final String nombre;
  final String apellido;
  final String documento;
  final String telefono;
  final String direccion;
  final String email;
  final DateTime? fechaNacimiento;
  final String? eps;
  final bool activa;
  final bool riesgoAlto;
  final DateTime? fechaProbableParto;
  final String? madrinaId;
  final String? ipsId;
  final String? medicoId;
  final DateTime? fechaUltimoControl;
  final int? semanasGestacion;
  final String? estado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? creadaPor;
  final String? municipio;
  final String? municipioId;
  final String? tipoDocumento;
  final DateTime? fechaUltimaMestruacion;
  final String? barrio;
  final String? regimen;
  final String? coordenadas;
  final int? numeroEmbarazo;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'documento': documento,
      'telefono': telefono,
      'direccion': direccion,
      'email': email,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'eps': eps,
      'activa': activa,
      'riesgoAlto': riesgoAlto,
      'fechaProbableParto': fechaProbableParto?.toIso8601String(),
      'fecha_probable_parto': fechaProbableParto?.toIso8601String(),
      'madrinaId': madrinaId,
      'ipsId': ipsId,
      'medicoId': medicoId,
      'fechaUltimoControl': fechaUltimoControl?.toIso8601String(),
      'fecha_ultimo_control': fechaUltimoControl?.toIso8601String(),
      'semanasGestacion': semanasGestacion,
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'creadaPor': creadaPor,
      'municipio': municipio,
      'municipio_id': municipioId,
      'tipoDocumento': tipoDocumento,
      'tipo_documento': tipoDocumento,
      'fechaUltimaMestruacion': fechaUltimaMestruacion?.toIso8601String(),
      'fecha_ultima_mestruacion': fechaUltimaMestruacion?.toIso8601String(),
      'barrio': barrio,
      'regimen': regimen,
      'regimen_salud': regimen,
      'coordenadas': coordenadas,
      'numeroEmbarazo': numeroEmbarazo,
      'numero_embarazo': numeroEmbarazo,
    };
  }

  Gestante copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? documento,
    String? telefono,
    String? direccion,
    String? email,
    DateTime? fechaNacimiento,
    String? eps,
    bool? activa,
    bool? riesgoAlto,
    DateTime? fechaProbableParto,
    String? madrinaId,
    String? ipsId,
    String? medicoId,
    DateTime? fechaUltimoControl,
    int? semanasGestacion,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? creadaPor,
    String? municipio,
    String? municipioId,
    String? tipoDocumento,
    DateTime? fechaUltimaMestruacion,
    String? barrio,
    String? regimen,
    String? coordenadas,
    int? numeroEmbarazo,
  }) {
    return Gestante(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      documento: documento ?? this.documento,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      email: email ?? this.email,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      eps: eps ?? this.eps,
      activa: activa ?? this.activa,
      riesgoAlto: riesgoAlto ?? this.riesgoAlto,
      fechaProbableParto: fechaProbableParto ?? this.fechaProbableParto,
      madrinaId: madrinaId ?? this.madrinaId,
      ipsId: ipsId ?? this.ipsId,
      medicoId: medicoId ?? this.medicoId,
      fechaUltimoControl: fechaUltimoControl ?? this.fechaUltimoControl,
      semanasGestacion: semanasGestacion ?? this.semanasGestacion,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creadaPor: creadaPor ?? this.creadaPor,
      municipio: municipio ?? this.municipio,
      municipioId: municipioId ?? this.municipioId,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      fechaUltimaMestruacion: fechaUltimaMestruacion ?? this.fechaUltimaMestruacion,
      barrio: barrio ?? this.barrio,
      regimen: regimen ?? this.regimen,
      coordenadas: coordenadas ?? this.coordenadas,
      numeroEmbarazo: numeroEmbarazo ?? this.numeroEmbarazo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gestante &&
        other.id == id &&
        other.nombre == nombre &&
        other.apellido == apellido &&
        other.documento == documento;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nombre.hashCode ^ apellido.hashCode ^ documento.hashCode;
  }

  @override
  String toString() {
    return 'Gestante(id: $id, nombre: $nombre $apellido, documento: $documento)';
  }

  String get nombreCompleto => '$nombre $apellido';
  String get numeroDocumento => documento;
  int get edad {
    if (fechaNacimiento == null) return 0;
    final now = DateTime.now();
    var years = now.year - fechaNacimiento!.year;
    final hadBirthday = (now.month > fechaNacimiento!.month) || (now.month == fechaNacimiento!.month && now.day >= fechaNacimiento!.day);
    if (!hadBirthday) years -= 1;
    return years;
  }
  bool get esAltoRiesgo => riesgoAlto;
  String get barrioLocal => barrio ?? '';
  String get grupoSanguineo => '';
  DateTime? get fechaUltimaMestruacionLocal => fechaUltimaMestruacion;
  List<String> get factoresRiesgo => const [];
  String get regimenLocal => regimen ?? '';
  String get contactoEmergenciaNombre => '';
  String get contactoEmergenciaTelefono => '';
  List<String> get madrinasAsignadas => madrinaId != null ? [madrinaId!] : const [];
  String get nombres => nombre;
}
