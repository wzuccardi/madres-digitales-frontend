import 'contenido_unificado.dart';  // Corrección: Importar ContenidoUnificado que sí existe

class ContenidoModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String tipoContenido;
  final String? urlContenido;
  final String? imagenUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContenidoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.tipoContenido,
    this.urlContenido,
    this.imagenUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContenidoModel.fromJson(Map<String, dynamic> json) {
    return ContenidoModel(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? '',
      tipoContenido: json['tipoContenido'] ?? '',
      urlContenido: json['urlContenido'],
      imagenUrl: json['imagenUrl'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'tipoContenido': tipoContenido,
      'urlContenido': urlContenido,
      'imagenUrl': imagenUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crear copia
  ContenidoModel copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? categoria,
    String? tipoContenido,
    String? urlContenido,
    String? imagenUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContenidoModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      tipoContenido: tipoContenido ?? this.tipoContenido,
      urlContenido: urlContenido ?? this.urlContenido,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ContenidoModel(id: $id, titulo: $titulo, categoria: $categoria)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ContenidoModel &&
      other.id == id &&
      other.titulo == titulo &&
      other.descripcion == descripcion &&
      other.categoria == categoria &&
      other.tipoContenido == tipoContenido &&
      other.urlContenido == urlContenido &&
      other.imagenUrl == imagenUrl &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      titulo.hashCode ^
      descripcion.hashCode ^
      categoria.hashCode ^
      tipoContenido.hashCode ^
      urlContenido.hashCode ^
      imagenUrl.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }

  // Método para convertir ContenidoUnificado a ContenidoModel
  factory ContenidoModel.fromContenidoUnificado(ContenidoUnificado contenido) {
    return ContenidoModel(
      id: contenido.id,
      titulo: contenido.titulo,
      descripcion: contenido.descripcion ?? '', // Corrección: descripcion es String? en ContenidoUnificado
      categoria: contenido.categoria,
      tipoContenido: contenido.tipo, // Corrección: usar tipo en lugar de tipoContenido
      urlContenido: contenido.urlContenido,
      imagenUrl: contenido.urlImagen, // Corrección: usar urlImagen en lugar de imagenUrl
      createdAt: contenido.fechaCreacion, // Mapear fechaCreacion a createdAt
      updatedAt: contenido.fechaActualizacion, // Corrección: usar fechaActualizacion en lugar de updatedAt
    );
  }

  // Método para convertir ContenidoModel a ContenidoUnificado
  ContenidoUnificado toContenidoUnificado() {
    return ContenidoUnificado(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      categoria: categoria,
      tipo: tipoContenido, // Corrección: usar tipoContenido en lugar de tipoContenido
      urlContenido: urlContenido,
      urlImagen: imagenUrl, // Corrección: usar imagenUrl en lugar de urlImagen
      fechaCreacion: createdAt, // Mapear createdAt a fechaCreacion
      fechaActualizacion: updatedAt, // Corrección: usar updatedAt en lugar de fechaActualizacion
      activo: true, // Asignar activo por defecto
    );
  }
}