/// Interfaz base para todos los servicios de la aplicación
/// Define los métodos comunes que todos los servicios deben implementar
abstract class BaseService {
  /// Inicializa el servicio
  Future<void> initialize();
  
  /// Dispose de los recursos del servicio
  Future<void> dispose();
  
  /// Verifica si el servicio está inicializado
  bool get isInitialized;
  
  /// Obtiene el estado actual del servicio
  ServiceStatus get status;
}

/// Estados posibles de un servicio
enum ServiceStatus {
  /// El servicio no ha sido inicializado
  notInitialized,
  
  /// El servicio está en proceso de inicialización
  initializing,
  
  /// El servicio está inicializado y funcionando correctamente
  initialized,
  
  /// El servicio está en proceso de disposición
  disposing,
  
  /// El servicio ha sido dispuesto
  disposed,
  
  /// El servicio está en estado de error
  error,
}

/// Excepción base para errores de servicios
class ServiceException implements Exception {
  
  const ServiceException(
    this.message, {
    this.status,
    this.originalError,
  });
  final String message;
  final ServiceStatus? status;
  final dynamic originalError;
  
  @override
  String toString() {
    return 'ServiceException: $message${status != null ? ' (Status: $status)' : ''}';
  }
}
