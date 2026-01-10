import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import '../../domain/entities/alerta.dart';
import 'dart:async';

final alertaProvider = AsyncNotifierProvider<AlertaNotifier, List<Alerta>>(() {
  return AlertaNotifier();
});

class AlertaNotifier extends AsyncNotifier<List<Alerta>> {
  StreamSubscription? _alertaCreatedSub;
  StreamSubscription? _controlCreatedSub;
  @override
  Future<List<Alerta>> build() async {
    await _subscribeRealtime();
    return await _fetchAlertas();
  }

  Future<List<Alerta>> _fetchAlertas() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get<dynamic>('/api/alertas');
      final List<dynamic> data = apiService.extractList(response.data);
      return data.map((json) => Alerta.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar alertas: $e');
    }
  }

  Future<void> addAlerta(Alerta alerta) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.post('/api/alertas', data: alerta.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Error al agregar alerta: $e');
    }
  }

  Future<void> _subscribeRealtime() async {
    final ws = ref.read(webSocketServiceProvider);
    await ws.connect();
    _alertaCreatedSub = ws.stream<Map<String, dynamic>>('alerta:created').listen((data) {
      ref.invalidateSelf();
    });
    _controlCreatedSub = ws.stream<Map<String, dynamic>>('control:created').listen((data) {
      ref.invalidateSelf();
    });
    ref.onDispose(() {
      _alertaCreatedSub?.cancel();
      _controlCreatedSub?.cancel();
    });
  }

  Future<void> updateAlerta(String id, Alerta alerta) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.put('/api/alertas/$id', data: alerta.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Error al actualizar alerta: $e');
    }
  }

  Future<void> deleteAlerta(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.delete('/api/alertas/$id');
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Error al eliminar alerta: $e');
    }
  }
}
