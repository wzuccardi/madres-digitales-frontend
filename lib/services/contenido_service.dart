import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/contenido_model.dart';
import '../models/usuario_model.dart';
import 'api_service.dart';
import 'offline_service.dart';

class ContenidoService {
  final ApiService _apiService;
  final OfflineService _offlineService;

  ContenidoService({
    required ApiService apiService,
    required OfflineService offlineService,
  })  : _apiService = apiService,
        _offlineService = offlineService;

  // Obtener contenidos por categoría
  Future<List<ContenidoModel>> obtenerContenidosPorCategoria(
    CategoriaContenido categoria, {
    int page = 1,
    int limit = 20,
    NivelDificultad? nivel,
  }) async {
    try {
      final queryParams = {
        'categoria': categoria.name,
        'page': page.toString(),
        'limit': limit.toString(),
        if (nivel != null) 'nivel': nivel.name,
      };

      final response = await _apiService.get(
        '/contenidos',
        queryParameters: queryParams,
      );

      final contenidos = (response.data['contenidos'] as List)
          .map((json) => ContenidoModel.fromJson(json))
          .toList();

      // Guardar en caché offline
      await _guardarContenidosOffline(contenidos);

      return contenidos;
    } catch (e) {
      debugPrint('Error obteniendo contenidos por categoría: $e');
      // Intentar obtener datos offline
      return await _obtenerContenidosOffline(categoria);
    }
  }

  // Obtener contenido por ID
  Future<ContenidoModel?> obtenerContenidoPorId(String contenidoId) async {
    try {
      final response = await _apiService.get('/contenidos/$contenidoId');
      final contenido = ContenidoModel.fromJson(response.data);
      
      // Guardar en caché offline
      await _guardarContenidoOffline(contenido);
      
      return contenido;
    } catch (e) {
      debugPrint('Error obteniendo contenido por ID: $e');
      // Intentar obtener datos offline
      return await _obtenerContenidoOfflinePorId(contenidoId);
    }
  }

  // Buscar contenidos
  Future<List<ContenidoModel>> buscarContenidos(
    String query, {
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
        if (categoria != null) 'categoria': categoria.name,
        if (tipo != null) 'tipo': tipo.name,
        if (nivel != null) 'nivel': nivel.name,
      };

      final response = await _apiService.get(
        '/contenidos/buscar',
        queryParameters: queryParams,
      );

      return (response.data['contenidos'] as List)
          .map((json) => ContenidoModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error buscando contenidos: $e');
      rethrow;
    }
  }

  // Obtener contenidos recomendados
  Future<List<ContenidoModel>> obtenerContenidosRecomendados(
    String usuarioId, {
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'usuario_id': usuarioId,
        'limit': limit.toString(),
      };

      final response = await _apiService.get(
        '/contenidos/recomendados',
        queryParameters: queryParams,
      );

      return (response.data['contenidos'] as List)
          .map((json) => ContenidoModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo contenidos recomendados: $e');
      rethrow;
    }
  }

  // Marcar contenido como visto
  Future<void> marcarContenidoVisto(String contenidoId, String usuarioId) async {
    try {
      await _apiService.post('/contenidos/$contenidoId/visto', data: {
        'usuario_id': usuarioId,
        'fecha_visto': DateTime.now().toIso8601String(),
      });

      // Actualizar progreso offline
      await _actualizarProgresoOffline(contenidoId, usuarioId, completado: true);
    } catch (e) {
      debugPrint('Error marcando contenido como visto: $e');
      // Guardar acción offline para sincronizar después
      await _offlineService.addToSyncQueue({
        'action': 'marcar_contenido_visto',
        'contenido_id': contenidoId,
        'usuario_id': usuarioId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Actualizar progreso de contenido
  Future<void> actualizarProgreso(
    String contenidoId,
    String usuarioId, {
    int? tiempoVisto,
    double? porcentajeCompletado,
    bool? completado,
    Map<String, dynamic>? datosAdicionales,
  }) async {
    try {
      final body = {
        'usuario_id': usuarioId,
        if (tiempoVisto != null) 'tiempo_visto': tiempoVisto,
        if (porcentajeCompletado != null) 'porcentaje_completado': porcentajeCompletado,
        if (completado != null) 'completado': completado,
        if (datosAdicionales != null) 'datos_adicionales': datosAdicionales,
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      };

      await _apiService.post('/contenidos/$contenidoId/progreso', data: body);

      // Actualizar progreso offline
      await _actualizarProgresoOffline(
        contenidoId,
        usuarioId,
        tiempoVisto: tiempoVisto,
        porcentajeCompletado: porcentajeCompletado,
        completado: completado,
      );
    } catch (e) {
      debugPrint('Error actualizando progreso: $e');
      // Guardar acción offline para sincronizar después
      await _offlineService.addToSyncQueue({
        'action': 'actualizar_progreso_contenido',
        'contenido_id': contenidoId,
        'usuario_id': usuarioId,
        'tiempo_visto': tiempoVisto,
        'porcentaje_completado': porcentajeCompletado,
        'completado': completado,
        'datos_adicionales': datosAdicionales,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Obtener progreso del usuario
  Future<List<ProgresoContenidoModel>> obtenerProgresoUsuario(
    String usuarioId, {
    CategoriaContenido? categoria,
    bool? completado,
  }) async {
    try {
      final queryParams = {
        'usuario_id': usuarioId,
        if (categoria != null) 'categoria': categoria.name,
        if (completado != null) 'completado': completado.toString(),
      };

      final response = await _apiService.get(
        '/contenidos/progreso',
        queryParameters: queryParams,
      );

      return (response.data['progreso'] as List)
          .map((json) => ProgresoContenidoModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo progreso del usuario: $e');
      return await _obtenerProgresoOffline(usuarioId);
    }
  }

  // Descargar contenido para acceso offline
  Future<String> descargarContenido(String contenidoId) async {
    try {
      final contenido = await obtenerContenidoPorId(contenidoId);
      if (contenido == null) throw Exception('Contenido no encontrado');

      final response = await _apiService.get(
        '/contenidos/$contenidoId/descargar',
        options: {'responseType': 'bytes'},
      );

      final directory = await getApplicationDocumentsDirectory();
      final contentDir = Directory('${directory.path}/contenidos');
      if (!await contentDir.exists()) {
        await contentDir.create(recursive: true);
      }

      final extension = _obtenerExtensionPorTipo(contenido.tipo);
      final file = File('${contentDir.path}/${contenidoId}.$extension');
      await file.writeAsBytes(response.data);

      // Actualizar base de datos offline con la ruta local
      await _actualizarRutaLocalContenido(contenidoId, file.path);

      return file.path;
    } catch (e) {
      debugPrint('Error descargando contenido: $e');
      rethrow;
    }
  }

  // Verificar si el contenido está disponible offline
  Future<bool> estaDisponibleOffline(String contenidoId) async {
    try {
      final db = await _offlineService.database;
      final result = await db.query(
        'contenidos_cache',
        where: 'id = ? AND ruta_local IS NOT NULL',
        whereArgs: [contenidoId],
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error verificando disponibilidad offline: $e');
      return false;
    }
  }

  // Obtener ruta local del contenido
  Future<String?> obtenerRutaLocal(String contenidoId) async {
    try {
      final db = await _offlineService.database;
      final result = await db.query(
        'contenidos_cache',
        columns: ['ruta_local'],
        where: 'id = ?',
        whereArgs: [contenidoId],
      );
      
      if (result.isNotEmpty) {
        return result.first['ruta_local'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error obteniendo ruta local: $e');
      return null;
    }
  }

  // Eliminar contenido descargado
  Future<void> eliminarContenidoDescargado(String contenidoId) async {
    try {
      final rutaLocal = await obtenerRutaLocal(contenidoId);
      if (rutaLocal != null) {
        final file = File(rutaLocal);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Actualizar base de datos
      final db = await _offlineService.database;
      await db.update(
        'contenidos_cache',
        {'ruta_local': null},
        where: 'id = ?',
        whereArgs: [contenidoId],
      );
    } catch (e) {
      debugPrint('Error eliminando contenido descargado: $e');
    }
  }

  // Obtener estadísticas de contenido
  Future<Map<String, dynamic>> obtenerEstadisticasContenido(String usuarioId) async {
    try {
      final response = await _apiService.get('/contenidos/estadisticas/$usuarioId');
      return response.data;
    } catch (e) {
      debugPrint('Error obteniendo estadísticas de contenido: $e');
      rethrow;
    }
  }

  // Métodos privados para manejo offline

  Future<void> _guardarContenidosOffline(List<ContenidoModel> contenidos) async {
    try {
      final db = await _offlineService.database;
      for (final contenido in contenidos) {
        await db.insert(
          'contenidos_cache',
          {
            'id': contenido.id,
            'titulo': contenido.titulo,
            'descripcion': contenido.descripcion,
            'categoria': contenido.categoria.name,
            'tipo': contenido.tipo.name,
            'nivel': contenido.nivel.name,
            'url_contenido': contenido.urlContenido,
            'url_miniatura': contenido.urlMiniatura,
            'duracion': contenido.duracion,
            'tags': contenido.tags.join(','),
            'activo': contenido.activo ? 1 : 0,
            'fecha_creacion': contenido.fechaCreacion.toIso8601String(),
            'fecha_actualizacion': contenido.fechaActualizacion?.toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('Error guardando contenidos offline: $e');
    }
  }

  Future<void> _guardarContenidoOffline(ContenidoModel contenido) async {
    await _guardarContenidosOffline([contenido]);
  }

  Future<List<ContenidoModel>> _obtenerContenidosOffline(CategoriaContenido categoria) async {
    try {
      final db = await _offlineService.database;
      final result = await db.query(
        'contenidos_cache',
        where: 'categoria = ? AND activo = 1',
        whereArgs: [categoria.name],
        orderBy: 'fecha_creacion DESC',
      );

      return result.map((json) => ContenidoModel(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descripcion: json['descripcion'] as String,
        categoria: CategoriaContenido.values.firstWhere(
          (e) => e.name == json['categoria'],
        ),
        tipo: TipoContenido.values.firstWhere(
          (e) => e.name == json['tipo'],
        ),
        nivel: NivelDificultad.values.firstWhere(
          (e) => e.name == json['nivel'],
        ),
        urlContenido: json['url_contenido'] as String,
        urlMiniatura: json['url_miniatura'] as String?,
        duracion: json['duracion'] as int?,
        tags: (json['tags'] as String).split(','),
        activo: (json['activo'] as int) == 1,
        fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
        fechaActualizacion: json['fecha_actualizacion'] != null
            ? DateTime.parse(json['fecha_actualizacion'] as String)
            : null,
      )).toList();
    } catch (e) {
      debugPrint('Error obteniendo contenidos offline: $e');
      return [];
    }
  }

  Future<ContenidoModel?> _obtenerContenidoOfflinePorId(String contenidoId) async {
    try {
      final db = await _offlineService.database;
      final result = await db.query(
        'contenidos_cache',
        where: 'id = ?',
        whereArgs: [contenidoId],
      );

      if (result.isEmpty) return null;

      final json = result.first;
      return ContenidoModel(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descripcion: json['descripcion'] as String,
        categoria: CategoriaContenido.values.firstWhere(
          (e) => e.name == json['categoria'],
        ),
        tipo: TipoContenido.values.firstWhere(
          (e) => e.name == json['tipo'],
        ),
        nivel: NivelDificultad.values.firstWhere(
          (e) => e.name == json['nivel'],
        ),
        urlContenido: json['url_contenido'] as String,
        urlMiniatura: json['url_miniatura'] as String?,
        duracion: json['duracion'] as int?,
        tags: (json['tags'] as String).split(','),
        activo: (json['activo'] as int) == 1,
        fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
        fechaActualizacion: json['fecha_actualizacion'] != null
            ? DateTime.parse(json['fecha_actualizacion'] as String)
            : null,
      );
    } catch (e) {
      debugPrint('Error obteniendo contenido offline por ID: $e');
      return null;
    }
  }

  Future<void> _actualizarProgresoOffline(
    String contenidoId,
    String usuarioId, {
    int? tiempoVisto,
    double? porcentajeCompletado,
    bool? completado,
  }) async {
    try {
      final db = await _offlineService.database;
      await db.insert(
        'progreso_contenido_cache',
        {
          'contenido_id': contenidoId,
          'usuario_id': usuarioId,
          'tiempo_visto': tiempoVisto ?? 0,
          'porcentaje_completado': porcentajeCompletado ?? 0.0,
          'completado': (completado ?? false) ? 1 : 0,
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error actualizando progreso offline: $e');
    }
  }

  Future<List<ProgresoContenidoModel>> _obtenerProgresoOffline(String usuarioId) async {
    try {
      final db = await _offlineService.database;
      final result = await db.query(
        'progreso_contenido_cache',
        where: 'usuario_id = ?',
        whereArgs: [usuarioId],
      );

      return result.map((json) => ProgresoContenidoModel(
        id: '${json['contenido_id']}_${json['usuario_id']}',
        contenidoId: json['contenido_id'] as String,
        usuarioId: json['usuario_id'] as String,
        tiempoVisto: json['tiempo_visto'] as int,
        porcentajeCompletado: json['porcentaje_completado'] as double,
        completado: (json['completado'] as int) == 1,
        fechaInicio: DateTime.parse(json['fecha_actualizacion'] as String),
        fechaCompletado: (json['completado'] as int) == 1
            ? DateTime.parse(json['fecha_actualizacion'] as String)
            : null,
        fechaActualizacion: DateTime.parse(json['fecha_actualizacion'] as String),
      )).toList();
    } catch (e) {
      debugPrint('Error obteniendo progreso offline: $e');
      return [];
    }
  }

  Future<void> _actualizarRutaLocalContenido(String contenidoId, String rutaLocal) async {
    try {
      final db = await _offlineService.database;
      await db.update(
        'contenidos_cache',
        {'ruta_local': rutaLocal},
        where: 'id = ?',
        whereArgs: [contenidoId],
      );
    } catch (e) {
      debugPrint('Error actualizando ruta local: $e');
    }
  }

  String _obtenerExtensionPorTipo(TipoContenido tipo) {
    switch (tipo) {
      case TipoContenido.video:
        return 'mp4';
      case TipoContenido.audio:
        return 'mp3';
      case TipoContenido.imagen:
        return 'jpg';
      case TipoContenido.documento:
        return 'pdf';
      case TipoContenido.interactivo:
        return 'html';
    }
  }
}