import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/permission_service.dart';
import '../../../../utils/logger.dart';
import 'permission_service_provider.dart';
import '../../../auth/presentation/providers/auth_service_provider.dart';

class MadrinaSessionState {
  final String? madrinaId;
  final String? madrinaNombre;
  final String? madrinaEmail;
  final String? madrinaMunicipio;
  final bool esMadrina;
  final bool estaAutenticada;
  final bool tieneAccesoRestringido;
  final bool isLoading;
  final String? error;
  final Map<String, Set<String>> permisosCache;
  final Map<String, DateTime> permisosTimestamps;
  
  // NUEVO: Estado de inicialización para control de concurrencia
  final bool isInitializing;
  final DateTime? lastInitialized;

  const MadrinaSessionState({
    this.madrinaId,
    this.madrinaNombre,
    this.madrinaEmail,
    this.madrinaMunicipio,
    this.esMadrina = false,
    this.estaAutenticada = false,
    this.tieneAccesoRestringido = false,
    this.isLoading = false,
    this.error,
    this.permisosCache = const {},
    this.permisosTimestamps = const {},
    this.isInitializing = false,
    this.lastInitialized,
  });

  MadrinaSessionState copyWith({
    String? madrinaId,
    String? madrinaNombre,
    String? madrinaEmail,
    String? madrinaMunicipio,
    bool? esMadrina,
    bool? estaAutenticada,
    bool? tieneAccesoRestringido,
    bool? isLoading,
    String? error,
    Map<String, Set<String>>? permisosCache,
    Map<String, DateTime>? permisosTimestamps,
    bool? isInitializing,
    DateTime? lastInitialized,
    bool clearError = false,
  }) {
    return MadrinaSessionState(
      madrinaId: madrinaId ?? this.madrinaId,
      madrinaNombre: madrinaNombre ?? this.madrinaNombre,
      madrinaEmail: madrinaEmail ?? this.madrinaEmail,
      madrinaMunicipio: madrinaMunicipio ?? this.madrinaMunicipio,
      esMadrina: esMadrina ?? this.esMadrina,
      estaAutenticada: estaAutenticada ?? this.estaAutenticada,
      tieneAccesoRestringido: tieneAccesoRestringido ?? this.tieneAccesoRestringido,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      permisosCache: permisosCache ?? this.permisosCache,
      permisosTimestamps: permisosTimestamps ?? this.permisosTimestamps,
      isInitializing: isInitializing ?? this.isInitializing,
      lastInitialized: lastInitialized ?? this.lastInitialized,
    );
  }
}

class MadrinaSessionNotifier extends StateNotifier<MadrinaSessionState> {
  final PermissionService _permissionService;
  final AuthService _authService;
  
  // NUEVO: Variables para controlar inicialización
  bool _isInitializing = false;
  Completer<void>? _initializationCompleter;
  
  // NUEVO: Cache de duración reducida (5 minutos en lugar de 15)
  static const int _cacheDurationMinutes = 5;
  
  // NUEVO: Control de tiempo para evitar inicializaciones demasiado frecuentes
  static const Duration _minTimeBetweenInitializations = Duration(seconds: 2);

  MadrinaSessionNotifier(this._permissionService, this._authService) 
      : super(const MadrinaSessionState()) {
    _inicializarSesion();
  }

  /// Inicializar la sesión de madrina con control de concurrencia
  Future<void> _inicializarSesion() async {
    // NUEVO: Prevenir múltiples inicializaciones simultáneas
    if (_isInitializing) {
      debugPrint('🔐 MadrinaSessionNotifier: Inicialización ya en progreso, esperando...');
      try {
        await _initializationCompleter?.future;
        debugPrint('🔐 MadrinaSessionNotifier: Inicialización previa completada');
        return;
      } catch (e) {
        debugPrint('❌ MadrinaSessionNotifier: Error en inicialización previa: $e');
        // Si la inicialización previa falló, continuar con nueva inicialización
      }
    }

    // NUEVO: Verificar si pasó tiempo mínimo desde última inicialización
    if (state.lastInitialized != null) {
      final tiempoDesdeUltimaInicializacion = DateTime.now().difference(state.lastInitialized!);
      if (tiempoDesdeUltimaInicializacion < _minTimeBetweenInitializations) {
        debugPrint('🔐 MadrinaSessionNotifier: Inicialización muy reciente, omitiendo');
        return;
      }
    }

    _isInitializing = true;
    _initializationCompleter = Completer<void>();
    
    state = state.copyWith(
      isLoading: true,
      isInitializing: true,
    );

    try {
      debugPrint('🔐 MadrinaSessionNotifier: Inicializando sesión...');
      
      final rol = _authService.userRole;
      final userId = _authService.userId;
      final userName = _authService.userName;
      final userEmail = _authService.userEmail;
      final estaAutenticada = _authService.isAuthenticated;
      final esMadrina = _authService.hasRole('madrina');
      
      // Determinar si tiene acceso restringido
      final tieneAccesoRestringido = esMadrina && 
          !['admin', 'super_admin', 'coordinador', 'medico'].contains(rol);

      debugPrint('🔐 MadrinaSessionNotifier: Datos de sesión - '
          'rol: $rol, userId: $userId, esMadrina: $esMadrina, '
          'tieneAccesoRestringido: $tieneAccesoRestringido');

      // NUEVO: Validación adicional de datos
      if (userId == null || userId.isEmpty) {
        throw Exception('ID de usuario no disponible');
      }

      final nuevoEstado = state.copyWith(
        madrinaId: userId,
        madrinaNombre: userName,
        madrinaEmail: userEmail,
        esMadrina: esMadrina,
        estaAutenticada: estaAutenticada,
        tieneAccesoRestringido: tieneAccesoRestringido,
        isLoading: false,
        isInitializing: false,
        lastInitialized: DateTime.now(),
        error: null,
      );

      // NUEVO: Actualizar estado de forma atómica
      state = nuevoEstado;

      // Si es madrina, cargar permisos cache
      if (esMadrina && userId.isNotEmpty) {
        await _cargarPermisosCache();
      }
      
      // NUEVO: Completar inicialización
      _initializationCompleter?.complete();
      
      appLogger.info('Sesión de madrina inicializada correctamente', context: {
        'userId': userId,
        'rol': rol,
        'esMadrina': esMadrina,
        'tieneAccesoRestringido': tieneAccesoRestringido,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ MadrinaSessionNotifier: Error inicializando sesión: $e');
      appLogger.error('Error inicializando sesión de madrina', error: e, context: {
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      state = state.copyWith(
        isLoading: false,
        isInitializing: false,
        error: 'Error al inicializar sesión: $e',
      );
      
      // NUEVO: Completar inicialización con error
      _initializationCompleter?.completeError(e);
    } finally {
      // NUEVO: Liberar bloqueo de inicialización
      _isInitializing = false;
      _initializationCompleter = null;
    }
  }

  /// Verificar si tiene permiso sobre una gestante con invalidación automática
  Future<bool> tienePermiso(String gestanteId, String accion) async {
    if (!state.esMadrina || state.madrinaId == null || state.madrinaId!.isEmpty) {
      debugPrint('🔐 MadrinaSessionNotifier: No es madrina o no hay ID');
      return false;
    }

    // Si tiene acceso completo, verificar permisos directamente
    if (!state.tieneAccesoRestringido) {
      debugPrint('🔐 MadrinaSessionNotifier: Acceso completo - verificando permiso');
      return await _permissionService.tienePermisoSobreGestante(gestanteId, accion);
    }

    // NUEVO: Verificar si el cache es válido (con tiempo reducido)
    final cacheKey = gestanteId;
    if (_isCacheValid(cacheKey)) {
      final permisos = state.permisosCache[cacheKey] ?? <String>{};
      final tienePermiso = permisos.contains(accion);
      debugPrint('🔐 MadrinaSessionNotifier: Usando cache - permiso: $tienePermiso para "$accion"');
      return tienePermiso;
    }

    // Cargar permiso desde el servicio
    debugPrint('🔐 MadrinaSessionNotifier: Cargando permiso desde servicio...');
    try {
      final tienePermiso = await _permissionService.tienePermisoSobreGestante(
        gestanteId, 
        accion
      );
      
      // NUEVO: Actualizar caché con tiempo reducido (5 minutos en lugar de 15)
      if (tienePermiso) {
        final nuevosPermisos = Map<String, Set<String>>.from(state.permisosCache);
        final permisosExistentes = nuevosPermisos[cacheKey] ?? <String>{};
        permisosExistentes.add(accion);
        nuevosPermisos[cacheKey] = permisosExistentes;
        
        final nuevosTimestamps = Map<String, DateTime>.from(state.permisosTimestamps);
        nuevosTimestamps[cacheKey] = DateTime.now();
        
        state = state.copyWith(
          permisosCache: nuevosPermisos,
          permisosTimestamps: nuevosTimestamps,
        );
      }
      
      debugPrint('✅ MadrinaSessionNotifier: Permiso verificado - $tienePermiso para "$accion"');
      return tienePermiso;
    } catch (e) {
      debugPrint('❌ MadrinaSessionNotifier: Error verificando permiso: $e');
      appLogger.error('Error verificando permiso', error: e, context: {
        'gestanteId': gestanteId,
        'accion': accion,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return false;
    }
  }

  /// Verificar si tiene un permiso general
  bool tienePermisoGeneral(String permiso) {
    if (!state.esMadrina || state.madrinaId == null || state.madrinaId!.isEmpty) {
      debugPrint('🔐 MadrinaSessionNotifier: No es madrina o no hay ID para permiso general');
      return false;
    }

    // Si tiene acceso completo, tiene todos los permisos generales
    if (!state.tieneAccesoRestringido) {
      debugPrint('🔐 MadrinaSessionNotifier: Acceso completo - permiso general concedido');
      return true;
    }

    // Verificar permisos específicos según el rol
    final rol = _authService.userRole;
    switch (permiso) {
      case 'ver_dashboard':
        return true; // Todas las madrinas pueden ver el dashboard
      case 'ver_gestantes':
        return true; // Todas las madrinas pueden ver gestantes
      case 'ver_controles':
        return true; // Todas las madrinas pueden ver controles
      case 'ver_alertas':
        return true; // Todas las madrinas pueden ver alertas
      case 'crear_alerta':
        return true; // Todas las madrinas pueden crear alertas
      case 'ver_contenido':
        return true; // Todas las madrinas pueden ver contenido
      case 'ver_reportes':
        return ['admin', 'super_admin', 'coordinador'].contains(rol);
      case 'gestionar_usuarios':
        return ['admin', 'super_admin'].contains(rol);
      case 'gestionar_municipios':
        return ['admin', 'super_admin'].contains(rol);
      default:
        debugPrint('🔐 MadrinaSessionNotifier: Permiso general no reconocido: $permiso');
        return false;
    }
  }

  /// NUEVO: Invalidar cache de permisos para una gestante específica
  Future<void> invalidarPermisosGestante(String gestanteId) async {
    debugPrint('🔐 MadrinaSessionNotifier: Invalidando permisos para gestante: $gestanteId');
    
    final nuevosPermisos = Map<String, Set<String>>.from(state.permisosCache);
    final nuevosTimestamps = Map<String, DateTime>.from(state.permisosTimestamps);
    
    nuevosPermisos.remove(gestanteId);
    nuevosTimestamps.remove(gestanteId);
    
    state = state.copyWith(
      permisosCache: nuevosPermisos,
      permisosTimestamps: nuevosTimestamps,
    );
    
    debugPrint('✅ MadrinaSessionNotifier: Permisos invalidados para gestante: $gestanteId');
    appLogger.info('Permisos invalidados para gestante', context: {
      'gestanteId': gestanteId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// NUEVO: Invalidar todo el cache de permisos
  Future<void> invalidarTodosLosPermisos() async {
    debugPrint('🔐 MadrinaSessionNotifier: Invalidando todo el cache de permisos');
    
    state = state.copyWith(
      permisosCache: const {},
      permisosTimestamps: const {},
    );
    
    debugPrint('✅ MadrinaSessionNotifier: Todo el cache de permisos invalidado');
    appLogger.info('Todo el cache de permisos invalidado', context: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Cargar permisos cache desde el servicio
  Future<void> _cargarPermisosCache() async {
    try {
      debugPrint('🔐 MadrinaSessionNotifier: Cargando permisos cache...');
      
      // Por ahora, no hay un endpoint para cargar todos los permisos
      // Se cargarán bajo demanda
      
      debugPrint('✅ MadrinaSessionNotifier: Permisos cache cargados');
    } catch (e) {
      debugPrint('❌ MadrinaSessionNotifier: Error cargando permisos cache: $e');
      appLogger.error('Error cargando permisos cache', error: e, context: {
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// NUEVO: Verificar si el cache es válido (con tiempo reducido)
  bool _isCacheValid(String gestanteId) {
    if (!state.permisosCache.containsKey(gestanteId) || 
        !state.permisosTimestamps.containsKey(gestanteId)) {
      return false;
    }
    
    // CAMBIAR: Reducir tiempo de cache de 15 a 5 minutos
    final cacheAge = DateTime.now().difference(state.permisosTimestamps[gestanteId]!);
    return cacheAge.inMinutes < _cacheDurationMinutes;
  }

  /// Refrescar la sesión con control de concurrencia
  Future<void> refrescarSesion({bool forzar = false}) async {
    debugPrint('🔐 MadrinaSessionNotifier: Refrescando sesión... (forzar: $forzar)');
    
    // NUEVO: Si no se fuerza, verificar si ya hay una inicialización en progreso
    if (!forzar && _isInitializing) {
      debugPrint('🔐 MadrinaSessionNotifier: Inicialización ya en progreso, esperando...');
      await _initializationCompleter?.future;
      return;
    }
    
    // NUEVO: Si se fuerza, limpiar locks y esperar un poco
    if (forzar) {
      _isInitializing = false;
      _initializationCompleter = null;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    await _inicializarSesion();
  }

  /// Cerrar sesión
  Future<void> cerrarSesion() async {
    debugPrint('🔐 MadrinaSessionNotifier: Cerrando sesión...');
    
    // NUEVO: Limpiar locks de inicialización
    _isInitializing = false;
    _initializationCompleter = null;
    
    // Limpiar cache de permisos
    await invalidarTodosLosPermisos();
    
    // Limpiar estado
    state = const MadrinaSessionState();
    
    // Cerrar sesión en AuthService
    await _authService.logout();
    
    debugPrint('✅ MadrinaSessionNotifier: Sesión cerrada');
    appLogger.info('Sesión de madrina cerrada', context: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Actualizar información de la madrina
  void actualizarInfoMadrina({
    String? nombre,
    String? email,
    String? municipio,
  }) {
    state = state.copyWith(
      madrinaNombre: nombre ?? state.madrinaNombre,
      madrinaEmail: email ?? state.madrinaEmail,
      madrinaMunicipio: municipio ?? state.madrinaMunicipio,
    );
    
    appLogger.info('Información de madrina actualizada', context: {
      'nombre': nombre,
      'email': email,
      'municipio': municipio,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// NUEVO: Obtener estado actual de inicialización
  bool get isInitializing => _isInitializing;
  
  /// NUEVO: Obtener tiempo desde última inicialización
  Duration? get tiempoDesdeUltimaInicializacion {
    if (state.lastInitialized == null) return null;
    return DateTime.now().difference(state.lastInitialized!);
  }

  /// NUEVO: Verificar si la sesión está activa y válida
  bool get sesionActivaYValida {
    return state.estaAutenticada && 
           state.esMadrina && 
           state.madrinaId != null && 
           state.madrinaId!.isNotEmpty &&
           !state.isInitializing;
  }

  /// NUEVO: Forzar recarga completa de la sesión
  Future<void> forzarRecargaCompleta() async {
    debugPrint('🔄 MadrinaSessionNotifier: Forzando recarga completa...');
    
    // Limpiar todo el estado
    state = const MadrinaSessionState();
    
    // Limpiar locks
    _isInitializing = false;
    _initializationCompleter = null;
    
    // Esperar un poco para asegurar que se limpió todo
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Reinicializar completamente
    await _inicializarSesion();
    
    debugPrint('✅ MadrinaSessionNotifier: Recarga completa finalizada');
  }
}

// Provider para la sesión de madrina
final madrinaSessionProvider = StateNotifierProvider<MadrinaSessionNotifier, MadrinaSessionState>((ref) {
  final permissionService = ref.watch(permissionServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return MadrinaSessionNotifier(permissionService, authService);
});

// NUEVO: Provider para estado de inicialización de sesión
final sesionInitializationProvider = Provider<SesionInitializationState>((ref) {
  final sessionState = ref.watch(madrinaSessionProvider);
  final notifier = ref.watch(madrinaSessionProvider.notifier);
  
  return SesionInitializationState(
    isInitializing: sessionState.isInitializing,
    lastInitialized: sessionState.lastInitialized,
    tiempoDesdeUltimaInicializacion: notifier.tiempoDesdeUltimaInicializacion,
    sesionActivaYValida: notifier.sesionActivaYValida,
  );
});

class SesionInitializationState {
  final bool isInitializing;
  final DateTime? lastInitialized;
  final Duration? tiempoDesdeUltimaInicializacion;
  final bool sesionActivaYValida;
  
  const SesionInitializationState({
    required this.isInitializing,
    this.lastInitialized,
    this.tiempoDesdeUltimaInicializacion,
    required this.sesionActivaYValida,
  });
}

// NUEVO: Provider para acciones de sesión
final sesionActionsProvider = Provider<SesionActions>((ref) {
  final notifier = ref.read(madrinaSessionProvider.notifier);
  
  return SesionActions(
    refrescarSesion: notifier.refrescarSesion,
    forzarRecargaCompleta: notifier.forzarRecargaCompleta,
    cerrarSesion: notifier.cerrarSesion,
    invalidarPermisosGestante: notifier.invalidarPermisosGestante,
    invalidarTodosLosPermisos: notifier.invalidarTodosLosPermisos,
  );
});

class SesionActions {
  final Future<void> Function({bool forzar}) refrescarSesion;
  final Future<void> Function() forzarRecargaCompleta;
  final Future<void> Function() cerrarSesion;
  final Future<void> Function(String) invalidarPermisosGestante;
  final Future<void> Function() invalidarTodosLosPermisos;
  
  const SesionActions({
    required this.refrescarSesion,
    required this.forzarRecargaCompleta,
    required this.cerrarSesion,
    required this.invalidarPermisosGestante,
    required this.invalidarTodosLosPermisos,
  });
}