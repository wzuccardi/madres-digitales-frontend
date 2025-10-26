import 'dart:async';
import 'dart:convert';
import 'package:madres_digitales_flutter_new/services/api_service.dart';
import 'package:madres_digitales_flutter_new/services/contenido_service.dart';
import 'package:madres_digitales_flutter_new/services/local_storage_service.dart';
import 'package:madres_digitales_flutter_new/models/contenido_model.dart';
import 'package:madres_digitales_flutter_new/models/contenido_unificado.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';

/// Servicio para sincronizar contenidos
class ContenidoSyncService {
  final ApiService _apiService;
  final ContenidoService _contenidoService;
  final LocalStorageService _localStorageService;
  
  final bool _isSyncing = false;
  final double _syncProgress = 0.0;
  String? _syncError;
  
  // Stream para notificar progreso de sincronización
  final StreamController<double> _progressController = StreamController<double>.broadcast();
  Stream<double> get syncProgress => _progressController.stream;
  
  bool get isSyncing => _isSyncing;
  String? get syncError => _syncError;

  ContenidoSyncService(this._apiService, this._contenidoService, this._localStorageService);

  /// Inicializar el servicio
  Future<void> initialize() async {
    try {
      appLogger.info('ContenidoSyncService: Inicializando servicio');
      // No se necesita inicialización especial
    } catch (e) {
      appLogger.error('Error inicializando servicio de sincronización', error: e);
      rethrow;
    }
  }

  /// Sincronizar todos los contenidos
  Future<void> syncContenidos() async {
    try {
      appLogger.info('ContenidoSyncService: Iniciando sincronización');

      // Obtener contenidos locales
      final localContenidosJson = await _localStorageService.getString('contenidos');
      final List<ContenidoUnificado> localContenidos = localContenidosJson != null
          ? (jsonDecode(localContenidosJson) as List).map((e) => ContenidoUnificado.fromJson(e)).toList()
          : [];

      // Obtener contenidos remotos
      final remoteContenidos = await _contenidoService.getAllContenidos();

      // Detectar diferencias (simplificado)
      final contenidosParaSubir = localContenidos.where((local) => !remoteContenidos.any((remote) => remote.id == local.id)).toList();
      final contenidosParaActualizar = remoteContenidos.where((remote) => localContenidos.any((local) => local.id == remote.id && local.fechaCreacion.isBefore(remote.fechaCreacion))).toList();

      // Subir contenidos locales nuevos o modificados (simplificado)
      for (final contenido in contenidosParaSubir) {
        await _contenidoService.saveContenido(contenido);
      }

      // Actualizar o guardar contenidos remotos nuevos o actualizados localmente
      final allContenidos = <ContenidoUnificado>[];
      allContenidos.addAll(contenidosParaActualizar);
      allContenidos.addAll(remoteContenidos.where((remote) => !contenidosParaActualizar.contains(remote)));

      final jsonToSave = allContenidos.map((e) => e.toJson()).toList();
      await _localStorageService.saveString('contenidos', jsonEncode(jsonToSave));

      appLogger.info('ContenidoSyncService: Sincronización completada');
    } catch (e) {
      appLogger.error('Error en la sincronización de contenidos', error: e);
      rethrow;
    }
  }

  /// Sincronizar contenidos por categoría
  Future<void> syncContenidosPorCategoria(String categoria) async {
    try {
      appLogger.info('ContenidoSyncService: Sincronizando contenidos de categoría: $categoria');
      
      // Obtener contenidos por categoría desde el servicio
      final contenidos = await _contenidoService.getContenidosByCategoria(categoria);
      
      // Guardar en almacenamiento local con clave de categoría
      await _localStorageService.saveString('categoria_$categoria', jsonEncode({
        'categoria': categoria,
        'contenidos': contenidos.map((c) => c.toJson()).toList(),
      }));
      
      appLogger.info('ContenidoSyncService: Sincronización de categoría completada: ${contenidos.length} contenidos');
    } catch (e) {
      appLogger.error('Error en sincronización de categoría', error: e, context: {
        'categoria': categoria,
      });
      rethrow;
    }
  }

  /// Verificar conectividad
  Future<bool> _checkConnectivity() async {
    try {
      // En una implementación real, aquí se verificaría la conectividad
      // Por ahora, simulamos que siempre estamos conectados
      return true;
    } catch (e) {
      appLogger.error('Error verificando conectividad', error: e);
      return false;
    }
  }

  /// Convertir a ContenidoUnificado
  ContenidoUnificado _convertToContenidoUnificado(dynamic contenido) {
    if (contenido is ContenidoUnificado) {
      return contenido;
    }
    
    // Si es un ContenidoModel, usar conversión manual
    if (contenido is ContenidoModel) {
      return _convertContenidoModelToUnificado(contenido);
    }
    
    // Si es un Map, convertir a ContenidoUnificado
    if (contenido is Map<String, dynamic>) {
      return ContenidoUnificado.fromJson(contenido);
    }
    
    // Si es otro tipo, crear un ContenidoUnificado básico
    final now = DateTime.now();
    return ContenidoUnificado(
      id: contenido.id?.toString() ?? '',
      titulo: contenido.titulo?.toString() ?? contenido.title?.toString() ?? '',
      descripcion: contenido.descripcion?.toString() ?? contenido.description?.toString() ?? '',
      categoria: contenido.categoria?.toString() ?? contenido.category?.toString() ?? '',
      tipo: contenido.tipo?.toString() ?? // Corrección: usar tipo
             contenido.tipoContenido?.toString() ??
             contenido.contentType?.toString() ?? '',
      urlContenido: contenido.urlContenido?.toString() ??
                     contenido.url?.toString() ??
                     contenido.contentUrl?.toString(),
      urlImagen: contenido.urlImagen?.toString() ?? // Corrección: usar urlImagen
                 contenido.imagenUrl?.toString() ??
                 contenido.thumbnailUrl?.toString() ??
                 contenido.imageUrl?.toString(),
      duracionMinutos: contenido.duracionMinutos is int ? contenido.duracionMinutos : // Corrección: usar duracionMinutos
                 (contenido.duracionMinutos != null ? int.tryParse(contenido.duracionMinutos.toString()) : null),
      nivel: contenido.nivel?.toString() ?? contenido.nivelDificultad?.toString(), // Corrección: usar nivel
      tags: contenido.tags is List ? List<String>.from(contenido.tags) : null, // Corrección: usar tags
      fechaCreacion: contenido.fechaCreacion != null
          ? (contenido.fechaCreacion is DateTime
              ? contenido.fechaCreacion
              : DateTime.tryParse(contenido.fechaCreacion.toString()) ?? now)
          : (contenido.createdAt != null
              ? (contenido.createdAt is DateTime
                  ? contenido.createdAt
                  : DateTime.tryParse(contenido.createdAt.toString()) ?? now)
              : now),
      fechaActualizacion: contenido.fechaActualizacion != null // Corrección: usar fechaActualizacion
          ? (contenido.fechaActualizacion is DateTime
              ? contenido.fechaActualizacion
              : DateTime.tryParse(contenido.fechaActualizacion.toString()) ?? now)
          : now,
      activo: contenido.activo ?? true,
    );
  }

  /// Método auxiliar para convertir ContenidoModel a ContenidoUnificado manualmente
  ContenidoUnificado _convertContenidoModelToUnificado(ContenidoModel contenido) {
    return ContenidoUnificado(
      id: contenido.id,
      titulo: contenido.titulo,
      descripcion: contenido.descripcion,
      categoria: contenido.categoria,
      tipo: contenido.tipoContenido, // Corrección: usar tipo
      urlContenido: contenido.urlContenido,
      urlImagen: contenido.imagenUrl, // Corrección: usar urlImagen
      fechaCreacion: contenido.createdAt, // Mapear createdAt a fechaCreacion
      fechaActualizacion: contenido.updatedAt, // Corrección: usar fechaActualizacion
      activo: true, // Asignar activo por defecto
    );
  }

  /// Limpiar recursos
  void dispose() {
    _progressController.close();
  }
}

