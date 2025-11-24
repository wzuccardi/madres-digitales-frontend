import 'dart:async';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';

class NotificationService {
  NotificationService();

  Future<void> init() async {
    AppLogger.info('NotificationService(Web): Inicializado (stub)');
  }
  Future<void> showNotification({required String title, required String body, Map<String, dynamic>? payload}) async {}
  Future<void> showAlert({required String title, required String body}) async {}
  Future<void> showReminder({required String title, required String body}) async {}
}

class NotificationData {
  NotificationData(this.title, this.body, {this.payload});
  final String title;
  final String body;
  final Map<String, dynamic>? payload;
}
