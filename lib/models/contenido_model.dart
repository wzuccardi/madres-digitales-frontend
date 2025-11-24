import 'package:json_annotation/json_annotation.dart';

part 'contenido_model.g.dart';

@JsonSerializable()
class ContenidoModel {

  ContenidoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.categoria,
    required this.tags,
    required this.url,
    this.activo = true,
    this.fechaPublicacion,
    this.fechaExpiracion,
    this.autorId,
    this.autorNombre,
    this.orden = 0,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContenidoModel.fromJson(Map<String, dynamic> json) =>
      _$ContenidoModelFromJson(json);
  final String id;
  final String titulo;
  final String descripcion;
  final String tipo;
  final String categoria;
  final List<String> tags;
  final String url;
  final bool activo;
  final DateTime? fechaPublicacion;
  final DateTime? fechaExpiracion;
  final String? autorId;
  final String? autorNombre;
  final int orden;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$ContenidoModelToJson(this);

  ContenidoModel copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? tipo,
    String? categoria,
    List<String>? tags,
    String? url,
    bool? activo,
    DateTime? fechaPublicacion,
    DateTime? fechaExpiracion,
    String? autorId,
    String? autorNombre,
    int? orden,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContenidoModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      tags: tags ?? this.tags,
      url: url ?? this.url,
      activo: activo ?? this.activo,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
      fechaExpiracion: fechaExpiracion ?? this.fechaExpiracion,
      autorId: autorId ?? this.autorId,
      autorNombre: autorNombre ?? this.autorNombre,
      orden: orden ?? this.orden,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ContenidoModel{id: $id, titulo: $titulo, tipo: $tipo, categoria: $categoria}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContenidoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
