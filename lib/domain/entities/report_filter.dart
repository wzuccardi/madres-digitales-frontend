import 'package:equatable/equatable.dart';

enum FilterType {
  texto,
  numero,
  fecha,
  seleccion,
  multipleSeleccion,
  booleano,
}

enum ComparisonOperator {
  igual,
  diferente,
  mayorQue,
  menorQue,
  mayorIgualQue,
  menorIgualQue,
  contiene,
  noContiene,
  empiezaCon,
  terminaEn,
  entre,
}

class ReportFilter extends Equatable {

  const ReportFilter({
    required this.nombre,
    required this.etiqueta,
    required this.tipo,
    this.valorPorDefecto,
    this.requerido = false,
    this.opciones,
    this.operadorComparacion,
    this.descripcion,
  });

  factory ReportFilter.fromMap(Map<String, dynamic> map) {
    return ReportFilter(
      nombre: map['nombre'],
      etiqueta: map['etiqueta'],
      tipo: FilterType.values.firstWhere(
        (type) => type.toString() == map['tipo'],
        orElse: () => FilterType.texto,
      ),
      valorPorDefecto: map['valorPorDefecto'],
      requerido: map['requerido'] ?? false,
      opciones: map['opciones'],
      operadorComparacion: map['operadorComparacion'] != null
          ? ComparisonOperator.values.firstWhere(
              (op) => op.toString() == map['operadorComparacion'],
              orElse: () => ComparisonOperator.igual,
            )
          : null,
      descripcion: map['descripcion'],
    );
  }
  final String nombre;
  final String etiqueta;
  final FilterType tipo;
  final dynamic valorPorDefecto;
  final bool requerido;
  final List<dynamic>? opciones;
  final ComparisonOperator? operadorComparacion;
  final String? descripcion;

  ReportFilter copyWith({
    String? nombre,
    String? etiqueta,
    FilterType? tipo,
    dynamic valorPorDefecto,
    bool? requerido,
    List<dynamic>? opciones,
    ComparisonOperator? operadorComparacion,
    String? descripcion,
  }) {
    return ReportFilter(
      nombre: nombre ?? this.nombre,
      etiqueta: etiqueta ?? this.etiqueta,
      tipo: tipo ?? this.tipo,
      valorPorDefecto: valorPorDefecto ?? this.valorPorDefecto,
      requerido: requerido ?? this.requerido,
      opciones: opciones ?? this.opciones,
      operadorComparacion: operadorComparacion ?? this.operadorComparacion,
      descripcion: descripcion ?? this.descripcion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'etiqueta': etiqueta,
      'tipo': tipo.toString(),
      'valorPorDefecto': valorPorDefecto,
      'requerido': requerido,
      'opciones': opciones,
      'operadorComparacion': operadorComparacion?.toString(),
      'descripcion': descripcion,
    };
  }

  @override
  List<Object?> get props => [
        nombre,
        etiqueta,
        tipo,
        valorPorDefecto,
        requerido,
        opciones,
        operadorComparacion,
        descripcion,
      ];

  @override
  String toString() {
    return 'ReportFilter{nombre: $nombre, etiqueta: $etiqueta, tipo: $tipo}';
  }
}
