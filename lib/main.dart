import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';

void main() async {
  print('🚀 MAIN: ========== INICIANDO APLICACIÓN ==========');
  print('🚀 MAIN: Fecha/Hora: ${DateTime.now()}');
  
  WidgetsFlutterBinding.ensureInitialized();
  print('🚀 MAIN: ✅ WidgetsFlutterBinding inicializado');

  // Inicializar Hive
  print('🚀 MAIN: Inicializando Hive...');
  await Hive.initFlutter();
  print('🚀 MAIN: ✅ Hive inicializado exitosamente');

  // AGREGANDO RIVERPOD PARA DASHBOARD CON DATOS REALES
  print('🚀 MAIN: Creando App (CON Riverpod para datos reales)...');
  print('🚀 MAIN: ========== LANZANDO APLICACIÓN ==========');
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
  print('🚀 MAIN: ✅ runApp ejecutado');
}