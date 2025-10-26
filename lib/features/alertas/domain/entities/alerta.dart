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

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      id: json['id']?.toString() ?? '',
      gestanteId: json['gestante_id']?.toString() ?? '',
      tipoAlerta: json['tipo_alerta']?.toString() ?? '',
      nivelPrioridad: json['nivel_prioridad']?.toString() ?? '',
      mensaje: json['mensaje']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gestante_id': gestanteId,
      'tipo_alerta': tipoAlerta,
      'nivel_prioridad': nivelPrioridad,
      'mensaje': mensaje,
    };
  }
}
