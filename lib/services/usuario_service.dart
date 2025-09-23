import 'package:dio/dio.dart';
import '../models/usuario_model.dart';
import 'api_service.dart';
import 'location_service.dart';
import 'offline_service.dart';

class UsuarioService {
  final ApiService _apiService;
  final LocationService _locationService;
  final OfflineService _offlineService;
  
  UsuarioService({
    required ApiService apiService,
    required LocationService locationService,
    required OfflineService offlineService,
  }) : _apiService = apiService,
       _locationService = locationService,
       _offlineService = offlineService;
  
  // Gestión de Usuarios
  
  // Obtener todos los usuarios
  Future<List<UsuarioModel>> obtenerUsuarios({
    int? page,
    int? limit,
    String? search,
    RolUsuario? rol,
    String? departamento,
    String? municipio,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (rol != null) queryParams['rol'] = rol.name;
      if (departamento != null) queryParams['departamento'] = departamento;
      if (municipio != null) queryParams['municipio'] = municipio;
      
      final response = await _apiService.get('/usuarios', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> usuariosData = response.data['data'];
        return usuariosData.map((json) => UsuarioModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener usuarios');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        // Retornar datos offline si están disponibles
        return await _offlineService.getOfflineUsuarios();
      }
      rethrow;
    }
  }
  
  // Obtener usuario por ID
  Future<UsuarioModel> obtenerUsuarioPorId(String id) async {
    try {
      final response = await _apiService.get('/usuarios/$id');
      
      if (response.data['success'] == true) {
        return UsuarioModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener usuario');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Crear nuevo usuario
  Future<UsuarioModel> crearUsuario(UsuarioModel usuario) async {
    try {
      final usuarioData = usuario.toJson();
      
      // Obtener ubicación actual si está disponible
      final ubicacion = await _locationService.getCurrentLocation();
      if (ubicacion != null) {
        usuarioData['latitud'] = ubicacion.latitude;
        usuarioData['longitud'] = ubicacion.longitude;
      }
      
      final response = await _apiService.post('/usuarios', data: usuarioData);
      
      if (response.data['success'] == true) {
        return UsuarioModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Error al crear usuario');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('usuarios', usuario.toJson());
        return usuario;
      }
      rethrow;
    }
  }
  
  // Actualizar usuario
  Future<UsuarioModel> actualizarUsuario(String id, UsuarioModel usuario) async {
    try {
      final response = await _apiService.put('/usuarios/$id', data: usuario.toJson());
      
      if (response.data['success'] == true) {
        return UsuarioModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Error al actualizar usuario');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('usuarios_update', {
          'id': id,
          'data': usuario.toJson(),
        });
        return usuario;
      }
      rethrow;
    }
  }
  
  // Eliminar usuario
  Future<bool> eliminarUsuario(String id) async {
    try {
      final response = await _apiService.delete('/usuarios/$id');
      
      if (response.data['success'] == true) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Error al eliminar usuario');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('usuarios_delete', {'id': id});
        return true;
      }
      rethrow;
    }
  }
  
  // Buscar usuarios por ubicación
  Future<List<UsuarioModel>> buscarUsuariosPorUbicacion({
    required double latitud,
    required double longitud,
    required double radioKm,
    RolUsuario? rol,
  }) async {
    try {
      final queryParams = {
        'latitud': latitud,
        'longitud': longitud,
        'radio': radioKm,
        if (rol != null) 'rol': rol.name,
      };
      
      final response = await _apiService.get('/usuarios/ubicacion', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> usuariosData = response.data['data'];
        return usuariosData.map((json) => UsuarioModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al buscar usuarios por ubicación');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Gestión de IPS
  
  // Obtener todas las IPS
  Future<List<IpsModel>> obtenerIps({
    int? page,
    int? limit,
    String? search,
    NivelIps? nivel,
    String? departamento,
    String? municipio,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (nivel != null) queryParams['nivel'] = nivel.name;
      if (departamento != null) queryParams['departamento'] = departamento;
      if (municipio != null) queryParams['municipio'] = municipio;
      
      final response = await _apiService.get('/ips', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> ipsData = response.data['data'];
        return ipsData.map((json) => IpsModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener IPS');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        return await _offlineService.getOfflineIps();
      }
      rethrow;
    }
  }
  
  // Obtener IPS por ID
  Future<IpsModel> obtenerIpsPorId(String id) async {
    try {
      final response = await _apiService.get('/ips/$id');
      
      if (response.data['success'] == true) {
        return IpsModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener IPS');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Crear nueva IPS
  Future<IpsModel> crearIps(IpsModel ips) async {
    try {
      final response = await _apiService.post('/ips', data: ips.toJson());
      
      if (response.data['success'] == true) {
        return IpsModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Error al crear IPS');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('ips', ips.toJson());
        return ips;
      }
      rethrow;
    }
  }
  
  // Actualizar IPS
  Future<IpsModel> actualizarIps(String id, IpsModel ips) async {
    try {
      final response = await _apiService.put('/ips/$id', data: ips.toJson());
      
      if (response.data['success'] == true) {
        return IpsModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Error al actualizar IPS');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('ips_update', {
          'id': id,
          'data': ips.toJson(),
        });
        return ips;
      }
      rethrow;
    }
  }
  
  // Buscar IPS por ubicación
  Future<List<IpsModel>> buscarIpsPorUbicacion({
    required double latitud,
    required double longitud,
    required double radioKm,
    NivelIps? nivel,
  }) async {
    try {
      final queryParams = {
        'latitud': latitud,
        'longitud': longitud,
        'radio': radioKm,
        if (nivel != null) 'nivel': nivel.name,
      };
      
      final response = await _apiService.get('/ips/ubicacion', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> ipsData = response.data['data'];
        return ipsData.map((json) => IpsModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al buscar IPS por ubicación');
      }
    } catch (e) {
      // Búsqueda offline por ubicación
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        final ipsOffline = await _offlineService.getOfflineIps();
        return ipsOffline.where((ips) {
          if (ips.latitud != null && ips.longitud != null) {
            final distancia = _locationService.calculateDistance(
              latitud,
              longitud,
              ips.latitud!,
              ips.longitud!,
            );
            return distancia <= radioKm;
          }
          return false;
        }).toList();
      }
      rethrow;
    }
  }
  
  // Gestión de Médicos
  
  // Obtener todos los médicos
  Future<List<MedicoModel>> obtenerMedicos({
    int? page,
    int? limit,
    String? search,
    String? especialidad,
    String? ipsId,
    String? departamento,
    String? municipio,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (especialidad != null) queryParams['especialidad'] = especialidad;
      if (ipsId != null) queryParams['ipsId'] = ipsId;
      if (departamento != null) queryParams['departamento'] = departamento;
      if (municipio != null) queryParams['municipio'] = municipio;
      
      final response = await _apiService.get('/medicos', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> medicosData = response.data['data'];
        return medicosData.map((json) => MedicoModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener médicos');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        return await _offlineService.getOfflineMedicos();
      }
      rethrow;
    }
  }
  
  // Obtener médico por ID
  Future<MedicoModel> obtenerMedicoPorId(String id) async {
    try {
      final response = await _apiService.get('/medicos/$id');
      
      if (response.data['success'] == true) {
        return MedicoModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener médico');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Crear nuevo médico
  Future<MedicoModel> crearMedico(MedicoModel medico) async {
    try {
      final response = await _apiService.post('/medicos', data: medico.toJson());
      
      if (response.data['success'] == true) {
        return MedicoModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Error al crear médico');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('medicos', medico.toJson());
        return medico;
      }
      rethrow;
    }
  }
  
  // Actualizar médico
  Future<MedicoModel> actualizarMedico(String id, MedicoModel medico) async {
    try {
      final response = await _apiService.put('/medicos/$id', data: medico.toJson());
      
      if (response.data['success'] == true) {
        return MedicoModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Error al actualizar médico');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await _offlineService.saveOfflineData('medicos_update', {
          'id': id,
          'data': medico.toJson(),
        });
        return medico;
      }
      rethrow;
    }
  }
  
  // Buscar médicos por ubicación
  Future<List<MedicoModel>> buscarMedicosPorUbicacion({
    required double latitud,
    required double longitud,
    required double radioKm,
    String? especialidad,
  }) async {
    try {
      final queryParams = {
        'latitud': latitud,
        'longitud': longitud,
        'radio': radioKm,
        if (especialidad != null) 'especialidad': especialidad,
      };
      
      final response = await _apiService.get('/medicos/ubicacion', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> medicosData = response.data['data'];
        return medicosData.map((json) => MedicoModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al buscar médicos por ubicación');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Obtener médicos disponibles
  Future<List<MedicoModel>> obtenerMedicosDisponibles({
    String? especialidad,
    DateTime? fecha,
    String? horario,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'disponible': true,
      };
      if (especialidad != null) queryParams['especialidad'] = especialidad;
      if (fecha != null) queryParams['fecha'] = fecha.toIso8601String();
      if (horario != null) queryParams['horario'] = horario;
      
      final response = await _apiService.get('/medicos/disponibles', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> medicosData = response.data['data'];
        return medicosData.map((json) => MedicoModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener médicos disponibles');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Obtener estadísticas de usuarios
  Future<Map<String, dynamic>> obtenerEstadisticasUsuarios({
    String? departamento,
    String? municipio,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (departamento != null) queryParams['departamento'] = departamento;
      if (municipio != null) queryParams['municipio'] = municipio;
      
      final response = await _apiService.get('/usuarios/estadisticas', queryParams: queryParams);
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener estadísticas');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Sincronizar datos offline
  Future<void> sincronizarDatosOffline() async {
    try {
      await _offlineService.syncPendingData();
    } catch (e) {
      print('Error sincronizando datos offline: $e');
    }
  }
  
  // Validar datos de usuario
  bool validarUsuario(UsuarioModel usuario) {
    if (usuario.email.isEmpty || !usuario.email.contains('@')) return false;
    if (usuario.nombres.isEmpty || usuario.apellidos.isEmpty) return false;
    if (usuario.numeroDocumento.isEmpty) return false;
    if (usuario.telefono.isEmpty) return false;
    
    return true;
  }
  
  // Validar datos de IPS
  bool validarIps(IpsModel ips) {
    if (ips.nombre.isEmpty) return false;
    if (ips.codigoHabilitacion.isEmpty) return false;
    if (ips.direccion.isEmpty) return false;
    if (ips.telefono.isEmpty) return false;
    if (ips.latitud == null || ips.longitud == null) return false;
    
    return true;
  }
  
  // Validar datos de médico
  bool validarMedico(MedicoModel medico) {
    if (medico.usuarioId.isEmpty) return false;
    if (medico.numeroLicencia.isEmpty) return false;
    if (medico.especialidades.isEmpty) return false;
    
    return true;
  }
}