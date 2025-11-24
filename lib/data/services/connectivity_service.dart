import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio de conectividad
class ConnectivityService {
  
  ConnectivityService() : _connectivity = Connectivity();
  final Connectivity _connectivity;
  
  /// Verificar conexión a internet
  Future<bool> get isConnected async {
    try {
      AppLogger.debug('ConnectivityService: Verificando conexión a internet');
      final result = await _connectivity.checkConnectivity();
      // checkConnectivity() retorna ConnectivityResult (versión antigua)
      final isConnected = result != ConnectivityResult.none;
      
      AppLogger.debug('ConnectivityService: Estado de conexión: $isConnected ($result)');
      return isConnected;
    } catch (e) {
      AppLogger.error('ConnectivityService: Error verificando conexión', error: e);
      return false;
    }
  }
  
  /// Obtener stream de cambios de conectividad
  Stream<ConnectivityResult> get connectivityStream {
    try {
      AppLogger.debug('ConnectivityService: Obteniendo stream de cambios de conectividad');
      // connectivity_plus retorna Stream<ConnectivityResult> (versión antigua)
      return _connectivity.onConnectivityChanged;
    } catch (e) {
      AppLogger.error('ConnectivityService: Error obteniendo stream de conectividad', error: e);
      return Stream.value(ConnectivityResult.none);
    }
  }
  
  /// Verificar si hay conexión WiFi
  Future<bool> get isWifiConnected async {
    try {
      AppLogger.debug('ConnectivityService: Verificando conexión WiFi');
      final result = await _connectivity.checkConnectivity();
      final isWifiConnected = result == ConnectivityResult.wifi;
      
      AppLogger.debug('ConnectivityService: Estado de conexión WiFi: $isWifiConnected');
      return isWifiConnected;
    } catch (e) {
      AppLogger.error('ConnectivityService: Error verificando conexión WiFi', error: e);
      return false;
    }
  }
  
  /// Verificar si hay conexión móvil
  Future<bool> get isMobileConnected async {
    try {
      AppLogger.debug('ConnectivityService: Verificando conexión móvil');
      final result = await _connectivity.checkConnectivity();
      final isMobileConnected = result == ConnectivityResult.mobile;
      
      AppLogger.debug('ConnectivityService: Estado de conexión móvil: $isMobileConnected');
      return isMobileConnected;
    } catch (e) {
      AppLogger.error('ConnectivityService: Error verificando conexión móvil', error: e);
      return false;
    }
  }
}
