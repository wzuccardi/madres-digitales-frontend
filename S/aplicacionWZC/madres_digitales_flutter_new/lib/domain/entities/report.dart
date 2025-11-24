enum ReportType {
  gestantes,
  controles,
  alertas,
  actividadMadrinas,
  consolidadoMensual,
  consolidadoAnual,
  personalizado,
}

enum ReportFormat { pdf, excel, csv, txt }

class Report {

  Report({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.formato,
    this.gestanteId,
    this.medicoId,
    this.ipsId,
    required this.fechaGeneracion,
    required this.generadoPor,
    required this.parametros,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    final tipoStr = (json['tipo'] ?? '').toString();
    final formatoStr = (json['formato'] ?? 'pdf').toString();

    ReportType parseTipo(String v) {
      switch (v) {
        case 'gestantes':
          return ReportType.gestantes;
        case 'controles':
          return ReportType.controles;
        case 'alertas':
          return ReportType.alertas;
        case 'actividadMadrinas':
          return ReportType.actividadMadrinas;
        case 'consolidadoMensual':
          return ReportType.consolidadoMensual;
        case 'consolidadoAnual':
          return ReportType.consolidadoAnual;
        case 'personalizado':
          return ReportType.personalizado;
        default:
          return ReportType.personalizado;
      }
    }

    ReportFormat parseFormato(String v) {
      switch (v) {
        case 'pdf':
          return ReportFormat.pdf;
        case 'excel':
          return ReportFormat.excel;
        case 'csv':
          return ReportFormat.csv;
        case 'txt':
          return ReportFormat.txt;
        default:
          return ReportFormat.pdf;
      }
    }

    return Report(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      tipo: parseTipo(tipoStr),
      formato: parseFormato(formatoStr),
      gestanteId: json['gestanteId']?.toString(),
      medicoId: json['medicoId']?.toString(),
      ipsId: json['ipsId']?.toString(),
      fechaGeneracion: json['fechaGeneracion'] != null
          ? DateTime.parse(json['fechaGeneracion'].toString())
          : DateTime.now(),
      generadoPor: json['generadoPor']?.toString() ?? 'sistema',
      parametros: (json['parametros'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }
  final String id;
  final String titulo;
  final String descripcion;
  final ReportType tipo;
  final ReportFormat formato;
  final String? gestanteId;
  final String? medicoId;
  final String? ipsId;
  final DateTime fechaGeneracion;
  final String generadoPor;
  final Map<String, dynamic> parametros;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo.name,
      'formato': formato.name,
      'gestanteId': gestanteId,
      'medicoId': medicoId,
      'ipsId': ipsId,
      'fechaGeneracion': fechaGeneracion.toIso8601String(),
      'generadoPor': generadoPor,
      'parametros': parametros,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Report copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    ReportType? tipo,
    ReportFormat? formato,
    String? gestanteId,
    String? medicoId,
    String? ipsId,
    DateTime? fechaGeneracion,
    String? generadoPor,
    Map<String, dynamic>? parametros,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      formato: formato ?? this.formato,
      gestanteId: gestanteId ?? this.gestanteId,
      medicoId: medicoId ?? this.medicoId,
      ipsId: ipsId ?? this.ipsId,
      fechaGeneracion: fechaGeneracion ?? this.fechaGeneracion,
      generadoPor: generadoPor ?? this.generadoPor,
      parametros: parametros ?? this.parametros,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Report &&
        other.id == id &&
        other.titulo == titulo &&
        other.descripcion == descripcion &&
        other.tipo == tipo &&
        other.formato == formato;
  }

  @override
  int get hashCode {
    return id.hashCode ^ titulo.hashCode ^ descripcion.hashCode ^ tipo.hashCode ^ formato.hashCode;
  }

  @override
  String toString() {
    return 'Report(id: $id, titulo: $titulo, tipo: ${tipo.name}, formato: ${formato.name})';
  }

  String get tipoDisplay {
    switch (tipo) {
      case ReportType.gestantes:
        return 'Gestantes';
      case ReportType.controles:
        return 'Controles Prenatales';
      case ReportType.alertas:
        return 'Alertas';
      case ReportType.actividadMadrinas:
        return 'Actividad de Madrinas';
      case ReportType.consolidadoMensual:
        return 'Consolidado Mensual';
      case ReportType.consolidadoAnual:
        return 'Consolidado Anual';
      case ReportType.personalizado:
        return 'Personalizado';
    }
  }

  String get formatoDisplay {
    switch (formato) {
      case ReportFormat.pdf:
        return 'PDF';
      case ReportFormat.excel:
        return 'Excel';
      case ReportFormat.csv:
        return 'CSV';
      case ReportFormat.txt:
        return 'TXT';
    }
  }

  String get formattedFechaGeneracion =>
      '${fechaGeneracion.year}-${fechaGeneracion.month.toString().padLeft(2, '0')}-${fechaGeneracion.day.toString().padLeft(2, '0')}';
}
