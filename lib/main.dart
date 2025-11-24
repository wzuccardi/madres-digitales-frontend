import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/firebase/firebase_boot.dart';
import 'core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
// import 'core/providers/service_providers.dart'; // Comentado hasta que exista


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error('FlutterError', error: details.exception, context: {
      'library': details.library,
      'stack': details.stack?.toString(),
    });
  };
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Center(
        child: Text(
          'Error: ${details.exceptionAsString()}',
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  };
  // Firebase temporalmente deshabilitado para web
  if (!kIsWeb) {
    try {
      await FirebaseBoot.init();
    } catch (e) {
      AppLogger.error('Firebase init error', error: e);
    }
  }

  // Forzar HashUrlStrategy para evitar problemas de routing en servidores locales
  setUrlStrategy(const HashUrlStrategy());

  // Inicialización mínima requerida

  // Inicializar aplicación
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    AppLogger.info('MyApp build', context: {'isAuthenticated': authState.isAuthenticated});
    
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
