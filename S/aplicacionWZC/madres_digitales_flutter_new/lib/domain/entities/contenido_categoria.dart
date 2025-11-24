class ContenidoCategoria {

  ContenidoCategoria({
    required this.id,
    required this.contenidoId,
    required this.categoriaId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContenidoCategoria.fromJson(Map<String, dynamic> json) {
    return ContenidoCategoria(
      id: json['id'] ?? '',
      contenidoId: json['contenidoId'] ?? '',
      categoriaId: json['categoriaId'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
  final String id;
  final String contenidoId;
  final String categoriaId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contenidoId': contenidoId,
      'categoriaId': categoriaId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ContenidoCategoria copyWith({
    String? id,
    String? contenidoId,
    String? categoriaId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContenidoCategoria(
      id: id ?? this.id,
      contenidoId: contenidoId ?? this.contenidoId,
      categoriaId: categoriaId ?? this.categoriaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContenidoCategoria &&
        other.id == id &&
        other.contenidoId == contenidoId &&
        other.categoriaId == categoriaId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ contenidoId.hashCode ^ categoriaId.hashCode;
  }

  @override
  String toString() {
    return 'ContenidoCategoria(id: $id, contenidoId: $contenidoId, categoriaId: $categoriaId)';
  }
}