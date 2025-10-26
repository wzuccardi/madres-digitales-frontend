import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive.dart';

import 'package:madres_digitales_flutter_new/features/contenido/data/services/cache_service.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/models/contenido_model.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'package:madres_digitales_flutter_new/core/network/network_info.dart';

void main() {
  group('CacheService Tests', () {
    late CacheService cacheService;
    late MockNetworkInfo mockNetworkInfo;

    setUp(() async {
      // Inicializar Hive para pruebas
      await Hive.initFlutter();
      
      // Abrir cajas de prueba
      await Hive.openBox('test_contenidos_cache');
      await Hive.openBox('test_categorias_cache');
      await Hive.openBox('test_search_results_cache');
      await Hive.openBox('test_favoritos_cache');
      await Hive.openBox('test_progreso_cache');
      await Hive.openBox('test_timestamps_cache');
      
      // Crear instancia del servicio con nombres de caja personalizados
      mockNetworkInfo = MockNetworkInfo();
      cacheService = TestCacheService(mockNetworkInfo);
      
      // Inicializar el servicio
      await cacheService.init();
    });

    tearDown(() async {
      // Limpiar cajas de prueba
      await Hive.deleteBoxFromDisk('test_contenidos_cache');
      await Hive.deleteBoxFromDisk('test_categorias_cache');
      await Hive.deleteBoxFromDisk('test_search_results_cache');
      await Hive.deleteBoxFromDisk('test_favoritos_cache');
      await Hive.deleteBoxFromDisk('test_progreso_cache');
      await Hive.deleteBoxFromDisk('test_timestamps_cache');
    });

    test('debería almacenar y recuperar contenidos correctamente', () async {
      // arrange
      final testContenidos = [
        ContenidoModel(
          id: '1',
          titulo: 'Test Contenido 1',
          descripcion: 'Test Descripción 1',
          url: 'https://example.com/video1.mp4',
          thumbnailUrl: 'https://example.com/thumb1.jpg',
          tipo: TipoContenido.video,
          categoria: CategoriaContenido.nutricion,
          nivel: NivelDificultad.basico,
          duracion: 300,
          etiquetas: const ['test', 'video'],
          semanaGestacionInicio: 10,
          semanaGestacionFin: 20,
          fechaPublicacion: DateTime.parse('2023-01-01'),
          createdAt: DateTime.parse('2023-01-01'),
          updatedAt: DateTime.parse('2023-01-01'),
        ),
        ContenidoModel(
          id: '2',
          titulo: 'Test Contenido 2',
          descripcion: 'Test Descripción 2',
          url: 'https://example.com/video2.mp4',
          thumbnailUrl: 'https://example.com/thumb2.jpg',
          tipo: TipoContenido.articulo,
          categoria: CategoriaContenido.ejercicio,
          nivel: NivelDificultad.intermedio,
          etiquetas: const ['test', 'articulo'],
          fechaPublicacion: DateTime.parse('2023-01-02'),
          createdAt: DateTime.parse('2023-01-02'),
          updatedAt: DateTime.parse('2023-01-02'),
        ),
      ];

      // act
      await cacheService.cacheContenidos(testContenidos);
      final cachedContenidos = await cacheService.getCachedContenidos();

      // assert
      expect(cachedContenidos.length, testContenidos.length);
      expect(cachedContenidos[0].id, testContenidos[0].id);
      expect(cachedContenidos[0].titulo, testContenidos[0].titulo);
      expect(cachedContenidos[1].id, testContenidos[1].id);
      expect(cachedContenidos[1].titulo, testContenidos[1].titulo);
    });

    test('debería almacenar y recuperar un contenido por ID correctamente', () async {
      // arrange
      final testContenido = ContenidoModel(
        id: '1',
        titulo: 'Test Contenido 1',
        descripcion: 'Test Descripción 1',
        url: 'https://example.com/video1.mp4',
        thumbnailUrl: 'https://example.com/thumb1.jpg',
        tipo: TipoContenido.video,
        categoria: CategoriaContenido.nutricion,
        nivel: NivelDificultad.basico,
        duracion: 300,
        etiquetas: const ['test', 'video'],
        semanaGestacionInicio: 10,
        semanaGestacionFin: 20,
        fechaPublicacion: DateTime.parse('2023-01-01'),
        createdAt: DateTime.parse('2023-01-01'),
        updatedAt: DateTime.parse('2023-01-01'),
      );

      // act
      await cacheService.cacheContenido(testContenido);
      final cachedContenido = await cacheService.getCachedContenidoById('1');

      // assert
      expect(cachedContenido, isNotNull);
      expect(cachedContenido!.id, testContenido.id);
      expect(cachedContenido.titulo, testContenido.titulo);
    });

    test('debería almacenar y recuperar resultados de búsqueda correctamente', () async {
      // arrange
      final testContenidos = [
        ContenidoModel(
          id: '1',
          titulo: 'Test Contenido 1',
          descripcion: 'Test Descripción 1',
          url: 'https://example.com/video1.mp4',
          thumbnailUrl: 'https://example.com/thumb1.jpg',
          tipo: TipoContenido.video,
          categoria: CategoriaContenido.nutricion,
          nivel: NivelDificultad.basico,
          duracion: 300,
          etiquetas: const ['test', 'video'],
          semanaGestacionInicio: 10,
          semanaGestacionFin: 20,
          fechaPublicacion: DateTime.parse('2023-01-01'),
          createdAt: DateTime.parse('2023-01-01'),
          updatedAt: DateTime.parse('2023-01-01'),
        ),
      ];

      // act
      await cacheService.cacheSearchResults('test query', testContenidos);
      final cachedResults = await cacheService.getCachedSearchResults('test query');

      // assert
      expect(cachedResults.length, testContenidos.length);
      expect(cachedResults[0].id, testContenidos[0].id);
      expect(cachedResults[0].titulo, testContenidos[0].titulo);
    });

    test('debería almacenar y recuperar favoritos correctamente', () async {
      // arrange
      final testContenidos = [
        ContenidoModel(
          id: '1',
          titulo: 'Test Contenido 1',
          descripcion: 'Test Descripción 1',
          url: 'https://example.com/video1.mp4',
          thumbnailUrl: 'https://example.com/thumb1.jpg',
          tipo: TipoContenido.video,
          categoria: CategoriaContenido.nutricion,
          nivel: NivelDificultad.basico,
          duracion: 300,
          etiquetas: const ['test', 'video'],
          semanaGestacionInicio: 10,
          semanaGestacionFin: 20,
          fechaPublicacion: DateTime.parse('2023-01-01'),
          createdAt: DateTime.parse('2023-01-01'),
          updatedAt: DateTime.parse('2023-01-01'),
        ),
      ];

      // act
      await cacheService.cacheFavoritos('user1', testContenidos);
      final cachedFavoritos = await cacheService.getCachedFavoritos('user1');

      // assert
      expect(cachedFavoritos.length, testContenidos.length);
      expect(cachedFavoritos[0].id, testContenidos[0].id);
      expect(cachedFavoritos[0].titulo, testContenidos[0].titulo);
    });

    test('debería almacenar y recuperar progreso correctamente', () async {
      // arrange
      final testProgreso = {
        'tiempoVisualizado': 150,
        'porcentaje': 50.0,
        'completado': false,
        'ultimaPosicion': 150,
      };

      // act
      await cacheService.cacheProgreso('1', 'user1', testProgreso);
      final cachedProgreso = await cacheService.getCachedProgreso('1', 'user1');

      // assert
      expect(cachedProgreso, isNotNull);
      expect(cachedProgreso!['tiempoVisualizado'], testProgreso['tiempoVisualizado']);
      expect(cachedProgreso['porcentaje'], testProgreso['porcentaje']);
      expect(cachedProgreso['completado'], testProgreso['completado']);
    });

    test('debería limpiar el caché correctamente', () async {
      // arrange
      final testContenido = ContenidoModel(
        id: '1',
        titulo: 'Test Contenido 1',
        descripcion: 'Test Descripción 1',
        url: 'https://example.com/video1.mp4',
        thumbnailUrl: 'https://example.com/thumb1.jpg',
        tipo: TipoContenido.video,
        categoria: CategoriaContenido.nutricion,
        nivel: NivelDificultad.basico,
        duracion: 300,
        etiquetas: const ['test', 'video'],
        semanaGestacionInicio: 10,
        semanaGestacionFin: 20,
        fechaPublicacion: DateTime.parse('2023-01-01'),
        createdAt: DateTime.parse('2023-01-01'),
        updatedAt: DateTime.parse('2023-01-01'),
      );

      // act
      await cacheService.cacheContenido(testContenido);
      await cacheService.clearCache();
      final cachedContenido = await cacheService.getCachedContenidoById('1');

      // assert
      expect(cachedContenido, isNull);
    });

    test('debería verificar si el caché es válido correctamente', () async {
      // arrange
      final testContenido = ContenidoModel(
        id: '1',
        titulo: 'Test Contenido 1',
        descripcion: 'Test Descripción 1',
        url: 'https://example.com/video1.mp4',
        thumbnailUrl: 'https://example.com/thumb1.jpg',
        tipo: TipoContenido.video,
        categoria: CategoriaContenido.nutricion,
        nivel: NivelDificultad.basico,
        duracion: 300,
        etiquetas: const ['test', 'video'],
        semanaGestacionInicio: 10,
        semanaGestacionFin: 20,
        fechaPublicacion: DateTime.parse('2023-01-01'),
        createdAt: DateTime.parse('2023-01-01'),
        updatedAt: DateTime.parse('2023-01-01'),
      );

      // act
      await cacheService.cacheContenido(testContenido);
      final isValid = await cacheService.isCacheValid(key: 'contenido_1');

      // assert
      expect(isValid, true);
    });
  });
}

// Clase mock para NetworkInfo
class MockNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

// Clase de prueba para CacheService con nombres de caja personalizados
class TestCacheService extends CacheService {
  TestCacheService(super.networkInfo);

  @override
  Future<void> init() async {
    try {
      // Abrir cajas de Hive con nombres de prueba
      if (!Hive.isBoxOpen('test_contenidos_cache')) {
        _contenidosBox = await Hive.openBox<Map>('test_contenidos_cache');
      } else {
        _contenidosBox = Hive.box<Map>('test_contenidos_cache');
      }
      
      if (!Hive.isBoxOpen('test_categorias_cache')) {
        _categoriasBox = await Hive.openBox<Map>('test_categorias_cache');
      } else {
        _categoriasBox = Hive.box<Map>('test_categorias_cache');
      }
      
      if (!Hive.isBoxOpen('test_search_results_cache')) {
        _searchResultsBox = await Hive.openBox<Map>('test_search_results_cache');
      } else {
        _searchResultsBox = Hive.box<Map>('test_search_results_cache');
      }
      
      if (!Hive.isBoxOpen('test_favoritos_cache')) {
        _favoritosBox = await Hive.openBox<Map>('test_favoritos_cache');
      } else {
        _favoritosBox = Hive.box<Map>('test_favoritos_cache');
      }
      
      if (!Hive.isBoxOpen('test_progreso_cache')) {
        _progresoBox = await Hive.openBox<Map>('test_progreso_cache');
      } else {
        _progresoBox = Hive.box<Map>('test_progreso_cache');
      }
      
      if (!Hive.isBoxOpen('test_timestamps_cache')) {
        _timestampsBox = await Hive.openBox<String>('test_timestamps_cache');
      } else {
        _timestampsBox = Hive.box<String>('test_timestamps_cache');
      }
      
      // Limpiar caché expirado
      await _cleanExpiredCache();
    } catch (e) {
      throw Exception('Error inicializando caché: $e');
    }
  }
}