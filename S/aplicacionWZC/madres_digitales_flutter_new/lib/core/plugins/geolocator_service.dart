import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:geolocator/geolocator.dart';

/// Servicio de geolocalización
class GeolocatorService {
  
  GeolocatorService();
  
  /// Obtener posición actual
  Future<Position?> getCurrentPosition() async {
    try {
      AppLogger.debug('GeolocatorService: Obteniendo posición actual');
      
      // Verificar permisos
      final permissionStatus = await Geolocator.checkPermission();
      if (permissionStatus == LocationPermission.denied || permissionStatus == LocationPermission.deniedForever) {
        AppLogger.debug('GeolocatorService: Solicitando permisos de ubicación');
        final permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          AppLogger.error('GeolocatorService: Permisos de ubicación denegados');
          return null;
        }
      }
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      AppLogger.debug('GeolocatorService: Posición actual obtenida: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      AppLogger.error('GeolocatorService: Error obteniendo posición actual', error: e);
      return null;
    }
  }
  
  /// Obtener última posición conocida
  Future<Position?> getLastKnownPosition() async {
    try {
      AppLogger.debug('GeolocatorService: Obteniendo última posición conocida');
      final position = await Geolocator.getLastKnownPosition();
      
      AppLogger.debug('GeolocatorService: Última posición conocida: ${position?.latitude}, ${position?.longitude}');
      return position;
    } catch (e) {
      AppLogger.error('GeolocatorService: Error obteniendo última posición conocida', error: e);
      return null;
    }
  }
  
  /// Calcular distancia entre dos posiciones
  double calculateDistance(Position start, Position end) {
    try {
      AppLogger.debug('GeolocatorService: Calculando distancia entre posiciones');
      final distance = Geolocator.distanceBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
      AppLogger.debug('GeolocatorService: Distancia calculada: ${distance.toStringAsFixed(2)} metros');
      return distance;
    } catch (e) {
      AppLogger.error('GeolocatorService: Error calculando distancia', error: e);
      return 0;
    }
  }
  
  /// Verificar si el GPS está habilitado
  Future<bool> isLocationServiceEnabled() async {
    try {
      AppLogger.debug('GeolocatorService: Verificando si el GPS está habilitado');
      final isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      AppLogger.debug('GeolocatorService: GPS habilitado: $isLocationServiceEnabled');
      return isLocationServiceEnabled;
    } catch (e) {
      AppLogger.error('GeolocatorService: Error verificando si el GPS está habilitado', error: e);
      return false;
    }
  }
  
  /// Obtener stream de cambios de posición
  Stream<Position> getPositionStream() {
    try {
      AppLogger.debug('GeolocatorService: Obteniendo stream de cambios de posición');
      final positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );
      
      return positionStream;
    } catch (e) {
      AppLogger.error('GeolocatorService: Error obteniendo stream de cambios de posición', error: e);
      return const Stream.empty();
    }
  }
}
