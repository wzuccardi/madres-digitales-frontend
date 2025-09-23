import 'package:equatable/equatable.dart';

class Alerta extends Equatable {
  final String id;
  final String gestanteId;
  final String tipoAlerta;
  final String nivelPrioridad;
  final String mensaje;

  const Alerta({
    required this.id,
    required this.gestanteId,
    required this.tipoAlerta,
    required this.nivelPrioridad,
    required this.mensaje,
  });

  @override
  List<Object?> get props => [id, gestanteId, tipoAlerta, nivelPrioridad, mensaje];
}
