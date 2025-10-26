import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/service_providers.dart';
import '../../domain/entities/alerta.dart';

final alertaProvider = AsyncNotifierProvider<AlertaNotifier, List<Alerta>>(() {
  return AlertaNotifier();
});

class AlertaNotifier extends AsyncNotifier<List<Alerta>> {
  @override
  Future<List<Alerta>> build() async {
    return await _fetchAlertas();
  }

  Future<List<Alerta>> _fetchAlertas() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/alertas');
      final List<dynamic> data = response.data;
      return data.map((json) => Alerta.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar alertas: $e');
    }
  }

  Future<void> addAlerta(Alerta alerta) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.post('/alertas', data: alerta.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Error al agregar alerta: $e');
    }
  }

  Future<void> updateAlerta(String id, Alerta alerta) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.put('/alertas/$id', data: alerta.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Error al actualizar alerta: $e');
    }
  }

  Future<void> deleteAlerta(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.delete('/alertas/$id');
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Error al eliminar alerta: $e');
    }
  }
}
