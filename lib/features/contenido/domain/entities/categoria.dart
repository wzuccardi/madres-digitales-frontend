import 'package:equatable/equatable.dart';

class Categoria extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final String color;
  final bool activa;
  final int orden;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Categoria({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.color,
    this.activa = true,
    this.orden = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Categoria copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? icono,
    String? color,
    bool? activa,
    int? orden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      activa: activa ?? this.activa,
      orden: orden ?? this.orden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, nombre, descripcion, icono, color, activa, orden,
        createdAt, updatedAt,
      ];
}