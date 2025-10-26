import 'package:equatable/equatable.dart';
import '../../domain/entities/contenido.dart';

class ContenidoModel extends Equatable {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String tipo;
  final String? url;
  final String? urlContenido; // Propiedad del modelo simple
  final String? thumbnailUrl;
  final String? imagenUrl; // Propiedad del modelo simple
  final int? duracion;
  final String nivel;
  final List<String> etiquetas;
  final bool activo;
  final bool favorito;
  final DateTime fechaPublicacion;
  final DateTime fechaCreacion; // Propiedad del modelo simple
  final int? semanaGestacionInicio;
  final int? semanaGestacionFin;
  final ProgresoUsuarioModel? progreso;
  final bool isAvailableOffline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContenidoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.tipo,
    this.url,
    this.urlContenido,
    this.thumbnailUrl,
    this.imagenUrl,
    this.duracion,
    required this.nivel,
    this.etiquetas = const [],
    this.activo = true,
    this.favorito = false,
    required this.fechaPublicacion,
    required this.fechaCreacion,
    this.semanaGestacionInicio,
    this.semanaGestacionFin,
    this.progreso,
    this.isAvailableOffline = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContenidoModel.fromJson(Map<String, dynamic> json) {
    return ContenidoModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      categoria: json['categoria'] as String,
      tipo: json['tipo'] as String,
      url: json['url_contenido'] as String? ?? json['url'] as String?,
      urlContenido: json['url_contenido'] as String? ?? json['url'] as String?,
      thumbnailUrl: json['url_imagen'] as String? ?? json['thumbnailUrl'] as String?,
      imagenUrl: json['url_imagen'] as String? ?? json['imagenUrl'] as String?,
      duracion: json['duracion_minutos'] as int? ?? json['duracion'] as int?,
      nivel: json['nivel'] as String? ?? 'basico',
      etiquetas: json['tags'] != null ? List<String>.from(json['tags']) :
                (json['etiquetas'] != null ? List<String>.from(json['etiquetas']) : []),
      activo: json['activo'] as bool? ?? true,
      favorito: json['favorito'] as bool? ?? false,
      fechaPublicacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : (json['fechaCreacion'] != null ? DateTime.parse(json['fechaCreacion'] as String) : DateTime.now()),
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : (json['fechaPublicacion'] != null ? DateTime.parse(json['fechaPublicacion'] as String) : DateTime.now()),
      semanaGestacionInicio: json['semana_gestacion_inicio'] as int? ?? json['semanaGestacionInicio'] as int?,
      semanaGestacionFin: json['semana_gestacion_fin'] as int? ?? json['semanaGestacionFin'] as int?,
      progreso: json['progreso'] != null
          ? ProgresoUsuarioModel.fromJson(json['progreso'] as Map<String, dynamic>)
          : null,
      isAvailableOffline: json['isAvailableOffline'] as bool? ?? false,
      createdAt: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : DateTime.now(),
      updatedAt: json['fecha_actualizacion'] != null
          ? DateTime.parse(json['fecha_actualizacion'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'tipo': tipo,
      'url_contenido': urlContenido ?? url,
      'url_imagen': imagenUrl ?? thumbnailUrl,
      'duracion_minutos': duracion,
      'nivel': nivel,
      'tags': etiquetas,
      'activo': activo,
      'favorito': favorito,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': updatedAt.toIso8601String(),
      'semana_gestacion_inicio': semanaGestacionInicio,
      'semana_gestacion_fin': semanaGestacionFin,
      'progreso': progreso?.toJson(),
      'isAvailableOffline': isAvailableOffline,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Contenido toEntity() {
    return Contenido(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      categoria: CategoriaContenido.fromString(categoria),
      tipo: TipoContenido.fromString(tipo),
      url: url,
      thumbnailUrl: thumbnailUrl,
      duracion: duracion,
      nivel: NivelDificultad.fromString(nivel),
      etiquetas: etiquetas,
      activo: activo,
      favorito: favorito,
      fechaPublicacion: fechaPublicacion,
      semanaGestacionInicio: semanaGestacionInicio,
      semanaGestacionFin: semanaGestacionFin,
      progreso: progreso?.toEntity(),
      isAvailableOffline: isAvailableOffline,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ContenidoModel.fromEntity(Contenido contenido) {
    return ContenidoModel(
      id: contenido.id,
      titulo: contenido.titulo,
      descripcion: contenido.descripcion,
      categoria: contenido.categoria.value,
      tipo: contenido.tipo.value,
      url: contenido.url,
      urlContenido: contenido.url,
      thumbnailUrl: contenido.thumbnailUrl,
      imagenUrl: contenido.thumbnailUrl,
      duracion: contenido.duracion,
      nivel: contenido.nivel.value,
      etiquetas: contenido.etiquetas,
      activo: contenido.activo,
      favorito: contenido.favorito,
      fechaPublicacion: contenido.fechaPublicacion,
      fechaCreacion: contenido.fechaPublicacion,
      semanaGestacionInicio: contenido.semanaGestacionInicio,
      semanaGestacionFin: contenido.semanaGestacionFin,
      progreso: contenido.progreso != null
          ? ProgresoUsuarioModel.fromEntity(contenido.progreso!)
          : null,
      isAvailableOffline: contenido.isAvailableOffline,
      createdAt: contenido.createdAt,
      updatedAt: contenido.updatedAt,
    );
  }

  ContenidoModel copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? categoria,
    String? tipo,
    String? url,
    String? urlContenido,
    String? thumbnailUrl,
    String? imagenUrl,
    int? duracion,
    String? nivel,
    List<String>? etiquetas,
    bool? activo,
    bool? favorito,
    DateTime? fechaPublicacion,
    DateTime? fechaCreacion,
    int? semanaGestacionInicio,
    int? semanaGestacionFin,
    ProgresoUsuarioModel? progreso,
    bool? isAvailableOffline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContenidoModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      tipo: tipo ?? this.tipo,
      url: url ?? this.url,
      urlContenido: urlContenido ?? this.urlContenido,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      duracion: duracion ?? this.duracion,
      nivel: nivel ?? this.nivel,
      etiquetas: etiquetas ?? this.etiquetas,
      activo: activo ?? this.activo,
      favorito: favorito ?? this.favorito,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      semanaGestacionInicio: semanaGestacionInicio ?? this.semanaGestacionInicio,
      semanaGestacionFin: semanaGestacionFin ?? this.semanaGestacionFin,
      progreso: progreso ?? this.progreso,
      isAvailableOffline: isAvailableOffline ?? this.isAvailableOffline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, titulo, descripcion, categoria, tipo, url, urlContenido, thumbnailUrl, imagenUrl,
        duracion, nivel, etiquetas, activo, favorito, fechaPublicacion, fechaCreacion,
        semanaGestacionInicio, semanaGestacionFin, progreso,
        isAvailableOffline, createdAt, updatedAt,
      ];
}

class ProgresoUsuarioModel extends Equatable {
  final String id;
  final String contenidoId;
  final String usuarioId;
  final int tiempoVisualizado;
  final double porcentaje;
  final bool estaCompletado;
  final DateTime? fechaCompletado;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProgresoUsuarioModel({
    required this.id,
    required this.contenidoId,
    required this.usuarioId,
    required this.tiempoVisualizado,
    required this.porcentaje,
    required this.estaCompletado,
    this.fechaCompletado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProgresoUsuarioModel.fromJson(Map<String, dynamic> json) {
    return ProgresoUsuarioModel(
      id: json['id'] as String,
      contenidoId: json['contenidoId'] as String,
      usuarioId: json['usuarioId'] as String,
      tiempoVisualizado: json['tiempoVisualizado'] as int,
      porcentaje: json['porcentaje'] as double,
      estaCompletado: json['estaCompletado'] as bool,
      fechaCompletado: json['fechaCompletado'] != null 
          ? DateTime.parse(json['fechaCompletado'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contenidoId': contenidoId,
      'usuarioId': usuarioId,
      'tiempoVisualizado': tiempoVisualizado,
      'porcentaje': porcentaje,
      'estaCompletado': estaCompletado,
      'fechaCompletado': fechaCompletado?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProgresoUsuario toEntity() {
    return ProgresoUsuario(
      id: id,
      contenidoId: contenidoId,
      usuarioId: usuarioId,
      tiempoVisualizado: tiempoVisualizado,
      porcentaje: porcentaje,
      estaCompletado: estaCompletado,
      fechaCompletado: fechaCompletado,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProgresoUsuarioModel.fromEntity(ProgresoUsuario progreso) {
    return ProgresoUsuarioModel(
      id: progreso.id,
      contenidoId: progreso.contenidoId,
      usuarioId: progreso.usuarioId,
      tiempoVisualizado: progreso.tiempoVisualizado,
      porcentaje: progreso.porcentaje,
      estaCompletado: progreso.estaCompletado,
      fechaCompletado: progreso.fechaCompletado,
      createdAt: progreso.createdAt,
      updatedAt: progreso.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, contenidoId, usuarioId, tiempoVisualizado, porcentaje,
        estaCompletado, fechaCompletado, createdAt, updatedAt,
      ];
}