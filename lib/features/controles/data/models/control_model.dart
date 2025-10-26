import 'package:json_annotation/json_annotation.dart';

part 'control_model.g.dart';

@JsonSerializable()
class ControlModel {
  final String id;
  final String gestante_id;
  final DateTime fecha_control;
  final int? semanas_gestacion;
  final double? peso;
  final double? presion_sistolica;
  final double? presion_diastolica;
  final int? frecuencia_cardiaca;
  final double? temperatura;
  final double? altura_uterina;
  final String? movimientos_fetales;
  final String? edemas;
  final String? recomendaciones;
  final String medico_id;

  ControlModel({
    required this.id,
    required this.gestante_id,
    required this.fecha_control,
    this.semanas_gestacion,
    this.peso,
    this.presion_sistolica,
    this.presion_diastolica,
    this.frecuencia_cardiaca,
    this.temperatura,
    this.altura_uterina,
    this.movimientos_fetales,
    this.edemas,
    this.recomendaciones,
    required this.medico_id,
  });

  factory ControlModel.fromJson(Map<String, dynamic> json) => _$ControlModelFromJson(json);
  Map<String, dynamic> toJson() => _$ControlModelToJson(this);
}
