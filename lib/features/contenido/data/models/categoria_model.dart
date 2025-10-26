import 'package:equatable/equatable.dart';
import '../../domain/entities/categoria.dart';

class CategoriaModel extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final String color;
  final bool activa;
  final int orden;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoriaModel({
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

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      icono: json['icono'] as String,
      color: json['color'] as String,
      activa: json['activa'] as bool? ?? true,
      orden: json['orden'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'color': color,
      'activa': activa,
      'orden': orden,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Categoria toEntity() {
    return Categoria(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      icono: icono,
      color: color,
      activa: activa,
      orden: orden,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory CategoriaModel.fromEntity(Categoria categoria) {
    return CategoriaModel(
      id: categoria.id,
      nombre: categoria.nombre,
      descripcion: categoria.descripcion,
      icono: categoria.icono,
      color: categoria.color,
      activa: categoria.activa,
      orden: categoria.orden,
      createdAt: categoria.createdAt,
      updatedAt: categoria.updatedAt,
    );
  }

  CategoriaModel copyWith({
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
    return CategoriaModel(
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