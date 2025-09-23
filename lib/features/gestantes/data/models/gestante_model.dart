import 'package:json_annotation/json_annotation.dart';

part 'gestante_model.g.dart';

@JsonSerializable()
class GestanteModel {
  final String id;
  final String nombre;
  final String municipioId;

  GestanteModel({required this.id, required this.nombre, required this.municipioId});

  factory GestanteModel.fromJson(Map<String, dynamic> json) => _$GestanteModelFromJson(json);
  Map<String, dynamic> toJson() => _$GestanteModelToJson(this);
}
