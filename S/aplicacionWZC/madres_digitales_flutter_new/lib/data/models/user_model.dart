import 'package:json_annotation/json_annotation.dart';
import 'package:madres_digitales_flutter_new/domain/entities/user.dart';

part 'user_model.g.dart';

/// Modelo de datos (DTO) para User
/// Convierte entre JSON y la entidad del dominio
@JsonSerializable()
class UserModel {

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.municipalityId,
    this.phone,
    this.document,
    this.documentType,
    required this.active,
    this.lastAccess,
    required this.createdAt,
    required this.updatedAt,
    this.municipalityName,
    this.departmentName,
    this.profileImageUrl,
    this.preferences,
    this.metadata,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// Convierte desde entidad de dominio User
  factory UserModel.fromDomainEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.nombre,
      role: user.rol,
      municipalityId: null,
      phone: user.telefono,
      document: null,
      documentType: null,
      active: user.activo,
      lastAccess: user.ultimoAcceso,
      createdAt: user.fechaCreacion ?? DateTime.now(),
      updatedAt: user.fechaCreacion ?? DateTime.now(),
      municipalityName: null,
      departmentName: null,
      profileImageUrl: null,
      preferences: null,
      metadata: null,
    );
  }
  final String id;
  final String email;
  final String name;
  final String role;
  final String? municipalityId;
  final String? phone;
  final String? document;
  final String? documentType;
  final bool active;
  final DateTime? lastAccess;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? municipalityName;
  final String? departmentName;
  final String? profileImageUrl;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convierte el modelo a entidad de dominio User
  User toDomainEntity() {
    return User(
      id: id,
      email: email,
      nombre: name,
      apellido: null,
      telefono: phone,
      rol: role,
      fechaCreacion: createdAt,
      ultimoAcceso: lastAccess,
      activo: active,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.role == role &&
        other.municipalityId == municipalityId &&
        other.phone == phone &&
        other.document == document &&
        other.documentType == documentType &&
        other.active == active &&
        other.lastAccess == lastAccess &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.municipalityName == municipalityName &&
        other.departmentName == departmentName &&
        other.profileImageUrl == profileImageUrl &&
        other.preferences == preferences &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => Object.hash(
        id,
        email,
        name,
        role,
        municipalityId,
        phone,
        document,
        documentType,
        active,
        lastAccess,
        createdAt,
        updatedAt,
        municipalityName,
        departmentName,
        profileImageUrl,
        preferences,
        metadata,
      );

  @override
  String toString() {
    return 'UserModel{id: $id, email: $email, name: $name, role: $role}';
  }
}
