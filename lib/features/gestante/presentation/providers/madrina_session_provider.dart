import 'dart:async';
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
  
  // NUEVO: Estado de inicializaciÃ³n para control de concurrencia
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
  
  // NUEVO: Variables para controlar inicializaciÃ³n
  bool _isInitializing = false;
  Completer<void>? _initializationCompleter;
  
  // NUEVO: Cache de duraciÃ³n reducida (5 minutos en lugar de 15)
  static const int _cacheDurationMinutes = 5;
  
  // NUEVO: Control de tiempo para evitar inicializaciones demasiado frecuentes
  static const Duration _minTimeBetweenInitializations = Duration(seconds: 2);

  MadrinaSessionNotifier(this._permissionService, this._authService) 
      : super(const MadrinaSessionState()) {
    _inicializarSesion();
  }

  /// Inicializar la sesiÃ³n de madrina con control de concurrencia
  Future<void> _inicializarSesion() async {
    // NUEVO: Prevenir mÃºltiples inicializaciones simultÃ¡neas
    if (_isInitializing) {
      try {
        await _initializationCompleter?.future;
        return;
      } catch (e) {
        // Si la inicializaciÃ³n previa fallÃ³, continuar con nueva inicializaciÃ³n
      }
    }

    // NUEVO: Verificar si pasÃ³ tiempo mÃ­nimo desde Ãºltima inicializaciÃ³n
    if (state.lastInitialized != null) {
      final tiempoDesdeUltimaInicializacion = DateTime.now().difference(state.lastInitialized!);
      if (tiempoDesdeUltimaInicializacion < _minTimeBetweenInitializations) {
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
      
      final rol = _authService.userRole;
      final userId = _authService.userId;
      final userName = _authService.userName;
      final userEmail = _authService.userEmail;
      final estaAutenticada = _authService.isAuthenticated;
      final esMadrina = _authService.hasRole('madrina');
      
      // Determinar si tiene acceso restringido
      final tieneAccesoRestringido = esMadrina && 
          !['admin', 'super_admin', 'coordinador', 'medico'].contains(rol);

      // NUEVO: ValidaciÃ³n adicional de datos
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

      // NUEVO: Actualizar estado de forma atÃ³mica
      state = nuevoEstado;

      // Si es madrina, cargar permisos cache
      if (esMadrina && userId.isNotEmpty) {
        await _cargarPermisosCache();
      }
      
      // NUEVO: Completar inicializaciÃ³n
      _initializationCompleter?.complete();
      
      appLogger.info('SesiÃ³n de madrina inicializada correctamente', context: {
        'userId': userId,
        'rol': rol,
        'esMadrina': esMadrina,
        'tieneAccesoRestringido': tieneAccesoRestringido,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      appLogger.error('Error inicializando sesiÃ³n de madrina', error: e, context: {
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      state = state.copyWith(
        isLoading: false,
        isInitializing: false,
        error: 'Error al inicializar sesiÃ³n: $e',
      );
      
      // NUEVO: Completar inicializaciÃ³n con error
      _initializationCompleter?.completeError(e);
    } finally {
      // NUEVO: Liberar bloqueo de inicializaciÃ³n
      _isInitializing = false;
      _initializationCompleter = null;
    }
  }

  /// Verificar si tiene permiso sobre una gestante con invalidaciÃ³n automÃ¡tica
  Future<bool> tienePermiso(String gestanteId, String accion) async {
    if (!state.esMadrina || state.madrinaId == null || state.madrinaId!.isEmpty) {
      return false;
    }

    // Si tiene acceso completo, verificar permisos directamente
    if (!state.tieneAccesoRestringido) {
      return await _permissionService.tienePermisoSobreGestante(gestanteId, accion);
    }

    // NUEVO: Verificar si el cache es vÃ¡lido (con tiempo reducido)
    final cacheKey = gestanteId;
    if (_isCacheValid(cacheKey)) {
      final permisos = state.permisosCache[cacheKey] ?? <String>{};
      final tienePermiso = permisos.contains(accion);
      return tienePermiso;
    }

    // Cargar permiso desde el servicio
    try {
      final tienePermiso = await _permissionService.tienePermisoSobreGestante(
        gestanteId, 
        accion
      );
      
      // NUEVO: Actualizar cachÃ© con tiempo reducido (5 minutos en lugar de 15)
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
      
      return tienePermiso;
    } catch (e) {
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
      return false;
    }

    // Si tiene acceso completo, tiene todos los permisos generales
    if (!state.tieneAccesoRestringido) {
      return true;
    }

    // Verificar permisos especÃ­ficos segÃºn el rol
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
        return false;
    }
  }

  /// NUEVO: Invalidar cache de permisos para una gestante especÃ­fica
  Future<void> invalidarPermisosGestante(String gestanteId) async {
    
    final nuevosPermisos = Map<String, Set<String>>.from(state.permisosCache);
    final nuevosTimestamps = Map<String, DateTime>.from(state.permisosTimestamps);
    
    nuevosPermisos.remove(gestanteId);
    nuevosTimestamps.remove(gestanteId);
    
    state = state.copyWith(
      permisosCache: nuevosPermisos,
      permisosTimestamps: nuevosTimestamps,
    );
    
    appLogger.info('Permisos invalidados para gestante', context: {
      'gestanteId': gestanteId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// NUEVO: Invalidar todo el cache de permisos
  Future<void> invalidarTodosLosPermisos() async {
    
    state = state.copyWith(
      permisosCache: const {},
      permisosTimestamps: const {},
    );
    
    appLogger.info('Todo el cache de permisos invalidado', context: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Cargar permisos cache desde el servicio
  Future<void> _cargarPermisosCache() async {
    try {
      
      // Por ahora, no hay un endpoint para cargar todos los permisos
      // Se cargarÃ¡n bajo demanda
      
    } catch (e) {
      appLogger.error('Error cargando permisos cache', error: e, context: {
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// NUEVO: Verificar si el cache es vÃ¡lido (con tiempo reducido)
  bool _isCacheValid(String gestanteId) {
    if (!state.permisosCache.containsKey(gestanteId) || 
        !state.permisosTimestamps.containsKey(gestanteId)) {
      return false;
    }
    
    // CAMBIAR: Reducir tiempo de cache de 15 a 5 minutos
    final cacheAge = DateTime.now().difference(state.permisosTimestamps[gestanteId]!);
    return cacheAge.inMinutes < _cacheDurationMinutes;
  }

  /// Refrescar la sesiÃ³n con control de concurrencia
  Future<void> refrescarSesion({bool forzar = false}) async {
    
    // NUEVO: Si no se fuerza, verificar si ya hay una inicializaciÃ³n en progreso
    if (!forzar && _isInitializing) {
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

  /// Cerrar sesiÃ³n
  Future<void> cerrarSesion() async {
    
    // NUEVO: Limpiar locks de inicializaciÃ³n
    _isInitializing = false;
    _initializationCompleter = null;
    
    // Limpiar cache de permisos
    await invalidarTodosLosPermisos();
    
    // Limpiar estado
    state = const MadrinaSessionState();
    
    // Cerrar sesiÃ³n en AuthService
    await _authService.logout();
    
    appLogger.info('SesiÃ³n de madrina cerrada', context: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Actualizar informaciÃ³n de la madrina
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
    
    appLogger.info('InformaciÃ³n de madrina actualizada', context: {
      'nombre': nombre,
      'email': email,
      'municipio': municipio,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// NUEVO: Obtener estado actual de inicializaciÃ³n
  bool get isInitializing => _isInitializing;
  
  /// NUEVO: Obtener tiempo desde Ãºltima inicializaciÃ³n
  Duration? get tiempoDesdeUltimaInicializacion {
    if (state.lastInitialized == null) return null;
    return DateTime.now().difference(state.lastInitialized!);
  }

  /// NUEVO: Verificar si la sesiÃ³n estÃ¡ activa y vÃ¡lida
  bool get sesionActivaYValida {
    return state.estaAutenticada && 
           state.esMadrina && 
           state.madrinaId != null && 
           state.madrinaId!.isNotEmpty &&
           !state.isInitializing;
  }

  /// NUEVO: Forzar recarga completa de la sesiÃ³n
  Future<void> forzarRecargaCompleta() async {
    
    // Limpiar todo el estado
    state = const MadrinaSessionState();
    
    // Limpiar locks
    _isInitializing = false;
    _initializationCompleter = null;
    
    // Esperar un poco para asegurar que se limpiÃ³ todo
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Reinicializar completamente
    await _inicializarSesion();
    
  }
}

// Provider para la sesiÃ³n de madrina
final madrinaSessionProvider = StateNotifierProvider<MadrinaSessionNotifier, MadrinaSessionState>((ref) {
  final permissionService = ref.watch(permissionServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return MadrinaSessionNotifier(permissionService, authService);
});

// NUEVO: Provider para estado de inicializaciÃ³n de sesiÃ³n
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

// NUEVO: Provider para acciones de sesiÃ³n
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
