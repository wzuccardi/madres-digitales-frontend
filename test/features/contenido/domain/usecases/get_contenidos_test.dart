import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/repositories/contenido_repository.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/get_contenidos.dart';
import 'package:madres_digitales_flutter_new/core/errors/failures.dart';

import 'get_contenidos_test.mocks.dart';

@GenerateMocks([ContenidoRepository])
void main() {
  late GetContenidosUseCase useCase;
  late MockContenidoRepository mockRepository;

  setUp(() {
    mockRepository = MockContenidoRepository();
    useCase = GetContenidosUseCase(mockRepository);
  });

  const testContenidos = [
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
      etiquetas: ['test', 'video'],
      semanaGestacionInicio: 10,
      semanaGestacionFin: 20,
      createdAt: '2023-01-01T00:00:00.000Z',
      updatedAt: '2023-01-01T00:00:00.000Z',
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
      etiquetas: ['test', 'articulo'],
      createdAt: '2023-01-02T00:00:00.000Z',
      updatedAt: '2023-01-02T00:00:00.000Z',
    ),
  ];

  test('debería obtener contenidos del repositorio', () async {
    // arrange
    when(mockRepository.getContenidos(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    )).thenAnswer((_) async => const Right(testContenidos));

    // act
    final result = await useCase.call(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    );

    // assert
    expect(result, const Right(testContenidos));
    verify(mockRepository.getContenidos(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('debería obtener contenidos filtrados por categoría', () async {
    // arrange
    when(mockRepository.getContenidos(
      categoria: CategoriaContenido.nutricion,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    )).thenAnswer((_) async => const Right([testContenidos[0]]));

    // act
    final result = await useCase.call(
      categoria: CategoriaContenido.nutricion,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    );

    // assert
    expect(result, const Right([testContenidos[0]]));
    verify(mockRepository.getContenidos(
      categoria: CategoriaContenido.nutricion,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('debería obtener contenidos filtrados por tipo', () async {
    // arrange
    when(mockRepository.getContenidos(
      categoria: null,
      tipo: TipoContenido.video,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    )).thenAnswer((_) async => const Right([testContenidos[0]]));

    // act
    final result = await useCase.call(
      categoria: null,
      tipo: TipoContenido.video,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    );

    // assert
    expect(result, const Right([testContenidos[0]]));
    verify(mockRepository.getContenidos(
      categoria: null,
      tipo: TipoContenido.video,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('debería obtener contenidos filtrados por nivel', () async {
    // arrange
    when(mockRepository.getContenidos(
      categoria: null,
      tipo: null,
      nivel: NivelDificultad.basico,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    )).thenAnswer((_) async => const Right([testContenidos[0]]));

    // act
    final result = await useCase.call(
      categoria: null,
      tipo: null,
      nivel: NivelDificultad.basico,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    );

    // assert
    expect(result, const Right([testContenidos[0]]));
    verify(mockRepository.getContenidos(
      categoria: null,
      tipo: null,
      nivel: NivelDificultad.basico,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('debería obtener contenidos con paginación', () async {
    // arrange
    when(mockRepository.getContenidos(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 2,
      limit: 10,
      useCache: true,
      forceRefresh: false,
    )).thenAnswer((_) async => const Right(testContenidos));

    // act
    final result = await useCase.call(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 2,
      limit: 10,
      useCache: true,
      forceRefresh: false,
    );

    // assert
    expect(result, const Right(testContenidos));
    verify(mockRepository.getContenidos(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 2,
      limit: 10,
      useCache: true,
      forceRefresh: false,
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('debería forzar la actualización de contenidos', () async {
    // arrange
    when(mockRepository.getContenidos(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: false,
      forceRefresh: true,
    )).thenAnswer((_) async => const Right(testContenidos));

    // act
    final result = await useCase.call(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: false,
      forceRefresh: true,
    );

    // assert
    expect(result, const Right(testContenidos));
    verify(mockRepository.getContenidos(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: false,
      forceRefresh: true,
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('debería retornar un ServerFailure cuando el repositorio falla', () async {
    // arrange
    when(mockRepository.getContenidos(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    )).thenAnswer((_) async => const Left(ServerFailure('Error del servidor')));

    // act
    final result = await useCase.call(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    );

    // assert
    expect(result, const Left(ServerFailure('Error del servidor')));
    verify(mockRepository.getContenidos(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('debería retornar un NetworkFailure cuando no hay conexión', () async {
    // arrange
    when(mockRepository.getContenidos(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    )).thenAnswer((_) async => const Left(NetworkFailure('Sin conexión')));

    // act
    final result = await useCase.call(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    );

    // assert
    expect(result, const Left(NetworkFailure('Sin conexión')));
    verify(mockRepository.getContenidos(
      categoria: null,
      tipo: null,
      nivel: null,
      page: 1,
      limit: 20,
      useCache: true,
      forceRefresh: false,
    ));
    verifyNoMoreInteractions(mockRepository);
  });
}