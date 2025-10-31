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
      semanasGestacion: _parseInt(json['semanas_gestacion']),
      peso: _parseDouble(json['peso']),
      talla: _parseDouble(json['talla']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
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
