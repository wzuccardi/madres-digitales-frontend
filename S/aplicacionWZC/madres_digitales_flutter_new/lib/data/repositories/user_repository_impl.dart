import '../../core/network/api_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';


/// Implementación concreta de UserException para uso interno
class _UserExceptionImpl implements UserException {
  
  const _UserExceptionImpl(this.message, {this.code});
  @override
  final String message;
  
  @override
  final String? code;
  
  @override
  String toString() => 'UserException: $message${code != null ? ' (code: $code)' : ''}';
  
}

/// Implementación concreta del repositorio de usuarios
/// Utiliza ApiService para comunicarse con el backend
class UserRepositoryImpl implements UserRepository {

  UserRepositoryImpl(this._apiService);
  final ApiService _apiService;

  @override
  Future<List<User>> getAllUsers([Map<String, dynamic>? filters]) async {
    try {
      final response = await _apiService.get<List<dynamic>>('/users', queryParameters: filters);

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al obtener usuarios',
          code: response.error?.code,
        );
      }

      final usersData = response.data!;
      return usersData.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener usuarios: ${e.toString()}');
    }
  }

  @override
  Future<User?> getUserById(String id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/users/$id');

      if (!response.success) {
        if (response.statusCode == 404) {
          return null;
        }
        
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al obtener usuario',
          code: response.error?.code,
        );
      }

      final userData = response.data!;
      return User.fromJson(userData);
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener usuario: ${e.toString()}');
    }
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/users/by-email/$email');

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al obtener usuario por email',
          code: response.error?.code,
        );
      }

      final userData = response.data!;
      return User.fromJson(userData);
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener usuario por email: ${e.toString()}');
    }
  }

  Future<User> saveUser(User user) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/users',
        data: user.toJson(),
      );

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al guardar usuario',
          code: response.error?.code,
        );
      }

      final userData = response.data!;
      return User.fromJson(userData);
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al guardar usuario: ${e.toString()}');
    }
  }

  @override
  Future<User> updateUser(User user) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/users/${user.id}',
        data: user.toJson(),
      );

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al actualizar usuario',
          code: response.error?.code,
        );
      }

      final userData = response.data!;
      return User.fromJson(userData);
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al actualizar usuario: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>('/users/$id');

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al eliminar usuario',
          code: response.error?.code,
        );
      }
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al eliminar usuario: ${e.toString()}');
    }
  }

  @override
  Future<bool> isEmailRegistered(String email) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/users/check-email/$email');

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al verificar email',
          code: response.error?.code,
        );
      }

      return response.data!['registered'] as bool;
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al verificar email: ${e.toString()}');
    }
  }

  @override
  Future<bool> isDocumentRegistered(String document, String documentType) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/users/check-document', queryParameters: {
        'document': document,
        'documentType': documentType,
      });

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al verificar documento',
          code: response.error?.code,
        );
      }

      return response.data!['registered'] as bool;
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al verificar documento: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> searchUsers(Map<String, dynamic> criteria) async {
    try {
      final response = await _apiService.post<dynamic>('/users/search', data: criteria);

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al buscar usuarios',
          code: response.error?.code,
        );
      }

      final usersData = response.data! as List<dynamic>;
      return usersData.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al buscar usuarios: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> getUsersPage({
    required int page,
    required int limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
        ...?filters,
      };
      
      final response = await _apiService.get<List<dynamic>>('/users', queryParameters: queryParameters);

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al obtener página de usuarios',
          code: response.error?.code,
        );
      }

      final usersData = response.data!;
      return usersData.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener página de usuarios: ${e.toString()}');
    }
  }

  @override
  Future<int> getUsersCount([Map<String, dynamic>? filters]) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/users/count', queryParameters: filters);

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al obtener conteo de usuarios',
          code: response.error?.code,
        );
      }

      return response.data!['count'] as int;
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener conteo de usuarios: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> getActiveUsers([Map<String, dynamic>? filters]) async {
    try {
      final queryParameters = <String, dynamic>{
        'active': true,
        ...?filters,
      };
      
      final response = await _apiService.get<List<dynamic>>('/users', queryParameters: queryParameters);

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al obtener usuarios activos',
          code: response.error?.code,
        );
      }

      final usersData = response.data!;
      return usersData.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener usuarios activos: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> getInactiveUsers([Map<String, dynamic>? filters]) async {
    try {
      final queryParameters = <String, dynamic>{
        'active': false,
        ...?filters,
      };
      
      final response = await _apiService.get<List<dynamic>>('/users', queryParameters: queryParameters);

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al obtener usuarios inactivos',
          code: response.error?.code,
        );
      }

      final usersData = response.data!;
      return usersData.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener usuarios inactivos: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> getAdmins([Map<String, dynamic>? filters]) async {
    try {
      final queryParameters = <String, dynamic>{
        'roles': ['admin', 'super_admin'],
        ...?filters,
      };
      
      final response = await _apiService.get<List<dynamic>>('/users', queryParameters: queryParameters);

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al obtener administradores',
          code: response.error?.code,
        );
      }

      final usersData = response.data!;
      return usersData.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener administradores: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> getHealthWorkers([Map<String, dynamic>? filters]) async {
    try {
      final queryParameters = <String, dynamic>{
        'roles': ['madrina', 'medico'],
        ...?filters,
      };
      
      final response = await _apiService.get<List<dynamic>>('/users', queryParameters: queryParameters);

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al obtener personal de salud',
          code: response.error?.code,
        );
      }

      final usersData = response.data!;
      return usersData.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener personal de salud: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> getMadrinas([Map<String, dynamic>? filters]) async {
    try {
      final queryParameters = <String, dynamic>{
        'role': 'madrina',
        ...?filters,
      };
      
      final response = await _apiService.get<List<dynamic>>('/users', queryParameters: queryParameters);

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al obtener madrinas',
          code: response.error?.code,
        );
      }

      final usersData = response.data!;
      return usersData.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener madrinas: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> getMedicos([Map<String, dynamic>? filters]) async {
    try {
      final queryParameters = <String, dynamic>{
        'role': 'medico',
        ...?filters,
      };
      
      final response = await _apiService.get<List<dynamic>>('/users', queryParameters: queryParameters);

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al obtener médicos',
          code: response.error?.code,
        );
      }

      final usersData = response.data!;
      return usersData.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener médicos: ${e.toString()}');
    }
  }

  @override
  Future<void> activateUser(String id) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/users/$id/activate',
        data: {'active': true},
      );

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al activar usuario',
          code: response.error?.code,
        );
      }
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al activar usuario: ${e.toString()}');
    }
  }

  @override
  Future<void> deactivateUser(String id) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/users/$id/deactivate',
        data: {'active': false},
      );

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al desactivar usuario',
          code: response.error?.code,
        );
      }
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al desactivar usuario: ${e.toString()}');
    }
  }

  @override
  Future<void> changeUserRole(String id, String newRole) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/users/$id/role',
        data: {'role': newRole},
      );

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al cambiar rol de usuario',
          code: response.error?.code,
        );
      }
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al cambiar rol de usuario: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserPassword(String id, String newPassword) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/users/$id/password',
        data: {'password': newPassword},
      );

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al actualizar contraseña de usuario',
          code: response.error?.code,
        );
      }
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al actualizar contraseña de usuario: ${e.toString()}');
    }
  }

  Future<void> updateUserProfile(String id, Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/users/$id/profile',
        data: profileData,
      );

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al actualizar perfil de usuario',
          code: response.error?.code,
        );
      }
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al actualizar perfil de usuario: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserPreferences(String id, Map<String, dynamic> preferences) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/users/$id/preferences',
        data: {'preferences': preferences},
      );

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al actualizar preferencias de usuario',
          code: response.error?.code,
        );
      }
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al actualizar preferencias de usuario: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserMetadata(String id, Map<String, dynamic> metadata) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/users/$id/metadata',
        data: {'metadata': metadata},
      );

      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al actualizar metadatos de usuario',
          code: response.error?.code,
        );
      }
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al actualizar metadatos de usuario: ${e.toString()}');
    }
  }

  
  @override
  Future<void> resetUserPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/users/reset-password',
        data: {
          'email': email,
          'resetToken': resetToken,
          'newPassword': newPassword,
        },
      );
      if (!response.success) {
        throw _UserExceptionImpl(
          response.error?.message ?? 'Error al restablecer contraseña',
          code: response.error?.code,
        );
      }
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al restablecer contraseña: ${e.toString()}');
    }
  }
  @override
  Future<List<User>> getUsersByRole(String role, [Map<String, dynamic>? filters]) async {
    final params = {'role': role, ...?filters};
    try {
      final response = await _apiService.get<List<dynamic>>('/users', queryParameters: params);
      if (!response.success) {
        throw _UserExceptionImpl(response.error?.message ?? 'Error al obtener usuarios por rol', code: response.error?.code);
      }
      return response.data!.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener usuarios por rol: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> getUsersByMunicipality(String municipalityId, [Map<String, dynamic>? filters]) async {
    final params = {'municipalityId': municipalityId, ...?filters};
    try {
      final response = await _apiService.get<List<dynamic>>('/users', queryParameters: params);
      if (!response.success) {
        throw _UserExceptionImpl(response.error?.message ?? 'Error al obtener usuarios por municipio', code: response.error?.code);
      }
      return response.data!.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener usuarios por municipio: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserLastAccess(String id) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>('/users/$id/last-access', data: {'lastAccess': DateTime.now().toIso8601String()});
      if (!response.success) {
        throw _UserExceptionImpl(response.error?.message ?? 'Error al actualizar último acceso', code: response.error?.code);
      }
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al actualizar último acceso: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProfileImage(String id, String profileImageUrl) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>('/users/$id/profile-image', data: {'profileImageUrl': profileImageUrl});
      if (!response.success) {
        throw _UserExceptionImpl(response.error?.message ?? 'Error al actualizar imagen de perfil', code: response.error?.code);
      }
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al actualizar imagen de perfil: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStats([Map<String, dynamic>? filters]) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/users/stats', queryParameters: filters);
      if (!response.success) {
        throw _UserExceptionImpl(response.error?.message ?? 'Error al obtener estadísticas de usuarios', code: response.error?.code);
      }
      return response.data!;
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al obtener estadísticas de usuarios: ${e.toString()}');
    }
  }

  @override
  Future<User> createUser(User user, String password) async {
    try {
      final payload = user.toJson();
      payload['password'] = password;
      final response = await _apiService.post<Map<String, dynamic>>('/users', data: payload);
      if (!response.success) {
        throw _UserExceptionImpl(response.error?.message ?? 'Error al crear usuario', code: response.error?.code);
      }
      return User.fromJson(response.data!);
    } catch (e) {
      if (e is UserException) rethrow;
      throw _UserExceptionImpl('Error de red al crear usuario: ${e.toString()}');
    }
  }
}
