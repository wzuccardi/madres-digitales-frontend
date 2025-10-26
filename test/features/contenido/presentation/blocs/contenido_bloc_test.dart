import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:madres_digitales_flutter_new/features/contenido/presentation/blocs/contenido/contenido_bloc.dart';
import 'package:madres_digitales_flutter_new/features/contenido/presentation/blocs/contenido/contenido_event.dart';
import 'package:madres_digitales_flutter_new/features/contenido/presentation/blocs/contenido/contenido_state.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';

void main() {
  group('ContenidoBloc Tests', () {
    late ContenidoBloc contenidoBloc;
    late List<Contenido> testContenidos;

    setUp(() {
      // Inicializar el BLoC con casos de uso simulados
      contenidoBloc = ContenidoBloc(
        getContenidosUseCase: MockGetContenidosUseCase(),
        getContenidoByIdUseCase: MockGetContenidoByIdUseCase(),
        createContenidoUseCase: MockCreateContenidoUseCase(),
        searchContenidosUseCase: MockSearchContenidosUseCase(),
        toggleFavoritoUseCase: MockToggleFavoritoUseCase(),
        registrarVistaUseCase: MockRegistrarVistaUseCase(),
        actualizarProgresoUseCase: MockActualizarProgresoUseCase(),
        getFavoritosUseCase: MockGetFavoritosUseCase(),
        getContenidosConProgresoUseCase: MockGetContenidosConProgresoUseCase(),
      );

      testContenidos = [
        Contenido(
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
        Contenido(
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
    });

    tearDown(() {
      contenidoBloc.close();
    });

    test('estado inicial debe ser ContenidoState.initial()', () {
      expect(contenidoBloc.state, const ContenidoState.initial());
    });

    blocTest<ContenidoBloc, ContenidoState>(
      'emite [loading, success] cuando LoadContenidosEvent es agregado',
      build: () => contenidoBloc,
      act: (bloc) => bloc.add(const LoadContenidosEvent()),
      expect: () => [
        const ContenidoState(
          status: ContenidoStatus.loading,
          contenidos: [],
          page: 1,
          limit: 20,
          hasReachedMax: false,
        ),
        ContenidoState(
          status: ContenidoStatus.success,
          contenidos: testContenidos,
          page: 1,
          limit: 20,
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<ContenidoBloc, ContenidoState>(
      'emite [loading, success] cuando LoadContenidoByIdEvent es agregado',
      build: () => contenidoBloc,
      act: (bloc) => bloc.add(const LoadContenidoByIdEvent('1')),
      expect: () => [
        const ContenidoState(
          status: ContenidoStatus.loading,
          contenidos: [],
          page: 1,
          limit: 20,
          hasReachedMax: false,
        ),
        ContenidoState(
          status: ContenidoStatus.success,
          contenidos: testContenidos,
          selectedContenido: testContenidos[0],
          page: 1,
          limit: 20,
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<ContenidoBloc, ContenidoState>(
      'emite [loading, success] cuando SearchContenidosEvent es agregado',
      build: () => contenidoBloc,
      act: (bloc) => bloc.add(const SearchContenidosEvent(query: 'test')),
      expect: () => [
        const ContenidoState(
          status: ContenidoStatus.loading,
          contenidos: [],
          page: 1,
          limit: 20,
          hasReachedMax: false,
        ),
        ContenidoState(
          status: ContenidoStatus.success,
          contenidos: testContenidos,
          searchResults: testContenidos,
          page: 1,
          limit: 20,
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<ContenidoBloc, ContenidoState>(
      'emite [loading, success] cuando ToggleFavoritoEvent es agregado',
      build: () => contenidoBloc,
      act: (bloc) => bloc.add(const ToggleFavoritoEvent('1')),
      expect: () => [
        const ContenidoState(
          status: ContenidoStatus.loading,
          contenidos: [],
          page: 1,
          limit: 20,
          hasReachedMax: false,
        ),
        ContenidoState(
          status: ContenidoStatus.success,
          contenidos: testContenidos,
          page: 1,
          limit: 20,
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<ContenidoBloc, ContenidoState>(
      'emite [loading, success] cuando GetFavoritosEvent es agregado',
      build: () => contenidoBloc,
      act: (bloc) => bloc.add(const GetFavoritosEvent('usuario1')),
      expect: () => [
        const ContenidoState(
          status: ContenidoStatus.loading,
          contenidos: [],
          page: 1,
          limit: 20,
          hasReachedMax: false,
        ),
        ContenidoState(
          status: ContenidoStatus.success,
          contenidos: testContenidos,
          favoritos: testContenidos,
          page: 1,
          limit: 20,
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<ContenidoBloc, ContenidoState>(
      'emite [loading, success] cuando RefreshContenidosEvent es agregado',
      build: () => contenidoBloc,
      act: (bloc) => bloc.add(const RefreshContenidosEvent()),
      expect: () => [
        const ContenidoState(
          status: ContenidoStatus.loading,
          contenidos: [],
          page: 1,
          limit: 20,
          hasReachedMax: false,
        ),
        ContenidoState(
          status: ContenidoStatus.success,
          contenidos: testContenidos,
          page: 1,
          limit: 20,
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<ContenidoBloc, ContenidoState>(
      'emite [loading, success] cuando ClearContenidoEvent es agregado',
      build: () => contenidoBloc,
      act: (bloc) => bloc.add(const ClearContenidoEvent()),
      expect: () => [
        const ContenidoState(
          status: ContenidoStatus.loading,
          contenidos: [],
          page: 1,
          limit: 20,
          hasReachedMax: false,
        ),
        const ContenidoState.initial(),
      ],
    );
  });
}

// Clases mock para los casos de uso
class MockGetContenidosUseCase {
  Future<List<Contenido>> call({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    // Simular respuesta exitosa
    return [
      Contenido(
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
      Contenido(
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
  }
}

class MockGetContenidoByIdUseCase {
  Future<Contenido> call(String id) async {
    // Simular respuesta exitosa
    return Contenido(
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
  }
}

class MockCreateContenidoUseCase {
  Future<Contenido> call(CreateContenidoParams params) async {
    // Simular respuesta exitosa
    return Contenido(
      id: '1',
      titulo: params.titulo,
      descripcion: params.descripcion,
      url: params.url,
      tipo: params.tipo,
      categoria: params.categoria,
      nivel: params.nivel,
      etiquetas: params.etiquetas,
      fechaPublicacion: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class MockSearchContenidosUseCase {
  Future<List<Contenido>> call(String query, {Map<String, dynamic>? filters}) async {
    // Simular respuesta exitosa
    return [
      Contenido(
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
  }
}

class MockToggleFavoritoUseCase {
  Future<void> call(String id) async {
    // Simular respuesta exitosa
  }
}

class MockRegistrarVistaUseCase {
  Future<void> call(String id) async {
    // Simular respuesta exitosa
  }
}

class MockActualizarProgresoUseCase {
  Future<void> call(String id, {int? tiempoVisualizado, double? porcentaje, bool? completado}) async {
    // Simular respuesta exitosa
  }
}

class MockGetFavoritosUseCase {
  Future<List<Contenido>> call(String usuarioId) async {
    // Simular respuesta exitosa
    return [
      Contenido(
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
  }
}

class MockGetContenidosConProgresoUseCase {
  Future<List<Contenido>> call(String usuarioId) async {
    // Simular respuesta exitosa
    return [
      Contenido(
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
  }
}