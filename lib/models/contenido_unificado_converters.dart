// lib/models/contenido_unificado_converters.dart
import 'package:madres_digitales_flutter_new/models/contenido_unificado.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/models/contenido_model.dart' as ContenidoModelAlias;

/// Convertidores entre ContenidoUnificado y otros modelos de contenido
class ContenidoUnificadoConverters {
  
  /// Convertir desde ContenidoModel (alias) a ContenidoUnificado
  static ContenidoUnificado fromContenidoModelAlias(ContenidoModelAlias.ContenidoModel model) {
    return ContenidoUnificado(
      id: model.id,
      titulo: model.titulo,
      descripcion: model.descripcion ?? '', // Corrección: descripcion es nullable
      categoria: model.categoria,
      tipo: model.tipo, // Corrección: usar 'tipo' en lugar de 'tipoContenido'
      urlContenido: model.url, // Mapear 'url' a 'urlContenido'
      urlImagen: model.imagenUrl, // Corrección: usar 'urlImagen' en lugar de 'imagenUrl'
      duracionMinutos: model.duracion, // Corrección: usar 'duracionMinutos'
      nivel: model.nivel, // Corrección: usar 'nivel' en lugar de 'nivelDificultad'
      tags: model.etiquetas, // Corrección: usar 'tags' en lugar de 'etiquetas'
      fechaCreacion: model.createdAt, // Mapear 'createdAt' a 'fechaCreacion'
      fechaActualizacion: model.updatedAt, // Corrección: usar 'fechaActualizacion' en lugar de 'updatedAt'
      activo: model.activo,
    );
  }
  
  /// Convertir desde ContenidoUnificado a ContenidoModel (alias)
  static ContenidoModelAlias.ContenidoModel toContenidoModelAlias(ContenidoUnificado unificado) {
    return ContenidoModelAlias.ContenidoModel(
      id: unificado.id,
      titulo: unificado.titulo,
      descripcion: unificado.descripcion ?? '', // Corrección: descripcion es nullable
      categoria: unificado.categoria,
      tipo: unificado.tipo, // Corrección: usar 'tipo' en lugar de 'tipoContenido'
      url: unificado.urlContenido, // Mapear 'urlContenido' a 'url'
      urlContenido: unificado.urlContenido,
      thumbnailUrl: unificado.urlImagen, // Corrección: usar 'urlImagen' en lugar de 'imagenUrl'
      imagenUrl: unificado.urlImagen, // Corrección: usar 'urlImagen' en lugar de 'imagenUrl'
      duracion: unificado.duracionMinutos, // Corrección: usar 'duracionMinutos'
      nivel: unificado.nivel ?? 'basico', // Corrección: usar 'nivel' en lugar de 'nivelDificultad'
      etiquetas: unificado.tags ?? [], // Corrección: usar 'tags' en lugar de 'etiquetas'
      activo: unificado.activo,
      favorito: false, // Valor por defecto
      fechaPublicacion: unificado.fechaCreacion, // Mapear 'fechaCreacion' a 'fechaPublicacion'
      fechaCreacion: unificado.fechaCreacion,
      createdAt: unificado.fechaCreacion,
      updatedAt: unificado.fechaActualizacion, // Corrección: usar 'fechaActualizacion'
    );
  }
  
  /// Convertir desde Map<String, dynamic> a ContenidoUnificado
  static ContenidoUnificado fromJson(Map<String, dynamic> json) {
    return ContenidoUnificado(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? '',
      tipo: json['tipo'] ?? json['tipoContenido'] ?? '', // Corrección: usar 'tipo' en lugar de 'tipoContenido'
      urlContenido: json['urlContenido'] ?? json['url'], // Manejar ambos nombres
      urlImagen: json['urlImagen'] ?? json['imagenUrl'], // Corrección: usar 'urlImagen' en lugar de 'imagenUrl'
      duracionMinutos: json['duracion_minutos'] as int?, // Corrección: usar 'duracionMinutos'
      nivel: json['nivel'] as String?, // Corrección: usar 'nivel' en lugar de 'nivelDificultad'
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(), // Corrección: usar 'tags' en lugar de 'etiquetas'
      fechaCreacion: _parseDateTime(json['fecha_creacion'] ?? json['fechaCreacion'] ?? json['createdAt'] ?? json['created_at']),
      fechaActualizacion: _parseDateTime(json['fecha_actualizacion'] ?? json['updatedAt'] ?? json['updated_at']), // Corrección: usar 'fechaActualizacion'
      activo: json['activo'] as bool? ?? true,
    );
  }
  
  /// Convertir desde ContenidoUnificado a Map<String, dynamic>
  static Map<String, dynamic> toJson(ContenidoUnificado unificado) {
    return {
      'id': unificado.id,
      'titulo': unificado.titulo,
      'descripcion': unificado.descripcion,
      'categoria': unificado.categoria,
      'tipo': unificado.tipo, // Corrección: usar 'tipo' en lugar de 'tipoContenido'
      'urlContenido': unificado.urlContenido,
      'urlImagen': unificado.urlImagen, // Corrección: usar 'urlImagen' en lugar de 'imagenUrl'
      'duracionMinutos': unificado.duracionMinutos, // Corrección: usar 'duracionMinutos'
      'nivel': unificado.nivel, // Corrección: usar 'nivel' en lugar de 'nivelDificultad'
      'tags': unificado.tags, // Corrección: usar 'tags' en lugar de 'etiquetas'
      'fechaCreacion': unificado.fechaCreacion.toIso8601String(),
      'fechaActualizacion': unificado.fechaActualizacion.toIso8601String(), // Corrección: usar 'fechaActualizacion'
      'activo': unificado.activo,
    };
  }
  
  /// Parsear DateTime desde diferentes formatos
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    
    if (value is DateTime) return value;
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        // Si no se puede parsear, devolver fecha actual
        return DateTime.now();
      }
    }
    
    // Si es un timestamp (int)
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return DateTime.now();
  }
  
  /// Convertir lista de ContenidoModel (alias) a lista de ContenidoUnificado
  static List<ContenidoUnificado> fromListContenidoModelAlias(List<ContenidoModelAlias.ContenidoModel> models) {
    return models.map((model) => fromContenidoModelAlias(model)).toList();
  }
  
  /// Convertir lista de ContenidoUnificado a lista de ContenidoModel (alias)
  static List<ContenidoModelAlias.ContenidoModel> toListContenidoModelAlias(List<ContenidoUnificado> unificados) {
    return unificados.map((unificado) => toContenidoModelAlias(unificado)).toList();
  }
  
  /// Convertir lista de Map<String, dynamic> a lista de ContenidoUnificado
  static List<ContenidoUnificado> fromListJson(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
  
  /// Convertir lista de ContenidoUnificado a lista de Map<String, dynamic>
  static List<Map<String, dynamic>> toListJson(List<ContenidoUnificado> unificados) {
    return unificados.map((unificado) => toJson(unificado)).toList();
  }
}