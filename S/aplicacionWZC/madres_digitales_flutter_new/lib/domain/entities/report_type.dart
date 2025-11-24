import 'package:equatable/equatable.dart';
import 'report_filter.dart';

class ReportType extends Equatable {

  const ReportType({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.filtrosDisponibles,
    required this.formatosSoportados,
    this.requierePermisosEspeciales = false,
    this.permisoRequerido,
  });

  factory ReportType.fromMap(Map<String, dynamic> map) {
    return ReportType(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      filtrosDisponibles: (map['filtrosDisponibles'] as List<dynamic>?)
          ?.map((f) => ReportFilter.fromMap(f as Map<String, dynamic>))
          .toList() ?? [],
      formatosSoportados: List<String>.from(map['formatosSoportados'] ?? []),
      requierePermisosEspeciales: map['requierePermisosEspeciales'] ?? false,
      permisoRequerido: map['permisoRequerido'],
    );
  }
  final String id;
  final String nombre;
  final String descripcion;
  final List<ReportFilter> filtrosDisponibles;
  final List<String> formatosSoportados;
  final bool requierePermisosEspeciales;
  final String? permisoRequerido;

  ReportType copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    List<ReportFilter>? filtrosDisponibles,
    List<String>? formatosSoportados,
    bool? requierePermisosEspeciales,
    String? permisoRequerido,
  }) {
    return ReportType(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      filtrosDisponibles: filtrosDisponibles ?? this.filtrosDisponibles,
      formatosSoportados: formatosSoportados ?? this.formatosSoportados,
      requierePermisosEspeciales: requierePermisosEspeciales ?? this.requierePermisosEspeciales,
      permisoRequerido: permisoRequerido ?? this.permisoRequerido,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'filtrosDisponibles': filtrosDisponibles.map((f) => f.toMap()).toList(),
      'formatosSoportados': formatosSoportados,
      'requierePermisosEspeciales': requierePermisosEspeciales,
      'permisoRequerido': permisoRequerido,
    };
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        descripcion,
        filtrosDisponibles,
        formatosSoportados,
        requierePermisosEspeciales,
        permisoRequerido,
      ];

  @override
  String toString() {
    return 'ReportType{id: $id, nombre: $nombre}';
  }
}

// Tipos de reporte predefinidos
class ReportTypes {
  static const ReportType gestantes = ReportType(
    id: 'gestantes',
    nombre: 'Reporte de Gestantes',
    descripcion: 'Listado de gestantes con sus datos básicos y controles',
    filtrosDisponibles: [
      ReportFilter(
        nombre: 'municipio',
        etiqueta: 'Municipio',
        tipo: FilterType.seleccion,
        opciones: ['Bogotá', 'Medellín', 'Cali', 'Barranquilla'],
      ),
      ReportFilter(
        nombre: 'fechaInicio',
        etiqueta: 'Fecha Inicio',
        tipo: FilterType.fecha,
      ),
      ReportFilter(
        nombre: 'fechaFin',
        etiqueta: 'Fecha Fin',
        tipo: FilterType.fecha,
      ),
      ReportFilter(
        nombre: 'nivelRiesgo',
        etiqueta: 'Nivel de Riesgo',
        tipo: FilterType.seleccion,
        opciones: ['Bajo', 'Medio', 'Alto'],
      ),
    ],
    formatosSoportados: ['pdf', 'excel', 'csv'],
  );

  static const ReportType controles = ReportType(
    id: 'controles',
    nombre: 'Reporte de Controles Prenatales',
    descripcion: 'Listado de controles prenatales realizados',
    filtrosDisponibles: [
      ReportFilter(
        nombre: 'gestanteId',
        etiqueta: 'Gestante',
        tipo: FilterType.texto,
      ),
      ReportFilter(
        nombre: 'fechaInicio',
        etiqueta: 'Fecha Inicio',
        tipo: FilterType.fecha,
      ),
      ReportFilter(
        nombre: 'fechaFin',
        etiqueta: 'Fecha Fin',
        tipo: FilterType.fecha,
      ),
      ReportFilter(
        nombre: 'madrinaId',
        etiqueta: 'Madrina',
        tipo: FilterType.seleccion,
      ),
    ],
    formatosSoportados: ['pdf', 'excel', 'csv'],
  );

  static const ReportType alertas = ReportType(
    id: 'alertas',
    nombre: 'Reporte de Alertas',
    descripcion: 'Listado de alertas generadas en el sistema',
    filtrosDisponibles: [
      ReportFilter(
        nombre: 'gestanteId',
        etiqueta: 'Gestante',
        tipo: FilterType.texto,
      ),
      ReportFilter(
        nombre: 'fechaInicio',
        etiqueta: 'Fecha Inicio',
        tipo: FilterType.fecha,
      ),
      ReportFilter(
        nombre: 'fechaFin',
        etiqueta: 'Fecha Fin',
        tipo: FilterType.fecha,
      ),
      ReportFilter(
        nombre: 'tipoAlerta',
        etiqueta: 'Tipo de Alerta',
        tipo: FilterType.seleccion,
        opciones: ['Médica', 'Geográfica', 'SOS'],
      ),
      ReportFilter(
        nombre: 'estado',
        etiqueta: 'Estado',
        tipo: FilterType.seleccion,
        opciones: ['Activa', 'Atendida', 'Cancelada'],
      ),
    ],
    formatosSoportados: ['pdf', 'excel', 'csv'],
  );

  static const ReportType actividadMadrinas = ReportType(
    id: 'actividadMadrinas',
    nombre: 'Reporte de Actividad de Madrinas',
    descripcion: 'Estadísticas de actividad de las madrinas',
    filtrosDisponibles: [
      ReportFilter(
        nombre: 'madrinaId',
        etiqueta: 'Madrina',
        tipo: FilterType.seleccion,
      ),
      ReportFilter(
        nombre: 'fechaInicio',
        etiqueta: 'Fecha Inicio',
        tipo: FilterType.fecha,
      ),
      ReportFilter(
        nombre: 'fechaFin',
        etiqueta: 'Fecha Fin',
        tipo: FilterType.fecha,
      ),
    ],
    formatosSoportados: ['pdf', 'excel', 'csv'],
  );

  static const ReportType consolidadoMensual = ReportType(
    id: 'consolidadoMensual',
    nombre: 'Reporte Consolidado Mensual',
    descripcion: 'Resumen mensual de todas las actividades',
    filtrosDisponibles: [
      ReportFilter(
        nombre: 'mes',
        etiqueta: 'Mes',
        tipo: FilterType.seleccion,
        opciones: [
          'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
          'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
        ],
        requerido: true,
      ),
      ReportFilter(
        nombre: 'anio',
        etiqueta: 'Año',
        tipo: FilterType.numero,
        requerido: true,
      ),
    ],
    formatosSoportados: ['pdf', 'excel', 'csv'],
    requierePermisosEspeciales: true,
    permisoRequerido: 'ver_reportes_avanzados',
  );

  static const ReportType consolidadoAnual = ReportType(
    id: 'consolidadoAnual',
    nombre: 'Reporte Consolidado Anual',
    descripcion: 'Resumen anual de todas las actividades',
    filtrosDisponibles: [
      ReportFilter(
        nombre: 'anio',
        etiqueta: 'Año',
        tipo: FilterType.numero,
        requerido: true,
      ),
    ],
    formatosSoportados: ['pdf', 'excel', 'csv'],
    requierePermisosEspeciales: true,
    permisoRequerido: 'ver_reportes_avanzados',
  );

  static const ReportType personalizado = ReportType(
    id: 'personalizado',
    nombre: 'Reporte Personalizado',
    descripcion: 'Reporte con filtros personalizados',
    filtrosDisponibles: [
      ReportFilter(
        nombre: 'campos',
        etiqueta: 'Campos a incluir',
        tipo: FilterType.multipleSeleccion,
        opciones: [
          'ID Gestante', 'Nombre', 'Documento', 'Teléfono', 'Dirección',
          'Municipio', 'EPS', 'Fecha Último Control', 'Madrina Asignada'
        ],
      ),
    ],
    formatosSoportados: ['pdf', 'excel', 'csv', 'txt'],
    requierePermisosEspeciales: true,
    permisoRequerido: 'exportar_reportes',
  );

  static List<ReportType> get allTypes => [
        gestantes,
        controles,
        alertas,
        actividadMadrinas,
        consolidadoMensual,
        consolidadoAnual,
        personalizado,
      ];

  static ReportType? getById(String id) {
    try {
      return allTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }
}
