import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  NotificationService._();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  
  // Inicializar servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Configuración para Android
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuración para iOS
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Configuración general
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    await _requestPermissions();
    _initialized = true;
  }
  
  // Solicitar permisos de notificación
  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }
  
  // Manejar tap en notificación
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Aquí puedes manejar la navegación basada en el payload
      print('Notificación tocada con payload: $payload');
    }
  }
  
  // Mostrar notificación inmediata
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    await initialize();
    
    final androidDetails = AndroidNotificationDetails(
      'madres_digitales_channel',
      'Madres Digitales',
      channelDescription: 'Notificaciones de la aplicación Madres Digitales',
      importance: _getAndroidImportance(priority),
      priority: _getAndroidPriority(priority),
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(id, title, body, details, payload: payload);
  }
  
  // Programar notificación
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    await initialize();
    
    final androidDetails = AndroidNotificationDetails(
      'madres_digitales_scheduled',
      'Recordatorios Madres Digitales',
      channelDescription: 'Recordatorios programados de controles prenatales',
      importance: _getAndroidImportance(priority),
      priority: _getAndroidPriority(priority),
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  // Notificación de alerta médica
  Future<void> showMedicalAlert({
    required String gestanteName,
    required String alertType,
    required String message,
    String? gestanteId,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🚨 Alerta Médica - $gestanteName',
      body: '$alertType: $message',
      payload: 'medical_alert:$gestanteId',
      priority: NotificationPriority.high,
    );
  }
  
  // Recordatorio de control prenatal
  Future<void> scheduleControlReminder({
    required String gestanteName,
    required DateTime controlDate,
    required String gestanteId,
  }) async {
    // Recordatorio 24 horas antes
    final reminderDate = controlDate.subtract(const Duration(days: 1));
    
    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: int.parse(gestanteId.hashCode.toString().substring(0, 8)),
        title: '📅 Recordatorio de Control',
        body: '$gestanteName tiene control prenatal mañana',
        scheduledDate: reminderDate,
        payload: 'control_reminder:$gestanteId',
        priority: NotificationPriority.high,
      );
    }
    
    // Recordatorio el día del control
    if (controlDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: int.parse(gestanteId.hashCode.toString().substring(0, 8)) + 1,
        title: '🏥 Control Prenatal Hoy',
        body: '$gestanteName tiene control prenatal programado',
        scheduledDate: controlDate,
        payload: 'control_today:$gestanteId',
        priority: NotificationPriority.high,
      );
    }
  }
  
  // Notificación de sincronización
  Future<void> showSyncNotification({
    required bool success,
    required int syncedCount,
    int errorCount = 0,
  }) async {
    String title;
    String body;
    
    if (success) {
      title = '✅ Sincronización Completada';
      body = 'Se sincronizaron $syncedCount registros correctamente';
    } else {
      title = '⚠️ Sincronización con Errores';
      body = 'Sincronizados: $syncedCount, Errores: $errorCount';
    }
    
    await showNotification(
      id: 999999,
      title: title,
      body: body,
      priority: success ? NotificationPriority.low : NotificationPriority.defaultPriority,
    );
  }
  
  // Cancelar notificación específica
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  // Obtener notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
  
  // Convertir prioridad a Android Importance
  Importance _getAndroidImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.defaultPriority:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.max:
        return Importance.max;
    }
  }
  
  // Convertir prioridad a Android Priority
  Priority _getAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.defaultPriority:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.max:
        return Priority.max;
    }
  }
}

enum NotificationPriority {
  low,
  defaultPriority,
  high,
  max,
}

class NotificationPayload {
  final String type;
  final String? id;
  final Map<String, dynamic>? data;
  
  NotificationPayload({
    required this.type,
    this.id,
    this.data,
  });
  
  factory NotificationPayload.fromString(String payload) {
    final parts = payload.split(':');
    return NotificationPayload(
      type: parts[0],
      id: parts.length > 1 ? parts[1] : null,
    );
  }
  
  @override
  String toString() {
    return id != null ? '$type:$id' : type;
  }
}