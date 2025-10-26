import 'package:equatable/equatable.dart';

class Control extends Equatable {
  final String id;
  final String gestanteId;
  final DateTime fechaControl;
  final int? semanasGestacion;
  final double? peso;
  final double? talla;
  // ...otros campos relevantes

  const Control({
    required this.id,
    required this.gestanteId,
    required this.fechaControl,
    this.semanasGestacion,
    this.peso,
    this.talla,
    // ...otros campos
  });

  @override
  List<Object?> get props => [id, gestanteId, fechaControl, semanasGestacion, peso, talla];

  factory Control.fromJson(Map<String, dynamic> json) {
    return Control(
      id: json['id']?.toString() ?? '',
      gestanteId: json['gestante_id']?.toString() ?? '',
      fechaControl: DateTime.tryParse(json['fecha_control']?.toString() ?? '') ?? DateTime.now(),
      semanasGestacion: json['semanas_gestacion'] != null ? int.tryParse(json['semanas_gestacion'].toString()) : null,
      peso: json['peso'] != null ? double.tryParse(json['peso'].toString()) : null,
      talla: json['talla'] != null ? double.tryParse(json['talla'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gestante_id': gestanteId,
      'fecha_control': fechaControl.toIso8601String(),
      'semanas_gestacion': semanasGestacion,
      'peso': peso,
      'talla': talla,
    };
  }
}
