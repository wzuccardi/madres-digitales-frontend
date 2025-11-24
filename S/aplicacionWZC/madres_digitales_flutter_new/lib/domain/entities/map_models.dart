import 'package:latlong2/latlong.dart';

class PuntoGeo {
  const PuntoGeo(this.lat, this.lng);
  final double lat;
  final double lng;
  LatLng get latLng => LatLng(lat, lng);
  double get latitud => lat;
  double get longitud => lng;
  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };
}

class EntidadCercana {
  factory EntidadCercana.fromJson(Map<String, dynamic> json) {
    return EntidadCercana(
      id: (json['id'] ?? '').toString(),
      tipo: (json['tipo'] ?? '').toString(),
      ubicacion: PuntoGeo(
        (json['lat'] ?? json['latitud'] ?? 0).toDouble(),
        (json['lng'] ?? json['longitud'] ?? 0).toDouble(),
      ),
      nombre: json['nombre']?.toString(),
      direccion: json['direccion']?.toString(),
      telefono: json['telefono']?.toString(),
      distanciaKm: (json['distancia'] ?? json['distanciaKm'])?.toDouble(),
    );
  }
  const EntidadCercana({
    required this.id,
    required this.tipo,
    required this.ubicacion,
    this.nombre,
    this.direccion,
    this.telefono,
    this.distanciaKm,
  });
  final String id;
  final String tipo;
  final PuntoGeo ubicacion;
  final String? nombre;
  final String? direccion;
  final String? telefono;
  final double? distanciaKm;
  String get distanciaFormateada => distanciaKm == null ? '-' : '${distanciaKm!.toStringAsFixed(2)} km';
}

class ZonaCobertura {
  factory ZonaCobertura.fromJson(Map<String, dynamic> json) {
    final puntos = (json['poligono'] as List?)
            ?.map((e) => LatLng((e['lat'] ?? 0).toDouble(), (e['lng'] ?? 0).toDouble()))
            .toList() ??
        <LatLng>[];
    return ZonaCobertura(
      id: (json['id'] ?? '').toString(),
      poligono: puntos,
      color: json['color']?.toString(),
    );
  }
  const ZonaCobertura({required this.id, this.poligono, this.color});
  final String id;
  final List<LatLng>? poligono;
  final String? color;
}

class RutaCalculada {
  factory RutaCalculada.fromJson(Map<String, dynamic> json) {
    final pts = (json['puntos'] as List?)
            ?.map((e) => PuntoGeo((e['lat'] ?? 0).toDouble(), (e['lng'] ?? 0).toDouble()))
            .toList() ??
        <PuntoGeo>[];
    return RutaCalculada(
      puntos: pts,
      distancia: (json['distancia'] ?? json['distanciaKm'])?.toDouble(),
      duracion: (json['duracion'] ?? 0)?.toDouble(),
    );
  }
  const RutaCalculada({required this.puntos, this.distancia, this.duracion});
  final List<PuntoGeo> puntos;
  final double? distancia; // km
  final double? duracion; // minutos
  List<LatLng> get latLngs => puntos.map((p) => p.latLng).toList();
  String get distanciaFormateada => distancia == null ? '-' : '${distancia!.toStringAsFixed(2)} km';
  String get duracionFormateada {
    if (duracion == null) return '-';
    final m = duracion!.round();
    final h = m ~/ 60;
    final mm = m % 60;
    return h > 0 ? '${h}h ${mm}m' : '${mm}m';
  }
}

class Poligono {
  const Poligono(this.puntos);
  final List<LatLng> puntos;
  Map<String, dynamic> toJson() => {
        'puntos': puntos.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      };
}

class RutaMultipleCalculada {
  factory RutaMultipleCalculada.fromJson(Map<String, dynamic> json) {
    return RutaMultipleCalculada(
      distanciaTotal: (json['distanciaTotal'] ?? 0).toDouble(),
      duracionTotal: (json['duracionTotal'] ?? 0).toDouble(),
    );
  }
  const RutaMultipleCalculada({required this.distanciaTotal, required this.duracionTotal});
  final double distanciaTotal;
  final double duracionTotal;
}

class EstadisticasGeolocalizacion {
  factory EstadisticasGeolocalizacion.fromJson(Map<String, dynamic> json) {
    return EstadisticasGeolocalizacion(
      totalZonas: (json['totalZonas'] ?? 0) as int,
      totalEntidades: (json['totalEntidades'] ?? 0) as int,
    );
  }
  const EstadisticasGeolocalizacion({required this.totalZonas, required this.totalEntidades});
  final int totalZonas;
  final int totalEntidades;
}

class MapaHeatmap {
  factory MapaHeatmap.fromJson(Map<String, dynamic> json) {
    final pts = (json['puntos'] as List?)?.map((e) {
      final lat = (e['lat'] ?? 0).toDouble();
      final lng = (e['lng'] ?? 0).toDouble();
      return PuntoGeo(lat, lng);
    }).toList() ?? <PuntoGeo>[];
    return MapaHeatmap(puntos: pts);
  }
  const MapaHeatmap({required this.puntos});
  final List<PuntoGeo> puntos;
}