import 'package:flutter_riverpod/flutter_riverpod.dart';

final madrinaPermissionsProvider = StateNotifierProvider<MadrinaPermissionsNotifier, Map<String, bool>>((ref) {
  return MadrinaPermissionsNotifier();
});

class MadrinaPermissionsNotifier extends StateNotifier<Map<String, bool>> {
  MadrinaPermissionsNotifier() : super({});

  void updatePermission(String permission, bool value) {
    state = {...state, permission: value};
  }

  bool hasPermission(String permission) {
    return state[permission] ?? false;
  }

  void setInitialPermissions(Map<String, bool> permissions) {
    state = permissions;
  }

  void clearPermissions() {
    state = {};
  }

  // Permisos específicos para madrinas
  static const String VER_GESTANTE = 'ver_gestante';
  static const String EDITAR_GESTANTE = 'editar_gestante';
  static const String CREAR_CONTROL = 'crear_control';
  static const String VER_ALERTAS = 'ver_alertas';
  static const String CREAR_ALERTA = 'crear_alerta';
  static const String ACTIVAR_SOS = 'activar_sos';
}