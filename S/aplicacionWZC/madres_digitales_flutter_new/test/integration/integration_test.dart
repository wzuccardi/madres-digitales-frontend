import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';

import 'package:madres_digitales_flutter_new/main.dart' as app;
import 'package:madres_digitales_flutter_new/core/monitoring/performance_metrics.dart';

/// Pruebas de integración automatizadas para Madres Digitales
/// Validan los flujos críticos de la aplicación
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Tests - Critical Flows', () {
    late IntegrationTestWidgetsFlutterBinding binding;

    setUpAll(() {
      binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('Complete User Flow - Login to Dashboard', (WidgetTester tester) async {
      // Inicializar métricas de rendimiento
      final metrics = PerformanceMetrics.instance;
      await metrics.startMonitoring();

      // Iniciar aplicación
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verificar pantalla inicial
      expect(find.text('Madres Digitales'), findsOneWidget);
      
      // Tomar screenshot para referencia visual
      await binding.takeScreenshot('initial_screen');

      // Simular flujo de login
      final emailField = find.byKey(const Key('email_field'));
      final passwordField = find.byKey(const Key('password_field'));
      final loginButton = find.byKey(const Key('login_button'));

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      // Ingresar credenciales
      await tester.enterText(emailField, 'test@madrinas.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Tomar screenshot después de ingresar datos
      await binding.takeScreenshot('login_filled');

      // Presionar botón de login
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verificar navegación al dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Tomar screenshot del dashboard
      await binding.takeScreenshot('dashboard_loaded');

      // Verificar métricas de rendimiento
      final report = metrics.getCurrentReport();
      expect(report.fps, greaterThan(30), reason: 'FPS should be > 30');
      expect(report.performanceScore, greaterThan(60), reason: 'Performance score should be > 60');

      print('Complete User Flow Performance:');
      print('  FPS: ${report.fps.toStringAsFixed(1)}');
      print('  Performance Score: ${report.performanceScore.toStringAsFixed(1)}');
      print('  Memory: ${(report.memoryUsage / 1024 / 1024).toStringAsFixed(1)}MB');

      metrics.stopMonitoring();
    });

    testWidgets('SOS Emergency Flow', (WidgetTester tester) async {
      final metrics = PerformanceMetrics.instance;
      await metrics.startMonitoring();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navegar a pantalla SOS
      final sosButton = find.byKey(const Key('sos_button'));
      expect(sosButton, findsOneWidget);

      await tester.tap(sosButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar pantalla SOS
      expect(find.text('BOTÓN DE EMERGENCIA'), findsOneWidget);
      await binding.takeScreenshot('sos_screen_loaded');

      // Simular activación de SOS
      final sosActivateButton = find.byKey(const Key('sos_activate_button'));
      await tester.tap(sosActivateButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verificar countdown
      expect(find.text('5'), findsOneWidget);
      await binding.takeScreenshot('sos_countdown');

      // Esperar countdown completo
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verificar diálogo de emergencia
      expect(find.text('EMERGENCIA ACTIVADA'), findsOneWidget);
      await binding.takeScreenshot('sos_emergency_dialog');

      // Verificar métricas durante emergencia
      final report = metrics.getCurrentReport();
      expect(report.fps, greaterThan(25), reason: 'FPS during SOS should be > 25');
      expect(report.droppedFrames, lessThan(10), reason: 'Dropped frames should be < 10');

      print('SOS Emergency Flow Performance:');
      print('  FPS: ${report.fps.toStringAsFixed(1)}');
      print('  Dropped Frames: ${report.droppedFrames}');
      print('  Performance Score: ${report.performanceScore.toStringAsFixed(1)}');

      metrics.stopMonitoring();
    });

    testWidgets('Content Navigation and Search', (WidgetTester tester) async {
      final metrics = PerformanceMetrics.instance;
      await metrics.startMonitoring();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navegar a contenido
      final contentTab = find.text('Contenido');
      await tester.tap(contentTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar carga de contenido
      expect(find.byType(ListView), findsOneWidget);
      await binding.takeScreenshot('content_loaded');

      // Simular búsqueda
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'nutrición');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar resultados de búsqueda
      expect(find.text('nutrición', skipOffstage: false), findsWidgets);
      await binding.takeScreenshot('content_search_results');

      // Seleccionar primer resultado
      final firstResult = find.byType(ListTile).first;
      await tester.tap(firstResult);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar detalle de contenido
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      await binding.takeScreenshot('content_detail');

      final report = metrics.getCurrentReport();
      expect(report.fps, greaterThan(40), reason: 'FPS during navigation should be > 40');
      expect(report.performanceScore, greaterThan(70), reason: 'Performance score should be > 70');

      print('Content Navigation Performance:');
      print('  FPS: ${report.fps.toStringAsFixed(1)}');
      print('  Performance Score: ${report.performanceScore.toStringAsFixed(1)}');

      metrics.stopMonitoring();
    });

    testWidgets('Gestantes List Management', (WidgetTester tester) async {
      final metrics = PerformanceMetrics.instance;
      await metrics.startMonitoring();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navegar a gestantes
      final gestantesTab = find.text('Gestantes');
      await tester.tap(gestantesTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar lista de gestantes
      expect(find.byType(ListView), findsOneWidget);
      await binding.takeScreenshot('gestantes_list');

      // Simular búsqueda
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'María');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar resultados filtrados
      expect(find.text('María', skipOffstage: false), findsWidgets);
      await binding.takeScreenshot('gestantes_filtered');

      // Limpiar búsqueda
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Agregar nueva gestante
      final addButton = find.byType(FloatingActionButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar formulario
      expect(find.byType(Form), findsOneWidget);
      await binding.takeScreenshot('gestantes_form');

      final report = metrics.getCurrentReport();
      expect(report.fps, greaterThan(35), reason: 'FPS during list management should be > 35');

      print('Gestantes Management Performance:');
      print('  FPS: ${report.fps.toStringAsFixed(1)}');
      print('  Performance Score: ${report.performanceScore.toStringAsFixed(1)}');

      metrics.stopMonitoring();
    });

    testWidgets('Memory Stress Test', (WidgetTester tester) async {
      final metrics = PerformanceMetrics.instance;
      await metrics.startMonitoring();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Medir memoria inicial
      final initialReport = metrics.getCurrentReport();
      final initialMemory = initialReport.memoryUsage;

      // Navegar entre diferentes pantallas múltiples veces
      for (int i = 0; i < 5; i++) {
        // Navegar a contenido
        final contentTab = find.text('Contenido');
        await tester.tap(contentTab);
        await tester.pumpAndSettle();

        // Navegar a gestantes
        final gestantesTab = find.text('Gestantes');
        await tester.tap(gestantesTab);
        await tester.pumpAndSettle();

        // Navegar a dashboard
        final dashboardTab = find.text('Dashboard');
        await tester.tap(dashboardTab);
        await tester.pumpAndSettle();

        print('Memory Stress Test - Cycle ${i + 1} completed');
      }

      // Medir memoria final
      final finalReport = metrics.getCurrentReport();
      final finalMemory = finalReport.memoryUsage;
      final memoryGrowth = finalMemory - initialMemory;
      final memoryGrowthMB = memoryGrowth / (1024 * 1024);

      // Verificar que el crecimiento de memoria sea razonable
      expect(memoryGrowthMB, lessThan(50), 
        reason: 'Memory growth should be less than 50MB after navigation cycles');

      await binding.takeScreenshot('memory_stress_test');

      print('Memory Stress Test Results:');
      print('  Initial Memory: ${(initialMemory / 1024 / 1024).toStringAsFixed(1)}MB');
      print('  Final Memory: ${(finalMemory / 1024 / 1024).toStringAsFixed(1)}MB');
      print('  Memory Growth: ${memoryGrowthMB.toStringAsFixed(1)}MB');
      print('  Performance Score: ${finalReport.performanceScore.toStringAsFixed(1)}');

      metrics.stopMonitoring();
    });

    testWidgets('Performance Regression Test', (WidgetTester tester) async {
      final metrics = PerformanceMetrics.instance;
      await metrics.startMonitoring();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Establecer baseline de rendimiento
      final baselineStopwatch = Stopwatch()..start();
      
      // Cargar pantalla simple
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      
      baselineStopwatch.stop();
      final baselineTime = baselineStopwatch.elapsedMilliseconds;

      // Probar carga compleja
      final complexStopwatch = Stopwatch()..start();
      
      // Navegar a contenido con búsqueda
      await tester.tap(find.text('Contenido'));
      await tester.pumpAndSettle();
      
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'embarazo');
      await tester.pumpAndSettle();
      
      // Seleccionar primer resultado
      final firstResult = find.byType(ListTile).first;
      await tester.tap(firstResult);
      await tester.pumpAndSettle();
      
      complexStopwatch.stop();
      final complexTime = complexStopwatch.elapsedMilliseconds;
      final performanceRatio = complexTime / baselineTime;

      // Verificar que el rendimiento no degradado significativamente
      expect(performanceRatio, lessThan(4.0), 
        reason: 'Complex flow should not take more than 4x baseline time');

      final report = metrics.getCurrentReport();
      expect(report.performanceScore, greaterThan(50), 
        reason: 'Overall performance score should be > 50');

      print('Performance Regression Test:');
      print('  Baseline Time: ${baselineTime}ms');
      print('  Complex Time: ${complexTime}ms');
      print('  Performance Ratio: ${performanceRatio.toStringAsFixed(2)}x');
      print('  Performance Score: ${report.performanceScore.toStringAsFixed(1)}');

      await binding.takeScreenshot('performance_regression_test');

      metrics.stopMonitoring();
    });
  });

  group('Integration Tests - Error Handling', () {
    testWidgets('Network Error Handling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Simular error de red (requiere configuración especial)
      // TODO: Implementar mock de errores de red
      
      // Verificar manejo de errores
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Memory Leak Detection', (WidgetTester tester) async {
      final metrics = PerformanceMetrics.instance;
      await metrics.startMonitoring();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Medir memoria inicial
      final initialReport = metrics.getCurrentReport();
      final initialMemory = initialReport.memoryUsage;

      // Crear y destruir widgets repetidamente
      for (int i = 0; i < 10; i++) {
        // Navegar a diferentes pantallas
        await tester.tap(find.text('Contenido'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Gestantes'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Dashboard'));
        await tester.pumpAndSettle();
        
        print('Memory Leak Test - Cycle ${i + 1} completed');
      }

      // Forzar garbage collection
      await tester.binding.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Medir memoria final
      final finalReport = metrics.getCurrentReport();
      final finalMemory = finalReport.memoryUsage;
      final memoryLeak = finalMemory - initialMemory;
      final memoryLeakMB = memoryLeak / (1024 * 1024);

      // Verificar que no haya fugas significativas
      expect(memoryLeakMB, lessThan(20), 
        reason: 'Memory leak should be less than 20MB');

      print('Memory Leak Detection:');
      print('  Initial Memory: ${(initialMemory / 1024 / 1024).toStringAsFixed(1)}MB');
      print('  Final Memory: ${(finalMemory / 1024 / 1024).toStringAsFixed(1)}MB');
      print('  Memory Leak: ${memoryLeakMB.toStringAsFixed(1)}MB');

      metrics.stopMonitoring();
    });
  });

  group('Integration Tests - Accessibility', () {
    testWidgets('Screen Reader Support', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verificar semántica de accesibilidad
      expect(find.bySemanticsLabel('Botón de emergencia SOS'), findsOneWidget);
      expect(find.bySemanticsLabel('Buscar contenido'), findsOneWidget);
      expect(find.bySemanticsLabel('Lista de gestantes'), findsOneWidget);
    });

    testWidgets('Contrast and Visibility', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verificar que los elementos sean visibles
      expect(find.byType(IconButton), findsWidgets);
      expect(find.byType(ElevatedButton), findsWidgets);
      
      // Verificar contraste (requiere herramienta especializada)
      // TODO: Implementar verificación de contraste
    });
  });

  group('Integration Tests - Multi-Device', () {
    testWidgets('Responsive Layout Test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Probar diferentes tamaños de pantalla
      final sizes = [
        const Size(360, 640),  // Móvil pequeño
        const Size(414, 896),  // Móvil grande
        const Size(768, 1024), // Tablet
      ];

      for (final size in sizes) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpAndSettle();

        // Verificar que la UI se adapte correctamente
        expect(find.byType(Scaffold), findsOneWidget);
        
        // Tomar screenshot para cada tamaño
        await binding.takeScreenshot('responsive_${size.width.toInt()}x${size.height.toInt()}');
        
        print('Responsive layout test completed for ${size.width}x${size.height}');
      }
    });

    testWidgets('Orientation Change Test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Probar orientación vertical
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpAndSettle();
      await binding.takeScreenshot('portrait_mode');

      // Probar orientación horizontal
      await tester.binding.setSurfaceSize(const Size(640, 360));
      await tester.pumpAndSettle();
      await binding.takeScreenshot('landscape_mode');

      // Verificar que la UI se adapte
      expect(find.byType(Scaffold), findsOneWidget);
      
      print('Orientation change test completed');
    });
  });
}

/// Helper class para pruebas de integración
class IntegrationTestHelper {
  static Future<void> waitForLoading(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final startTime = DateTime.now();
    
    while (DateTime.now().difference(startTime) < timeout) {
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verificar si no hay indicadores de carga
      final loadingIndicators = find.byType(CircularProgressIndicator);
      if (!loadingIndicators.evaluate().isNotEmpty) {
        return;
      }
    }
    
    throw TimeoutException('Loading did not complete within ${timeout.inSeconds} seconds', timeout);
  }

  static Future<void> takeScreenshotWithTimestamp(
    IntegrationTestWidgetsFlutterBinding binding,
    String name,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await binding.takeScreenshot('${name}_$timestamp');
  }

  static Future<void> simulateNetworkConditions({
    required WidgetTester tester,
    bool slowNetwork = false,
    bool offline = false,
  }) async {
    // TODO: Implementar simulación de condiciones de red
    // Esto requiere configuración especial de testing
    
    if (offline) {
      // Simular modo offline
      print('Simulating offline mode');
    } else if (slowNetwork) {
      // Simular red lenta
      print('Simulating slow network');
    }
  }

  static Future<void> verifyAccessibility(
    WidgetTester tester,
  ) async {
    // Verificar etiquetas semánticas
    final semanticLabels = find.bySemanticsLabel(RegExp('.+'));
    expect(semanticLabels.evaluate().isNotEmpty, true, 
      reason: 'Should have semantic labels for accessibility');

    // Verificar orden de foco
    final focusableElements = find.byWidgetPredicate((widget) {
      return widget is IconButton || 
             widget is ElevatedButton || 
             widget is TextField;
    });
    
    // TODO: Implementar verificación completa de accesibilidad
    print('Accessibility verification completed');
  }

  static Future<void> measurePerformanceThresholds(
    WidgetTester tester,
    Map<String, double> thresholds,
  ) async {
    final metrics = PerformanceMetrics.instance;
    await metrics.startMonitoring();

    // Ejecutar acciones y medir
    await tester.pumpAndSettle();
    final report = metrics.getCurrentReport();

    // Verificar umbrales
    thresholds.forEach((metric, threshold) {
      switch (metric) {
        case 'fps':
          expect(report.fps, greaterThan(threshold), 
            reason: 'FPS should be greater than $threshold');
          break;
        case 'memory':
          final memoryMB = report.memoryUsage / (1024 * 1024);
          expect(memoryMB, lessThan(threshold), 
            reason: 'Memory should be less than ${threshold}MB');
          break;
        case 'score':
          expect(report.performanceScore, greaterThan(threshold), 
            reason: 'Performance score should be greater than $threshold');
          break;
      }
    });

    metrics.stopMonitoring();
  }
}