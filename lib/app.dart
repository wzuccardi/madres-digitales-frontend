import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';

/// App widget principal que configura la aplicación con ProviderScope y MaterialApp.router
/// 
/// Este widget sirve como punto de entrada para la aplicación cuando se necesita
/// instanciar la app fuera de main.dart (por ejemplo, en tests o en configuraciones
/// específicas de inyección de dependencias).
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      title: AppConstants.appName,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
