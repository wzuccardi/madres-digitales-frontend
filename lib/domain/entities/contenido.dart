class Contenido {

  Contenido({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.url,
    this.categoriaId,
    this.imagenUrl,
    this.duracionMinutos,
    this.esFavorito = false,
    this.ordenVisualizacion,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Contenido.fromJson(Map<String, dynamic> json) {
    return Contenido(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      tipo: json['tipo'] ?? '',
      url: json['url'] ?? '',
      categoriaId: json['categoriaId'],
      imagenUrl: json['imagenUrl'],
      duracionMinutos: json['duracionMinutos'],
      esFavorito: json['esFavorito'] ?? false,
      ordenVisualizacion: json['ordenVisualizacion'],
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.parse(json['fechaCreacion']) 
          : DateTime.now(),
      fechaActualizacion: json['fechaActualizacion'] != null 
          ? DateTime.parse(json['fechaActualizacion']) 
          : DateTime.now(),
      estado: json['estado'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
  final String id;
  final String titulo;
  final String descripcion;
  final String tipo;
  final String url;
  final String? categoriaId;
  final String? imagenUrl;
  final int? duracionMinutos;
  final bool esFavorito;
  final int? ordenVisualizacion;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'url': url,
      'categoriaId': categoriaId,
      'imagenUrl': imagenUrl,
      'duracionMinutos': duracionMinutos,
      'esFavorito': esFavorito,
      'ordenVisualizacion': ordenVisualizacion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion.toIso8601String(),
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Contenido copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? tipo,
    String? url,
    String? categoriaId,
    String? imagenUrl,
    int? duracionMinutos,
    bool? esFavorito,
    int? ordenVisualizacion,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contenido(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      url: url ?? this.url,
      categoriaId: categoriaId ?? this.categoriaId,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      esFavorito: esFavorito ?? this.esFavorito,
      ordenVisualizacion: ordenVisualizacion ?? this.ordenVisualizacion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contenido &&
        other.id == id &&
        other.titulo == titulo &&
        other.descripcion == descripcion &&
        other.tipo == tipo;
  }

  @override
  int get hashCode {
    return id.hashCode ^ titulo.hashCode ^ descripcion.hashCode ^ tipo.hashCode;
  }

  @override
  String toString() {
    return 'Contenido(id: $id, titulo: $titulo, tipo: $tipo)';
  }
}