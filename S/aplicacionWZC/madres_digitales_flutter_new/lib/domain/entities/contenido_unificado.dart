
class ContenidoUnificado {
  
  const ContenidoUnificado({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.tipo,
    this.urlArchivo,
    this.urlThumbnail,
    this.tamanoArchivo,
    this.duracionSegundos = 0,
    this.gestanteId,
    this.creadoPor,
    required this.fechaCreacion,
    this.fechaModificacion,
    this.activo = true,
    this.esPublico = false,
    this.etiquetas = const [],
    this.metadatos = const {},
  });
  
  factory ContenidoUnificado.fromJson(Map<String, dynamic> json) {
    return ContenidoUnificado(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      categoria: json['categoria'] as String,
      tipo: contenidoTipoFromString(json['tipo'] as String),
      urlArchivo: json['urlArchivo'] as String?,
      urlThumbnail: json['urlThumbnail'] as String?,
      tamanoArchivo: json['tamanoArchivo'] as int?,
      duracionSegundos: json['duracionSegundos'] as int? ?? 0,
      gestanteId: json['gestanteId'] as String?,
      creadoPor: json['creadoPor'] as String?,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaModificacion: json['fechaModificacion'] != null 
          ? DateTime.parse(json['fechaModificacion']) 
          : null,
      activo: json['activo'] as bool? ?? true,
      esPublico: json['esPublico'] as bool? ?? false,
      etiquetas: (json['etiquetas'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      metadatos: json['metadatos'] as Map<String, dynamic>? ?? {},
    );
  }
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final ContenidoTipo tipo;
  final String? urlArchivo;
  final String? urlThumbnail;
  final int? tamanoArchivo;
  final int duracionSegundos;
  final String? gestanteId;
  final String? creadoPor;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;
  final bool activo;
  final bool esPublico;
  final List<String> etiquetas;
  final Map<String, dynamic> metadatos;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'tipo': tipo.toString().split('.').last,
      'urlArchivo': urlArchivo,
      'urlThumbnail': urlThumbnail,
      'tamanoArchivo': tamanoArchivo,
      'duracionSegundos': duracionSegundos,
      'gestanteId': gestanteId,
      'creadoPor': creadoPor,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaModificacion': fechaModificacion?.toIso8601String(),
      'activo': activo,
      'esPublico': esPublico,
      'etiquetas': etiquetas,
      'metadatos': metadatos,
    };
  }
  
  ContenidoUnificado copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? categoria,
    ContenidoTipo? tipo,
    String? urlArchivo,
    String? urlThumbnail,
    int? tamanoArchivo,
    int? duracionSegundos,
    String? gestanteId,
    String? creadoPor,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    bool? activo,
    bool? esPublico,
    List<String>? etiquetas,
    Map<String, dynamic>? metadatos,
  }) {
    return ContenidoUnificado(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      tipo: tipo ?? this.tipo,
      urlArchivo: urlArchivo ?? this.urlArchivo,
      urlThumbnail: urlThumbnail ?? this.urlThumbnail,
      tamanoArchivo: tamanoArchivo ?? this.tamanoArchivo,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      gestanteId: gestanteId ?? this.gestanteId,
      creadoPor: creadoPor ?? this.creadoPor,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      activo: activo ?? this.activo,
      esPublico: esPublico ?? this.esPublico,
      etiquetas: etiquetas ?? this.etiquetas,
      metadatos: metadatos ?? this.metadatos,
    );
  }
  
  String get duracionFormateada {
    if (duracionSegundos == 0) return 'N/A';
    final horas = duracionSegundos ~/ 3600;
    final minutos = (duracionSegundos % 3600) ~/ 60;
    final segundos = duracionSegundos % 60;
    
    if (horas > 0) {
      return '${horas}h ${minutos}m ${segundos}s';
    } else if (minutos > 0) {
      return '${minutos}m ${segundos}s';
    } else {
      return '${segundos}s';
    }
  }
  
  String get tamanoFormateado {
    if (tamanoArchivo == null) return 'N/A';
    
    if (tamanoArchivo! < 1024) {
      return '${tamanoArchivo}B';
    } else if (tamanoArchivo! < 1024 * 1024) {
      return '${(tamanoArchivo! / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(tamanoArchivo! / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
  
  bool get esVideo => tipo == ContenidoTipo.video;
  bool get esAudio => tipo == ContenidoTipo.audio;
  bool get esImagen => tipo == ContenidoTipo.imagen;
  bool get esDocumento => tipo == ContenidoTipo.documento;
  bool get esTexto => tipo == ContenidoTipo.texto;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContenidoUnificado && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'ContenidoUnificado(id: $id, titulo: $titulo, tipo: $tipo, categoria: $categoria)';
  }
}

enum ContenidoTipo {
  video,
  audio,
  imagen,
  documento,
  texto,
}

ContenidoTipo contenidoTipoFromString(String value) {
  switch (value.toLowerCase()) {
    case 'video':
      return ContenidoTipo.video;
    case 'audio':
      return ContenidoTipo.audio;
    case 'imagen':
      return ContenidoTipo.imagen;
    case 'documento':
      return ContenidoTipo.documento;
    case 'texto':
      return ContenidoTipo.texto;
    default:
      throw ArgumentError('Unknown ContenidoTipo: $value');
  }
}