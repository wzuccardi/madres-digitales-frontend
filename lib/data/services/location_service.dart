import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  
  // Configuración de ubicación
  static const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // metros
  );
  
  /// Verifica si los servicios de ubicación están habilitados
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  /// Verifica el estado de los permisos de ubicación
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }
  
  /// Solicita permisos de ubicación
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission;
  }
  
  /// Obtiene la ubicación actual del usuario
  Future<Position?> getCurrentLocation() async {
    try {
      AppLogger.debug('LocationService: Iniciando obtención de ubicación actual');
      
      // Verificar si el servicio está habilitado
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.error('LocationService: Los servicios de ubicación están deshabilitados');
        throw const ConfigurationError('Los servicios de ubicación están deshabilitados');
      }
      
      // Verificar permisos
      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        AppLogger.warning('LocationService: Permisos de ubicación denegados, solicitando permisos');
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          AppLogger.error('LocationService: Permisos de ubicación denegados por el usuario');
          throw const PermissionError('Permisos de ubicación denegados');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        AppLogger.error('LocationService: Permisos de ubicación denegados permanentemente');
        throw const PermissionError('Permisos de ubicación denegados permanentemente');
      }
      
      // Obtener ubicación
      AppLogger.debug('LocationService: Obteniendo posición actual con alta precisión');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      AppLogger.info('LocationService: Ubicación obtenida exitosamente: Lat=${position.latitude}, Lng=${position.longitude}');
      return position;
    } on ConfigurationError catch (e) {
      AppLogger.error('LocationService: Error de servicio deshabilitado: ${e.message}');
      rethrow;
    } on PermissionError catch (e) {
      AppLogger.error('LocationService: Error de permisos: ${e.message}');
      rethrow;
    } catch (e) {
      AppLogger.error('LocationService: Error inesperado obteniendo ubicación', error: e);
      throw UnknownError('Error inesperado al obtener ubicación: ${e.toString()}');
    }
  }
  
  /// Stream de ubicación en tiempo real
  Stream<Position> getLocationStream() {
    try {
      AppLogger.debug('LocationService: Iniciando stream de ubicación en tiempo real');
      return Geolocator.getPositionStream(
        locationSettings: locationSettings,
      );
    } catch (e) {
      AppLogger.error('LocationService: Error iniciando stream de ubicación', error: e);
      return Stream.error(UnknownError('Error al iniciar stream de ubicación: ${e.toString()}'));
    }
  }
  
  /// Calcula la distancia entre dos puntos en metros
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    try {
      final distance = Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
      AppLogger.debug('LocationService: Distancia calculada: ${distance.toStringAsFixed(2)} metros');
      return distance;
    } catch (e) {
      AppLogger.error('LocationService: Error calculando distancia', error: e);
      return 0.0;
    }
  }
  
  /// Verifica si una ubicación está dentro de un radio específico
  bool isWithinRadius(
    Position userLocation,
    double targetLatitude,
    double targetLongitude,
    double radiusInMeters,
  ) {
    try {
      final distance = calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        targetLatitude,
        targetLongitude,
      );
      
      final isWithin = distance <= radiusInMeters;
      AppLogger.debug('LocationService: Verificación de radio: ${distance.toStringAsFixed(2)}m <= ${radiusInMeters}m = $isWithin');
      return isWithin;
    } catch (e) {
      AppLogger.error('LocationService: Error verificando radio', error: e);
      return false;
    }
  }
  
  /// Abre la configuración de ubicación del dispositivo
  Future<void> openLocationSettings() async {
    try {
      AppLogger.info('LocationService: Abriendo configuración de ubicación del dispositivo');
      await Geolocator.openLocationSettings();
      AppLogger.debug('LocationService: Configuración de ubicación abierta exitosamente');
    } catch (e) {
      AppLogger.error('LocationService: Error abriendo configuración de ubicación', error: e);
      throw UnknownError('Error al abrir configuración de ubicación: ${e.toString()}');
    }
  }
  
  /// Abre la configuración de la aplicación
  Future<void> openAppSettings() async {
    try {
      AppLogger.info('LocationService: Abriendo configuración de la aplicación');
      await Geolocator.openAppSettings();
      AppLogger.debug('LocationService: Configuración de aplicación abierta exitosamente');
    } catch (e) {
      AppLogger.error('LocationService: Error abriendo configuración de aplicación', error: e);
      throw UnknownError('Error al abrir configuración de aplicación: ${e.toString()}');
    }
  }
  
  /// Verifica si la ubicación está disponible y los permisos están otorgados
  Future<LocationStatus> getLocationStatus() async {
    try {
      AppLogger.debug('LocationService: Verificando estado de ubicación y permisos');
      
      bool serviceEnabled = await isLocationServiceEnabled();
      LocationPermission permission = await checkLocationPermission();
      
      if (!serviceEnabled) {
        AppLogger.warning('LocationService: Servicio de ubicación deshabilitado');
        return LocationStatus.serviceDisabled;
      }
      
      LocationStatus status;
      switch (permission) {
        case LocationPermission.denied:
          AppLogger.warning('LocationService: Permisos de ubicación denegados');
          status = LocationStatus.permissionDenied;
          break;
        case LocationPermission.deniedForever:
          AppLogger.error('LocationService: Permisos de ubicación denegados permanentemente');
          status = LocationStatus.permissionDeniedForever;
          break;
        case LocationPermission.whileInUse:
        case LocationPermission.always:
          AppLogger.debug('LocationService: Permisos de ubicación otorgados');
          status = LocationStatus.available;
          break;
        default:
          AppLogger.warning('LocationService: Estado de permisos desconocido');
          status = LocationStatus.unknown;
          break;
      }
      
      AppLogger.debug('LocationService: Estado de ubicación: $status');
      return status;
    } catch (e) {
      AppLogger.error('LocationService: Error verificando estado de ubicación', error: e);
      return LocationStatus.unknown;
    }
  }
  
  /// Obtiene la dirección aproximada basada en coordenadas
  /// Nota: Para geocoding reverso completo, se necesitaría una API adicional
  String getApproximateAddress(double latitude, double longitude) {
    try {
      final address = 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
      AppLogger.debug('LocationService: Dirección aproximada generada: $address');
      return address;
    } catch (e) {
      AppLogger.error('LocationService: Error generando dirección aproximada', error: e);
      return 'Dirección no disponible';
    }
  }
}

enum LocationStatus {
  available,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unknown,
}

class LocationData {
  
  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
    this.address,
  });
  
  factory LocationData.fromPosition(Position position, {String? address}) {
    try {
      AppLogger.debug('LocationService: Creando LocationData desde Position');
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
        address: address,
      );
    } catch (e) {
      AppLogger.error('LocationService: Error creando LocationData desde Position', error: e);
      rethrow;
    }
  }
  
  factory LocationData.fromJson(Map<String, dynamic> json) {
    try {
      AppLogger.debug('LocationService: Creando LocationData desde JSON');
      return LocationData(
        latitude: json['latitude']?.toDouble() ?? 0.0,
        longitude: json['longitude']?.toDouble() ?? 0.0,
        accuracy: json['accuracy']?.toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
        address: json['address'],
      );
    } catch (e) {
      AppLogger.error('LocationService: Error creando LocationData desde JSON', error: e);
      rethrow;
    }
  }
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;
  final String? address;
  
  Map<String, dynamic> toJson() {
    try {
      final data = {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': timestamp.toIso8601String(),
        'address': address,
      };
      AppLogger.debug('LocationService: LocationData serializado a JSON');
      return data;
    } catch (e) {
      AppLogger.error('LocationService: Error serializando LocationData a JSON', error: e);
      rethrow;
    }
  }
}
