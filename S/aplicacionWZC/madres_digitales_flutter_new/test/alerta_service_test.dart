import 'package:flutter_test/flutter_test.dart';
import 'package:madres_digitales_flutter_new/data/services/alerta_service.dart';

void main() {
  test('AlertaService constantes de filtros', () {
    expect(AlertaService.nivelesPrioridad.contains('critica'), true);
    expect(AlertaService.tiposAlerta.contains('hipertension'), true);
    expect(AlertaService.sintomasComunes.contains('fiebre'), true);
  });
}