import 'package:json_annotation/json_annotation.dart';

part 'alerta_model.g.dart';

@JsonSerializable()
class AlertaModel {
  final String id;
  final String gestanteId;
  final String tipoAlerta;
  final String nivelPrioridad;
  final String mensaje;

  AlertaModel({
    required this.id,
    required this.gestanteId,
    required this.tipoAlerta,
    required this.nivelPrioridad,
    required this.mensaje,
  });

  factory AlertaModel.fromJson(Map<String, dynamic> json) => _$AlertaModelFromJson(json);
  Map<String, dynamic> toJson() => _$AlertaModelToJson(this);
}
