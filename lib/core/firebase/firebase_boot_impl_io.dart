import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';

abstract class FirebaseBootImpl {
  static Future<void> init() async {
    try {
      const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
      const appId = String.fromEnvironment('FIREBASE_APP_ID');
      const senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
      const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

      final hasConfig = [apiKey, appId, senderId, projectId].every((e) => e.isNotEmpty);
      if (hasConfig) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: apiKey,
            appId: appId,
            messagingSenderId: senderId,
            projectId: projectId,
          ),
        );
      } else {
        AppLogger.warning('Firebase (io) no configurado: variables de entorno faltantes');
        await Firebase.initializeApp();
      }

      // Mensajería deshabilitada en compilación web; iniciar solo core/analytics/crashlytics
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    } catch (e) {
      AppLogger.error('Firebase (io) init failed', error: e);
    }
  }
}