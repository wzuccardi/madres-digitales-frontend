import 'package:equatable/equatable.dart';
import '../../../domain/entities/contenido.dart';
import '../../../domain/entities/categoria.dart';

enum ContenidoStatus {
  initial,
  loading,
  success,
  failure,
}

class ContenidoState extends Equatable {
  final ContenidoStatus status;
  final List<Contenido> contenidos;
  final List<Contenido> searchResults;
  final Contenido? selectedContenido;
  final String? error;
  final CategoriaContenido? categoria;
  final TipoContenido? tipo;
  final NivelDificultad? nivel;
  final int page;
  final int limit;
  final bool hasReachedMax;
  final bool isRefreshing;
  final List<Categoria> categorias;
  final String? searchQuery;

  const ContenidoState({
    this.status = ContenidoStatus.initial,
    this.contenidos = const [],
    this.searchResults = const [],
    this.selectedContenido,
    this.error,
    this.categoria,
    this.tipo,
    this.nivel,
    this.page = 1,
    this.limit = 20,
    this.hasReachedMax = false,
    this.isRefreshing = false,
    this.categorias = const [],
    this.searchQuery,
  });

  ContenidoState copyWith({
    ContenidoStatus? status,
    List<Contenido>? contenidos,
    List<Contenido>? searchResults,
    Contenido? selectedContenido,
    String? error,
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int? page,
    int? limit,
    bool? hasReachedMax,
    bool? isRefreshing,
    List<Categoria>? categorias,
    String? searchQuery,
  }) {
    return ContenidoState(
      status: status ?? this.status,
      contenidos: contenidos ?? this.contenidos,
      searchResults: searchResults ?? this.searchResults,
      selectedContenido: selectedContenido ?? this.selectedContenido,
      error: error ?? this.error,
      categoria: categoria ?? this.categoria,
      tipo: tipo ?? this.tipo,
      nivel: nivel ?? this.nivel,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      categorias: categorias ?? this.categorias,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contenidos,
        searchResults,
        selectedContenido,
        error,
        categoria,
        tipo,
        nivel,
        page,
        limit,
        hasReachedMax,
        isRefreshing,
        categorias,
        searchQuery,
      ];
}