import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import '../../core/network/api_service.dart';
import 'cache_service.dart';


/// Modelo de IPS (Institución Prestadora de Salud)
class IPS {
  
  IPS({
    required this.id,
    required this.nombre,
    required this.nit,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.ciudad,
    required this.departamento,
    required this.tipo,
    required this.nivel,
    required this.servicios,
    this.municipioId,
    this.latitud,
    this.longitud,
    this.activo = true,
    this.fechaCreacion,
    this.fechaActualizacion,
  });
  
  factory IPS.fromJson(Map<String, dynamic> json) {
    String asString(dynamic v, {String def = ''}) => v is String ? v : (v?.toString() ?? def);
    int asInt(dynamic v, {int def = 0}) => v is int ? v : (v is String ? int.tryParse(v) ?? def : def);
    double? asDouble(dynamic v) => v is double ? v : (v is num ? v.toDouble() : (v is String ? double.tryParse(v) : null));

    return IPS(
      id: asString(json['id']),
      nombre: asString(json['nombre']),
      nit: asString(json['nit']),
      direccion: asString(json['direccion']),
      telefono: asString(json['telefono']),
      email: asString(json['email']),
      ciudad: asString(json['ciudad'] ?? json['municipio']),
      departamento: asString(json['departamento']),
      tipo: asString(json['tipo']),
      nivel: asInt(json['nivel']),
      servicios: (json['servicios'] is List) ? List<String>.from(json['servicios'] as List) : const <String>[],
      municipioId: asString(json['municipio_id']),
      latitud: asDouble(json['latitud']),
      longitud: asDouble(json['longitud']),
      activo: (json['activo'] is bool) ? (json['activo'] as bool) : true,
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.tryParse(asString(json['fechaCreacion'])) 
          : null,
      fechaActualizacion: json['fechaActualizacion'] != null 
          ? DateTime.tryParse(asString(json['fechaActualizacion'])) 
          : null,
    );
  }
  final String id;
  final String nombre;
  final String nit;
  final String direccion;
  final String telefono;
  final String email;
  final String ciudad;
  final String departamento;
  final String tipo; // pública, privada, mixta
  final int nivel; // 1, 2, 3
  final List<String> servicios;
  final String? municipioId;
  final double? latitud;
  final double? longitud;
  final bool activo;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nit': nit,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'ciudad': ciudad,
      'departamento': departamento,
      'tipo': tipo,
      'nivel': nivel,
      'servicios': servicios,
      'municipio_id': municipioId,
      'latitud': latitud,
      'longitud': longitud,
      'activo': activo,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }
}

/// Servicio de IPS
class IPSService {
  
  IPSService({ApiService? apiService, CacheService? cacheService}) 
      : _apiService = apiService ?? ApiService(),
        _cacheService = cacheService ?? CacheService();
  final ApiService _apiService;
  final CacheService _cacheService;
  
  /// Obtener todas las IPS
  Future<List<IPS>> getAllIPS() async {
    AppLogger.debug('IPSService: Obteniendo todas las IPS');
    final response = await _apiService.get<dynamic>('/ips');
    List<dynamic> raw = const [];
    if (response.success && response.data != null) {
      final data = _apiService.extractData(response.data);
      raw = (data is Map<String, dynamic> && data['ips'] is List)
          ? List<dynamic>.from(data['ips'] as List)
          : (data is List ? data : const []);
    }
    if (raw.isEmpty) {
      final retry = await _apiService.get<dynamic>('/ips', queryParameters: {'ts': DateTime.now().millisecondsSinceEpoch});
      if (retry.success && retry.data != null) {
        final data = _apiService.extractData(retry.data);
        raw = (data is Map<String, dynamic> && data['ips'] is List)
            ? List<dynamic>.from(data['ips'] as List)
            : (data is List ? data : const []);
      }
    }
    if (raw.isNotEmpty) {
      final ipsList = raw.map((item) => IPS.fromJson(item as Map<String, dynamic>)).toList();
      await _cacheService.setList('ips_list', ipsList.map((i) => i.toJson()).toList());
      await _cacheService.set('ips_list_meta', {'ts': DateTime.now().toIso8601String()});
      AppLogger.debug('IPSService: ${ipsList.length} IPS obtenidas');
      return ipsList;
    }
    final cached = await _cacheService.getList('ips_list') ?? const [];
    if (cached.isNotEmpty) {
      return cached.map((m) => IPS.fromJson(m as Map<String, dynamic>)).toList();
    }
    return const <IPS>[];
  }

  Future<IPS?> getIPSById(String id) async {
    final resp = await _apiService.get<dynamic>('/ips/$id');
    if (!resp.success) return null;
    final root = _apiService.extractObject(resp.data);
    if (root.isNotEmpty) {
      return IPS.fromJson(root);
    }
    return null;
  }

  // updateIPS duplicado removido (versión básica)
  
  // Método duplicado removido
  
  /// Obtener IPS por ciudad
  Future<List<IPS>> getIPSByCiudad(String ciudad) async {
    try {
      AppLogger.debug('IPSService: Obteniendo IPS de ciudad $ciudad');
      
      final response = await _apiService.get<dynamic>('/ips/ciudad/$ciudad');
      
      if (response.success && response.data != null) {
        final data = _apiService.extractData(response.data);
        final raw = (data is Map<String, dynamic> && data['ips'] is List)
            ? List<dynamic>.from(data['ips'] as List)
            : (data is List ? data : const []);
        final ipsList = raw.map((item) => IPS.fromJson(item as Map<String, dynamic>)).toList();
        AppLogger.debug('IPSService: ${ipsList.length} IPS obtenidas de $ciudad');
        return ipsList;
      } else {
        final errorMessage = response.error?.message ?? 'Error al obtener IPS por ciudad';
        AppLogger.error('IPSService: Error obteniendo IPS por ciudad: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('IPSService: Error obteniendo IPS por ciudad', error: e);
      rethrow;
    }
  }
  
  /// Obtener IPS por departamento
  Future<List<IPS>> getIPSByDepartamento(String departamento) async {
    try {
      AppLogger.debug('IPSService: Obteniendo IPS de departamento $departamento');
      
      final response = await _apiService.get<dynamic>('/ips/departamento/$departamento');
      
      if (response.success && response.data != null) {
        final data = _apiService.extractData(response.data);
        final raw = (data is Map<String, dynamic> && data['ips'] is List)
            ? List<dynamic>.from(data['ips'] as List)
            : (data is List ? data : const []);
        final ipsList = raw.map((item) => IPS.fromJson(item as Map<String, dynamic>)).toList();
        AppLogger.debug('IPSService: ${ipsList.length} IPS obtenidas de $departamento');
        return ipsList;
      } else {
        final errorMessage = response.error?.message ?? 'Error al obtener IPS por departamento';
        AppLogger.error('IPSService: Error obteniendo IPS por departamento: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('IPSService: Error obteniendo IPS por departamento', error: e);
      rethrow;
    }
  }
  
  /// Obtener IPS por tipo
  Future<List<IPS>> getIPSByTipo(String tipo) async {
    try {
      AppLogger.debug('IPSService: Obteniendo IPS de tipo $tipo');
      
      final response = await _apiService.get<dynamic>('/ips/tipo/$tipo');
      
      if (response.success && response.data != null) {
        final data = _apiService.extractData(response.data);
        final raw = (data is Map<String, dynamic> && data['ips'] is List)
            ? List<dynamic>.from(data['ips'] as List)
            : (data is List ? data : const []);
        final ipsList = raw.map((item) => IPS.fromJson(item as Map<String, dynamic>)).toList();
        AppLogger.debug('IPSService: ${ipsList.length} IPS obtenidas de tipo $tipo');
        return ipsList;
      } else {
        final errorMessage = response.error?.message ?? 'Error al obtener IPS por tipo';
        AppLogger.error('IPSService: Error obteniendo IPS por tipo: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('IPSService: Error obteniendo IPS por tipo', error: e);
      rethrow;
    }
  }
  
  /// Obtener IPS por nivel
  Future<List<IPS>> getIPSByNivel(int nivel) async {
    try {
      AppLogger.debug('IPSService: Obteniendo IPS de nivel $nivel');
      
      final response = await _apiService.get<dynamic>('/ips/nivel/$nivel');
      
      if (response.success && response.data != null) {
        final data = _apiService.extractData(response.data);
        final raw = (data is Map<String, dynamic> && data['ips'] is List)
            ? List<dynamic>.from(data['ips'] as List)
            : (data is List ? data : const []);
        final ipsList = raw.map((item) => IPS.fromJson(item as Map<String, dynamic>)).toList();
        AppLogger.debug('IPSService: ${ipsList.length} IPS obtenidas de nivel $nivel');
        return ipsList;
      } else {
        final errorMessage = response.error?.message ?? 'Error al obtener IPS por nivel';
        AppLogger.error('IPSService: Error obteniendo IPS por nivel: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('IPSService: Error obteniendo IPS por nivel', error: e);
      rethrow;
    }
  }
  
  /// Buscar IPS por nombre
  Future<List<IPS>> searchIPS(String query) async {
    try {
      AppLogger.debug('IPSService: Buscando IPS con query: $query');
      
      final response = await _apiService.get<dynamic>('/ips/search', queryParameters: {'q': query});
      
      if (response.success && response.data != null) {
        final data = _apiService.extractData(response.data);
        final raw = (data is Map<String, dynamic> && data['ips'] is List)
            ? List<dynamic>.from(data['ips'] as List)
            : (data is List ? data : const []);
        final ipsList = raw.map((item) => IPS.fromJson(item as Map<String, dynamic>)).toList();
        AppLogger.debug('IPSService: ${ipsList.length} IPS encontradas');
        return ipsList;
      } else {
        final errorMessage = response.error?.message ?? 'Error al buscar IPS';
        AppLogger.error('IPSService: Error buscando IPS: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('IPSService: Error buscando IPS', error: e);
      rethrow;
    }
  }

  // Aliases para compatibilidad con pantallas existentes
  Future<List<IPS>> obtenerTodasLasIPS() => getAllIPS();
  Future<List<String>> obtenerMunicipios(String departamento) => getCiudadesByDepartamento(departamento);

  /// Departamentos derivados de datos existentes (no hay endpoint específico)
  Future<List<String>> getDepartamentos() async {
    final all = await getAllIPS();
    final set = <String>{};
    for (final e in all) {
      final d = e.departamento.trim();
      if (d.isNotEmpty) set.add(d);
    }
    return set.toList()..sort();
  }

  /// Ciudades por departamento derivadas de datos existentes
  Future<List<String>> getCiudadesByDepartamento(String departamento) async {
    final all = await getAllIPS();
    final set = <String>{};
    for (final e in all) {
      if (e.departamento.trim().toLowerCase() == departamento.trim().toLowerCase()) {
        final c = e.ciudad.trim();
        if (c.isNotEmpty) set.add(c);
      }
    }
    return set.toList()..sort();
  }
  
  /// Crear nueva IPS
  Future<IPS> createIPS({
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    required String email,
    String? ciudad,
    String? departamento,
    String? municipioId,
    required String tipo,
    required int nivel,
    required List<String> servicios,
    double? latitud,
    double? longitud,
  }) async {
    try {
      AppLogger.debug('IPSService: Creando IPS: $nombre');
      
      final response = await _apiService.post<Map<String, dynamic>>(
        '/ips',
        data: {
          'nombre': nombre,
          'nit': nit,
          'direccion': direccion,
          'telefono': telefono,
          'email': email,
          if (ciudad != null) 'ciudad': ciudad,
          if (departamento != null) 'departamento': departamento,
          if (municipioId != null) 'municipio_id': municipioId,
          'tipo': tipo,
          'nivel': nivel,
          'servicios': servicios,
          'latitud': latitud,
          'longitud': longitud,
        },
      );
      
      if (response.success && response.data != null) {
        final ips = IPS.fromJson(response.data!);
        AppLogger.info('IPSService: IPS creada exitosamente: ${ips.nombre}');
        return ips;
      } else {
        final errorMessage = response.error?.message ?? 'Error al crear IPS';
        AppLogger.error('IPSService: Error creando IPS: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('IPSService: Error creando IPS', error: e);
      rethrow;
    }
  }

  // Alias: crearIPS -> createIPS
  Future<IPS> crearIPS({
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    required String email,
    String? ciudad,
    String? departamento,
    String? municipioId,
    required String tipo,
    required int nivel,
    required List<String> servicios,
    double? latitud,
    double? longitud,
  }) {
    return createIPS(
      nombre: nombre,
      nit: nit,
      direccion: direccion,
      telefono: telefono,
      email: email,
      ciudad: ciudad,
      departamento: departamento,
      municipioId: municipioId,
      tipo: tipo,
      nivel: nivel,
      servicios: servicios,
      latitud: latitud,
      longitud: longitud,
    );
  }
  
  /// Actualizar IPS
  Future<IPS> updateIPS({
    required String id,
    String? nombre,
    String? nit,
    String? direccion,
    String? telefono,
    String? email,
    String? ciudad,
    String? departamento,
    String? municipioId,
    String? tipo,
    int? nivel,
    List<String>? servicios,
    double? latitud,
    double? longitud,
    bool? activo,
  }) async {
    try {
      AppLogger.debug('IPSService: Actualizando IPS con ID $id');
      
      final body = <String, dynamic>{};
      if (nombre != null) body['nombre'] = nombre;
      if (nit != null) body['nit'] = nit;
      if (direccion != null) body['direccion'] = direccion;
      if (telefono != null) body['telefono'] = telefono;
      if (email != null) body['email'] = email;
      if (ciudad != null) body['ciudad'] = ciudad;
      if (departamento != null) body['departamento'] = departamento;
      if (municipioId != null) body['municipio_id'] = municipioId;
      if (tipo != null) body['tipo'] = tipo;
      if (nivel != null) body['nivel'] = nivel;
      if (servicios != null) body['servicios'] = servicios;
      if (latitud != null) body['latitud'] = latitud;
      if (longitud != null) body['longitud'] = longitud;
      if (activo != null) body['activo'] = activo;
      
      final response = await _apiService.put<Map<String, dynamic>>('/ips/$id', data: body);
      
      if (response.success && response.data != null) {
        final ips = IPS.fromJson(response.data!);
        AppLogger.info('IPSService: IPS actualizada exitosamente: ${ips.nombre}');
        return ips;
      } else {
        final errorMessage = response.error?.message ?? 'Error al actualizar IPS';
        AppLogger.error('IPSService: Error actualizando IPS: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('IPSService: Error actualizando IPS', error: e);
      rethrow;
    }
  }

  // Alias: actualizarIPS -> updateIPS
  Future<IPS> actualizarIPS({
    required String id,
    required String nombre,
    required String nit,
    String direccion = '',
    String telefono = '',
    String email = '',
    String ciudad = '',
    String departamento = '',
    String tipo = '',
    int nivel = 1,
    List<String> servicios = const [],
  }) {
    return updateIPS(
      id: id,
      nombre: nombre,
      nit: nit,
      direccion: direccion,
      telefono: telefono,
      email: email,
      ciudad: ciudad,
      departamento: departamento,
      tipo: tipo,
      nivel: nivel,
      servicios: servicios,
    );
  }
  
  /// Eliminar IPS
  Future<void> deleteIPS(String id) async {
    try {
      AppLogger.debug('IPSService: Eliminando IPS con ID $id');
      
      final response = await _apiService.delete<dynamic>('/ips/$id');
      
      if (response.success) {
        AppLogger.info('IPSService: IPS eliminada exitosamente');
      } else {
        final errorMessage = response.error?.message ?? 'Error al eliminar IPS';
        AppLogger.error('IPSService: Error eliminando IPS: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('IPSService: Error eliminando IPS', error: e);
      rethrow;
    }
  }
  
  
}
