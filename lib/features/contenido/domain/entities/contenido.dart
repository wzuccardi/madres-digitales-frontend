import 'package:equatable/equatable.dart';

// Enum para categorías de contenido
enum CategoriaContenido {
  nutricion('nutricion'),
  ejercicio('ejercicio'),
  saludMental('salud_mental'),
  preparacionParto('preparacion_parto'),
  cuidadoBebe('cuidado_bebe'),
  lactancia('lactancia'),
  desarrolloInfantil('desarrollo_infantil'),
  seguridad('seguridad');

  const CategoriaContenido(this.value);
  final String value;

  static CategoriaContenido fromString(String value) {
    return CategoriaContenido.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CategoriaContenido.nutricion,
    );
  }
}

// Enum para tipos de contenido
enum TipoContenido {
  articulo('articulo'),
  video('video'),
  podcast('podcast'),
  infografia('infografia'),
  guia('guia'),
  curso('curso'),
  webinar('webinar'),
  evaluacion('evaluacion');

  const TipoContenido(this.value);
  final String value;

  static TipoContenido fromString(String value) {
    return TipoContenido.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoContenido.articulo,
    );
  }
}

// Enum para niveles de dificultad
enum NivelDificultad {
  basico('basico'),
  intermedio('intermedio'),
  avanzado('avanzado');

  const NivelDificultad(this.value);
  final String value;

  static NivelDificultad fromString(String value) {
    return NivelDificultad.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NivelDificultad.basico,
    );
  }
}

// Entidad de progreso de usuario
class ProgresoUsuario extends Equatable {
  final String id;
  final String contenidoId;
  final String usuarioId;
  final int tiempoVisualizado;
  final double porcentaje;
  final bool estaCompletado;
  final DateTime? fechaCompletado;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProgresoUsuario({
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

  ProgresoUsuario copyWith({
    String? id,
    String? contenidoId,
    String? usuarioId,
    int? tiempoVisualizado,
    double? porcentaje,
    bool? estaCompletado,
    DateTime? fechaCompletado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgresoUsuario(
      id: id ?? this.id,
      contenidoId: contenidoId ?? this.contenidoId,
      usuarioId: usuarioId ?? this.usuarioId,
      tiempoVisualizado: tiempoVisualizado ?? this.tiempoVisualizado,
      porcentaje: porcentaje ?? this.porcentaje,
      estaCompletado: estaCompletado ?? this.estaCompletado,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, contenidoId, usuarioId, tiempoVisualizado, porcentaje,
        estaCompletado, fechaCompletado, createdAt, updatedAt,
      ];
}

// Entidad principal de contenido
class Contenido extends Equatable {
  final String id;
  final String titulo;
  final String descripcion;
  final CategoriaContenido categoria;
  final TipoContenido tipo;
  final String? url;
  final String? thumbnailUrl;
  final int? duracion;
  final NivelDificultad nivel;
  final List<String> etiquetas;
  final bool activo;
  final bool favorito;
  final DateTime fechaPublicacion;
  final int? semanaGestacionInicio;
  final int? semanaGestacionFin;
  final ProgresoUsuario? progreso;
  final bool isAvailableOffline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Contenido({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.tipo,
    this.url,
    this.thumbnailUrl,
    this.duracion,
    required this.nivel,
    this.etiquetas = const [],
    this.activo = true,
    this.favorito = false,
    required this.fechaPublicacion,
    this.semanaGestacionInicio,
    this.semanaGestacionFin,
    this.progreso,
    this.isAvailableOffline = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Contenido copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    String? url,
    String? thumbnailUrl,
    int? duracion,
    NivelDificultad? nivel,
    List<String>? etiquetas,
    bool? activo,
    bool? favorito,
    DateTime? fechaPublicacion,
    int? semanaGestacionInicio,
    int? semanaGestacionFin,
    ProgresoUsuario? progreso,
    bool? isAvailableOffline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contenido(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      tipo: tipo ?? this.tipo,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duracion: duracion ?? this.duracion,
      nivel: nivel ?? this.nivel,
      etiquetas: etiquetas ?? this.etiquetas,
      activo: activo ?? this.activo,
      favorito: favorito ?? this.favorito,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
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
        id, titulo, descripcion, categoria, tipo, url, thumbnailUrl,
        duracion, nivel, etiquetas, activo, favorito, fechaPublicacion,
        semanaGestacionInicio, semanaGestacionFin, progreso,
        isAvailableOffline, createdAt, updatedAt,
      ];
}