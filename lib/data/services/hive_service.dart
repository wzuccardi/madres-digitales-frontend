import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:hive/hive.dart';

/// Servicio de Hive para caché local
class HiveService {
  /// Abrir una caja de Hive
  Future<Box<T>> openBox<T>(String key) async {
    try {
      AppLogger.debug('HiveService: Abriendo caja con clave $key');
      return await Hive.openBox<T>(key);
    } catch (e) {
      AppLogger.error('HiveService: Error abriendo caja', error: e);
      rethrow;
    }
  }
  
  /// Cerrar todas las cajas de Hive
  Future<void> closeAllBoxes() async {
    try {
      AppLogger.debug('HiveService: Cerrando todas las cajas');
      await Hive.close();
      AppLogger.debug('HiveService: Cajas cerradas correctamente');
    } catch (e) {
      AppLogger.error('HiveService: Error cerrando cajas', error: e);
      rethrow;
    }
  }
}
