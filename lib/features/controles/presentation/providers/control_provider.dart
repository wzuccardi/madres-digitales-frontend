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

      // Manejar estructura de respuesta del backend: { success: true, data: { controles: [...] } }
      List<dynamic> controlesData = [];
      if (response.data is Map && response.data['data'] != null) {
        final dataValue = response.data['data'];
        if (dataValue is List) {
          // Formato: { success: true, data: [...] } (controles vencidos/pendientes)
          controlesData = dataValue;
        } else if (dataValue is Map && dataValue['controles'] != null) {
          // Formato: { success: true, data: { controles: [...] } } (controles normales)
          final controlesValue = dataValue['controles'];
          if (controlesValue is List) {
            controlesData = controlesValue;
          }
        }
      } else if (response.data is List) {
        controlesData = response.data;
      }

      return controlesData.map((json) => Control.fromJson(json)).toList();
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
