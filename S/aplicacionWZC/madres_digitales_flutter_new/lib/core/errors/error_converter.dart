import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';

class ErrorConverter {
  static AppError convert(Object e) {
    return UnknownError(e.toString());
  }
}