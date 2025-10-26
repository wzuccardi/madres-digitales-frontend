import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';
import '../../../../services/auth_service.dart';

// Estados de autenticación
class AuthState {
  final bool isAuthenticated;
  final UserModel? usuario;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.usuario,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? usuario,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      usuario: usuario ?? this.usuario,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier para manejar el estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  // Inicializar el estado de autenticación
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authService.initialize();
      
      if (_authService.isAuthenticated) {
        final userJson = _authService.currentUser;
        if (userJson != null) {
          final usuario = UserModel.fromJson(userJson);
          state = state.copyWith(
            isAuthenticated: true,
            usuario: usuario,
            isLoading: false,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al inicializar autenticación: $e',
      );
    }
  }

  // Login con email y password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _authService.login(email, password);
      
      if (success) {
        final userJson = _authService.currentUser;
        if (userJson != null) {
          final usuario = UserModel.fromJson(userJson);
          state = state.copyWith(
            isAuthenticated: true,
            usuario: usuario,
            isLoading: false,
          );
          return true;
        }
      }
      
      state = state.copyWith(
        isLoading: false,
        error: 'Credenciales inválidas',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error en login: $e',
      );
      return false;
    }
  }

  // Registro de nuevo usuario
  Future<bool> register({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    String? documento,
    String? telefono,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.register(
        nombre: nombre,
        email: email,
        password: password,
        rol: rol,
        documento: documento,
        telefono: telefono,
      );
      
      // Después de registrar, hacer login automáticamente
      return await login(email, password);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error en registro: $e',
      );
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authService.logout();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cerrar sesión: $e',
      );
    }
  }

  // Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Actualizar datos del usuario
  void updateUser(UserModel usuario) {
    state = state.copyWith(usuario: usuario);
  }
}

// Providers
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:54112/api'));
  return AuthRepositoryImpl(dio);
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});

// Provider para facilitar el acceso al usuario actual
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).usuario;
});

// Provider para verificar si el usuario está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

// Provider para obtener el rol del usuario actual
final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).usuario?.rol;
});

// Provider para verificar si el usuario es admin
final isAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == 'admin' || role == 'super_admin';
});

// Provider para verificar si el usuario es coordinador
final isCoordinadorProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == 'coordinador' || role == 'admin' || role == 'super_admin';
});

// Provider para verificar si el usuario es madrina
final isMadrinaProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == 'madrina' || role == 'coordinador' || role == 'admin' || role == 'super_admin';
});
