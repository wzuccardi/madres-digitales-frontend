import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/entities/gestante.dart';
import '../../../../domain/entities/tipo_permiso.dart';
import '../../domain/entities/asignacion.dart';
import 'gestante_local_datasource.dart';

class GestanteLocalDataSourceImpl implements GestanteLocalDataSource {
  static const String _gestanteCacheKey = 'gestante_cache';
  static const String _gestantesListCacheKey = 'gestantes_list_cache';
  static const String _asignacionCacheKey = 'asignacion_cache';
  static const String _pendingSyncGestantesKey = 'pending_sync_gestantes';
  static const String _pendingSyncAsignacionesKey = 'pending_sync_asignaciones';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  @override
  Future<Gestante?> getGestanteById(String id) async {
    try {
      final prefs = await _prefs;
      final cachedData = prefs.getString('$_gestanteCacheKey:$id');
      
      if (cachedData != null) {
        final Map<String, dynamic> jsonData = json.decode(cachedData);
        return Gestante.fromJson(jsonData);
      }
      
      return null;
    } catch (e) {
      throw CacheException(message: 'Error getting cached gestante: $e');
    }
  }

  @override
  Future<void> cacheGestante(Gestante gestante) async {
    try {
      final prefs = await _prefs;
      final jsonData = json.encode(gestante.toJson());
      await prefs.setString('$_gestanteCacheKey:${gestante.id}', jsonData);
    } catch (e) {
      throw CacheException(message: 'Error caching gestante: $e');
    }
  }

  @override
  Future<void> cacheGestantesList(List<Gestante> gestantes, String madrinaId) async {
    try {
      final prefs = await _prefs;
      final jsonData = json.encode({
        'madrinaId': madrinaId,
        'gestantes': gestantes.map((g) => g.toJson()).toList(),
        'cachedAt': DateTime.now().toIso8601String(),
      });
      await prefs.setString('$_gestantesListCacheKey:$madrinaId', jsonData);
    } catch (e) {
      throw CacheException(message: 'Error caching gestantes list: $e');
    }
  }

  @override
  Future<List<Gestante>> getCachedGestantesList({
    required String madrinaId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final prefs = await _prefs;
      final cachedData = prefs.getString('$_gestantesListCacheKey:$madrinaId');
      
      if (cachedData != null) {
        final Map<String, dynamic> jsonData = json.decode(cachedData);
        final List<dynamic> gestantesJson = jsonData['gestantes'];
        
        // Apply pagination
        final startIndex = (page - 1) * limit;
        final endIndex = startIndex + limit;
        
        if (startIndex >= gestantesJson.length) {
          return [];
        }
        
        final paginatedData = gestantesJson.sublist(
          startIndex,
          endIndex > gestantesJson.length ? gestantesJson.length : endIndex,
        );
        
        return paginatedData.map((json) => Gestante.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      throw CacheException(message: 'Error getting cached gestantes list: $e');
    }
  }

  @override
  Future<Asignacion?> getActiveAsignation({
    required String gestanteId,
    required String madrinaId,
  }) async {
    try {
      final prefs = await _prefs;
      final cachedData = prefs.getString('$_asignacionCacheKey:active:$gestanteId:$madrinaId');
      
      if (cachedData != null) {
        final Map<String, dynamic> jsonData = json.decode(cachedData);
        return Asignacion.fromMap(jsonData);
      }
      
      return null;
    } catch (e) {
      throw CacheException(message: 'Error getting cached asignacion: $e');
    }
  }

  @override
  Future<void> cacheAsignacion(Asignacion asignacion) async {
    try {
      final prefs = await _prefs;
      final jsonData = json.encode(asignacion.toMap());
      
      // Cache by gestante and madrina IDs for easy lookup
      await prefs.setString(
        '$_asignacionCacheKey:active:${asignacion.gestanteId}:${asignacion.madrinaId}',
        jsonData,
      );
      
      // Also cache by ID for direct access
      await prefs.setString('$_asignacionCacheKey:${asignacion.id}', jsonData);
    } catch (e) {
      throw CacheException(message: 'Error caching asignacion: $e');
    }
  }

  @override
  Future<Gestante> createGestanteForSync({
    required Gestante gestante,
    required String madrinaId,
    Set<TipoPermiso>? permisosAdicionales,
  }) async {
    try {
      final prefs = await _prefs;
      final pendingData = prefs.getString(_pendingSyncGestantesKey);
      final List<dynamic> pendingSync = pendingData != null ? json.decode(pendingData) : [];
      
      final syncData = {
        'gestante': gestante.toJson(),
        'madrinaId': madrinaId,
        'permisosAdicionales': permisosAdicionales?.map((p) => p.toString().split('.').last).toList(),
        'createdAt': DateTime.now().toIso8601String(),
        'type': 'create',
      };
      
      pendingSync.add(syncData);
      
      await prefs.setString(_pendingSyncGestantesKey, json.encode(pendingSync));
      
      // Also cache the gestante locally
      await cacheGestante(gestante);
      
      return gestante;
    } catch (e) {
      throw CacheException(message: 'Error creating gestante for sync: $e');
    }
  }

  @override
  Future<Asignacion> createAsignacionForSync(Asignacion asignacion) async {
    try {
      final prefs = await _prefs;
      final pendingData = prefs.getString(_pendingSyncAsignacionesKey);
      final List<dynamic> pendingSync = pendingData != null ? json.decode(pendingData) : [];
      
      final syncData = {
        'asignacion': asignacion.toMap(),
        'createdAt': DateTime.now().toIso8601String(),
        'type': 'create',
      };
      
      pendingSync.add(syncData);
      
      await prefs.setString(_pendingSyncAsignacionesKey, json.encode(pendingSync));
      
      // Also cache the asignacion locally
      await cacheAsignacion(asignacion);
      
      return asignacion;
    } catch (e) {
      throw CacheException(message: 'Error creating asignacion for sync: $e');
    }
  }

  @override
  Future<List<Gestante>> getPendingSyncGestantes() async {
    try {
      final prefs = await _prefs;
      final pendingData = prefs.getString(_pendingSyncGestantesKey);
      
      if (pendingData != null) {
        final List<dynamic> pendingList = json.decode(pendingData);
        return pendingList.map((item) {
          final gestanteData = item['gestante'] as Map<String, dynamic>;
          return Gestante.fromJson(gestanteData);
        }).cast<Gestante>().toList();
      }
      
      return [];
    } catch (e) {
      throw CacheException(message: 'Error getting pending sync gestantes: $e');
    }
  }

  @override
  Future<List<Asignacion>> getPendingSyncAsignaciones() async {
    try {
      final prefs = await _prefs;
      final pendingData = prefs.getString(_pendingSyncAsignacionesKey);
      
      if (pendingData != null) {
        final List<dynamic> pendingList = json.decode(pendingData);
        return pendingList.map((item) {
          final asignacionData = item['asignacion'] as Map<String, dynamic>;
          return Asignacion.fromMap(asignacionData);
        }).toList();
      }
      
      return [];
    } catch (e) {
      throw CacheException(message: 'Error getting pending sync asignaciones: $e');
    }
  }

  @override
  Future<void> markAsSynced(String id, {bool isGestante = true}) async {
    try {
      final prefs = await _prefs;
      
      if (isGestante) {
        final pendingSync = await getPendingSyncGestantes();
        final updatedPending = pendingSync.where((g) => g.id != id).toList();
        await prefs.setString(_pendingSyncGestantesKey, json.encode(updatedPending));
      } else {
        final pendingSync = await getPendingSyncAsignaciones();
        final updatedPending = pendingSync.where((a) => a.id != id).toList();
        await prefs.setString(_pendingSyncAsignacionesKey, json.encode(updatedPending));
      }
    } catch (e) {
      throw CacheException(message: 'Error marking as synced: $e');
    }
  }

  @override
  Future<bool> verifyMadrinaPermission({
    required String madrinaId,
    required String gestanteId,
    required String permiso,
  }) async {
    try {
      // In offline mode, we'll be more permissive and cache the result
      // This is a simplified implementation - in a real app you might want
      // more sophisticated permission caching
      final prefs = await _prefs;
      final permissionKey = 'permission:$madrinaId:$gestanteId:$permiso';
      final cachedPermission = prefs.getBool(permissionKey);
      
      if (cachedPermission != null) {
        return cachedPermission;
      }
      
      // Default to false for safety in offline mode
      return false;
    } catch (e) {
      throw CacheException(message: 'Error verifying madrina permission: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getMadrinaById(String id) async {
    try {
      final prefs = await _prefs;
      final cachedData = prefs.getString('madrina:$id');
      
      if (cachedData != null) {
        final Map<String, dynamic> jsonData = json.decode(cachedData);
        return jsonData;
      }
      
      return null;
    } catch (e) {
      throw CacheException(message: 'Error getting cached madrina: $e');
    }
  }
}

class CacheException implements Exception {
  CacheException({required this.message});
  final String message;
  
  @override
  String toString() => 'CacheException: $message';
}