import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gestantes_screen.dart';
import 'controles_screen.dart';
import 'alertas_screen.dart';
import 'dashboard_screen.dart';
import 'contenido_screen.dart';
import '../shared/theme/app_theme.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const GestantesScreen(),
    const ControlesScreen(),
    const AlertasScreen(),
    const ContenidoScreen(),
  ];

  final List<BottomNavigationBarItem> _navigationItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.pregnant_woman),
      label: 'Gestantes',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.assignment),
      label: 'Controles',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.warning),
      label: 'Alertas',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.school),
      label: 'Contenido',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: _navigationItems,
      ),
    );
  }
}