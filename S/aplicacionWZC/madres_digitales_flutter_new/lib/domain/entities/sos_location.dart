import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sos_location.g.dart';

@JsonSerializable()
class SOSLocation extends Equatable {

  const SOSLocation({
    required this.id,
    required this.alertaId,
    required this.latitud,
    required this.longitud,
    this.precision,
    this.direccion,
    this.barrio,
    this.municipio,
    this.departamento,
    required this.fechaRegistro,
    required this.metadata,
  });

  factory SOSLocation.fromJson(Map<String, dynamic> json) {
    return SOSLocation(
      id: json['id'] ?? '',
      alertaId: json['alertaId'] ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      precision: (json['precision'] as num?)?.toDouble(),
      direccion: json['direccion'],
      barrio: json['barrio'],
      municipio: json['municipio'],
      departamento: json['departamento'],
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'])
          : DateTime.now(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
  final String id;
  final String alertaId;
  final double latitud;
  final double longitud;
  final double? precision;
  final String? direccion;
  final String? barrio;
  final String? municipio;
  final String? departamento;
  final DateTime fechaRegistro;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => _$SOSLocationToJson(this);

  SOSLocation copyWith({
    String? id,
    String? alertaId,
    double? latitud,
    double? longitud,
    double? precision,
    String? direccion,
    String? barrio,
    String? municipio,
    String? departamento,
    DateTime? fechaRegistro,
    Map<String, dynamic>? metadata,
  }) {
    return SOSLocation(
      id: id ?? this.id,
      alertaId: alertaId ?? this.alertaId,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      precision: precision ?? this.precision,
      direccion: direccion ?? this.direccion,
      barrio: barrio ?? this.barrio,
      municipio: municipio ?? this.municipio,
      departamento: departamento ?? this.departamento,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        alertaId,
        latitud,
        longitud,
        precision,
        direccion,
        barrio,
        municipio,
        departamento,
        fechaRegistro,
        metadata,
      ];

  // Getters útiles
  String get coordenadas => '$latitud, $longitud';
  
  String get direccionCompleta {
    final partes = <String>[];
    if (direccion != null && direccion!.isNotEmpty) partes.add(direccion!);
    if (barrio != null && barrio!.isNotEmpty) partes.add(barrio!);
    if (municipio != null && municipio!.isNotEmpty) partes.add(municipio!);
    if (departamento != null && departamento!.isNotEmpty) partes.add(departamento!);
    
    return partes.join(', ');
  }

  bool get tienePrecision => precision != null && precision! > 0;
  
  String get precisionFormateada {
    if (!tienePrecision) return 'Desconocida';
    return '${precision!.toStringAsFixed(1)}m';
  }

  // Métodos estáticos para crear ubicaciones de prueba
  static SOSLocation testLocation({
    String id = 'test-location-id',
    String alertaId = 'test-alert-id',
    double latitud = 4.5709,
    double longitud = -74.2973,
    double? precision,
    String? direccion,
    String? barrio,
    String? municipio,
    String? departamento,
    DateTime? fechaRegistro,
    Map<String, dynamic>? metadata,
  }) {
    return SOSLocation(
      id: id,
      alertaId: alertaId,
      latitud: latitud,
      longitud: longitud,
      precision: precision ?? 10.0,
      direccion: direccion,
      barrio: barrio,
      municipio: municipio,
      departamento: departamento,
      fechaRegistro: fechaRegistro ?? DateTime.now(),
      metadata: metadata ?? {},
    );
  }

  static List<SOSLocation> testLocations() {
    final now = DateTime.now();
    return [
      SOSLocation.testLocation(
        id: 'loc-001',
        alertaId: 'sos-001',
        latitud: 4.6097,
        longitud: -74.0817,
        precision: 5.2,
        direccion: 'Calle 72 #45-30',
        barrio: 'Chapinero',
        municipio: 'Bogotá',
        departamento: 'Cundinamarca',
        fechaRegistro: now.subtract(const Duration(minutes: 5)),
      ),
      SOSLocation.testLocation(
        id: 'loc-002',
        alertaId: 'sos-002',
        latitud: 4.6486,
        longitud: -74.0785,
        precision: 8.7,
        direccion: 'Carrera 15 #23-10',
        barrio: 'Usaquén',
        municipio: 'Bogotá',
        departamento: 'Cundinamarca',
        fechaRegistro: now.subtract(const Duration(minutes: 15)),
      ),
      SOSLocation.testLocation(
        id: 'loc-003',
        alertaId: 'sos-003',
        latitud: 4.5981,
        longitud: -74.0760,
        precision: 3.1,
        direccion: 'Avenida 68 #90-25',
        barrio: 'Santa Bárbara',
        municipio: 'Bogotá',
        departamento: 'Cundinamarca',
        fechaRegistro: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }
}
