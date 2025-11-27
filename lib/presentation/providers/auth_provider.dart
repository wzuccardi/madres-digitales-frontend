import '../../../../../core/network/api_service.dart';
import '../../../../domain/entities/user.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/usecases/auth/sign_in_usecase.dart';
import '../../../../domain/usecases/auth/sign_up_usecase.dart';
import '../../../../domain/usecases/auth/sign_out_usecase.dart';
import '../../../../domain/usecases/auth/get_current_user_usecase.dart';
import 'package:madres_digitales_flutter_new/application/di/usecase_providers.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import '../../../core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import '../../../core/constants/app_constants.dart';


// Estado de autenticación
class AuthState {

  const AuthState({
    required this.isAuthenticated,
    this.user,
    required this.isLoading,
    this.error,
    this.lastLoginAttempt,
    required this.loginAttempts,
    this.permissionsCache = const {},
    this.permissionsTimestamps = const {},
    this.isInitializing = false,
    this.lastInitialized,
  });
  final bool isAuthenticated;
  final User? user;
  User? get usuario => user;
  final bool isLoading;
  final AppError? error;
  final DateTime? lastLoginAttempt;
  final int loginAttempts;
  final Map<String, Set<String>> permissionsCache;
  final Map<String, DateTime> permissionsTimestamps;
  final bool isInitializing;
  final DateTime? lastInitialized;

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    AppError? error,
    DateTime? lastLoginAttempt,
    int? loginAttempts,
    Map<String, Set<String>>? permissionsCache,
    Map<String, DateTime>? permissionsTimestamps,
    bool? isInitializing,
    DateTime? lastInitialized,
    bool clearError = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastLoginAttempt: lastLoginAttempt ?? this.lastLoginAttempt,
      loginAttempts: loginAttempts ?? this.loginAttempts,
      permissionsCache: permissionsCache ?? this.permissionsCache,
      permissionsTimestamps: permissionsTimestamps ?? this.permissionsTimestamps,
      isInitializing: isInitializing ?? this.isInitializing,
      lastInitialized: lastInitialized ?? this.lastInitialized,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.user == user &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.lastLoginAttempt == lastLoginAttempt &&
        other.loginAttempts == loginAttempts &&
        other.permissionsCache == permissionsCache &&
        other.permissionsTimestamps == permissionsTimestamps &&
        other.isInitializing == isInitializing &&
        other.lastInitialized == lastInitialized;
  }

  @override
  int get hashCode => Object.hash(
        isAuthenticated,
        user,
        isLoading,
        error,
        lastLoginAttempt,
        loginAttempts,
        permissionsCache,
        permissionsTimestamps,
        isInitializing,
        lastInitialized,
      );

  @override
  String toString() {
    return 'AuthState(isAuthenticated: $isAuthenticated, user: $user, isLoading: $isLoading, error: $error, lastLoginAttempt: $lastLoginAttempt, loginAttempts: $loginAttempts, isInitializing: $isInitializing, lastInitialized: $lastInitialized)';
  }
}

// Provider de autenticación consolidado usando casos de uso
class AuthProvider extends StateNotifier<AuthState> {

  AuthProvider(
    this._signInUseCase,
    this._signUpUseCase,
    this._signOutUseCase,
    this._getCurrentUserUseCase,
    this._apiService,
  ) : super(const AuthState(
        isAuthenticated: false,
        isLoading: false,
        loginAttempts: 0,
      )) {
    _initializeAuth();
  }
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ApiService _apiService;
  
  // Variables para controlar inicialización
  bool _isInitializing = false;
  Completer<void>? _initializationCompleter;
  
  // Cache de duración reducida (5 minutos)
  static const int _cacheDurationMinutes = 5;
  
  // Control de tiempo para evitar inicializaciones demasiado frecuentes
  static const Duration _minTimeBetweenInitializations = Duration(seconds: 2);

  // Iniciar sesión usando caso de uso
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final params = SignInParams(email: email, password: password);
      final result = await _signInUseCase(params);
      if (result.isFailure) {
        state = state.copyWith(
          isLoading: false,
          error: result.errorOrThrow,
          lastLoginAttempt: DateTime.now(),
          loginAttempts: state.loginAttempts + 1,
        );
        AppLogger.error('Login failed: ${result.errorOrThrow.message}');
        if (state.loginAttempts >= AppConstants.maxLoginAttempts) {
          state = state.copyWith(
            error: const AuthError('Too many login attempts. Account temporarily locked.'),
          );
        }
        return;
      }
      final user = result.dataOrThrow;
      
      // DEBUG: Log user role information
      print('🐛 AUTH DEBUG: User logged in - Email: ${user.email}, Role: ${user.role}');
      print('🐛 AUTH DEBUG: Role comparison with constants:');
      print('🐛 AUTH DEBUG: isSuperAdmin? ${user.role == AppConstants.superAdminRole}');
      print('🐛 AUTH DEBUG: isAdmin? ${user.role == AppConstants.adminRole}');
      print('🐛 AUTH DEBUG: isCoordinator? ${user.role == AppConstants.coordinatorRole}');
      
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
        error: null,
        lastLoginAttempt: DateTime.now(),
        loginAttempts: 0,
      );
      
      AppLogger.info('User logged in successfully: ${user.email}');
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
        lastLoginAttempt: DateTime.now(),
        loginAttempts: state.loginAttempts + 1,
      );
      
      AppLogger.error('Login failed: ${e.message}');
      
      // Verificar si se debe bloquear la cuenta
      if (state.loginAttempts >= AppConstants.maxLoginAttempts) {
        state = state.copyWith(
          error: const AuthError(
            'Too many login attempts. Account temporarily locked.',
          ),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
        lastLoginAttempt: DateTime.now(),
        loginAttempts: state.loginAttempts + 1,
      );
      
      AppLogger.error('Login exception: $e');
    }
  }

  // Registrar usuario usando caso de uso
  Future<void> register(String name, String email, String password, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final params = SignUpParams(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      final result = await _signUpUseCase(params);
      if (result.isFailure) {
        state = state.copyWith(
          isLoading: false,
          error: result.errorOrThrow,
          lastLoginAttempt: DateTime.now(),
        );
        AppLogger.error('Registration failed: ${result.errorOrThrow.message}');
        return;
      }
      final user = result.dataOrThrow;
      
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
        error: null,
        lastLoginAttempt: DateTime.now(),
        loginAttempts: 0,
      );
      
      AppLogger.info('User registered successfully: ${user.email}');
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
        lastLoginAttempt: DateTime.now(),
      );
      
      AppLogger.error('Registration failed: ${e.message}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
        lastLoginAttempt: DateTime.now(),
      );
      
      AppLogger.error('Registration exception: $e');
    }
  }

  // Cerrar sesión usando caso de uso
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _signOutUseCase();
      if (result.isFailure) {
        state = AuthState(
          isAuthenticated: false,
          isLoading: false,
          error: result.errorOrThrow,
          loginAttempts: 0,
        );
        AppLogger.error('Logout failed: ${result.errorOrThrow.message}');
        return;
      }
      
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
        loginAttempts: 0,
      );
      
      AppLogger.info('User logged out successfully');
    } on AppError catch (e) {
      state = AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: e,
        loginAttempts: 0,
      );
      
      AppLogger.error('Logout failed: ${e.message}');
    } catch (e) {
      // Incluso si falla el logout, limpiar estado
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
        loginAttempts: 0,
      );
      
      AppLogger.error('Logout exception: $e');
    }
  }

  Future<void> signOut() async {
    await logout();
  }

  // Refrescar token (mantenido de la versión completa)
  Future<void> refreshToken() async {
    if (!state.isAuthenticated) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final refreshToken = await _apiService.getRefreshToken();
      
      if (refreshToken == null) {
        throw const InvalidTokenError('No refresh token available');
      }
      
      final response = await _apiService.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      
      if (response.success && response.data != null) {
        final userData = response.data!;
        final user = User.fromJson(userData['user'] as Map<String, dynamic>);
        
        // Guardar nuevos tokens
        await _apiService.saveTokens(
          userData['accessToken'] ?? '',
          userData['refreshToken'] ?? '',
        );
        
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
          error: null,
        );
        
        AppLogger.info('Token refreshed successfully');
      } else {
        final error = response.error ?? const UnknownError('Token refresh failed');
        
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        
        AppLogger.error('Token refresh failed: ${error.message}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
      );
      
      AppLogger.error('Token refresh exception: $e');
    }
  }

  // Obtener usuario actual usando caso de uso
  Future<void> getCurrentUser() async {
    if (state.user != null) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _getCurrentUserUseCase.call();
      if (result.isFailure) {
        state = state.copyWith(
          isLoading: false,
          error: result.errorOrThrow,
        );
        AppLogger.error('Get current user failed: ${result.errorOrThrow.message}');
        return;
      }
      final user = result.dataOrThrow;
      
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
        error: null,
      );
      
      AppLogger.info('Current user retrieved successfully');
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
      
      AppLogger.error('Get current user failed: ${e.message}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
      );
      
      AppLogger.error('Get current user exception: $e');
    }
  }

  // Cambiar contraseña (mantenido de la versión completa)
  Future<void> changePassword(String oldPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.post('/auth/change-password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      
      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        
        AppLogger.info('Password changed successfully');
      } else {
        final error = response.error ?? const UnknownError('Failed to change password');
        
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        
        AppLogger.error('Change password failed: ${error.message}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
      );
      
      AppLogger.error('Change password exception: $e');
    }
  }

  // Resetear contraseña (mantenido de la versión completa)
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.post('/auth/forgot-password', data: {
        'email': email,
      });
      
      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        
        AppLogger.info('Password reset email sent successfully');
      } else {
        final error = response.error ?? const UnknownError('Failed to reset password');
        
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        
        AppLogger.error('Reset password failed: ${error.message}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
      );
      
      AppLogger.error('Reset password exception: $e');
    }
  }

  // Confirmar reseteo de contraseña (mantenido de la versión completa)
  Future<void> confirmResetPassword(String token, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.post('/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
      });
      
      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        
        AppLogger.info('Password reset confirmed successfully');
      } else {
        final error = response.error ?? const UnknownError('Failed to confirm reset password');
        
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        
        AppLogger.error('Confirm reset password failed: ${error.message}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
      );
      
      AppLogger.error('Confirm reset password exception: $e');
    }
  }

  // Limpiar errores
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Verificar si el usuario está autenticado
  bool get isAuthenticated => state.isAuthenticated;

  // Obtener usuario actual
  User? get user => state.user;

  // Verificar si está cargando
  bool get isLoading => state.isLoading;

  // Obtener error actual
  AppError? get error => state.error;

  // Verificar si la cuenta está bloqueada
  bool get isAccountLocked => state.loginAttempts >= AppConstants.maxLoginAttempts;

  // Obtener intentos de login
  int get loginAttempts => state.loginAttempts;

  // Verificar rol del usuario
  bool get isAdmin => state.user?.role == AppConstants.adminRole;
  bool get isMadrina => state.user?.role == AppConstants.madrinaRole;
  bool get isMedico => state.user?.role == AppConstants.medicoRole;
  bool get isGestante => state.user?.role == AppConstants.gestanteRole;
  bool get isCoordinator => state.user?.role == AppConstants.coordinatorRole;
  bool get isSuperAdmin => state.user?.role == AppConstants.superAdminRole;

  // Verificar permisos específicos
  bool get canManageUsers => isAdmin || isSuperAdmin;
  bool get canManageGestantes => isMadrina || isMedico || isCoordinator || isAdmin || isSuperAdmin;
  bool get canViewReports => isCoordinator || isAdmin || isSuperAdmin;
  bool get canManageSettings => isSuperAdmin;
  
  // Métodos adicionales para gestión de sesión y permisos
  
  /// Inicializar la autenticación con control de concurrencia
  Future<void> _initializeAuth() async {
    // Prevenir múltiples inicializaciones simultáneas
    if (_isInitializing) {
      try {
        await _initializationCompleter?.future;
        return;
      } catch (e) {
        // Si la inicialización previa falló, continuar con nueva inicialización
      }
    }

    // Verificar si pasó tiempo mínimo desde última inicialización
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
      // Verificar si hay tokens guardados
      final accessToken = await _apiService.getAccessToken();
      
      if (accessToken != null) {
        // Obtener usuario actual con el token usando caso de uso
        final result = await _getCurrentUserUseCase.call();
        final user = result.isSuccess ? result.dataOrThrow : null;
        state = AuthState(
          isAuthenticated: true,
          user: user,
          isLoading: false,
          loginAttempts: 0,
          isInitializing: false,
          lastInitialized: DateTime.now(),
          error: null,
        );
        
        if (user != null) {
          AppLogger.info('User authenticated from stored token: ${user.email}');
        } else {
          AppLogger.info('Token present but user could not be fetched');
        }
      } else {
        // No hay tokens, usuario no autenticado
        state = const AuthState(
          isAuthenticated: false,
          isLoading: false,
          loginAttempts: 0,
          isInitializing: false,
        );
        
        AppLogger.info('No stored tokens found, user not authenticated');
      }
      
      _initializationCompleter?.complete();
    } catch (e) {
      // Token inválido, limpiar tokens
      await _apiService.clearTokens();
      
      state = AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: NetworkError(e.toString()),
        loginAttempts: 0,
        isInitializing: false,
      );
      
      AppLogger.error('Auth initialization failed: $e');
      _initializationCompleter?.completeError(e);
    } finally {
      _isInitializing = false;
      _initializationCompleter = null;
    }
  }
  
  /// Verificar si tiene permiso sobre una gestante con invalidación automática
  Future<bool> tienePermisoSobreGestante(String gestanteId, String accion) async {
    final id = user?.id ?? '';
    if (!isAuthenticated || id.isEmpty) {
      return false;
    }

    // Si tiene acceso completo, verificar permisos directamente
    if (!tieneAccesoRestringido) {
      return true; // Admins y super admins tienen todos los permisos
    }

    // Verificar si el cache es válido (con tiempo reducido)
    final cacheKey = gestanteId;
    if (_isCacheValid(cacheKey)) {
      final permisos = state.permissionsCache[cacheKey] ?? <String>{};
      final tienePermiso = permisos.contains(accion);
      return tienePermiso;
    }

    // Para madrinas con acceso restringido, verificar permisos específicos
    try {
      // Aquí se podría llamar a un servicio de permisos específico
      // Por ahora, implementamos lógica básica
      final tienePermiso = await _verificarPermisoEspecifico(gestanteId, accion);
      
      // Actualizar caché con tiempo reducido (5 minutos)
      if (tienePermiso) {
        final nuevosPermisos = Map<String, Set<String>>.from(state.permissionsCache);
        final permisosExistentes = nuevosPermisos[cacheKey] ?? <String>{};
        permisosExistentes.add(accion);
        nuevosPermisos[cacheKey] = permisosExistentes;
        
        final nuevosTimestamps = Map<String, DateTime>.from(state.permissionsTimestamps);
        nuevosTimestamps[cacheKey] = DateTime.now();
        
        state = state.copyWith(
          permissionsCache: nuevosPermisos,
          permissionsTimestamps: nuevosTimestamps,
        );
      }
      
      return tienePermiso;
    } catch (e) {
      AppLogger.error('Error verificando permiso', error: e, context: {
        'gestanteId': gestanteId,
        'accion': accion,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return false;
    }
  }
  
  /// Verificar si tiene un permiso general
  bool tienePermisoGeneral(String permiso) {
    final id = user?.id ?? '';
    if (!isAuthenticated || id.isEmpty) {
      return false;
    }

    // Si tiene acceso completo, tiene todos los permisos generales
    if (!tieneAccesoRestringido) {
      return true;
    }

    // Verificar permisos específicos según el rol
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
        return ['admin', 'super_admin', 'coordinador'].contains(user?.role);
      case 'gestionar_usuarios':
        return ['admin', 'super_admin'].contains(user?.role);
      case 'gestionar_municipios':
        return ['admin', 'super_admin'].contains(user?.role);
      default:
        return false;
    }
  }
  
  /// Verificar si el usuario tiene acceso restringido
  bool get tieneAccesoRestringido {
    final rol = user?.role;
    return isMadrina &&
        !['admin', 'super_admin', 'coordinador', 'medico'].contains(rol);
  }
  
  /// Invalidar cache de permisos para una gestante específica
  Future<void> invalidarPermisosGestante(String gestanteId) async {
    final nuevosPermisos = Map<String, Set<String>>.from(state.permissionsCache);
    final nuevosTimestamps = Map<String, DateTime>.from(state.permissionsTimestamps);
    
    nuevosPermisos.remove(gestanteId);
    nuevosTimestamps.remove(gestanteId);
    
    state = state.copyWith(
      permissionsCache: nuevosPermisos,
      permissionsTimestamps: nuevosTimestamps,
    );
    
    AppLogger.info('Permisos invalidados para gestante', context: {
      'gestanteId': gestanteId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Invalidar todo el cache de permisos
  Future<void> invalidarTodosLosPermisos() async {
    state = state.copyWith(
      permissionsCache: const {},
      permissionsTimestamps: const {},
    );
    
    AppLogger.info('Todo el cache de permisos invalidado', context: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// Verificar si el cache es válido (con tiempo reducido)
  bool _isCacheValid(String gestanteId) {
    if (!state.permissionsCache.containsKey(gestanteId) ||
        !state.permissionsTimestamps.containsKey(gestanteId)) {
      return false;
    }
    
    // Reducir tiempo de cache de 15 a 5 minutos
    final ts = state.permissionsTimestamps[gestanteId];
    if (ts == null) return false;
    final cacheAge = DateTime.now().difference(ts);
    return cacheAge.inMinutes < _cacheDurationMinutes;
  }
  
  /// Refrescar la sesión con control de concurrencia
  Future<void> refrescarSesion({bool forzar = false}) async {
    // Si no se fuerza, verificar si ya hay una inicialización en progreso
    if (!forzar && _isInitializing) {
      await _initializationCompleter?.future;
      return;
    }
    
    // Si se fuerza, limpiar locks y esperar un poco
    if (forzar) {
      _isInitializing = false;
      _initializationCompleter = null;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    await _initializeAuth();
  }
  
  /// Forzar recarga completa de la sesión
  Future<void> forzarRecargaCompleta() async {
    // Limpiar todo el estado
    state = const AuthState(isAuthenticated: false, isLoading: false, loginAttempts: 0);
    
    // Limpiar locks
    _isInitializing = false;
    _initializationCompleter = null;
    
    // Esperar un poco para asegurar que se limpió todo
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Reinicializar completamente
    await _initializeAuth();
  }
  
  /// Verificar permiso específico (implementación básica)
  Future<bool> _verificarPermisoEspecifico(String gestanteId, String accion) async {
    // Implementación básica - en un caso real esto llamaría a un servicio
    // Por ahora, asumimos que las madrinas tienen acceso a gestantes asignadas
    if (isMadrina) {
      // Aquí se verificaría si la gestante está asignada a esta madrina
      // Por ahora, devolvemos true para no bloquear funcionalidad
      return true;
    }
    return false;
  }
  
  /// Obtener estado actual de inicialización
  bool get isInitializing => _isInitializing;
  
  /// Obtener tiempo desde última inicialización
  Duration? get tiempoDesdeUltimaInicializacion {
    if (state.lastInitialized == null) return null;
    return DateTime.now().difference(state.lastInitialized!);
  }

  /// Verificar si la sesión está activa y válida
  bool get sesionActivaYValida {
    return state.isAuthenticated &&
           state.user != null &&
           state.user!.id.isNotEmpty &&
           !state.isInitializing;
  }
}

// Provider para verificar estado de autenticación al iniciar la app
class AuthInitializer extends StateNotifier<AuthState> {

  AuthInitializer(
    this._getCurrentUserUseCase,
    this._apiService,
  ) : super(const AuthState(
        isAuthenticated: false,
        isLoading: true,
        loginAttempts: 0,
      ));
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ApiService _apiService;

  Future<void> initialize() async {
    try {
      // Verificar si hay tokens guardados
      final accessToken = await _apiService.getAccessToken();
      
      if (accessToken != null) {
        final result = await _getCurrentUserUseCase.call();
        final user = result.isSuccess ? result.dataOrThrow : null;
        state = AuthState(
          isAuthenticated: user != null,
          user: user,
          isLoading: false,
          loginAttempts: 0,
        );
        if (user != null) {
          AppLogger.info('User authenticated from stored token: ${user.email}');
        } else {
          AppLogger.info('Token present but user could not be fetched');
        }
      } else {
        // No hay tokens, usuario no autenticado
        state = const AuthState(
          isAuthenticated: false,
          isLoading: false,
          loginAttempts: 0,
        );
        
        AppLogger.info('No stored tokens found, user not authenticated');
      }
    } catch (e) {
      // Token inválido, limpiar tokens
      await _apiService.clearTokens();
      
      state = AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: NetworkError(e.toString()),
        loginAttempts: 0,
      );
      
      AppLogger.error('Auth initialization failed: $e');
    }
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  // Inyectar casos de uso
  final signIn = ref.read(signInUseCaseProvider);
  final signUp = ref.read(signUpUseCaseProvider);
  final signOut = ref.read(signOutUseCaseProvider);
  final getCurrent = ref.read(getCurrentUserUseCaseProvider);
  final apiService = ref.read(apiServiceProvider);

  return AuthProvider(
    signIn,
    signUp,
    signOut,
    getCurrent,
    apiService,
  );
});

final authInitializerProvider = StateNotifierProvider<AuthInitializer, AuthState>((ref) {
  final getCurrent = ref.read(getCurrentUserUseCaseProvider);
  final apiService = ref.read(apiServiceProvider);

  return AuthInitializer(getCurrent, apiService);
});

// Provider para observar el estado de autenticación
final authStateProvider = Provider<AuthState>((ref) => ref.watch(authProvider));

// Providers específicos para valores booleanos
final isAuthenticatedProvider = Provider<bool>((ref) => ref.watch(authProvider.notifier).isAuthenticated);
final currentUserProvider = Provider<User?>((ref) => ref.watch(authProvider.notifier).user);
final isLoadingProvider = Provider<bool>((ref) => ref.watch(authProvider.notifier).isLoading);
final authErrorProvider = Provider<AppError?>((ref) => ref.watch(authProvider.notifier).error);
final isAdminProvider = Provider<bool>((ref) => ref.watch(authProvider.notifier).isAdmin);
final isMadrinaProvider = Provider<bool>((ref) => ref.watch(authProvider.notifier).isMadrina);
final isMedicoProvider = Provider<bool>((ref) => ref.watch(authProvider.notifier).isMedico);
final isGestanteProvider = Provider<bool>((ref) => ref.watch(authProvider.notifier).isGestante);
final isCoordinatorProvider = Provider<bool>((ref) => ref.watch(authProvider.notifier).isCoordinator);
final isSuperAdminProvider = Provider<bool>((ref) => ref.watch(authProvider.notifier).isSuperAdmin);
final canManageUsersProvider = Provider<bool>((ref) => ref.watch(authProvider.notifier).canManageUsers);
final canManageGestantesProvider = Provider<bool>((ref) => ref.watch(authProvider.notifier).canManageGestantes);
final canViewReportsProvider = Provider<bool>((ref) => ref.watch(authProvider.notifier).canViewReports);
final canManageSettingsProvider = Provider<bool>((ref) => ref.watch(authProvider.notifier).canManageSettings);
final isAccountLockedProvider = Provider<bool>((ref) => ref.watch(authProvider.notifier).isAccountLocked);
final loginAttemptsProvider = Provider<int>((ref) => ref.watch(authProvider.notifier).loginAttempts);
