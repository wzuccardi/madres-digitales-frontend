class Permissions {
  final Map<String, bool> _permissions;

  Permissions(this._permissions);

  bool hasPermission(String permission) {
    return _permissions[permission] ?? false;
  }

  void updatePermission(String permission, bool value) {
    _permissions[permission] = value;
  }

  Map<String, bool> getAllPermissions() {
    return Map.from(_permissions);
  }

  // Permisos específicos para madrinas
  static const String VER_GESTANTE = 'ver_gestante';
  static const String EDITAR_GESTANTE = 'editar_gestante';
  static const String CREAR_CONTROL = 'crear_control';
  static const String VER_ALERTAS = 'ver_alertas';
  static const String CREAR_ALERTA = 'crear_alerta';
  static const String activarSos = 'activar_sos';
}