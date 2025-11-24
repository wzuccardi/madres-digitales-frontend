import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      AppLogger.info('NotificationService(IO): Inicializando');
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
      await _local.initialize(initSettings);

      // Recepción push remota deshabilitada cuando no está disponible la dependencia
    } catch (e) {
      AppLogger.error('NotificationService(IO): Error init', error: e);
    }
  }

  Future<void> showNotification({required String title, required String body, Map<String, dynamic>? payload}) async {
    const androidDetails = AndroidNotificationDetails('general', 'General', importance: Importance.max, priority: Priority.high);
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _local.show(0, title, body, details, payload: payload?.toString());
  }

  Future<void> showAlert({required String title, required String body}) => showNotification(title: title, body: body);
  Future<void> showReminder({required String title, required String body}) => showNotification(title: title, body: body);
}

class NotificationData {
  NotificationData(this.title, this.body, {this.payload});
  final String title;
  final String body;
  final Map<String, dynamic>? payload;
}

// Background handler deshabilitado cuando no está disponible firebase_messaging
