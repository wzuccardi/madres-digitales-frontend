import 'package:latlong2/latlong.dart';

/// Punto geográfico
class PuntoGeo {
  final String type;
  final List<double> coordinates; // [longitud, latitud]

  PuntoGeo({
    this.type = 'Point',
    required this.coordinates,
  });

  factory PuntoGeo.fromJson(Map<String, dynamic> json) {
    return PuntoGeo(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  double get longitud => coordinates[0];
  double get latitud => coordinates[1];
  
  LatLng get latLng => LatLng(latitud, longitud);
}

/// Entidad cercana
class EntidadCercana {
  final String id;
  final String tipo; // gestante, ips, madrina
  final String nombre;
  final PuntoGeo ubicacion;
  final double distancia; // en km
  final String? direccion;
  final String? telefono;
  final Map<String, dynamic>? metadata;

  EntidadCercana({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.ubicacion,
    required this.distancia,
    this.direccion,
    this.telefono,
    this.metadata,
  });

  factory EntidadCercana.fromJson(Map<String, dynamic> json) {
    return EntidadCercana(
      id: json['id'],
      tipo: json['tipo'],
      nombre: json['nombre'],
      ubicacion: PuntoGeo.fromJson(json['ubicacion']),
      distancia: (json['distancia'] as num).toDouble(),
      direccion: json['direccion'],
      telefono: json['telefono'],
      metadata: json['metadata'],
    );
  }

  String get distanciaFormateada {
    if (distancia < 1) {
      return '${(distancia * 1000).toStringAsFixed(0)} m';
    }
    return '${distancia.toStringAsFixed(2)} km';
  }
}

/// Ruta calculada
class RutaCalculada {
  final double distancia; // en km
  final double duracion; // en minutos
  final List<PuntoGeo> puntos;
  final List<String>? instrucciones;
  final Map<String, dynamic>? metadata;

  RutaCalculada({
    required this.distancia,
    required this.duracion,
    required this.puntos,
    this.instrucciones,
    this.metadata,
  });

  factory RutaCalculada.fromJson(Map<String, dynamic> json) {
    return RutaCalculada(
      distancia: (json['distancia'] as num).toDouble(),
      duracion: (json['duracion'] as num).toDouble(),
      puntos: (json['puntos'] as List)
          .map((p) => PuntoGeo.fromJson(p))
          .toList(),
      instrucciones: json['instrucciones'] != null
          ? List<String>.from(json['instrucciones'])
          : null,
      metadata: json['metadata'],
    );
  }

  String get distanciaFormateada => '${distancia.toStringAsFixed(2)} km';
  
  String get duracionFormateada {
    if (duracion < 60) {
      return '${duracion.toStringAsFixed(0)} min';
    }
    final horas = duracion ~/ 60;
    final minutos = (duracion % 60).toStringAsFixed(0);
    return '${horas}h ${minutos}min';
  }

  List<LatLng> get latLngs => puntos.map((p) => p.latLng).toList();
}

/// Ruta múltiple calculada
class RutaMultipleCalculada {
  final double distanciaTotal;
  final double duracionTotal;
  final List<int> orden;
  final List<RutaCalculada> rutas;

  RutaMultipleCalculada({
    required this.distanciaTotal,
    required this.duracionTotal,
    required this.orden,
    required this.rutas,
  });

  factory RutaMultipleCalculada.fromJson(Map<String, dynamic> json) {
    return RutaMultipleCalculada(
      distanciaTotal: (json['distanciaTotal'] as num).toDouble(),
      duracionTotal: (json['duracionTotal'] as num).toDouble(),
      orden: List<int>.from(json['orden']),
      rutas: (json['rutas'] as List)
          .map((r) => RutaCalculada.fromJson(r))
          .toList(),
    );
  }

  String get distanciaFormateada => '${distanciaTotal.toStringAsFixed(2)} km';
  
  String get duracionFormateada {
    if (duracionTotal < 60) {
      return '${duracionTotal.toStringAsFixed(0)} min';
    }
    final horas = duracionTotal ~/ 60;
    final minutos = (duracionTotal % 60).toStringAsFixed(0);
    return '${horas}h ${minutos}min';
  }
}

/// Zona de cobertura
class ZonaCobertura {
  final String id;
  final String nombre;
  final String? descripcion;
  final String madrinaId;
  final String? madrinaNombre;
  final String municipioId;
  final String? municipioNombre;
  final Poligono poligono;
  final String? color;
  final bool activo;
  final int? gestantesEnZona;
  final DateTime createdAt;
  final DateTime updatedAt;

  ZonaCobertura({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.madrinaId,
    this.madrinaNombre,
    required this.municipioId,
    this.municipioNombre,
    required this.poligono,
    this.color,
    required this.activo,
    this.gestantesEnZona,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ZonaCobertura.fromJson(Map<String, dynamic> json) {
    return ZonaCobertura(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      madrinaId: json['madrinaId'],
      madrinaNombre: json['madrinaNombre'],
      municipioId: json['municipioId'],
      municipioNombre: json['municipioNombre'],
      poligono: Poligono.fromJson(json['poligono']),
      color: json['color'],
      activo: json['activo'] ?? true,
      gestantesEnZona: json['gestantesEnZona'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'madrinaId': madrinaId,
      'municipioId': municipioId,
      'poligono': poligono.toJson(),
      'color': color,
      'activo': activo,
    };
  }
}

/// Polígono
class Poligono {
  final String type;
  final List<List<List<double>>> coordinates;

  Poligono({
    this.type = 'Polygon',
    required this.coordinates,
  });

  factory Poligono.fromJson(Map<String, dynamic> json) {
    return Poligono(
      type: json['type'] ?? 'Polygon',
      coordinates: (json['coordinates'] as List)
          .map((ring) => (ring as List)
              .map((point) => List<double>.from(point))
              .toList())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  List<LatLng> get latLngs {
    if (coordinates.isEmpty || coordinates[0].isEmpty) return [];
    return coordinates[0].map((point) => LatLng(point[1], point[0])).toList();
  }
}

/// Estadísticas de geolocalización
class EstadisticasGeolocalizacion {
  final int totalGestantes;
  final int gestantesConUbicacion;
  final int gestantesSinUbicacion;
  final int totalIPS;
  final int ipsConUbicacion;
  final int totalZonasCobertura;
  final int zonasActivas;
  final double distanciaPromedioIPS;
  final double coberturaPorcentaje;

  EstadisticasGeolocalizacion({
    required this.totalGestantes,
    required this.gestantesConUbicacion,
    required this.gestantesSinUbicacion,
    required this.totalIPS,
    required this.ipsConUbicacion,
    required this.totalZonasCobertura,
    required this.zonasActivas,
    required this.distanciaPromedioIPS,
    required this.coberturaPorcentaje,
  });

  factory EstadisticasGeolocalizacion.fromJson(Map<String, dynamic> json) {
    return EstadisticasGeolocalizacion(
      totalGestantes: json['totalGestantes'] ?? 0,
      gestantesConUbicacion: json['gestantesConUbicacion'] ?? 0,
      gestantesSinUbicacion: json['gestantesSinUbicacion'] ?? 0,
      totalIPS: json['totalIPS'] ?? 0,
      ipsConUbicacion: json['ipsConUbicacion'] ?? 0,
      totalZonasCobertura: json['totalZonasCobertura'] ?? 0,
      zonasActivas: json['zonasActivas'] ?? 0,
      distanciaPromedioIPS: (json['distanciaPromedioIPS'] ?? 0).toDouble(),
      coberturaPorcentaje: (json['coberturaPorcentaje'] ?? 0).toDouble(),
    );
  }
}

/// Punto de heatmap
class PuntoHeatmap {
  final double latitud;
  final double longitud;
  final double peso;

  PuntoHeatmap({
    required this.latitud,
    required this.longitud,
    required this.peso,
  });

  factory PuntoHeatmap.fromJson(Map<String, dynamic> json) {
    return PuntoHeatmap(
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      peso: (json['peso'] as num).toDouble(),
    );
  }

  LatLng get latLng => LatLng(latitud, longitud);
}

/// Mapa heatmap
class MapaHeatmap {
  final List<PuntoHeatmap> puntos;
  final PuntoGeo centro;
  final int zoom;

  MapaHeatmap({
    required this.puntos,
    required this.centro,
    required this.zoom,
  });

  factory MapaHeatmap.fromJson(Map<String, dynamic> json) {
    return MapaHeatmap(
      puntos: (json['puntos'] as List)
          .map((p) => PuntoHeatmap.fromJson(p))
          .toList(),
      centro: PuntoGeo.fromJson(json['centro']),
      zoom: json['zoom'] ?? 10,
    );
  }
}

