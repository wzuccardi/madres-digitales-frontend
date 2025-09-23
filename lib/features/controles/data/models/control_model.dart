import 'package:json_annotation/json_annotation.dart';

part 'control_model.g.dart';

@JsonSerializable()
class ControlModel {
  final String id;
  final String gestanteId;
  final DateTime fechaControl;
  final int? semanasGestacion;
  final double? peso;
  final double? talla;
  // ...otros campos relevantes

  ControlModel({
    required this.id,
    required this.gestanteId,
    required this.fechaControl,
    this.semanasGestacion,
    this.peso,
    this.talla,
    // ...otros campos
  });

  factory ControlModel.fromJson(Map<String, dynamic> json) => _$ControlModelFromJson(json);
  Map<String, dynamic> toJson() => _$ControlModelToJson(this);
}
