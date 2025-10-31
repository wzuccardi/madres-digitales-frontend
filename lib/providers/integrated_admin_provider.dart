import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/integrated_models.dart';
import 'service_providers.dart';

// Providers simples usando FutureProvider como el resto de la app
final municipiosIntegradosProvider = FutureProvider<List<MunicipioIntegrado>>((ref) async {
  try {
    // Usar el endpoint pÃºblico de municipios que no requiere autenticaciÃ³n
    final apiService = ref.read(apiServiceProvider);
    final response = await apiService.get('/municipios');
    
    if (response.data['success'] == true) {
      final List<Map<String, dynamic>> municipiosData =
          List<Map<String, dynamic>>.from(response.data['data']);
      
      // Convertir a MunicipioIntegrado con valores predeterminados
      final municipios = municipiosData.map((municipio) {
        return MunicipioIntegrado(
          id: municipio['id'] ?? '',
          codigo: municipio['codigo_dane'] ?? '',
          nombre: municipio['nombre'] ?? '',
          departamento: municipio['departamento'] ?? '',
          activo: municipio['activo'] ?? true,
          latitud: municipio['latitud']?.toDouble(),
          longitud: municipio['longitud']?.toDouble(),
          created_at: DateTime.parse(municipio['created_at'] ?? DateTime.now().toIso8601String()),
          updated_at: DateTime.parse(municipio['updated_at'] ?? DateTime.now().toIso8601String()),
          // Valores predeterminados para estadÃ­sticas
          totalGestantes: 0,
          gestantesActivas: 0,
          gestantesRiesgoAlto: 0,
          totalMadrinas: 0,
          totalIPS: 0,
          totalMedicos: 0,
          alertasActivas: 0,
        );
      }).toList();
      
      return municipios;
    } else {
      throw Exception(response.data['error'] ?? 'Error desconocido');
    }
  } catch (e) {
    throw Exception('Error cargando municipios: $e');
  }
});

final resumenIntegradoProvider = FutureProvider<ResumenIntegrado>((ref) async {
  try {
    // Usar el endpoint pÃºblico de estadÃ­sticas de municipios que no requiere autenticaciÃ³n
    final apiService = ref.read(apiServiceProvider);
    final response = await apiService.get('/municipios/stats');
    
    if (response.data['success'] == true) {
      final data = response.data['data'];
      final resumen = data['resumen'] as Map<String, dynamic>;
      
      return ResumenIntegrado(
        totalMunicipios: resumen['total'] as int? ?? 0,
        municipiosActivos: resumen['activos'] as int? ?? 0,
        totalIPS: 0, // No disponible en endpoint pÃºblico
        ipsActivas: 0,
        totalMedicos: 0,
        medicosActivos: 0,
        totalGestantes: 0,
        gestantesActivas: 0,
        alertasActivas: 0,
        controlesEsteMes: 0,
        municipiosTopActividad: [],
      );
    } else {
      throw Exception(response.data['error'] ?? 'Error desconocido');
    }
  } catch (e) {
    throw Exception('Error cargando resumen: $e');
  }
});

final ipsIntegradaProvider = FutureProvider.family<List<IPSIntegrada>, String>((ref, municipioId) async {
  final service = await ref.read(integratedAdminServiceProvider.future);
  try {
    final ips = await service.getIPSByMunicipio(municipioId);
    return ips;
  } catch (e) {
    rethrow;
  }
});

final medicosIntegradosProvider = FutureProvider.family<List<MedicoIntegrado>, String>((ref, municipioId) async {
  final service = await ref.read(integratedAdminServiceProvider.future);
  try {
    final medicos = await service.getMedicosByMunicipio(municipioId);
    return medicos;
  } catch (e) {
    rethrow;
  }
});
