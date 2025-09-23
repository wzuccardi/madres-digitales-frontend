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
}
