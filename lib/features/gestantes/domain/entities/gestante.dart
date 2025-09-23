import 'package:equatable/equatable.dart';

class Gestante extends Equatable {
  final String id;
  final String nombre;
  final String municipioId;

  const Gestante({required this.id, required this.nombre, required this.municipioId});

  @override
  List<Object?> get props => [id, nombre, municipioId];
}
