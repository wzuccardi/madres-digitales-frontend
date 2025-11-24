import 'package:flutter_test/flutter_test.dart';
import 'package:madres_digitales_flutter_new/models/integrated_models.dart';

void main() {
  test('MunicipioIntegrado estado getters', () {
    final m1 = MunicipioIntegrado(id: '1', nombre: 'Cartagena', activo: true);
    expect(m1.estadoTexto, 'ACTIVO');
    final m2 = m1.copyWith(activo: false);
    expect(m2.estadoTexto, 'INACTIVO');
  });
}