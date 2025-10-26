import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _getCurrentIndex() {
    switch (widget.currentRoute) {
      case '/dashboard':
        return 0;
      case '/gestantes':
        return 1;
      case '/medicos':
        return 2;
      case '/ips':
        return 3;
      case '/controles':
        return 4;
      case '/alertas':
        return 5;
      case '/alertas-dashboard':
        return 6;
      case '/contenido':
        return 7;
      case '/mensajes':
        return 8;
      case '/reportes':
        return 9;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/gestantes');
        break;
      case 2:
        context.go('/medicos');
        break;
      case 3:
        context.go('/ips');
        break;
      case 4:
        context.go('/controles');
        break;
      case 5:
        context.go('/alertas');
        break;
      case 6:
        context.go('/alertas-dashboard');
        break;
      case 7:
        context.go('/contenido');
        break;
      case 8:
        context.go('/mensajes');
        break;
      case 9:
        context.go('/reportes');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // No usar Scaffold aquí para evitar conflictos con los Scaffold de las pantallas
    return Column(
      children: [
        Expanded(child: widget.child),
        BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _getCurrentIndex(),
          onTap: _onItemTapped,
          selectedItemColor: Colors.pink,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, size: 20),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pregnant_woman, size: 20),
              label: 'Gestantes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services, size: 20),
              label: 'Médicos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital, size: 20),
              label: 'IPS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment, size: 20),
              label: 'Controles',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active, size: 20),
              label: 'Alertas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics, size: 20),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books, size: 20),
              label: 'Contenido',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat, size: 20),
              label: 'Mensajes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment, size: 20),
              label: 'Reportes',
            ),
          ],
        ),
      ],
    );
  }
}