import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'contenido_model.g.dart';

@JsonSerializable()
class ContenidoModel extends Equatable {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String tipoContenido;
  final String? urlContenido;
  final String? urlImagen;
  final String? urlVideo;
  final String? contenidoTexto;
  final int duracionMinutos;
  final String nivelDificultad;
  final List<String> etiquetas;
  final bool activo;
  final int orden;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const ContenidoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.tipoContenido,
    this.urlContenido,
    this.urlImagen,
    this.urlVideo,
    this.contenidoTexto,
    required this.duracionMinutos,
    required this.nivelDificultad,
    required this.etiquetas,
    required this.activo,
    required this.orden,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory ContenidoModel.fromJson(Map<String, dynamic> json) => _$ContenidoModelFromJson(json);
  Map<String, dynamic> toJson() => _$ContenidoModelToJson(this);
  
  bool get esVideo => tipoContenido == 'VIDEO' && urlVideo != null;
  bool get esArticulo => tipoContenido == 'ARTICULO';
  bool get esInfografia => tipoContenido == 'INFOGRAFIA';
  bool get esAudio => tipoContenido == 'AUDIO';
  
  String get duracionFormateada {
    if (duracionMinutos < 60) {
      return '$duracionMinutos min';
    } else {
      final horas = duracionMinutos ~/ 60;
      final minutos = duracionMinutos % 60;
      return minutos > 0 ? '${horas}h ${minutos}min' : '${horas}h';
    }
  }
  
  @override
  List<Object?> get props => [
    id,
    titulo,
    descripcion,
    categoria,
    tipoContenido,
    urlContenido,
    urlImagen,
    urlVideo,
    contenidoTexto,
    duracionMinutos,
    nivelDificultad,
    etiquetas,
    activo,
    orden,
    createdAt,
    updatedAt,
  ];
}

@JsonSerializable()
class ProgresoContenidoModel extends Equatable {
  final String id;
  final String usuarioId;
  final String contenidoId;
  final bool completado;
  final int porcentajeProgreso;
  final int tiempoVisualizacion;
  final DateTime? fechaCompletado;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relaciones
  final ContenidoModel? contenido;
  
  const ProgresoContenidoModel({
    required this.id,
    required this.usuarioId,
    required this.contenidoId,
    required this.completado,
    required this.porcentajeProgreso,
    required this.tiempoVisualizacion,
    this.fechaCompletado,
    required this.createdAt,
    required this.updatedAt,
    this.contenido,
  });
  
  factory ProgresoContenidoModel.fromJson(Map<String, dynamic> json) => _$ProgresoContenidoModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProgresoContenidoModelToJson(this);
  
  @override
  List<Object?> get props => [
    id,
    usuarioId,
    contenidoId,
    completado,
    porcentajeProgreso,
    tiempoVisualizacion,
    fechaCompletado,
    createdAt,
    updatedAt,
  ];
}

// Enums para categorías de contenido
enum CategoriaContenido {
  @JsonValue('EMBARAZO')
  embarazo,
  @JsonValue('PARTO')
  parto,
  @JsonValue('POSPARTO')
  posparto,
  @JsonValue('LACTANCIA')
  lactancia,
  @JsonValue('NUTRICION')
  nutricion,
  @JsonValue('EJERCICIO')
  ejercicio,
  @JsonValue('SALUD_MENTAL')
  saludMental,
  @JsonValue('CUIDADO_BEBE')
  cuidadoBebe,
  @JsonValue('PLANIFICACION_FAMILIAR')
  planificacionFamiliar,
  @JsonValue('EMERGENCIAS')
  emergencias,
}

// Enums para tipos de contenido
enum TipoContenido {
  @JsonValue('VIDEO')
  video,
  @JsonValue('ARTICULO')
  articulo,
  @JsonValue('INFOGRAFIA')
  infografia,
  @JsonValue('AUDIO')
  audio,
  @JsonValue('INTERACTIVO')
  interactivo,
}

// Enums para nivel de dificultad
enum NivelDificultad {
  @JsonValue('BASICO')
  basico,
  @JsonValue('INTERMEDIO')
  intermedio,
  @JsonValue('AVANZADO')
  avanzado,
}