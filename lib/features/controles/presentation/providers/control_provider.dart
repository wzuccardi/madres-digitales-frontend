import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/service_providers.dart';
import '../../domain/entities/control.dart';

final controlProvider = AsyncNotifierProvider<ControlNotifier, List<Control>>(() {
  return ControlNotifier();
});

class ControlNotifier extends AsyncNotifier<List<Control>> {
  @override
  Future<List<Control>> build() async {
    return await _fetchControles();
  }

  Future<List<Control>> _fetchControles() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/controles');
      final List<dynamic> data = response.data;
      return data.map((json) => Control.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar controles: $e');
    }
  }

  Future<void> addControl(Control control) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.post('/controles', data: control.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Error al agregar control: $e');
    }
  }

  Future<void> updateControl(String id, Control control) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.put('/controles/$id', data: control.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Error al actualizar control: $e');
    }
  }

  Future<void> deleteControl(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.delete('/controles/$id');
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Error al eliminar control: $e');
    }
  }
}
