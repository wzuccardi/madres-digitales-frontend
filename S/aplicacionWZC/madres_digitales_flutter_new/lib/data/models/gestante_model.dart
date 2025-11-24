import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/gestante.dart';


part 'gestante_model.g.dart';

/// Modelo de datos (DTO) para Gestante
/// Convierte entre JSON y la entidad del dominio
@JsonSerializable()
class GestanteModel {

  const GestanteModel({
    required this.id,
    required this.name,
    this.document,
    this.documentType,
    this.birthDate,
    this.phone,
    this.address,
    this.coordinates,
    this.lastMenstruation,
    this.probableDelivery,
    this.eps,
    this.healthRegime,
    this.municipalityId,
    this.madrinaId,
    this.medicoTratanteId,
    this.ipsAsignadaId,
    required this.active,
    this.highRisk = false,
    this.lastControlDate,
    this.nextControlDate,
    required this.createdAt,
    this.updatedAt,
    this.municipalityName,
    this.departmentName,
    this.madrinaName,
    this.medicoTratanteName,
    this.ipsAsignadaName,
    this.riskFactors,
    this.controls,
    this.notes,
    this.metadata,
  });

  factory GestanteModel.fromJson(Map<String, dynamic> json) => _$GestanteModelFromJson(json);

  /// Convierte la entidad del dominio al modelo
  factory GestanteModel.fromDomainEntity(Gestante gestante) {
    return GestanteModel(
      id: gestante.id,
      name: '${gestante.nombre} ${gestante.apellido}'.trim(),
      document: gestante.documento,
      documentType: null, // No disponible en la entidad actual
      birthDate: gestante.fechaNacimiento,
      phone: gestante.telefono,
      address: gestante.direccion,
      coordinates: null, // No disponible en la entidad actual
      lastMenstruation: null, // No disponible en la entidad actual
      probableDelivery: gestante.fechaProbableParto,
      eps: gestante.eps,
      healthRegime: gestante.regimen,
      municipalityId: null, // No disponible en la entidad actual
      madrinaId: gestante.madrinaId,
      medicoTratanteId: gestante.medicoId,
      ipsAsignadaId: gestante.ipsId,
      active: gestante.activa, // Usar directamente el campo activa
      highRisk: gestante.riesgoAlto, // Usar directamente el campo riesgoAlto
      lastControlDate: gestante.fechaUltimoControl,
      createdAt: gestante.createdAt,
      updatedAt: gestante.updatedAt,
      municipalityName: null,
      departmentName: null,
      madrinaName: null,
      medicoTratanteName: null,
      ipsAsignadaName: null,
      riskFactors: null,
      controls: null,
      notes: null,
      metadata: null,
    );
  }
  final String id;
  final String name;
  final String? document;
  final String? documentType;
  final DateTime? birthDate;
  final String? phone;
  final String? address;
  final String? coordinates;
  final DateTime? lastMenstruation;
  final DateTime? probableDelivery;
  final String? eps;
  final String? healthRegime;
  final String? municipalityId;
  final String? madrinaId;
  final String? medicoTratanteId;
  final String? ipsAsignadaId;
  final bool active;
  final bool highRisk;
  final DateTime? lastControlDate;
  final DateTime? nextControlDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? municipalityName;
  final String? departmentName;
  final String? madrinaName;
  final String? medicoTratanteName;
  final String? ipsAsignadaName;
  final Map<String, dynamic>? riskFactors;
  final Map<String, dynamic>? controls;
  final Map<String, dynamic>? notes;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => _$GestanteModelToJson(this);

  /// Convierte el modelo a la entidad del dominio
  Gestante toDomainEntity() {
    return Gestante(
      id: id,
      nombre: name.split(' ').take(1).join(' '), // Tomar primera palabra como nombre
      apellido: name.split(' ').skip(1).join(' '), // Resto como apellido
      documento: document ?? '',
      telefono: phone ?? '',
      direccion: address ?? '',
      email: '', // No disponible en el modelo actual
      fechaNacimiento: birthDate,
      eps: eps,
      activa: active, // Mapear active a activa
      riesgoAlto: highRisk, // Mapear highRisk a riesgoAlto
      fechaProbableParto: probableDelivery,
      madrinaId: madrinaId,
      ipsId: ipsAsignadaId,
      medicoId: medicoTratanteId,
      fechaUltimoControl: lastControlDate,
      semanasGestacion: null, // No disponible en el modelo actual
      estado: active ? 'activa' : 'inactiva',
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GestanteModel &&
        other.id == id &&
        other.name == name &&
        other.document == document &&
        other.documentType == documentType &&
        other.birthDate == birthDate &&
        other.phone == phone &&
        other.address == address &&
        other.coordinates == coordinates &&
        other.lastMenstruation == lastMenstruation &&
        other.probableDelivery == probableDelivery &&
        other.eps == eps &&
        other.healthRegime == healthRegime &&
        other.municipalityId == municipalityId &&
        other.madrinaId == madrinaId &&
        other.medicoTratanteId == medicoTratanteId &&
        other.ipsAsignadaId == ipsAsignadaId &&
        other.active == active &&
        other.highRisk == highRisk &&
        other.lastControlDate == lastControlDate &&
        other.nextControlDate == nextControlDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.municipalityName == municipalityName &&
        other.departmentName == departmentName &&
        other.madrinaName == madrinaName &&
        other.medicoTratanteName == medicoTratanteName &&
        other.ipsAsignadaName == ipsAsignadaName &&
        other.riskFactors == riskFactors &&
        other.controls == controls &&
        other.notes == notes &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        document,
        documentType,
        birthDate,
        phone,
        address,
        coordinates,
        lastMenstruation,
        probableDelivery,
        eps,
        healthRegime,
        municipalityId,
        madrinaId,
        medicoTratanteId,
        ipsAsignadaId,
        active,
        highRisk,
        lastControlDate,
        nextControlDate,
        createdAt,
        updatedAt,
        municipalityName,
        departmentName,
        madrinaName,
        medicoTratanteName,
        ipsAsignadaName,
        riskFactors,
        controls,
        notes,
        metadata,
      ]);

  @override
  String toString() {
    return 'GestanteModel{id: $id, name: $name, active: $active, highRisk: $highRisk}';
  }
}
