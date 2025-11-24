/// Interfaz base para todos los repositorios de la aplicación
/// Define los métodos comunes que todos los repositorios deben implementar
library;
import '../types/result.dart';

abstract class BaseRepository<T, ID> {
  /// Obtiene todos los elementos
  Future<Result<List<T>, Exception>> getAll();
  
  /// Obtiene un elemento por su ID
  Future<Result<T?, Exception>> getById(ID id);
  
  /// Crea un nuevo elemento
  Future<Result<T, Exception>> create(T item);
  
  /// Actualiza un elemento existente
  Future<Result<T, Exception>> update(T item);
  
  /// Elimina un elemento por su ID
  Future<Result<void, Exception>> delete(ID id);
  
  /// Busca elementos según criterios
  Future<Result<List<T>, Exception>> search(Map<String, dynamic> criteria);
  
  /// Obtiene elementos con paginación
  Future<Result<List<T>, Exception>> getPage({
    required int page,
    required int limit,
    Map<String, dynamic>? filters,
  });
  
  /// Cuenta el total de elementos
  Future<Result<int, Exception>> count([Map<String, dynamic>? filters]);
}

/// Parámetros de paginación para consultas
class PaginationParams {
  
  const PaginationParams({
    required this.page,
    required this.limit,
    this.filters,
    this.sortBy,
    this.ascending = true,
  });
  final int page;
  final int limit;
  final Map<String, dynamic>? filters;
  final String? sortBy;
  final bool ascending;
}

/// Resultado de una consulta paginada
class PagedResult<T> {
  
  const PagedResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNextPage;
  final bool hasPreviousPage;
}

/// Excepción base para errores de repositorios
class RepositoryException implements Exception {
  
  const RepositoryException(
    this.message, {
    this.operation,
    this.originalError,
  });
  final String message;
  final String? operation;
  final dynamic originalError;
  
  @override
  String toString() {
    return 'RepositoryException: $message${operation != null ? ' (Operation: $operation)' : ''}';
  }
}
