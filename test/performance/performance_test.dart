import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/monitoring/performance_metrics.dart';

/// Pruebas de rendimiento automatizadas para Madres Digitales
void main() {
  group('Performance Tests', () {
    late PerformanceMetrics metrics;

    setUp(() {
      metrics = PerformanceMetrics.instance;
    });

    tearDown(() {
      metrics.stopMonitoring();
    });

    testWidgets('SOS Screen Performance Test', (WidgetTester tester) async {
      // Iniciar monitoreo de rendimiento
      await metrics.startMonitoring();

      final stopwatch = Stopwatch()..start();

      // Cargar pantalla SOS
      // TODO: Reemplazar con el widget real cuando esté disponible
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('SOS Screen Test')),
          ),
        ),
      );

      // Esperar a que se complete la construcción
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verificar tiempo de construcción
      expect(stopwatch.elapsedMilliseconds, lessThan(100), 
        reason: 'SOS Screen should build in less than 100ms');

      // Verificar métricas de rendimiento
      final report = metrics.getCurrentReport();
      expect(report.fps, greaterThan(30), 
        reason: 'FPS should be greater than 30');
      expect(report.performanceScore, greaterThan(60), 
        reason: 'Performance score should be greater than 60');

      print('SOS Screen Performance:');
      print('  Build Time: ${stopwatch.elapsedMilliseconds}ms');
      print('  FPS: ${report.fps.toStringAsFixed(1)}');
      print('  Performance Score: ${report.performanceScore.toStringAsFixed(1)}');
      metrics.stopMonitoring();
    });

    testWidgets('Contenido List Performance Test', (WidgetTester tester) async {
      await metrics.startMonitoring();

      final stopwatch = Stopwatch()..start();

      // Simular lista de contenido con 50 items
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Contenido $index'),
                    subtitle: Text('Descripción del contenido $index'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verificar rendimiento de lista
      expect(stopwatch.elapsedMilliseconds, lessThan(200), 
        reason: 'Content list should build in less than 200ms');

      final report = metrics.getCurrentReport();
      expect(report.fps, greaterThan(45), 
        reason: 'FPS should be greater than 45 for lists');

      print('Contenido List Performance:');
      print('  Build Time: ${stopwatch.elapsedMilliseconds}ms');
      print('  FPS: ${report.fps.toStringAsFixed(1)}');
    });

    testWidgets('Memory Usage Test', (WidgetTester tester) async {
      await metrics.startMonitoring();

      // Medir memoria inicial
      final initialReport = metrics.getCurrentReport();
      final initialMemory = initialReport.memoryUsage;

      // Crear múltiples widgets para probar gestión de memoria
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: List.generate(20, (index) => 
                  Text('Memory Test Item $i-$index')),
              ),
            ),
          ),
        );
        await tester.pump();
      }

      final finalReport = metrics.getCurrentReport();
      final finalMemory = finalReport.memoryUsage;

      // Verificar que el crecimiento de memoria sea razonable
      final memoryGrowth = finalMemory - initialMemory;
      final memoryGrowthMB = memoryGrowth / (1024 * 1024);

      expect(memoryGrowthMB, lessThan(50), 
        reason: 'Memory growth should be less than 50MB');

      print('Memory Usage Test:');
      print('  Initial Memory: ${(initialMemory / 1024 / 1024).toStringAsFixed(1)}MB');
      print('  Final Memory: ${(finalMemory / 1024 / 1024).toStringAsFixed(1)}MB');
      print('  Memory Growth: ${memoryGrowthMB.toStringAsFixed(1)}MB');
    });

    testWidgets('Animation Performance Test', (WidgetTester tester) async {
      await metrics.startMonitoring();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100,
                height: 100,
                color: Colors.blue,
                child: const Text('Animation Test'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ejecutar animación y medir rendimiento
      final animationStopwatch = Stopwatch()..start();

      for (int i = 0; i < 10; i++) {
        // Disparar animación
        await tester.tap(find.byType(AnimatedContainer));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));
      }

      animationStopwatch.stop();

      final report = metrics.getCurrentReport();
      final averageFrameTime = animationStopwatch.elapsedMilliseconds / 10;

      expect(averageFrameTime, lessThan(16), 
        reason: 'Average frame time should be less than 16ms');
      expect(report.droppedFrames, lessThan(5), 
        reason: 'Dropped frames should be less than 5');

      print('Animation Performance:');
      print('  Average Frame Time: ${averageFrameTime.toStringAsFixed(1)}ms');
      print('  Dropped Frames: ${report.droppedFrames}');
      print('  FPS: ${report.fps.toStringAsFixed(1)}');
    });

    testWidgets('Widget Rebuild Test', (WidgetTester tester) async {
      await metrics.startMonitoring();

      int buildCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              buildCount++;
              return Scaffold(
                body: Column(
                  children: [
                    Text('Build Count: $buildCount'),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Rebuild'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final initialBuildCount = buildCount;

      // Forzar múltiples reconstrucciones
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Rebuild'));
        await tester.pump();
      }

      final finalBuildCount = buildCount;
      final rebuilds = finalBuildCount - initialBuildCount;

      // Verificar número de reconstrucciones
      expect(rebuilds, equals(5), 
        reason: 'Should have exactly 5 rebuilds');

      final report = metrics.getCurrentReport();
      
      print('Widget Rebuild Test:');
      print('  Initial Builds: $initialBuildCount');
      print('  Final Builds: $finalBuildCount');
      print('  Rebuilds: $rebuilds');
      print('  Performance Score: ${report.performanceScore.toStringAsFixed(1)}');
      metrics.stopMonitoring();
    });

    group('Performance Benchmarks', () {
      testWidgets('Complex Layout Benchmark', (WidgetTester tester) async {
        await metrics.startMonitoring();

        final stopwatch = Stopwatch()..start();

        // Crear layout complejo con múltiples elementos
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Complex Layout'),
                actions: [
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header con imágenes
                    Container(
                      height: 200,
                      child: Row(
                        children: List.generate(3, (index) => 
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              color: Colors.grey[300],
                              child: Center(child: Text('Image $index')),
                            ),
                          )),
                      ),
                    ),
                    // Lista de cards
                    ...List.generate(20, (index) => Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text('Item $index'),
                        subtitle: Text('Description for item $index'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        stopwatch.stop();

        // Verificar rendimiento del layout complejo
        expect(stopwatch.elapsedMilliseconds, lessThan(300), 
          reason: 'Complex layout should build in less than 300ms');

        final report = metrics.getCurrentReport();
        expect(report.fps, greaterThan(30), 
          reason: 'FPS should be greater than 30 for complex layouts');

        print('Complex Layout Benchmark:');
        print('  Build Time: ${stopwatch.elapsedMilliseconds}ms');
        print('  FPS: ${report.fps.toStringAsFixed(1)}');
        print('  Memory: ${(report.memoryUsage / 1024 / 1024).toStringAsFixed(1)}MB');
        metrics.stopMonitoring();
      });

      testWidgets('Scroll Performance Benchmark', (WidgetTester tester) async {
        await metrics.startMonitoring();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 100,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('$index')),
                      title: Text('Scroll Item $index'),
                      subtitle: Text('Description for scroll item $index'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final scrollStopwatch = Stopwatch()..start();

        // Simular scroll rápido
        for (int i = 0; i < 10; i++) {
          await tester.fling(
            find.byType(ListView), 
            const Offset(0, -500), 
            10000,
          );
          await tester.pumpAndSettle();
        }

        scrollStopwatch.stop();

        final report = metrics.getCurrentReport();
        
        expect(report.droppedFrames, lessThan(20), 
          reason: 'Dropped frames during scroll should be less than 20');
        expect(report.fps, greaterThan(40), 
          reason: 'FPS during scroll should be greater than 40');

        print('Scroll Performance Benchmark:');
        print('  Scroll Time: ${scrollStopwatch.elapsedMilliseconds}ms');
        print('  Dropped Frames: ${report.droppedFrames}');
        print('  FPS: ${report.fps.toStringAsFixed(1)}');
      });
    });

    group('Performance Regression Tests', () {
      testWidgets('Regression Test - Build Time', (WidgetTester tester) async {
        await metrics.startMonitoring();

        // Establecer baseline de rendimiento
        final baselineStopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Baseline Test')),
            ),
          ),
        );

        await tester.pumpAndSettle();
        baselineStopwatch.stop();

        final baselineTime = baselineStopwatch.elapsedMilliseconds;

        // Test con widget complejo
        final complexStopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Complex Test')),
              body: Column(
                children: [
                  const Text('Complex Widget'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Button'),
                  ),
                  const SizedBox(height: 20),
                  const TextField(decoration: InputDecoration(labelText: 'Input')),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        complexStopwatch.stop();

        final complexTime = complexStopwatch.elapsedMilliseconds;
        final performanceRatio = complexTime / baselineTime;

        // Verificar que el widget complejo no tome más de 3x el baseline
        expect(performanceRatio, lessThan(3.0), 
          reason: 'Complex widget should not take more than 3x baseline time');

        print('Regression Test - Build Time:');
        print('  Baseline Time: ${baselineTime}ms');
        print('  Complex Time: ${complexTime}ms');
        print('  Performance Ratio: ${performanceRatio.toStringAsFixed(2)}x');
      });

      testWidgets('Regression Test - Memory Usage', (WidgetTester tester) async {
        await metrics.startMonitoring();

        // Medir memoria baseline
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: Center(child: Text('Baseline'))),
          ),
        );

        await tester.pumpAndSettle();
        final baselineReport = metrics.getCurrentReport();
        final baselineMemory = baselineReport.memoryUsage;

        // Medir memoria con múltiples widgets
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    title: Text('Memory Test $index'),
                    subtitle: Text('Testing memory usage with widget $index'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        final memoryReport = metrics.getCurrentReport();
        final memoryUsage = memoryReport.memoryUsage;
        final memoryIncrease = memoryUsage - baselineMemory;
        final memoryIncreaseMB = memoryIncrease / (1024 * 1024);

        // Verificar que el aumento de memoria sea razonable
        expect(memoryIncreaseMB, lessThan(30), 
          reason: 'Memory increase should be less than 30MB');

        print('Regression Test - Memory Usage:');
        print('  Baseline Memory: ${(baselineMemory / 1024 / 1024).toStringAsFixed(1)}MB');
        print('  Current Memory: ${(memoryUsage / 1024 / 1024).toStringAsFixed(1)}MB');
        print('  Memory Increase: ${memoryIncreaseMB.toStringAsFixed(1)}MB');
        metrics.stopMonitoring();
      });
    });
  });
}

/// Helper class para pruebas de rendimiento
class PerformanceTestHelper {
  static Future<void> measureBuildTime(
    WidgetTester tester,
    Widget widget,
    String testName,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    await tester.pumpWidget(MaterialApp(home: widget));
    await tester.pumpAndSettle();
    
    stopwatch.stop();
    
    print('$testName Build Time: ${stopwatch.elapsedMilliseconds}ms');
    
    expect(stopwatch.elapsedMilliseconds, lessThan(100), 
      reason: '$testName should build in less than 100ms');
  }

  static Future<void> measureFPS(
    WidgetTester tester,
    Widget widget,
    String testName,
    int durationSeconds,
  ) async {
    await tester.pumpWidget(MaterialApp(home: widget));
    await tester.pumpAndSettle();
    
    final metrics = PerformanceMetrics.instance;
    await metrics.startMonitoring();
    
    // Esperar y medir FPS
    await Future.delayed(Duration(seconds: durationSeconds));
    
    final report = metrics.getCurrentReport();
    
    print('$testName FPS: ${report.fps.toStringAsFixed(1)}');
    
    expect(report.fps, greaterThan(30), 
      reason: '$testName should maintain FPS greater than 30');
  }

  static Future<void> measureMemoryUsage(
    WidgetTester tester,
    Widget widget,
    String testName,
  ) async {
    final metrics = PerformanceMetrics.instance;
    await metrics.startMonitoring();
    
    await tester.pumpWidget(MaterialApp(home: widget));
    await tester.pumpAndSettle();
    
    final report = metrics.getCurrentReport();
    final memoryMB = report.memoryUsage / (1024 * 1024);
    
    print('$testName Memory Usage: ${memoryMB.toStringAsFixed(1)}MB');
    
    expect(memoryMB, lessThan(100), 
      reason: '$testName should use less than 100MB memory');
  }
}