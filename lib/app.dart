import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'screens/simple_main_screen.dart'; // MOVIDO A RECICLADO
// import 'screens/reportes_dashboard_screen.dart'; // ELIMINADO - archivo no existe
import 'screens/ips_screen.dart';
import 'screens/ips_form_screen.dart'; // HABILITADO - formulario con municipios reales
import 'screens/medicos_screen.dart';
// import 'screens/standalone_medicos_screen.dart'; // MOVIDO A RECICLADO
import 'screens/medico_form_screen.dart';
// import 'screens/simple_medico_form.dart'; // DESHABILITADO - usar medico_form_screen.dart completo
import 'features/municipios/presentation/screens/municipios_admin_screen.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
// import 'features/usuarios/presentation/screens/crear_usuario_admin_screen.dart'; // ELIMINADO
import 'screens/usuario_form_screen.dart';
import 'screens/usuarios_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/controles_screen.dart';
import 'screens/gestantes_screen.dart';
import 'screens/alertas_screen.dart';
import 'screens/alerta_form_screen.dart';
import 'screens/alertas_dashboard_screen.dart';
import 'screens/control_form_screen.dart';
import 'services/alerta_service.dart';
import 'services/control_service.dart';
import 'screens/contenido_screen.dart';
import 'screens/contenido_crud_screen.dart';
import 'screens/contenido_import_export_screen.dart';
import 'screens/mensajes_screen.dart';
import 'features/reportes/presentation/reportes_list_page.dart';
import 'widgets/main_layout.dart';



final GoRouter _router = GoRouter(
  debugLogDiagnostics: true, // HABILITAMOS logs para diagnóstico
  initialLocation: '/',
  routes: [
    // Rutas sin layout (login, splash, etc.)
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainLayout(
        currentRoute: '/dashboard',
        child: DashboardScreen(),
      ),
    ),
    
    // Shell route con MainLayout persistente
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(
          currentRoute: state.uri.path,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/gestantes',
          builder: (context, state) => const GestantesScreen(),
        ),
        GoRoute(
          path: '/medicos',
          builder: (context, state) => const MedicosScreen(),
        ),
        GoRoute(
          path: '/ips',
          builder: (context, state) => const IpsScreen(),
        ),
        GoRoute(
          path: '/controles',
          builder: (context, state) => const ControlesScreen(),
        ),
        GoRoute(
          path: '/alertas',
          builder: (context, state) => const AlertasScreen(),
        ),
        GoRoute(
          path: '/alertas-dashboard',
          builder: (context, state) => const AlertasDashboardScreen(),
        ),
        GoRoute(
          path: '/contenido',
          builder: (context, state) => const ContenidoScreen(),
        ),
        GoRoute(
          path: '/contenido-crud',
          builder: (context, state) => const ContenidoCrudScreen(),
        ),
        GoRoute(
          path: '/contenido-import-export',
          builder: (context, state) => const ContenidoImportExportScreen(),
        ),
        GoRoute(
          path: '/mensajes',
          builder: (context, state) => const MensajesScreen(),
        ),
        GoRoute(
          path: '/reportes',
          builder: (context, state) => const ReportesListPage(),
        ),
        GoRoute(
          path: '/municipios',
          builder: (context, state) => const MunicipiosAdminScreen(),
        ),
        GoRoute(
          path: '/usuarios',
          builder: (context, state) => const UsuariosScreen(),
        ),
        GoRoute(
          path: '/reportes',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Reportes - En desarrollo')),
          ),
        ),

        GoRoute(
          path: '/emergencias',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Emergencias SOS - En desarrollo')),
          ),
        ),

        GoRoute(
          path: '/estadisticas',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Estadísticas - En desarrollo')),
          ),
        ),
        GoRoute(
          path: '/mensajes',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Mensajería - En desarrollo')),
          ),
        ),
      ],
    ),
    
    // RUTAS PARA FORMULARIOS CRUD (fuera del layout principal)
    GoRoute(
      path: '/medicos/nuevo',
      builder: (context, state) => const MedicoFormScreen(),
    ),
    GoRoute(
      path: '/medicos/editar/:id',
      builder: (context, state) {
        final medicoData = state.extra as Map<String, dynamic>?;
        return MedicoFormScreen(medico: medicoData);
      },
    ),
    GoRoute(
      path: '/ips/nuevo',
      builder: (context, state) => const IPSFormScreen(),
    ),
    GoRoute(
      path: '/ips/editar/:id',
      builder: (context, state) {
        final ipsData = state.extra as Map<String, dynamic>?;
        return IPSFormScreen(ips: ipsData);
      },
    ),
    GoRoute(
      path: '/usuarios/nuevo',
      builder: (context, state) => const UsuarioFormScreen(), // MANTENER - archivo existe
    ),
    GoRoute(
      path: '/usuarios/editar/:id',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Editar Usuario - En desarrollo')),
      ),
    ),
    GoRoute(
      path: '/alertas/nueva',
      builder: (context, state) => const AlertaFormScreen(),
    ),
    GoRoute(
      path: '/alertas/editar/:id',
      builder: (context, state) {
        final alertaData = state.extra as Alerta?;
        return const AlertaFormScreen();
      },
    ),
    GoRoute(
      path: '/controles/nuevo',
      builder: (context, state) => ControlFormScreen(),
    ),
    GoRoute(
      path: '/controles/editar/:id',
      builder: (context, state) {
        final controlData = state.extra as Control?;
        return ControlFormScreen(controlId: controlData as String?);
      },
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    print('📱 APP: ========== CONSTRUYENDO MATERIALAPP ==========');
    print('📱 APP: Configurando GoRouter...');
    print('📱 APP: Tema: Material2 (useMaterial3: false)');
    
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Madres Digitales',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        // Temporalmente deshabilitamos Material3 para evitar conflictos
        useMaterial3: false,
      ),
      // Manejo de errores que no interfiera con el build
      builder: (context, child) {
        print('📱 APP: Builder ejecutándose...');
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          print('🚨 APP: ERROR CAPTURADO EN BUILDER: ${errorDetails.exception}');
          print('🚨 APP: Stack trace: ${errorDetails.stack}');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Error en la aplicación'),
                  const SizedBox(height: 8),
                  Text(errorDetails.exception.toString()),
                ],
              ),
            ),
          );
        };
        print('📱 APP: ✅ Builder completado, retornando child');
        return child ?? const SizedBox();
      },
    );
  }
}
