import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/dashboard/dashboard_page_optimized.dart';
import '../../presentation/widgets/layout/main_layout.dart';
  import '../../features/gestante/presentation/pages/gestantes_list_page.dart';
  import '../../features/gestante/presentation/pages/gestante_create_page.dart';
  import '../../features/gestante/presentation/pages/gestante_edit_page.dart';
import '../../features/alertas/presentation/pages/alertas_page.dart';
import '../../presentation/pages/reportes/reportes_screen.dart';
import '../../presentation/pages/notifications/notifications_page.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/auth/reset_password_page.dart';
import '../../presentation/pages/settings/sync_conflicts_page.dart';
import '../../presentation/routes/route_names.dart';
import '../../presentation/pages/contenido/contenido_list_simple_page.dart';
import '../../presentation/pages/contenido/contenido_advanced_search_page.dart';
import '../../features/contenido/presentation/pages/contenido_detail_page.dart';
  import '../../features/medicos/presentation/screens/medicos_screen.dart';
  import '../../features/ips/presentation/screens/ips_screen.dart';
  import '../../features/ips/presentation/screens/ips_form_screen.dart';
  import '../../features/medicos/presentation/screens/medico_form_screen.dart';
  import '../../presentation/pages/home/mensajes_screen.dart';
  import '../../features/municipios/presentation/screens/municipios_admin_screen.dart';
  import '../../presentation/pages/alertas/alertas_dashboard_screen.dart';
  import '../../presentation/pages/home/sos_mejorado_screen.dart';
  import '../../presentation/pages/admin/usuarios_screen.dart';
import '../../presentation/pages/admin/usuario_form_screen.dart';
import '../../features/gestante/presentation/pages/assign_gestante_page.dart';
import '../../features/controles_v2/presentation/controles_list_v2_page.dart';
import '../../features/controles_v2/presentation/controles_list_optimized_page.dart';
import '../../features/gestante/presentation/pages/assign_madrinas_to_coordinator_page.dart';
import '../../presentation/widgets/common/route_guard.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/profile/edit_profile_page.dart';
import '../../presentation/pages/help/help_page.dart';
import '../../presentation/pages/about/about_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.loginRoute,
    redirect: (context, state) {
      try {
        final container = ProviderScope.containerOf(context);
        final auth = container.read(authProvider);
        final isAuthed = auth.isAuthenticated;
        final loc = state.uri.toString();
        final public = {
          AppConstants.loginRoute,
          AppConstants.registerRoute,
          AppConstants.forgotPasswordRoute,
          AppConstants.resetPasswordRoute,
          AppConstants.helpRoute,
          AppConstants.aboutRoute,
        };
        if (!isAuthed && !public.contains(loc)) {
          return AppConstants.loginRoute;
        }
        if (isAuthed && loc == AppConstants.loginRoute) {
          return AppConstants.dashboardRoute;
        }
      } catch (_) {}
      return null;
    },
    routes: [
      // Ruta de Login
      GoRoute(
        path: AppConstants.loginRoute,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      
      // Ruta de Registro
      GoRoute(
        path: AppConstants.registerRoute,
        name: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      
      // Ruta de Dashboard
      GoRoute(
        path: AppConstants.dashboardRoute,
        name: RouteNames.dashboard,
        builder: (context, state) => const MainLayout(
          currentRoute: AppConstants.dashboardRoute,
          child: DashboardPageOptimized(),
        ),
      ),
      
      // Ruta de Gestantes
      GoRoute(
        path: AppConstants.gestantesRoute,
        name: RouteNames.gestantes,
        builder: (context, state) => const MainLayout(
          currentRoute: AppConstants.gestantesRoute,
          child: GestantesListPage(),
        ),
      ),
      GoRoute(
        path: '/gestantes/nueva',
        name: 'gestantes_nueva',
        builder: (context, state) => const MainLayout(
          currentRoute: AppConstants.gestantesRoute,
          child: GestanteCreatePage(),
        ),
      ),
      GoRoute(
        path: '/gestantes/editar/:id',
        name: 'gestantes_editar',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return MainLayout(
            currentRoute: AppConstants.gestantesRoute,
            child: GestanteEditPage(gestanteId: id ?? ''),
          );
        },
      ),
      
      // Ruta de Controles
      GoRoute(
        path: AppConstants.controlsRoute,
        name: RouteNames.controls,
        builder: (context, state) => MainLayout(
          currentRoute: AppConstants.controlsRoute,
          child: ControlesListOptimizedPage(gestanteId: state.uri.queryParameters['gestanteId']),
        ),
      ),
      // Alias en español
      GoRoute(
        path: '/controles',
        name: 'controles_es',
        builder: (context, state) => MainLayout(
          currentRoute: AppConstants.controlsRoute,
          child: ControlesListOptimizedPage(gestanteId: state.uri.queryParameters['gestanteId']),
        ),
      ),
      GoRoute(
        path: '/medicos',
        name: 'medicos',
        builder: (context, state) => const MainLayout(
          currentRoute: '/medicos',
          child: RouteGuard(
            allowedRoles: [
              AppConstants.adminRole,
              AppConstants.superAdminRole,
              AppConstants.coordinatorRole,
              AppConstants.medicoRole,
            ],
            child: MedicosScreen()
          ),
        ),
      ),
      GoRoute(
        path: '/medicos/nuevo',
        name: 'medicos_nuevo',
        builder: (context, state) => const MainLayout(
          currentRoute: '/medicos',
          child: RouteGuard(allowedRoles: [AppConstants.adminRole, AppConstants.superAdminRole], child: MedicoFormScreen()),
        ),
      ),
      GoRoute(
        path: '/medicos/editar/:id',
        name: 'medicos_editar',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return MainLayout(
            currentRoute: '/medicos',
            child: RouteGuard(allowedRoles: const [AppConstants.adminRole, AppConstants.superAdminRole], child: MedicoFormScreen(medicoId: id)),
          );
        },
      ),
      GoRoute(
        path: '/ips',
        name: 'ips',
        builder: (context, state) => const MainLayout(
          currentRoute: '/ips',
          child: RouteGuard(
            allowedRoles: [
              AppConstants.adminRole,
              AppConstants.superAdminRole,
              AppConstants.coordinatorRole,
              AppConstants.medicoRole,
            ],
            child: IpsScreen()
          ),
        ),
      ),
      GoRoute(
        path: '/ips/nuevo',
        name: 'ips_nuevo',
        builder: (context, state) => const MainLayout(
          currentRoute: '/ips',
          child: RouteGuard(allowedRoles: [AppConstants.adminRole, AppConstants.superAdminRole], child: IPSFormScreen()),
        ),
      ),
      GoRoute(
        path: '/ips/editar/:id',
        name: 'ips_editar',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return MainLayout(
            currentRoute: '/ips',
            child: RouteGuard(allowedRoles: const [AppConstants.adminRole, AppConstants.superAdminRole], child: IPSFormScreen(ipsId: id)),
          );
        },
      ),
      GoRoute(
        path: '/mensajes',
        name: 'mensajes',
        builder: (context, state) => const MainLayout(
          currentRoute: '/mensajes',
          child: MensajesScreen(),
        ),
      ),
      
      // Ruta de Alertas
      GoRoute(
        path: AppConstants.alertsRoute,
        name: RouteNames.alertas,
        builder: (context, state) => const MainLayout(
          currentRoute: AppConstants.alertsRoute,
          child: AlertasPage(),
        ),
      ),
      GoRoute(
        path: '/alertas-dashboard',
        name: 'alertas_dashboard',
        builder: (context, state) => const MainLayout(
          currentRoute: '/alertas-dashboard',
          child: RouteGuard(allowedRoles: [AppConstants.adminRole, AppConstants.superAdminRole, AppConstants.coordinatorRole], child: AlertasDashboardScreen()),
        ),
      ),
      
      // Ruta de Reportes
      GoRoute(
        path: AppConstants.reportsRoute,
        name: RouteNames.reportes,
        builder: (context, state) => const MainLayout(
          currentRoute: AppConstants.reportsRoute,
          child: RouteGuard(allowedRoles: [AppConstants.adminRole, AppConstants.superAdminRole, AppConstants.coordinatorRole], child: ReportesScreen()),
        ),
      ),

      // Ruta de Lista simple de Contenido (Presentación)
      GoRoute(
        path: AppConstants.contenidoListRoute,
        name: RouteNames.contenidoList,
        builder: (context, state) => const MainLayout(
          currentRoute: AppConstants.contenidoListRoute,
          child: ContenidoListSimplePage(),
        ),
      ),
      GoRoute(
        path: '/contenido/search',
        name: 'contenido_search',
        builder: (context, state) => const MainLayout(
          currentRoute: '/contenido/search',
          child: ContenidoAdvancedSearchPage(),
        ),
      ),
      GoRoute(
        path: '/municipios-admin',
        name: 'municipios_admin',
        builder: (context, state) => const MainLayout(
          currentRoute: '/municipios',
          child: RouteGuard(allowedRoles: [AppConstants.superAdminRole], child: MunicipiosAdminScreen()),
        ),
      ),
      GoRoute(
        path: '/sos',
        name: 'sos',
        builder: (context, state) => const MainLayout(
          currentRoute: '/sos',
          child: SOSMejoradoScreen(),
        ),
      ),
      GoRoute(
        path: '/gestantes/asignar',
        name: 'gestantes_asignar',
        builder: (context, state) => const MainLayout(
          currentRoute: '/gestantes',
          child: RouteGuard(allowedRoles: [AppConstants.adminRole, AppConstants.coordinatorRole], child: AssignGestantePage()),
        ),
      ),
      GoRoute(
        path: '/asignaciones/madrinas',
        name: 'asignaciones_madrinas',
        builder: (context, state) => const MainLayout(
          currentRoute: '/asignaciones/madrinas',
          child: RouteGuard(allowedRoles: [AppConstants.adminRole, AppConstants.superAdminRole], child: AssignMadrinasToCoordinatorPage()),
        ),
      ),

      GoRoute(
        path: '/usuarios',
        name: 'usuarios',
        builder: (context, state) => const MainLayout(
          currentRoute: '/usuarios',
          child: RouteGuard(allowedRoles: [AppConstants.adminRole, AppConstants.superAdminRole], child: UsuariosScreen()),
        ),
      ),
      GoRoute(
        path: '/usuarios/nuevo',
        name: 'usuarios_nuevo',
        builder: (context, state) => const MainLayout(
          currentRoute: '/usuarios',
          child: RouteGuard(allowedRoles: [AppConstants.adminRole, AppConstants.superAdminRole], child: UsuarioFormScreen()),
        ),
      ),
      GoRoute(
        path: '/usuarios/editar/:id',
        name: 'usuarios_editar',
        builder: (context, state) {
          final usuario = state.extra as UsuarioModel?;
          return MainLayout(
            currentRoute: '/usuarios',
            child: UsuarioFormScreen(usuario: usuario),
          );
        },
      ),

      // Ruta de Detalle de Contenido
      GoRoute(
        path: AppConstants.contenidoDetailRoute,
        name: RouteNames.contenidoDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ContenidoDetailPage(contenidoId: id);
        },
      ),
      
      // Ruta de Perfil
      GoRoute(
        path: AppConstants.profileRoute,
        name: RouteNames.profile,
        builder: (context, state) => const MainLayout(
          currentRoute: AppConstants.profileRoute,
          child: ProfilePage(),
        ),
      ),
      GoRoute(
        path: '/perfil/editar',
        name: 'perfil_editar',
        builder: (context, state) => const MainLayout(
          currentRoute: AppConstants.profileRoute,
          child: EditProfilePage(),
        ),
      ),
      
      // Ruta de Configuración
      GoRoute(
        path: AppConstants.settingsRoute,
        name: RouteNames.settings,
        builder: (context, state) => const MainLayout(
          currentRoute: AppConstants.settingsRoute,
          child: SyncConflictsPage(),
        ),
      ),
      
      // Ruta de Notificaciones
      GoRoute(
        path: AppConstants.notificationsRoute,
        name: 'notifications',
        builder: (context, state) => const MainLayout(
          currentRoute: AppConstants.notificationsRoute,
          child: NotificationsPage(),
        ),
      ),
      
      // Ruta de Ayuda (placeholder)
      GoRoute(
        path: AppConstants.helpRoute,
        name: 'help',
        builder: (context, state) => const MainLayout(
          currentRoute: AppConstants.helpRoute,
          child: HelpPage(),
        ),
      ),
      
      // Ruta de Acerca de (placeholder)
      GoRoute(
        path: AppConstants.aboutRoute,
        name: 'about',
        builder: (context, state) => const MainLayout(
          currentRoute: AppConstants.aboutRoute,
          child: AboutPage(),
        ),
      ),
      
      // Ruta de Forgot Password (placeholder)
      GoRoute(
        path: AppConstants.forgotPasswordRoute,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // Ruta de Reset Password (placeholder)
      GoRoute(
        path: AppConstants.resetPasswordRoute,
        name: RouteNames.resetPassword,
        builder: (context, state) => ResetPasswordPage(token: state.uri.queryParameters['token']),
      ),
    ],
    // redirect desactivado temporalmente para depuración de login
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Página no encontrada', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Ruta: ${state.uri.toString()}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.loginRoute),
              child: const Text('Ir al Login'),
            ),
          ],
        ),
      ),
    ),
  );
}
