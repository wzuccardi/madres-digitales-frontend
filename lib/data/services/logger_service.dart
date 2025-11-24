import 'package:madres_digitales_flutter_new/core/utils/logger.dart';

class LoggerService {
  void info(String message, {Object? data, StackTrace? stackTrace}) => AppLogger.info(message);
  void error(String message, {Object? error, StackTrace? stackTrace}) => AppLogger.error(message);
  void warn(String message, {Object? data, StackTrace? stackTrace}) => AppLogger.warning(message);
  void warning(String message, {Object? data, StackTrace? stackTrace}) => AppLogger.warning(message);
  void debug(String message, {Object? data, StackTrace? stackTrace}) => AppLogger.debug(message);
}