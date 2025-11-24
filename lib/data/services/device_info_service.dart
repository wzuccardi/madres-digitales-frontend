import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'dart:io' show Platform;

/// Servicio de información del dispositivo
class DeviceInfoService {
  DeviceInfoService();
  
  /// Obtener información del dispositivo Android
  Future<Map<String, dynamic>?> getAndroidDeviceInfo() async {
    try {
      AppLogger.debug('DeviceInfoService: Obteniendo información del dispositivo Android');
      if (!Platform.isAndroid) return null;
      // Información mínima disponible sin dependencias externas
      AppLogger.debug('DeviceInfoService: Información mínima de Android disponible');
      return {
        'platform': 'android',
      };
    } catch (e) {
      AppLogger.error('DeviceInfoService: Error obteniendo información del dispositivo Android', error: e);
      return null;
    }
  }
  
  /// Obtener información del dispositivo iOS
  Future<Map<String, dynamic>?> getIosDeviceInfo() async {
    try {
      AppLogger.debug('DeviceInfoService: Obteniendo información del dispositivo iOS');
      if (!Platform.isIOS) return null;
      AppLogger.debug('DeviceInfoService: Información mínima de iOS disponible');
      return {
        'platform': 'ios',
      };
    } catch (e) {
      AppLogger.error('DeviceInfoService: Error obteniendo información del dispositivo iOS', error: e);
      return null;
    }
  }
  
  /// Obtener información general del dispositivo
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      AppLogger.debug('DeviceInfoService: Obteniendo información general del dispositivo');
      if (Platform.isAndroid) {
        return {'platform': 'android'};
      }
      if (Platform.isIOS) {
        return {'platform': 'ios'};
      }
      if (Platform.isWindows) {
        return {'platform': 'windows'};
      }
      if (Platform.isMacOS) {
        return {'platform': 'macos'};
      }
      if (Platform.isLinux) {
        return {'platform': 'linux'};
      }
      return {'platform': 'unknown'};
    } catch (e) {
      AppLogger.error('DeviceInfoService: Error obteniendo información general del dispositivo', error: e);
      return {};
    }
  }
}
