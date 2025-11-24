import 'package:madres_digitales_flutter_new/core/utils/logger.dart';

abstract class FirebaseBootImpl {
  static Future<void> init() async {
    AppLogger.info('Firebase deshabilitado temporalmente para build web');
  }
}