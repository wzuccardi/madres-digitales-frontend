import 'dart:convert';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/contenido_model.dart';
import '../../domain/entities/contenido.dart';
import '../../../../core/errors/exceptions.dart';

class CacheService {
  static const String _contenidosBoxName = 'contenidos_cache';
  static const String _categoriasBoxName = 'categorias_cache';
  static const String _searchResultsBoxName = 'search_results_cache';
  static const String _favoritosBoxName = 'favoritos_cache';
  static const String _progresoBoxName = 'progreso_cache';
  static const String _timestampsBoxName = 'timestamps_cache';
  
  // Tiempos de expiración en minutos
  static const int _defaultExpirationMinutes = 60;
  static const int _searchExpirationMinutes = 30;
  static const int _favoritosExpirationMinutes = 15;
  static const int _progresoExpirationMinutes = 5;
  
  late Box<Map> _contenidosBox;
  late Box<Map> _categoriasBox;
  late Box<Map> _searchResultsBox;
  late Box<Map> _favoritosBox;
  late Box<Map> _progresoBox;
  late Box<String> _timestampsBox;
  
  CacheService();
  
  Future<void> init() async {
    try {
      // Abrir cajas de Hive
      if (!Hive.isBoxOpen(_contenidosBoxName)) {
        _contenidosBox = await Hive.openBox<Map>(_contenidosBoxName);
      } else {
        _contenidosBox = Hive.box<Map>(_contenidosBoxName);
      }
      
      if (!Hive.isBoxOpen(_categoriasBoxName)) {
        _categoriasBox = await Hive.openBox<Map>(_categoriasBoxName);
      } else {
        _categoriasBox = Hive.box<Map>(_categoriasBoxName);
      }
      
      if (!Hive.isBoxOpen(_searchResultsBoxName)) {
        _searchResultsBox = await Hive.openBox<Map>(_searchResultsBoxName);
      } else {
        _searchResultsBox = Hive.box<Map>(_searchResultsBoxName);
      }
      
      if (!Hive.isBoxOpen(_favoritosBoxName)) {
        _favoritosBox = await Hive.openBox<Map>(_favoritosBoxName);
      } else {
        _favoritosBox = Hive.box<Map>(_favoritosBoxName);
      }
      
      if (!Hive.isBoxOpen(_progresoBoxName)) {
        _progresoBox = await Hive.openBox<Map>(_progresoBoxName);
      } else {
        _progresoBox = Hive.box<Map>(_progresoBoxName);
      }
      
      if (!Hive.isBoxOpen(_timestampsBoxName)) {
        _timestampsBox = await Hive.openBox<String>(_timestampsBoxName);
      } else {
        _timestampsBox = Hive.box<String>(_timestampsBoxName);
      }
      
      // Limpiar caché expirado
      await _cleanExpiredCache();
    } catch (e) {
      throw CacheException('Error inicializando caché: $e');
    }
  }
  
  // Métodos para contenidos
  Future<void> cacheContenidos(List<ContenidoModel> contenidos, {
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
  }) async {
    try {
      final key = _generateContenidosKey(categoria, tipo, nivel, page);
      final data = contenidos.map((c) => c.toJson()).toList();
      
      // Guardar en caché
      await _contenidosBox.put(key, {'data': data});
      
      // Guardar timestamp
      await _setTimestamp(key, _defaultExpirationMinutes);
    } catch (e) {
      throw CacheException('Error guardando contenidos en caché: $e');
    }
  }
  
  Future<List<ContenidoModel>> getCachedContenidos({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
  }) async {
    try {
      final key = _generateContenidosKey(categoria, tipo, nivel, page);
      
      // Verificar si el caché es válido
      if (!await _isCacheValid(key)) {
        throw const CacheException('Caché expirado o no encontrado');
      }
      
      final cachedData = _contenidosBox.get(key);
      if (cachedData == null) {
        throw const CacheException('Datos no encontrados en caché');
      }
      
      final List<dynamic> dataList = cachedData['data'];
      return dataList.map((json) => ContenidoModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException('Error obteniendo contenidos de caché: $e');
    }
  }
  
  Future<void> cacheContenido(ContenidoModel contenido) async {
    try {
      final key = 'contenido_${contenido.id}';
      final data = contenido.toJson();
      
      // Guardar en caché
      await _contenidosBox.put(key, {'data': data});
      
      // Guardar timestamp
      await _setTimestamp(key, _defaultExpirationMinutes);
    } catch (e) {
      throw CacheException('Error guardando contenido en caché: $e');
    }
  }
  
  Future<ContenidoModel?> getCachedContenidoById(String id) async {
    try {
      final key = 'contenido_$id';
      
      // Verificar si el caché es válido
      if (!await _isCacheValid(key)) {
        return null;
      }
      
      final cachedData = _contenidosBox.get(key);
      if (cachedData == null) {
        return null;
      }
      
      return ContenidoModel.fromJson(cachedData['data']);
    } catch (e) {
      throw CacheException('Error obteniendo contenido de caché: $e');
    }
  }
  
  // Métodos para categorías
  Future<void> cacheCategorias(List<Map<String, dynamic>> categorias) async {
    try {
      const key = 'categorias';
      
      // Guardar en caché
      await _categoriasBox.put(key, {'data': categorias});
      
      // Guardar timestamp
      await _setTimestamp(key, _defaultExpirationMinutes);
    } catch (e) {
      throw CacheException('Error guardando categorías en caché: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getCachedCategorias() async {
    try {
      const key = 'categorias';
      
      // Verificar si el caché es válido
      if (!await _isCacheValid(key)) {
        throw const CacheException('Caché expirado o no encontrado');
      }
      
      final cachedData = _categoriasBox.get(key);
      if (cachedData == null) {
        throw const CacheException('Datos no encontrados en caché');
      }
      
      return List<Map<String, dynamic>>.from(cachedData['data']);
    } catch (e) {
      throw CacheException('Error obteniendo categorías de caché: $e');
    }
  }
  
  // Métodos para resultados de búsqueda
  Future<void> cacheSearchResults(String query, List<ContenidoModel> resultados) async {
    try {
      final key = _generateHash(query);
      final data = resultados.map((c) => c.toJson()).toList();
      
      // Guardar en caché
      await _searchResultsBox.put(key, {'data': data});
      
      // Guardar timestamp
      await _setTimestamp('search_$key', _searchExpirationMinutes);
    } catch (e) {
      throw CacheException('Error guardando resultados de búsqueda en caché: $e');
    }
  }
  
  Future<List<ContenidoModel>> getCachedSearchResults(String query) async {
    try {
      final key = _generateHash(query);
      final timestampKey = 'search_$key';
      
      // Verificar si el caché es válido
      if (!await _isCacheValid(timestampKey)) {
        throw const CacheException('Caché expirado o no encontrado');
      }
      
      final cachedData = _searchResultsBox.get(key);
      if (cachedData == null) {
        throw const CacheException('Datos no encontrados en caché');
      }
      
      final List<dynamic> dataList = cachedData['data'];
      return dataList.map((json) => ContenidoModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException('Error obteniendo resultados de búsqueda de caché: $e');
    }
  }
  
  // Métodos para favoritos
  Future<void> cacheFavoritos(String usuarioId, List<ContenidoModel> favoritos) async {
    try {
      final key = 'favoritos_$usuarioId';
      final data = favoritos.map((c) => c.toJson()).toList();
      
      // Guardar en caché
      await _favoritosBox.put(key, {'data': data});
      
      // Guardar timestamp
      await _setTimestamp(key, _favoritosExpirationMinutes);
    } catch (e) {
      throw CacheException('Error guardando favoritos en caché: $e');
    }
  }
  
  Future<List<ContenidoModel>> getCachedFavoritos(String usuarioId) async {
    try {
      final key = 'favoritos_$usuarioId';
      
      // Verificar si el caché es válido
      if (!await _isCacheValid(key)) {
        throw const CacheException('Caché expirado o no encontrado');
      }
      
      final cachedData = _favoritosBox.get(key);
      if (cachedData == null) {
        throw const CacheException('Datos no encontrados en caché');
      }
      
      final List<dynamic> dataList = cachedData['data'];
      return dataList.map((json) => ContenidoModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException('Error obteniendo favoritos de caché: $e');
    }
  }
  
  // Métodos para progreso
  Future<void> cacheProgreso(String contenidoId, String usuarioId, Map<String, dynamic> progreso) async {
    try {
      final key = 'progreso_${contenidoId}_$usuarioId';
      
      // Guardar en caché
      await _progresoBox.put(key, progreso);
      
      // Guardar timestamp
      await _setTimestamp(key, _progresoExpirationMinutes);
    } catch (e) {
      throw CacheException('Error guardando progreso en caché: $e');
    }
  }
  
  Future<Map<String, dynamic>?> getCachedProgreso(String contenidoId, String usuarioId) async {
    try {
      final key = 'progreso_${contenidoId}_$usuarioId';
      
      // Verificar si el caché es válido
      if (!await _isCacheValid(key)) {
        return null;
      }
      
      final cachedData = _progresoBox.get(key);
      if (cachedData == null) {
        return null;
      }
      
      // Convertir a Map<String, dynamic>
      return Map<String, dynamic>.from(cachedData);
    } catch (e) {
      throw CacheException('Error obteniendo progreso de caché: $e');
    }
  }
  
  // Métodos de gestión de caché
  Future<void> clearCache({String? key}) async {
    try {
      if (key != null) {
        // Limpiar una clave específica
        await _contenidosBox.delete(key);
        await _categoriasBox.delete(key);
        await _searchResultsBox.delete(key);
        await _favoritosBox.delete(key);
        await _progresoBox.delete(key);
        await _timestampsBox.delete(key);
      } else {
        // Limpiar todo el caché
        await _contenidosBox.clear();
        await _categoriasBox.clear();
        await _searchResultsBox.clear();
        await _favoritosBox.clear();
        await _progresoBox.clear();
        await _timestampsBox.clear();
      }
    } catch (e) {
      throw CacheException('Error limpiando caché: $e');
    }
  }
  
  Future<void> clearExpiredCache() async {
    await _cleanExpiredCache();
  }
  
  Future<bool> isCacheValid({String? key}) async {
    if (key != null) {
      return await _isCacheValid(key);
    }
    
    // Verificar si hay alguna clave válida
    final keys = _timestampsBox.keys.toList();
    for (final k in keys) {
      if (await _isCacheValid(k)) {
        return true;
      }
    }
    
    return false;
  }
  
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;
      
      // Calcular tamaño de cada caja
      totalSize += await _calculateBoxSize(_contenidosBox);
      totalSize += await _calculateBoxSize(_categoriasBox);
      totalSize += await _calculateBoxSize(_searchResultsBox);
      totalSize += await _calculateBoxSize(_favoritosBox);
      totalSize += await _calculateBoxSize(_progresoBox);
      totalSize += await _calculateBoxSize(_timestampsBox);
      
      return totalSize;
    } catch (e) {
      throw CacheException('Error calculando tamaño de caché: $e');
    }
  }
  
  // Métodos privados
  String _generateContenidosKey(
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page,
  ) {
    final parts = <String>['contenidos'];
    
    if (categoria != null) parts.add(categoria.name);
    if (tipo != null) parts.add(tipo.name);
    if (nivel != null) parts.add(nivel.name);
    parts.add('page_$page');
    
    return parts.join('_');
  }
  
  String _generateHash(String input) {
    // Implementación simple de hash sin dependencias externas
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash) + input.codeUnitAt(i);
      hash &= 0xffffffff; // Convertir a 32 bits
    }
    return hash.abs().toString();
  }
  
  Future<void> _setTimestamp(String key, int expirationMinutes) async {
    final timestamp = DateTime.now().toIso8601String();
    final expiration = DateTime.now().add(Duration(minutes: expirationMinutes)).toIso8601String();
    
    await _timestampsBox.put(key, '$timestamp|$expiration');
  }
  
  Future<bool> _isCacheValid(String key) async {
    try {
      final timestampData = _timestampsBox.get(key);
      if (timestampData == null) return false;
      
      final parts = timestampData.split('|');
      if (parts.length != 2) return false;
      
      final expiration = DateTime.parse(parts[1]);
      return DateTime.now().isBefore(expiration);
    } catch (e) {
      return false;
    }
  }
  
  Future<void> _cleanExpiredCache() async {
    try {
      final keys = _timestampsBox.keys.toList();
      final expiredKeys = <String>[];
      
      for (final key in keys) {
        if (!await _isCacheValid(key)) {
          expiredKeys.add(key);
        }
      }
      
      // Eliminar claves expiradas
      for (final key in expiredKeys) {
        await _contenidosBox.delete(key);
        await _categoriasBox.delete(key);
        await _searchResultsBox.delete(key);
        await _favoritosBox.delete(key);
        await _progresoBox.delete(key);
        await _timestampsBox.delete(key);
      }
    } catch (e) {
      throw CacheException('Error limpiando caché expirado: $e');
    }
  }
  
  Future<int> _calculateBoxSize(Box box) async {
    try {
      int size = 0;
      for (final key in box.keys) {
        final value = box.get(key);
        if (value != null) {
          // Estimar tamaño basado en la longitud del JSON
          final jsonStr = jsonEncode(value);
          size += jsonStr.length;
        }
      }
      return size;
    } catch (e) {
      return 0;
    }
  }
}