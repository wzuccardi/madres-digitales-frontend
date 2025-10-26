import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  @JsonKey(name: 'password_hash', includeToJson: false)
  final String? passwordHash;
  final String nombre;
  final String? documento;
  final String? telefono;
  final String rol;
  @JsonKey(name: 'municipio_id')
  final String? municipioId;
  final String? direccion;
  final dynamic coordenadas;
  @JsonKey(name: 'zona_cobertura')
  final dynamic zonaCobertura;
  final bool activo;
  @JsonKey(name: 'ultimo_acceso')
  final String? ultimoAcceso;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.passwordHash,
    required this.nombre,
    this.documento,
    this.telefono,
    required this.rol,
    this.municipioId,
    this.direccion,
    this.coordenadas,
    this.zonaCobertura,
    required this.activo,
    this.ultimoAcceso,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
