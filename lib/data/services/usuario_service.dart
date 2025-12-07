import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import 'package:madres_digitales_flutter_new/models/integrated_models.dart';

class UsuarioService {
  UsuarioService({ApiService? apiService}) : _apiService = apiService ?? ApiService();
  final ApiService _apiService;

  Future<List<UsuarioModel>> obtenerUsuarios() async {
    try {
      final resp = await _apiService.get<Map<String, dynamic>>('/usuarios');
      if (!resp.success || resp.data == null) {
        AppLogger.warning('UsuarioService.obtenerUsuarios: No data received');
        return [];
      }
      
      final root = resp.data as Map<String, dynamic>;
      
      // El backend devuelve {success: true, data: [...]}
      List<dynamic> list;
      if (root.containsKey('data') && root['data'] is List) {
        list = root['data'] as List;
      } else if (root.containsKey('usuarios') && root['usuarios'] is List) {
        list = root['usuarios'] as List;
      } else if (root is List) {
        list = root;
      } else {
        AppLogger.warning('UsuarioService.obtenerUsuarios: Unexpected data format', context: {'root': root});
        return [];
      }
      
      AppLogger.info('UsuarioService.obtenerUsuarios: Found ${list.length} users');
      
      return list.map((j) {
        final m = j as Map<String, dynamic>;
        return UsuarioModel(
          id: (m['id'] ?? '').toString(),
          nombre: (m['name'] ?? m['nombre'] ?? '').toString(),
          email: (m['email'] ?? '').toString(),
          rol: (m['role'] ?? m['rol'] ?? 'USER').toString(),
          activo: (m['activo'] is bool) ? (m['activo'] as bool) : true,
        );
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.error('UsuarioService.obtenerUsuarios error', error: e, context: {'stackTrace': stackTrace.toString()});
      return [];
    }
  }

  Future<void> actualizarUsuario(String id, UsuarioModel usuario) async {
    try {
      await _apiService.put<Map<String, dynamic>>('/usuarios/$id', data: {
        'name': usuario.nombre,
        'email': usuario.email,
        'role': usuario.rol,
        'activo': usuario.activo,
      });
    } catch (e) {
      AppLogger.error('UsuarioService.actualizarUsuario error', error: e);
      rethrow;
    }
  }

  Future<void> eliminarUsuario(String id) async {
    try {
      await _apiService.delete<Map<String, dynamic>>('/usuarios/$id');
    } catch (e) {
      AppLogger.error('UsuarioService.eliminarUsuario error', error: e);
      rethrow;
    }
  }
}
