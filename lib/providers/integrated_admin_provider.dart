import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/integrated_models.dart';
import 'service_providers.dart';

// Providers simples usando FutureProvider como el resto de la app
final municipiosIntegradosProvider = FutureProvider<List<MunicipioIntegrado>>((ref) async {
  try {
    debugPrint('🔍 [IntegratedAdminProvider] Cargando municipios integrados');
    // Usar el endpoint público de municipios que no requiere autenticación
    final apiService = ref.read(apiServiceProvider);
    debugPrint('🔧 [IntegratedAdminProvider] ApiService hash: ${apiService.hashCode}');
    final response = await apiService.get('/municipios');
    debugPrint('🔍 [IntegratedAdminProvider] Respuesta municipios: ${response.statusCode}');
    
    if (response.data['success'] == true) {
      final List<Map<String, dynamic>> municipiosData =
          List<Map<String, dynamic>>.from(response.data['data']);
      debugPrint('✅ [IntegratedAdminProvider] Procesando ${municipiosData.length} municipios');
      
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
          // Valores predeterminados para estadísticas
          totalGestantes: 0,
          gestantesActivas: 0,
          gestantesRiesgoAlto: 0,
          totalMadrinas: 0,
          totalIPS: 0,
          totalMedicos: 0,
          alertasActivas: 0,
        );
      }).toList();
      
      debugPrint('✅ [IntegratedAdminProvider] Municipios convertidos exitosamente');
      return municipios;
    } else {
      debugPrint('❌ [IntegratedAdminProvider] Error en respuesta: ${response.data['error']}');
      throw Exception(response.data['error'] ?? 'Error desconocido');
    }
  } catch (e) {
    debugPrint('❌ [IntegratedAdminProvider] Error cargando municipios: $e');
    debugPrint('❌ [IntegratedAdminProvider] Stack trace: ${StackTrace.current}');
    throw Exception('Error cargando municipios: $e');
  }
});

final resumenIntegradoProvider = FutureProvider<ResumenIntegrado>((ref) async {
  try {
    // Usar el endpoint público de estadísticas de municipios que no requiere autenticación
    final apiService = ref.read(apiServiceProvider);
    final response = await apiService.get('/municipios/stats');
    
    if (response.data['success'] == true) {
      final data = response.data['data'];
      final resumen = data['resumen'] as Map<String, dynamic>;
      
      return ResumenIntegrado(
        totalMunicipios: resumen['total'] as int? ?? 0,
        municipiosActivos: resumen['activos'] as int? ?? 0,
        totalIPS: 0, // No disponible en endpoint público
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
  debugPrint('🔍 [IntegratedAdminProvider] Cargando IPS para municipio: $municipioId');
  final service = await ref.read(integratedAdminServiceProvider.future);
  debugPrint('🔧 [IntegratedAdminProvider] IntegratedAdminService hash: ${service.hashCode}');
  debugPrint('⚠️ [IntegratedAdminProvider] ADVERTENCIA: IntegratedAdminService no tiene dependencias inyectadas');
  try {
    final ips = await service.getIPSByMunicipio(municipioId);
    debugPrint('✅ [IntegratedAdminProvider] Se obtuvieron ${ips.length} IPS para municipio $municipioId');
    return ips;
  } catch (e) {
    debugPrint('❌ [IntegratedAdminProvider] Error obteniendo IPS: $e');
    rethrow;
  }
});

final medicosIntegradosProvider = FutureProvider.family<List<MedicoIntegrado>, String>((ref, municipioId) async {
  debugPrint('🔍 [IntegratedAdminProvider] Cargando médicos para municipio: $municipioId');
  final service = await ref.read(integratedAdminServiceProvider.future);
  debugPrint('🔧 [IntegratedAdminProvider] IntegratedAdminService hash: ${service.hashCode}');
  debugPrint('⚠️ [IntegratedAdminProvider] ADVERTENCIA: IntegratedAdminService no tiene dependencias inyectadas');
  try {
    final medicos = await service.getMedicosByMunicipio(municipioId);
    debugPrint('✅ [IntegratedAdminProvider] Se obtuvieron ${medicos.length} médicos para municipio $municipioId');
    return medicos;
  } catch (e) {
    debugPrint('❌ [IntegratedAdminProvider] Error obteniendo médicos: $e');
    rethrow;
  }
});