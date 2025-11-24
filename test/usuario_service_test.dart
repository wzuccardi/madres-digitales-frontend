import 'package:flutter_test/flutter_test.dart';
import 'package:madres_digitales_flutter_new/models/integrated_models.dart';

void main() {
  test('UsuarioModel copyWith y getters', () {
    final u = UsuarioModel(id: '1', nombre: 'Juan', email: 'juan@test.com', rol: 'ADMIN', activo: true);
    final u2 = u.copyWith(nombre: 'Juan Perez', activo: false);
    expect(u2.nombreCompleto, 'Juan Perez');
    expect(u2.activo, false);
    expect(u2.rol, 'ADMIN');
  });
}