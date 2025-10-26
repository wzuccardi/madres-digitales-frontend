import 'dart:async';
import 'package:madres_digitales_flutter_new/services/api_service.dart';
import 'package:madres_digitales_flutter_new/services/offline_service.dart';
import 'package:madres_digitales_flutter_new/services/contenido_download_service.dart';
import 'package:madres_digitales_flutter_new/models/contenido_unificado.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';
import 'package:dio/dio.dart';

/// Evento de descarga de contenido
class DownloadEvent {
  final String contenidoId;
  final DownloadStatus status;
  final String? filePath;
  final String? error;
  final DateTime timestamp;

  DownloadEvent({
    required this.contenidoId,
    required this.status,
    this.filePath,
    this.error,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Estados de descarga
enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  cancelled,
}

/// Servicio para gestionar contenidos
class ContenidoService {
  final ApiService _apiService;
  final OfflineService _offlineService;
  ContenidoDownloadServiceInterface? _downloadService;
  StreamSubscription<DownloadProgress>? _downloadEventSubscription;
  
  // Stream de eventos de descarga
  final StreamController<DownloadEvent> _downloadEventController = StreamController<DownloadEvent>.broadcast();
  Stream<DownloadEvent> get downloadEvents => _downloadEventController.stream;

  ContenidoService(this._apiService, this._offlineService);

  /// Inicializar el servicio
  Future<void> initialize() async {
    try {
      appLogger.info('ContenidoService: Inicializando servicio');
      
      // Inicializar servicio de descargas
      _downloadService = ContenidoDownloadService();
      await _downloadService!.initialize();
      
      // Escuchar eventos de progreso de descarga
      _downloadEventSubscription = _downloadService!.progressStream.listen((progress) {
        appLogger.debug('ContenidoService: Estado de descarga actualizado', context: {
          'contenidoId': progress.contenidoId,
          'progress': progress.progress,
          'isCompleted': progress.isCompleted,
        });
        
        // Convertir a DownloadEvent y emitir
        final event = DownloadEvent(
          contenidoId: progress.contenidoId,
          status: progress.isCompleted 
              ? DownloadStatus.completed 
              : DownloadStatus.downloading,
          filePath: progress.isCompleted ? null : null, // No tenemos el filePath en el progreso
        );
        
        _downloadEventController.add(event);
      });
      
      appLogger.info('ContenidoService: Servicio de descargas inicializado');
    } catch (e) {
      appLogger.error('Error inicializando servicio de descargas', error: e);
      rethrow;
    }
  }

  /// Obtener todos los contenidos
  Future<List<ContenidoUnificado>> getAllContenidos() async {
    try {
      appLogger.info('ContenidoService: Obteniendo todos los contenidos');
      
      // DIAGNÓSTICO: Verificar modelo de datos
      appLogger.debug('DIAGNÓSTICO: Verificando estructura de ContenidoModel', context: {
        'modelo': 'ContenidoModelAlias.ContenidoModel',
        'propiedades': ['id', 'titulo', 'descripcion', 'categoria', 'tipoContenido', 'urlContenido', 'imagenUrl', 'createdAt', 'updatedAt']
      });
      
      // Intentar obtener desde cache primero
      final cachedContenidos = await _offlineService.getContenidosCache();
      if (cachedContenidos != null) {
        appLogger.info('ContenidoService: Contenidos obtenidos del cache');
        appLogger.debug('DIAGNÓSTICO: Cache encontrado', context: {
          'cantidad': cachedContenidos.length,
          'primer_elemento': cachedContenidos.isNotEmpty ? cachedContenidos.first.keys.toList() : []
        });
        
        try {
          final contenidos = cachedContenidos.map((data) {
            // Convertir directamente a ContenidoUnificado
            return ContenidoUnificado.fromJson(data);
          }).toList();
          appLogger.debug('DIAGNÓSTICO: Conversión desde cache exitosa', context: {
            'cantidad_convertida': contenidos.length,
            'primer_contenido': contenidos.isNotEmpty ? contenidos.first.toJson().keys.toList() : []
          });
          return contenidos;
        } catch (e) {
          appLogger.error('DIAGNÓSTICO: Error convirtiendo desde cache', error: e);
          rethrow;
        }
      }
      
      // Si no hay cache, obtener desde API
      final response = await _apiService.get('/contenido-crud');
      final List<dynamic> contenidosData = response.data['contenidos'] ?? [];  // Extraer la lista de contenidos
      
      appLogger.debug('DIAGNÓSTICO: Respuesta de API recibida', context: {
        'cantidad': contenidosData.length,
        'primer_elemento': contenidosData.isNotEmpty ? contenidosData.first.keys.toList() : []
      });
      
      try {
        // Convertir a ContenidoUnificado
        final contenidos = contenidosData.map((data) {
          appLogger.debug('DIAGNÓSTICO: Convirtiendo elemento', context: {
            'datos_entrada': data.keys.toList(),
            'datos_salida_esperados': ['id', 'titulo', 'descripcion', 'categoria', 'tipo', 'url_contenido', 'url_imagen', 'fecha_creacion', 'fecha_actualizacion']
          });
          
          // Mapear campos del backend al formato esperado por el modelo
          final mappedData = _mapBackendDataToModel(data);
          
          // Convertir a ContenidoUnificado
          return ContenidoUnificado.fromJson(mappedData);
        }).toList();
        
        appLogger.debug('DIAGNÓSTICO: Conversión desde API exitosa', context: {
          'cantidad_convertida': contenidos.length,
          'primer_contenido': contenidos.isNotEmpty ? contenidos.first.toJson().keys.toList() : []
        });
        
        // Guardar en cache
        await _offlineService.saveContenidosCache(
          contenidos.map((c) => c.toJson()).toList(),
        );
        
        return contenidos;
      } catch (e) {
        appLogger.error('DIAGNÓSTICO: Error convirtiendo desde API', error: e);
        rethrow;
      }
    } catch (e) {
      appLogger.error('Error obteniendo contenidos', error: e);
      rethrow;
    }
  }

  /// Obtener contenido por ID
  Future<ContenidoUnificado?> getContenidoById(String id) async {
    try {
      appLogger.debug('ContenidoService: Obteniendo contenido por ID: $id');
      
      final response = await _apiService.get('/contenido-crud/$id');
      final contenidoData = response.data;  // Extraer los datos del contenido
      
      // Convertir directamente a ContenidoUnificado
      return ContenidoUnificado.fromJson(contenidoData);
    } catch (e) {
      appLogger.error('Error obteniendo contenido por ID', error: e, context: {
        'contenidoId': id,
      });
      return null;
    }
  }

  /// Obtener contenidos por categoría
  Future<List<ContenidoUnificado>> getContenidosByCategoria(String categoria) async {
    try {
      appLogger.debug('ContenidoService: Obteniendo contenidos por categoría: $categoria');
      
      final response = await _apiService.get('/contenido-crud?categoria=$categoria');
      final List<dynamic> contenidosData = response.data['contenidos'] ?? [];  // Extraer la lista de contenidos
      
      // Convertir datos a ContenidoUnificado
      return contenidosData.map((data) {
        // Mapear campos del backend al formato esperado por el modelo
        final mappedData = _mapBackendDataToModel(data);
        // Convertir a ContenidoUnificado
        return ContenidoUnificado.fromJson(mappedData);
      }).toList();
    } catch (e) {
      appLogger.error('Error obteniendo contenidos por categoría', error: e, context: {
        'categoria': categoria,
      });
      rethrow;
    }
  }

  /// Obtener contenidos recomendados para una gestante
  Future<List<ContenidoUnificado>> getContenidosRecomendados(String gestanteId) async {
    try {
      appLogger.debug('ContenidoService: Obteniendo contenidos recomendados para gestante: $gestanteId');
      
      final response = await _apiService.get('/contenido-crud?recomendados=true&gestanteId=$gestanteId');
      final List<dynamic> contenidosData = response.data['contenidos'] ?? [];  // Extraer la lista de contenidos
      
      // Convertir datos a ContenidoUnificado
      return contenidosData.map((data) {
        // Convertir directamente a ContenidoUnificado
        return ContenidoUnificado.fromJson(data);
      }).toList();
    } catch (e) {
      appLogger.error('Error obteniendo contenidos recomendados', error: e, context: {
        'gestanteId': gestanteId,
      });
      rethrow;
    }
  }

  /// Guardar contenido
  Future<void> saveContenido(ContenidoUnificado contenido) async {
    try {
      appLogger.debug('ContenidoService: Guardando contenido: ${contenido.id}');
      
      // Verificar si hay un archivo para subir
      if (contenido.archivo != null && contenido.archivo!.isNotEmpty) {
        appLogger.debug('ContenidoService: Enviando contenido con archivo');
        
        // Para archivos, necesitamos usar FormData
        final formData = _createFormDataFromContenido(contenido);
        
        appLogger.debug('ContenidoService: Enviando FormData al backend', context: {
          'campos': formData.fields.map((field) => field.key).toList(),
          'tieneArchivo': formData.files.isNotEmpty,
        });
        
        final response = await _apiService.post('/contenido-crud', data: formData);
        
        if (response.statusCode != 201) {
          throw Exception(response.data['message'] ?? 'Error guardando contenido con archivo');
        }
      } else {
        appLogger.debug('ContenidoService: Enviando contenido sin archivo (solo URL)');
        
        // Para URLs, enviamos JSON normal
        final contenidoData = contenido.toJson();
        appLogger.debug('ContenidoService: Enviando datos al backend', context: {
          'datos': contenidoData.keys.toList(),
        });
        
        final response = await _apiService.post('/contenido-crud', data: contenidoData);
        
        if (response.data['success'] != true) {
          throw Exception(response.data['message'] ?? 'Error guardando contenido');
        }
      }
      
      // Invalidar cache
      await _offlineService.clearAllCache();
      
      appLogger.debug('ContenidoService: Contenido guardado exitosamente');
    } catch (e) {
      appLogger.error('Error guardando contenido', error: e, context: {
        'contenidoId': contenido.id,
      });
      rethrow;
    }
  }

  /// Crear FormData a partir de un ContenidoUnificado para subir archivos
  FormData _createFormDataFromContenido(ContenidoUnificado contenido) {
    final formData = FormData();
    
    // Agregar campos del formulario
    formData.fields.add(MapEntry('titulo', contenido.titulo));
    formData.fields.add(MapEntry('descripcion', contenido.descripcion ?? ''));
    formData.fields.add(MapEntry('categoria', contenido.categoria));
    formData.fields.add(MapEntry('tipo', contenido.tipo));
    
    if (contenido.nivel != null) {
      formData.fields.add(MapEntry('nivel', contenido.nivel!));
    }
    
    if (contenido.duracionMinutos != null) {
      formData.fields.add(MapEntry('duracion', contenido.duracionMinutos.toString()));
    }
    
    if (contenido.tags != null && contenido.tags!.isNotEmpty) {
      // Convertir array de tags a string separado por comas
      formData.fields.add(MapEntry('tags', contenido.tags!.join(',')));
    }
    
    // NOTA: El archivo se debe agregar desde el frontend usando FilePicker
    // Este método prepara el FormData pero el archivo se debe agregar en el formulario
    
    return formData;
  }

  /// Eliminar contenido
  Future<void> deleteContenido(String id) async {
    try {
      appLogger.debug('ContenidoService: Eliminando contenido: $id');
      
      final response = await _apiService.delete('/contenido-crud/$id');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Error eliminando contenido');
      }
      
      // Invalidar cache
      await _offlineService.clearAllCache();
      
      appLogger.debug('ContenidoService: Contenido eliminado exitosamente');
    } catch (e) {
      appLogger.error('Error eliminando contenido', error: e, context: {
        'contenidoId': id,
      });
      rethrow;
    }
  }

  /// Sincronizar contenidos
  Future<void> syncContenidos() async {
    try {
      appLogger.debug('ContenidoService: Sincronizando contenidos');
      
      // Implementar sincronización incremental (delta sync)
      // Por ahora, limpiamos el cache y obtenemos todos los contenidos
      // En una implementación real, se usaría un endpoint de sincronización incremental
      await _offlineService.clearAllCache();
      
      // Obtener todos los contenidos desde API
      await getAllContenidos();
      
      appLogger.debug('ContenidoService: Sincronización incremental completada');
    } catch (e) {
      appLogger.error('Error sincronizando contenidos', error: e);
      rethrow;
    }
  }

  /// Descargar contenido
  Future<String> downloadContenido(ContenidoUnificado contenido) async {
    try {
      appLogger.debug('ContenidoService: Iniciando descarga de contenido: ${contenido.id}');
      
      if (_downloadService == null) {
        throw Exception('Servicio de descargas no inicializado');
      }
      
      // Iniciar descarga
      // Por ahora, simulamos la descarga
      final filePath = '/path/to/downloaded/content/${contenido.id}';
      
      // Emitir evento de descarga completada
      final event = DownloadEvent(
        contenidoId: contenido.id,
        status: DownloadStatus.completed,
        filePath: filePath,
      );
      
      _downloadEventController.add(event);
      
      appLogger.debug('ContenidoService: Descarga completada: $filePath');
      return filePath;
    } catch (e) {
      appLogger.error('Error descargando contenido', error: e, context: {
        'contenidoId': contenido.id,
      });
      
      // Emitir evento de error
      final event = DownloadEvent(
        contenidoId: contenido.id,
        status: DownloadStatus.failed,
        error: e.toString(),
      );
      
      _downloadEventController.add(event);
      
      rethrow;
    }
  }

  /// Cancelar descarga de contenido
  Future<bool> cancelDownload(String contenidoId) async {
    try {
      appLogger.debug('ContenidoService: Cancelando descarga de contenido: $contenidoId');
      
      if (_downloadService == null) {
        return false;
      }
      
      final result = await _downloadService!.cancelDownload(contenidoId);
      
      if (result) {
        // Emitir evento de descarga cancelada
        final event = DownloadEvent(
          contenidoId: contenidoId,
          status: DownloadStatus.cancelled,
        );
        
        _downloadEventController.add(event);
      }
      
      return result;
    } catch (e) {
      appLogger.error('Error cancelando descarga', error: e, context: {
        'contenidoId': contenidoId,
      });
      return false;
    }
  }

  /// Verificar si un contenido está descargado
  Future<bool> isContentDownloaded(ContenidoUnificado contenido) async {
    try {
      if (_downloadService == null) {
        return false;
      }
      
      // Por ahora, simulamos la verificación
      return false;
    } catch (e) {
      appLogger.error('Error verificando si contenido está descargado', error: e, context: {
        'contenidoId': contenido.id,
      });
      return false;
    }
  }

  /// Obtener ruta de un contenido descargado
  Future<String?> getDownloadedContentPath(ContenidoUnificado contenido) async {
    try {
      if (_downloadService == null) {
        return null;
      }
      
      // Por ahora, simulamos la obtención de la ruta
      return null;
    } catch (e) {
      appLogger.error('Error obteniendo ruta de contenido descargado', error: e, context: {
        'contenidoId': contenido.id,
      });
      return null;
    }
  }

  /// Buscar contenidos
  Future<List<ContenidoUnificado>> searchContenidos(String query) async {
    try {
      appLogger.debug('ContenidoService: Buscando contenidos: $query');
      
      final response = await _apiService.get('/contenido-crud?q=$query');
      final List<dynamic> contenidosData = response.data['contenidos'] ?? [];  // Extraer la lista de contenidos
      
      // Convertir datos a ContenidoUnificado
      return contenidosData.map((data) {
        // Convertir directamente a ContenidoUnificado
        return ContenidoUnificado.fromJson(data);
      }).toList();
    } catch (e) {
      appLogger.error('Error buscando contenidos', error: e, context: {
        'query': query,
      });
      rethrow;
    }
  }

  /// Mapear datos del backend al formato esperado por el modelo
  Map<String, dynamic> _mapBackendDataToModel(Map<String, dynamic> backendData) {
    final mappedData = Map<String, dynamic>.from(backendData);
    
    // Mapear campos específicos
    if (backendData.containsKey('archivo_url')) {
      mappedData['url_contenido'] = backendData['archivo_url'];
      mappedData.remove('archivo_url');
    }
    
    if (backendData.containsKey('miniatura_url')) {
      mappedData['url_imagen'] = backendData['miniatura_url'];
      mappedData.remove('miniatura_url');
    }
    
    if (backendData.containsKey('duracion')) {
      mappedData['duracion_minutos'] = backendData['duracion'];
      mappedData.remove('duracion');
    }
    
    if (backendData.containsKey('etiquetas')) {
      mappedData['tags'] = backendData['etiquetas'];
      mappedData.remove('etiquetas');
    }
    
    // Asegurar que los campos requeridos no sean null
    mappedData['fecha_creacion'] = backendData['created_at'] ?? backendData['fecha_creacion'] ?? DateTime.now().toIso8601String();
    mappedData['fecha_actualizacion'] = backendData['updated_at'] ?? backendData['fecha_actualizacion'] ?? DateTime.now().toIso8601String();
    mappedData['activo'] = backendData['activo'] ?? backendData['publico'] ?? true;
    mappedData['destacado'] = backendData['destacado'] ?? false;
    
    appLogger.debug('DIAGNÓSTICO: Datos mapeados', context: {
      'datos_originales': backendData.keys.toList(),
      'datos_mapeados': mappedData.keys.toList(),
    });
    
    return mappedData;
  }

  /// Disponer recursos
  void dispose() {
    _downloadEventSubscription?.cancel();
    _downloadEventController.close();
    _downloadService?.dispose();
  }
}

// Estas clases ya están definidas en contenido_download_service.dart
// No es necesario definirlas aquí nuevamente