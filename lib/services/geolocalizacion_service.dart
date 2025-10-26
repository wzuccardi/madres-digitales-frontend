import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../models/geolocalizacion.dart';
import 'logger_service.dart';

/// Servicio de geolocalización
class GeolocalizacionService {
  static final GeolocalizacionService _instance = GeolocalizacionService._internal();
  factory GeolocalizacionService() => _instance;
  GeolocalizacionService._internal();

  final _logger = LoggerService();
  Dio? _dio;

  /// Inicializar servicio
  void initialize(Dio dio) {
    _dio = dio;
  }

  /// Obtener ubicación actual del dispositivo
  Future<PuntoGeo?> obtenerUbicacionActual() async {
    try {
      // Verificar permisos
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.warning('Servicio de ubicación deshabilitado');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _logger.warning('Permiso de ubicación denegado');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.error('Permiso de ubicación denegado permanentemente');
        return null;
      }

      // Obtener posición
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _logger.info('Ubicación obtenida', data: {
        'lat': position.latitude,
        'lon': position.longitude,
      });

      return PuntoGeo(
        coordinates: [position.longitude, position.latitude],
      );
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo ubicación', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Buscar entidades cercanas
  Future<List<EntidadCercana>> buscarCercanos({
    required double latitud,
    required double longitud,
    double radio = 10,
    String tipo = 'todos',
    int limit = 20,
  }) async {
    try {
      final response = await _dio!.get(
        '/geolocalizacion/cercanos',
        queryParameters: {
          'latitud': latitud,
          'longitud': longitud,
          'radio': radio,
          'tipo': tipo,
          'limit': limit,
        },
      );

      final entidades = (response.data['data'] as List)
          .map((e) => EntidadCercana.fromJson(e))
          .toList();

      _logger.info('Entidades cercanas encontradas', data: {'count': entidades.length});

      return entidades;
    } catch (e, stackTrace) {
      _logger.error('Error buscando entidades cercanas', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Calcular ruta entre dos puntos
  Future<RutaCalculada> calcularRuta({
    required PuntoGeo origen,
    required PuntoGeo destino,
    bool optimizar = true,
    bool evitarPeajes = false,
  }) async {
    try {
      final response = await _dio!.post(
        '/geolocalizacion/ruta',
        data: {
          'origen': origen.toJson(),
          'destino': destino.toJson(),
          'optimizar': optimizar,
          'evitarPeajes': evitarPeajes,
        },
      );

      final ruta = RutaCalculada.fromJson(response.data['data']);

      _logger.info('Ruta calculada', data: {
        'distancia': ruta.distancia,
        'duracion': ruta.duracion,
      });

      return ruta;
    } catch (e, stackTrace) {
      _logger.error('Error calculando ruta', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Calcular ruta múltiple optimizada
  Future<RutaMultipleCalculada> calcularRutaMultiple({
    required PuntoGeo origen,
    required List<PuntoGeo> destinos,
    bool optimizar = true,
    bool retornarAlOrigen = false,
  }) async {
    try {
      final response = await _dio!.post(
        '/geolocalizacion/ruta-multiple',
        data: {
          'origen': origen.toJson(),
          'destinos': destinos.map((d) => d.toJson()).toList(),
          'optimizar': optimizar,
          'retornarAlOrigen': retornarAlOrigen,
        },
      );

      final ruta = RutaMultipleCalculada.fromJson(response.data['data']);

      _logger.info('Ruta múltiple calculada', data: {
        'distanciaTotal': ruta.distanciaTotal,
        'duracionTotal': ruta.duracionTotal,
        'paradas': destinos.length,
      });

      return ruta;
    } catch (e, stackTrace) {
      _logger.error('Error calculando ruta múltiple', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Crear zona de cobertura
  Future<ZonaCobertura> crearZonaCobertura({
    required String nombre,
    String? descripcion,
    required String madrinaId,
    required String municipioId,
    required Poligono poligono,
    String? color,
    bool activo = true,
  }) async {
    try {
      final response = await _dio!.post(
        '/geolocalizacion/zonas',
        data: {
          'nombre': nombre,
          'descripcion': descripcion,
          'madrinaId': madrinaId,
          'municipioId': municipioId,
          'poligono': poligono.toJson(),
          'color': color,
          'activo': activo,
        },
      );

      final zona = ZonaCobertura.fromJson(response.data['data']);

      _logger.info('Zona de cobertura creada', data: {'id': zona.id});

      return zona;
    } catch (e, stackTrace) {
      _logger.error('Error creando zona de cobertura', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtener zonas de cobertura
  Future<List<ZonaCobertura>> obtenerZonasCobertura({String? municipioId}) async {
    try {
      final response = await _dio!.get(
        '/geolocalizacion/zonas',
        queryParameters: {
          if (municipioId != null) 'municipioId': municipioId,
        },
      );

      final zonas = (response.data['data'] as List)
          .map((z) => ZonaCobertura.fromJson(z))
          .toList();

      _logger.info('Zonas de cobertura obtenidas', data: {'count': zonas.length});

      return zonas;
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo zonas de cobertura', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtener estadísticas de geolocalización
  Future<EstadisticasGeolocalizacion> obtenerEstadisticas() async {
    try {
      final response = await _dio!.get('/geolocalizacion/estadisticas');
      return EstadisticasGeolocalizacion.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo estadísticas', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtener heatmap
  Future<MapaHeatmap> obtenerHeatmap({
    required String tipo,
    String? municipioId,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      final response = await _dio!.get(
        '/geolocalizacion/heatmap',
        queryParameters: {
          'tipo': tipo,
          if (municipioId != null) 'municipioId': municipioId,
          if (fechaInicio != null) 'fechaInicio': fechaInicio,
          if (fechaFin != null) 'fechaFin': fechaFin,
        },
      );

      return MapaHeatmap.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo heatmap', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Calcular distancia entre dos puntos (Haversine)
  double calcularDistancia(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km
  }

  /// Verificar si el servicio de ubicación está habilitado
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Verificar permisos de ubicación
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Solicitar permisos de ubicación
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Abrir configuración de ubicación
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Stream de ubicación en tiempo real
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // metros
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}

