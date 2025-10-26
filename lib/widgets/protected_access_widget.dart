// Widget de protección de acceso basado en permisos
// Protege el acceso a componentes según los permisos del usuario

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/gestante/presentation/providers/madrina_session_provider.dart';
import '../services/auth_service.dart';

class ProtectedAccessWidget extends ConsumerWidget {
  final Widget child;
  final String gestanteId;
  final String permisoRequerido;
  final Widget? fallback;
  final String? mensajeDenegado;
  final bool mostrarIndicadorCarga;

  const ProtectedAccessWidget({
    super.key,
    required this.child,
    required this.gestanteId,
    required this.permisoRequerido,
    this.fallback,
    this.mensajeDenegado,
    this.mostrarIndicadorCarga = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(madrinaSessionProvider);

    // Si está cargando la sesión
    if (sessionState.isLoading) {
      return mostrarIndicadorCarga 
          ? _buildLoadingWidget()
          : const SizedBox.shrink();
    }

    // Si no está autenticado, mostrar fallback
    if (!sessionState.esMadrina && sessionState.madrinaId == null) {
      return fallback ?? _buildNoAutenticadoWidget(context);
    }

    // Si tiene acceso completo, permitir acceso
    if (!sessionState.tieneAccesoRestringido) {
      return child;
    }

    // Verificar permiso específico
    return FutureBuilder<bool>(
      future: ref.read(madrinaSessionProvider.notifier).tienePermiso(
        gestanteId,
        permisoRequerido,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return mostrarIndicadorCarga 
              ? _buildLoadingWidget()
              : const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          return fallback ?? _buildErrorWidget(context, snapshot.error.toString());
        }

        if (snapshot.hasData && snapshot.data == true) {
          return child;
        }

        return fallback ?? _buildAccesoDenegadoWidget(context);
      },
    );
  }

  Widget _buildNoAutenticadoWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Acceso Restringido',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Debes iniciar sesión como madrina para acceder a esta función.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Navegar a la pantalla de login
              Navigator.of(context).pushNamed('/login');
            },
            icon: const Icon(Icons.login),
            label: const Text('Iniciar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[500],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccesoDenegadoWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.security,
              color: Colors.orange[700],
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Acceso Restringido',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            mensajeDenegado ?? 'No tienes permiso para acceder a esta gestante.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta gestante está asignada a otra madrina. Contacta al coordinador si necesitas acceso.',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error de Verificación',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se pudieron verificar tus permisos: $error',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Reintentar la verificación
              // Se necesita el contexto para invalidar el provider
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[500],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Verificando permisos...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Widget simplificado para proteger acceso basado en rol
class RoleProtectedWidget extends ConsumerWidget {
  final Widget child;
  final List<String> rolesPermitidos;
  final Widget? fallback;
  final String? mensajeDenegado;

  const RoleProtectedWidget({
    super.key,
    required this.child,
    required this.rolesPermitidos,
    this.fallback,
    this.mensajeDenegado,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(madrinaSessionProvider);

    // Si está cargando la sesión
    if (sessionState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Verificar si el usuario tiene alguno de los roles permitidos
    final authService = AuthService();
    final tieneRolPermitido = rolesPermitidos.any((rol) => authService.hasRole(rol));

    if (tieneRolPermitido) {
      return child;
    }

    return fallback ?? _buildAccesoDenegadoPorRolWidget(context);
  }

  Widget _buildAccesoDenegadoPorRolWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Acceso Restringido',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mensajeDenegado ?? 'No tienes el rol necesario para acceder a esta función.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget para proteger acceso a gestantes específicas
class GestanteProtectedWidget extends ConsumerWidget {
  final Widget child;
  final String gestanteId;
  final Widget? fallback;
  final String? mensajeDenegado;

  const GestanteProtectedWidget({
    super.key,
    required this.child,
    required this.gestanteId,
    this.fallback,
    this.mensajeDenegado,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(madrinaSessionProvider);

    // Si está cargando la sesión
    if (sessionState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Si no está autenticado, mostrar fallback
    if (!sessionState.estaAutenticada) {
      return fallback ?? _buildNoAutenticadoWidget(context);
    }

    // Si tiene acceso completo, permitir acceso
    if (!sessionState.tieneAccesoRestringido) {
      return child;
    }

    // Verificar si tiene acceso a esta gestante
    return FutureBuilder<String>(
      future: Future.value('asignada'), // Valor por defecto mientras se implementa el método
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return fallback ?? _buildErrorWidget(context, snapshot.error.toString());
        }

        final tipoRelacion = snapshot.data ?? 'sin_acceso';

        if (tipoRelacion != 'sin_acceso') {
          return child;
        }

        return fallback ?? _buildAccesoDenegadoWidget(context, tipoRelacion);
      },
    );
  }

  Widget _buildNoAutenticadoWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Acceso Restringido',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Debes iniciar sesión para acceder a esta función.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccesoDenegadoWidget(BuildContext context, String tipoRelacion) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Gestante No Asignada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mensajeDenegado ?? 'Esta gestante no está asignada a tu cuenta.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error de Verificación',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se pudo verificar el acceso: $error',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}