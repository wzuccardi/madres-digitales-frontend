// lib/models/contenido_unificado.dart
import 'package:json_annotation/json_annotation.dart';

part 'contenido_unificado.g.dart'; // Importación del archivo generado

@JsonSerializable(fieldRename: FieldRename.snake)
class ContenidoUnificado {
  final String id;
  final String titulo;
  final String? descripcion;
  final String categoria;
  final String tipo; // Corresponde a 'tipo' del backend
  final String? urlContenido; // Corresponde a 'url_contenido' del backend
  final String? urlImagen; // Corresponde a 'url_imagen' del backend
  final int? duracionMinutos; // Corresponde a 'duracion_minutos' del backend
  final String? nivel; // Corresponde a 'nivel' del backend
  final List<String>? tags; // Corresponde a 'tags' del backend
  final DateTime fechaCreacion; // Corresponde a 'fecha_creacion' del backend
  final DateTime fechaActualizacion; // Corresponde a 'fecha_actualizacion' del backend
  final bool activo; // Corresponde a 'activo' del backend
  final bool destacado; // Corresponde a 'destacado' del backend
  final bool? destacadoEnSemanaGestacion; // Corresponde a 'destacadoEnSemanaGestacion' del backend
  final int? semanaGestacionInicio; // Corresponde a 'semana_gestacion_inicio' del backend
  final int? semanaGestacionFin; // Corresponde a 'semana_gestacion_fin' del backend
  final String? urlVideo; // Corresponde a 'url_video' del backend
  final String? archivo; // Corresponde a 'archivo' del backend
  
  // Getters para compatibilidad con el código existente
  String get tipoContenido => tipo;
  String? get archivoUrl => urlContenido;
  String? get miniaturaUrl => urlImagen;
  String? get nivelDificultad => nivel;
  DateTime get createdAt => fechaCreacion;
  DateTime get updatedAt => fechaActualizacion;
  List<String>? get etiquetas => tags;
  int? get duracion => duracionMinutos;
  bool get publico => activo;

  ContenidoUnificado({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.categoria,
    required this.tipo,
    this.urlContenido,
    this.urlImagen,
    this.duracionMinutos,
    this.nivel,
    this.tags,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    required this.activo,
    this.destacado = false,
    this.destacadoEnSemanaGestacion,
    this.semanaGestacionInicio,
    this.semanaGestacionFin,
    this.urlVideo,
    this.archivo,
  });

  // Método para convertir de Map<String, dynamic> a ContenidoUnificado
  factory ContenidoUnificado.fromJson(Map<String, dynamic> json) {
    final contenido = _$ContenidoUnificadoFromJson(json);
    
    // Asegurarnos de que el campo 'archivo' se incluya si es necesario
    if (json.containsKey('archivo')) {
      // Crear una copia para poder añadir el campo
      final jsonConArchivo = Map<String, dynamic>.from(json);
      jsonConArchivo['archivo'] = json['archivo'];
      return _$ContenidoUnificadoFromJson(jsonConArchivo);
    }
    
    return contenido;
  }

  // Método para convertir de ContenidoUnificado a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    final json = _$ContenidoUnificadoToJson(this);
    
    // Asegurarnos de que el campo 'archivo' se incluya si es necesario
    if (archivo != null) {
      json['archivo'] = archivo;
    }
    
    return json;
  }

  // Método de conveniencia para crear una copia con nuevos valores
  ContenidoUnificado copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? categoria,
    String? tipo,
    String? urlContenido,
    String? urlImagen,
    int? duracionMinutos,
    String? nivel,
    List<String>? tags,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    bool? activo,
    bool? destacado,
    bool? destacadoEnSemanaGestacion,
    int? semanaGestacionInicio,
    int? semanaGestacionFin,
    String? urlVideo,
    String? archivo,
  }) {
    return ContenidoUnificado(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      tipo: tipo ?? this.tipo,
      urlContenido: urlContenido ?? this.urlContenido,
      urlImagen: urlImagen ?? this.urlImagen,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      nivel: nivel ?? this.nivel,
      tags: tags ?? this.tags,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      activo: activo ?? this.activo,
      destacado: destacado ?? this.destacado,
      destacadoEnSemanaGestacion: destacadoEnSemanaGestacion ?? this.destacadoEnSemanaGestacion,
      semanaGestacionInicio: semanaGestacionInicio ?? this.semanaGestacionInicio,
      semanaGestacionFin: semanaGestacionFin ?? this.semanaGestacionFin,
      urlVideo: urlVideo ?? this.urlVideo,
      archivo: archivo ?? this.archivo,
    );
  }

  @override
  String toString() {
    return 'ContenidoUnificado(id: $id, titulo: $titulo, categoria: $categoria, tipo: $tipo, archivo: $archivo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ContenidoUnificado &&
      other.id == id &&
      other.titulo == titulo &&
      other.descripcion == descripcion &&
      other.categoria == categoria &&
      other.tipo == tipo &&
      other.urlContenido == urlContenido &&
      other.urlImagen == urlImagen &&
      other.duracionMinutos == duracionMinutos &&
      other.nivel == nivel &&
      other.tags == tags &&
      other.fechaCreacion == fechaCreacion &&
      other.fechaActualizacion == fechaActualizacion &&
      other.activo == activo &&
      other.destacado == destacado &&
      other.destacadoEnSemanaGestacion == destacadoEnSemanaGestacion &&
      other.semanaGestacionInicio == semanaGestacionInicio &&
      other.semanaGestacionFin == semanaGestacionFin &&
      other.urlVideo == urlVideo &&
      other.archivo == archivo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        titulo.hashCode ^
        descripcion.hashCode ^
        categoria.hashCode ^
        tipo.hashCode ^
        urlContenido.hashCode ^
        urlImagen.hashCode ^
        duracionMinutos.hashCode ^
        nivel.hashCode ^
        tags.hashCode ^
        fechaCreacion.hashCode ^
        fechaActualizacion.hashCode ^
        activo.hashCode ^
        destacado.hashCode ^
        destacadoEnSemanaGestacion.hashCode ^
        semanaGestacionInicio.hashCode ^
        semanaGestacionFin.hashCode ^
        urlVideo.hashCode ^
        archivo.hashCode;
  }
}