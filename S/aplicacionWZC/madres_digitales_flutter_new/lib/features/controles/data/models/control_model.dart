import 'package:json_annotation/json_annotation.dart';

part 'control_model.g.dart';

@JsonSerializable()
class ControlModel {

  ControlModel({
    required this.id,
    required this.gestanteId,
    required this.fechaControl,
    this.semanasGestacion,
    this.peso,
    this.presionSistolica,
    this.presionDiastolica,
    this.frecuenciaCardiaca,
    this.temperatura,
    this.alturaUterina,
    this.movimientosFetales,
    this.edemas,
    this.recomendaciones,
    required this.medicoId,
  });

  factory ControlModel.fromJson(Map<String, dynamic> json) => _$ControlModelFromJson(json);
  final String id;
  @JsonKey(name: 'gestante_id')
  final String gestanteId;
  @JsonKey(name: 'fecha_control')
  final DateTime fechaControl;
  @JsonKey(name: 'semanas_gestacion')
  final int? semanasGestacion;
  final double? peso;
  @JsonKey(name: 'presion_sistolica')
  final double? presionSistolica;
  @JsonKey(name: 'presion_diastolica')
  final double? presionDiastolica;
  @JsonKey(name: 'frecuencia_cardiaca')
  final int? frecuenciaCardiaca;
  final double? temperatura;
  @JsonKey(name: 'altura_uterina')
  final double? alturaUterina;
  @JsonKey(name: 'movimientos_fetales')
  final String? movimientosFetales;
  final String? edemas;
  final String? recomendaciones;
  @JsonKey(name: 'medico_id')
  final String medicoId;
  Map<String, dynamic> toJson() => _$ControlModelToJson(this);
}
