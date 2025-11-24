class Control {
  const Control({
    required this.id,
    this.gestanteId,
    this.fecha,
    this.tipo,
    this.estado,
    this.semanasGestacion,
    this.peso,
    this.presionSistolica,
    this.presionDiastolica,
    this.alturaUterina,
    this.frecuenciaCardiaca,
    this.temperatura,
    this.observaciones,
    this.recomendaciones,
    this.fechaProgramada,
    this.gestante,
    this.gestanteNombre,
  });
  final String id;
  final String? gestanteId;
  final DateTime? fecha;
  final String? tipo;
  final String? estado;
  final int? semanasGestacion;
  final double? peso;
  final int? presionSistolica;
  final int? presionDiastolica;
  final double? alturaUterina;
  final int? frecuenciaCardiaca;
  final double? temperatura;
  final String? observaciones;
  final String? recomendaciones;
  final DateTime? fechaProgramada;
  final Object? gestante;
  final String? gestanteNombre;
}

extension ControlJson on Control {
  static Control fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
    return Control(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      gestanteId: (json['gestante_id'] ?? json['gestanteId'])?.toString(),
      fecha: parseDate(json['fecha_control'] ?? json['fecha']),
      tipo: json['tipo']?.toString(),
      estado: json['estado']?.toString(),
      semanasGestacion: (json['semanas_gestacion'] ?? json['semanasGestacion'] as num?)?.toInt(),
      peso: (json['peso'] as num?)?.toDouble(),
      presionSistolica: (json['presion_sistolica'] ?? json['presionSistolica'] as num?)?.toInt(),
      presionDiastolica: (json['presion_diastolica'] ?? json['presionDiastolica'] as num?)?.toInt(),
      alturaUterina: (json['altura_uterina'] ?? json['alturaUterina'] as num?)?.toDouble(),
      frecuenciaCardiaca: (json['frecuencia_cardiaca'] ?? json['frecuenciaCardiaca'] as num?)?.toInt(),
      temperatura: (json['temperatura'] as num?)?.toDouble(),
      observaciones: (json['observaciones'] ?? json['descripcion'])?.toString(),
      recomendaciones: json['recomendaciones']?.toString(),
      fechaProgramada: parseDate(json['proximo_control'] ?? json['fechaProgramada']),
      gestante: json['gestante'],
      gestanteNombre: (json['gestante_nombre'] ?? json['gestanteNombre'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gestanteId': gestanteId,
      'fecha': fecha?.toIso8601String(),
      'tipo': tipo,
      'estado': estado,
      'semanasGestacion': semanasGestacion,
      'peso': peso,
      'presionSistolica': presionSistolica,
      'presionDiastolica': presionDiastolica,
      'alturaUterina': alturaUterina,
      'frecuenciaCardiaca': frecuenciaCardiaca,
      'temperatura': temperatura,
      'observaciones': observaciones,
      'recomendaciones': recomendaciones,
      'fechaProgramada': fechaProgramada?.toIso8601String(),
      'gestante': gestante,
      'gestanteNombre': gestanteNombre,
    };
  }
}