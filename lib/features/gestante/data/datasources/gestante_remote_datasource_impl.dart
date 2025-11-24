import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_service.dart';
import '../../../../domain/entities/gestante.dart';
import '../../../../domain/entities/tipo_permiso.dart';
import '../../domain/entities/asignacion.dart';
import 'gestante_remote_datasource.dart';
import '../../../../core/converters/gestante_converter.dart';

class GestanteRemoteDataSourceImpl implements GestanteRemoteDataSource {

  GestanteRemoteDataSourceImpl({required this.apiService});
  final ApiService apiService;

  @override
  Future<Gestante> createGestante({
    required Gestante gestante,
    required String madrinaId,
    Set<TipoPermiso>? permisosAdicionales,
  }) async {
    try {
      // Convert the gestante to API format using the converter
      final apiGestante = GestanteConverter.gestanteToApi(gestante);
      
      // Add madrina_id to the request
      apiGestante['madrina_id'] = madrinaId;
      
      // Add permisos adicionales if provided
      if (permisosAdicionales != null && permisosAdicionales.isNotEmpty) {
        apiGestante['permisos_adicionales'] = permisosAdicionales
            .map((p) => p.toString().split('.').last)
            .toList();
      }

      final response = await apiService.post(
        '/api/gestantes',
        data: apiGestante,
      );

      if (response.success) {
        final responseData = response.data;
        
        // Convert the response back to Gestante entity
        if (responseData != null) {
          if (responseData['data'] != null) {
            return GestanteConverter.apiToGestante(responseData['data'] as Map<String, dynamic>);
          } else {
            return GestanteConverter.apiToGestante(responseData);
          }
        } else {
          throw const ServerException('Invalid response data format');
        }
      } else {
        throw ServerException('Failed to create gestante: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error creating gestante: $e');
    }
  }

  @override
  Future<Gestante> getGestanteById(String id) async {
    try {
      final response = await apiService.get('/api/gestantes/$id');
      
      if (response.success) {
        final responseData = response.data;
        return GestanteConverter.apiToGestante(responseData['data'] ?? responseData);
      } else {
        throw ServerException('Failed to get gestante: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error getting gestante: $e');
    }
  }

  @override
  Future<List<Gestante>> getAllGestantes({
    int page = 1,
    int limit = 20,
    String? search,
    bool? soloActivas,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (search != null) queryParams['search'] = search;
      if (soloActivas != null) queryParams['soloActivas'] = soloActivas;
      
      final response = await apiService.get(
        '/api/gestantes',
        queryParameters: queryParams,
      );
      
      if (response.success) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'] ?? responseData;
        
        return data.map((item) => GestanteConverter.apiToGestante(item)).toList();
      } else {
        throw ServerException('Failed to get gestantes: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error getting gestantes: $e');
    }
  }

  @override
  Future<Gestante> updateGestante(Gestante gestante) async {
    try {
      final apiGestante = GestanteConverter.gestanteToApi(gestante);
      
      final response = await apiService.put(
        '/api/gestantes/${gestante.id}',
        data: apiGestante,
      );
      
      if (response.success) {
        final responseData = response.data;
        if (responseData != null) {
          return GestanteConverter.apiToGestante(responseData['data'] as Map<String, dynamic>? ?? responseData);
        } else {
          throw const ServerException('Invalid response data format');
        }
      } else {
        throw ServerException('Failed to update gestante: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error updating gestante: $e');
    }
  }

  @override
  Future<bool> deleteGestante(String id) async {
    try {
      final response = await apiService.delete('/api/gestantes/$id');
      
      if (response.success) {
        return true;
      } else {
        throw ServerException('Failed to delete gestante: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error deleting gestante: $e');
    }
  }

  @override
  Future<Asignacion> createAsignacion(Asignacion asignacion) async {
    try {
      final response = await apiService.post(
        '/api/asignaciones',
        data: asignacion.toMap(),
      );
      
      if (response.success) {
        final responseData = response.data;
        if (responseData != null) {
          return Asignacion.fromMap(responseData['data'] as Map<String, dynamic>? ?? responseData);
        } else {
          throw const ServerException('Invalid response data format');
        }
      } else {
        throw ServerException('Failed to create asignacion: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error creating asignacion: $e');
    }
  }

  @override
  Future<Asignacion?> getActiveAsignation({
    required String gestanteId,
    required String madrinaId,
  }) async {
    try {
      final response = await apiService.get(
        '/api/asignaciones/active',
        queryParameters: {
          'gestanteId': gestanteId,
          'madrinaId': madrinaId,
        },
      );
      
      if (response.success) {
        final responseData = response.data;
        if (responseData['data'] != null) {
          return Asignacion.fromMap(responseData['data']);
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ServerException('Failed to get active asignation: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error getting active asignation: $e');
    }
  }

  @override
  Future<List<Asignacion>> getAsignacionesByGestante(String gestanteId) async {
    try {
      final response = await apiService.get('/api/asignaciones/gestante/$gestanteId');
      
      if (response.success) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'] ?? responseData;
        
        return data.map((item) => Asignacion.fromMap(item)).toList();
      } else {
        throw ServerException('Failed to get asignaciones by gestante: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error getting asignaciones by gestante: $e');
    }
  }

  @override
  Future<List<Asignacion>> getAsignacionesByMadrina(String madrinaId) async {
    try {
      final response = await apiService.get('/api/asignaciones/madrina/$madrinaId');
      
      if (response.success) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'] ?? responseData;
        
        return data.map((item) => Asignacion.fromMap(item)).toList();
      } else {
        throw ServerException('Failed to get asignaciones by madrina: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error getting asignaciones by madrina: $e');
    }
  }

  @override
  Future<bool> deactivatePrincipalAssignments(String gestanteId) async {
    try {
      final response = await apiService.put(
        '/api/asignaciones/deactivate-principal/$gestanteId',
      );
      
      if (response.success) {
        return true;
      } else {
        throw ServerException('Failed to deactivate principal assignments: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error deactivating principal assignments: $e');
    }
  }

  @override
  Future<List<Gestante>> getGestantesAsignadas({
    required String madrinaId,
    int page = 1,
    int limit = 20,
    String? search,
    bool? soloActivas,
    bool? soloPropias,
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'madrinaId': madrinaId,
        'page': page,
        'limit': limit,
      };
      
      if (search != null) queryParams['search'] = search;
      if (soloActivas != null) queryParams['soloActivas'] = soloActivas;
      if (soloPropias != null) queryParams['soloPropias'] = soloPropias;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      queryParams['ascending'] = ascending;
      
      final response = await apiService.get(
        '/api/gestantes/asignadas',
        queryParameters: queryParams,
      );
      
      if (response.success) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'] ?? responseData;
        
        return data.map<Gestante>((item) => GestanteConverter.apiToGestante(item)).toList();
      } else {
        throw ServerException('Failed to get gestantes asignadas: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error getting gestantes asignadas: $e');
    }
  }

  @override
  Future<bool> verifyMadrinaPermission({
    required String madrinaId,
    required String gestanteId,
    required String permiso,
  }) async {
    try {
      final response = await apiService.get(
        '/api/permissions/madrina/verify',
        queryParameters: {
          'madrinaId': madrinaId,
          'gestanteId': gestanteId,
          'permiso': permiso,
        },
      );
      
      if (response.success) {
        final responseData = response.data;
        if (responseData != null && responseData is Map<String, dynamic>) {
          return responseData['hasPermission'] ?? false;
        } else {
          return false;
        }
      } else {
        throw ServerException('Failed to verify madrina permission: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error verifying madrina permission: $e');
    }
  }

  @override
  Future<bool> verifyMadrinaPermissions({
    required String madrinaId,
    required String permiso,
  }) async {
    try {
      final response = await apiService.get(
        '/api/permissions/madrina/global',
        queryParameters: {
          'madrinaId': madrinaId,
          'permiso': permiso,
        },
      );
      
      if (response.success) {
        final responseData = response.data;
        return responseData['hasPermission'] ?? false;
      } else {
        throw ServerException('Failed to verify madrina permissions: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error verifying madrina permissions: $e');
    }
  }

  @override
  Future<bool> verifyUserPermissions({
    required String userId,
    required String permiso,
  }) async {
    try {
      final response = await apiService.get(
        '/api/permissions/user',
        queryParameters: {
          'userId': userId,
          'permiso': permiso,
        },
      );
      
      if (response.success) {
        final responseData = response.data;
        return responseData['hasPermission'] ?? false;
      } else {
        throw ServerException('Failed to verify user permissions: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error verifying user permissions: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getMadrinaById(String id) async {
    try {
      final response = await apiService.get('/api/madrinas/$id');
      
      if (response.success) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw ServerException('Failed to get madrina: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error getting madrina: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableMadrinas() async {
    try {
      final response = await apiService.get('/api/madrinas/available');
      
      if (response.success) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'] ?? responseData;
        
        return data.cast<Map<String, dynamic>>();
      } else {
        throw ServerException('Failed to get available madrinas: ${response.message ?? "Unknown error"}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error getting available madrinas: $e');
    }
  }
}