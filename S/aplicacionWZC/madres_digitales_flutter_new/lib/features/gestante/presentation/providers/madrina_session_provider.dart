import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/user.dart';

// Estado de sesión de madrina
class MadrinaSessionState {

  const MadrinaSessionState({
    required this.isLoading,
    this.esMadrina = false,
    this.madrinaId,
    this.tieneAccesoRestringido = true,
    this.estaAutenticada = false,
    this.user,
    this.error,
  });
  final bool isLoading;
  final bool esMadrina;
  final String? madrinaId;
  final bool tieneAccesoRestringido;
  final bool estaAutenticada;
  final User? user;
  final String? error;

  MadrinaSessionState copyWith({
    bool? isLoading,
    bool? esMadrina,
    String? madrinaId,
    bool? tieneAccesoRestringido,
    bool? estaAutenticada,
    User? user,
    String? error,
    bool clearError = false,
  }) {
    return MadrinaSessionState(
      isLoading: isLoading ?? this.isLoading,
      esMadrina: esMadrina ?? this.esMadrina,
      madrinaId: madrinaId ?? this.madrinaId,
      tieneAccesoRestringido: tieneAccesoRestringido ?? this.tieneAccesoRestringido,
      estaAutenticada: estaAutenticada ?? this.estaAutenticada,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Provider para gestión de sesión de madrina
class MadrinaSessionNotifier extends StateNotifier<MadrinaSessionState> {
  MadrinaSessionNotifier() : super(const MadrinaSessionState(isLoading: false));

  // Inicializar sesión
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Lógica para inicializar sesión
      // Por ahora, establecemos valores por defecto
      state = state.copyWith(
        isLoading: false,
        esMadrina: true,
        madrinaId: 'default_madrina_id',
        tieneAccesoRestringido: false,
        estaAutenticada: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Verificar si tiene permiso sobre una gestante
  Future<bool> tienePermiso(String gestanteId, String accion) async {
    // Implementación básica - en un caso real esto verificaría en la base de datos
    // Por ahora, devolvemos true para no bloquear funcionalidad
    return true;
  }

  // Establecer como madrina
  void setAsMadrina(String madrinaId, {bool tieneAccesoRestringido = true}) {
    state = state.copyWith(
      esMadrina: true,
      madrinaId: madrinaId,
      tieneAccesoRestringido: tieneAccesoRestringido,
      estaAutenticada: true,
    );
  }

  // Cerrar sesión
  void logout() {
    state = const MadrinaSessionState(isLoading: false);
  }

  // Limpiar error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Provider
final madrinaSessionProvider = StateNotifierProvider<MadrinaSessionNotifier, MadrinaSessionState>((ref) {
  return MadrinaSessionNotifier();
});