import 'package:flutter_test/flutter_test.dart';
import 'package:madres_digitales_flutter_new/core/converters/gestante_converter.dart';
import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';

void main() {
  group('Gestante Converter', () {
    test('API → Entidad mapping', () {
      final api = {
        'id': 'g1',
        'nombre': 'Ana',
        'apellido': 'Pérez',
        'documento': '123',
        'telefono': '3000000000',
        'direccion': 'Calle 1',
        'email': 'ana@example.com',
        'fecha_nacimiento': '2000-01-01T00:00:00.000Z',
        'activa': true,
        'riesgo_alto': false,
        'fecha_probable_parto': '2025-05-01T00:00:00.000Z',
        'madrina_id': 'm1',
        'ips_id': 'ips1',
        'medico_tratante_id': 'med1',
        'fecha_ultimo_control': '2025-02-01T00:00:00.000Z',
        'semanas_gestacion': 20,
        'estado': 'activa',
        'created_at': '2025-01-01T00:00:00.000Z',
        'updated_at': '2025-02-01T00:00:00.000Z',
      };

      final g = GestanteConverter.apiToGestante(api);
      expect(g.nombre, 'Ana');
      expect(g.apellido, 'Pérez');
      expect(g.documento, '123');
      expect(g.madrinaId, 'm1');
      expect(g.semanasGestacion, 20);
      expect(g.createdAt, isA<DateTime>());
    });

    test('Entidad → API mapping', () {
      final g = Gestante(
        id: 'g1',
        nombre: 'Ana',
        apellido: 'Pérez',
        documento: '123',
        telefono: '3000000000',
        direccion: 'Calle 1',
        email: 'ana@example.com',
        fechaNacimiento: DateTime.parse('2000-01-01T00:00:00.000Z'),
        eps: 'EPS1',
        activa: true,
        riesgoAlto: false,
        fechaProbableParto: DateTime.parse('2025-05-01T00:00:00.000Z'),
        madrinaId: 'm1',
        ipsId: 'ips1',
        medicoId: 'med1',
        fechaUltimoControl: DateTime.parse('2025-02-01T00:00:00.000Z'),
        semanasGestacion: 20,
        estado: 'activa',
        createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2025-02-01T00:00:00.000Z'),
      );

      final api = GestanteConverter.gestanteToApi(g);
      expect(api['nombre'], 'Ana');
      expect(api['apellido'], 'Pérez');
      expect(api['documento'], '123');
      expect(api['madrina_id'], 'm1');
      expect(api['semanas_gestacion'], 20);
      expect(api['created_at'], isNotNull);
    });
  });
}