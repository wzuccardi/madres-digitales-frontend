import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/models/integrated_models.dart';
import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

final municipiosIntegradosProvider = FutureProvider<List<MunicipioIntegrado>>((ref) async {
  final svc = ref.read(municipioServiceProvider);
  return await svc.getAllMunicipios();
});

final resumenIntegradoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final svc = ref.read(municipioServiceProvider);
  final stats = await svc.getStats();
  return stats;
});

class IntegratedAdminService {
  IntegratedAdminService([ApiService? api]) : _api = api ?? ApiService();
  final ApiService _api;

  Future<void> toggleMunicipioEstado(String municipioId, bool activo) async {
    await _api.put<Map<String, dynamic>>('/api/municipios/$municipioId/estado', data: {
      'activo': activo,
    });
  }
}

final integratedAdminServiceProvider = FutureProvider<IntegratedAdminService>((ref) async {
  final api = ref.read(apiServiceProvider);
  return IntegratedAdminService(api);
});