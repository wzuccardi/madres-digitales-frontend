class ControlDto {

  ControlDto({
    required this.id,
    this.gestanteId,
    this.fechaControl,
    this.semanasGestacion,
    this.peso,
    this.presionSistolica,
    this.presionDiastolica,
    this.alturaUterina,
    this.frecuenciaCardiaca,
    this.temperatura,
    this.observaciones,
    this.recomendaciones,
    this.proximoControl,
    this.gestanteNombre,
    this.gestante,
  });
  final String id;
  final String? gestanteId;
  final DateTime? fechaControl;
  final int? semanasGestacion;
  final double? peso;
  final int? presionSistolica;
  final int? presionDiastolica;
  final double? alturaUterina;
  final int? frecuenciaCardiaca;
  final double? temperatura;
  final String? observaciones;
  final String? recomendaciones;
  final DateTime? proximoControl;
  final String? gestanteNombre;
  final Map<String, dynamic>? gestante;
}