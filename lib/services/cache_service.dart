// lib/services/cache_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';

class VideoCacheModel {
  final String videoUrl;
  final String localPath;
  final DateTime cachedAt;
  final int fileSize;
  
  VideoCacheModel({
    required this.videoUrl,
    required this.localPath,
    required this.cachedAt,
    required this.fileSize,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'videoUrl': videoUrl,
      'localPath': localPath,
      'cachedAt': cachedAt.millisecondsSinceEpoch,
      'fileSize': fileSize,
    };
  }
  
  factory VideoCacheModel.fromMap(Map<String, dynamic> map) {
    return VideoCacheModel(
      videoUrl: map['videoUrl'],
      localPath: map['localPath'],
      cachedAt: DateTime.fromMillisecondsSinceEpoch(map['cachedAt']),
      fileSize: map['fileSize'],
    );
  }
}

class CacheService {
  static const String _cacheBoxName = 'video_cache';
  static const String _cacheDirName = 'video_cache';
  Box? _cacheBox;
  Directory? _cacheDir;
  
  Future<void> init() async {
    // Deshabilitar caché en Flutter Web
    if (kIsWeb) {
      return;
    }

    try {
      _cacheBox = await Hive.openBox(_cacheBoxName);
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/$_cacheDirName');

      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
    } catch (e) {
      // Error al inicializar caché (esperado en Web)
    }
  }
  
  Future<String?> getCachedVideoPath(String videoUrl) async {
    // Caché no disponible en Web
    if (kIsWeb) {
      return null;
    }

    if (_cacheBox == null) await init();

    final cacheData = _cacheBox!.get(videoUrl);
    if (cacheData != null) {
      final model = VideoCacheModel.fromMap(Map<String, dynamic>.from(cacheData));
      final file = File(model.localPath);

      if (await file.exists()) {
        return model.localPath;
      } else {
        // El archivo no existe, limpiar la entrada
        await _cacheBox!.delete(videoUrl);
      }
    }
    return null;
  }
  
  Future<String> cacheVideo(String videoUrl, {Function(double)? onProgress}) async {
    // Caché no disponible en Web, retornar la URL original
    if (kIsWeb) {
      return videoUrl;
    }

    if (_cacheBox == null) await init();

    try {
      // Verificar si ya está cacheado
      final cachedPath = await getCachedVideoPath(videoUrl);
      if (cachedPath != null) {
        return cachedPath;
      }

      // Descargar el video
      final dio = Dio();
      // Configurar headers de autenticación si es necesario
      final apiService = ApiService();
      final token = await apiService.getToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final fileName = videoUrl.split('/').last.replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
      final savePath = '${_cacheDir!.path}/$fileName';

      await dio.download(
        videoUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      // Guardar en la base de datos local
      final file = File(savePath);
      final stat = await file.stat();

      final cacheModel = VideoCacheModel(
        videoUrl: videoUrl,
        localPath: savePath,
        cachedAt: DateTime.now(),
        fileSize: stat.size,
      );

      await _cacheBox!.put(videoUrl, cacheModel.toMap());

      return savePath;
    } catch (e) {
      // Error al cachear video
      rethrow;
    }
  }
  
  Future<void> clearCache() async {
    if (_cacheBox == null) await init();
    
    await _cacheBox!.clear();
    
    if (_cacheDir != null && await _cacheDir!.exists()) {
      await _cacheDir!.delete(recursive: true);
      await _cacheDir!.create();
    }
  }
  
  Future<int> getCacheSize() async {
    if (_cacheBox == null) await init();
    
    int totalSize = 0;
    
    for (final key in _cacheBox!.keys) {
      final cacheData = _cacheBox!.get(key);
      if (cacheData != null) {
        final model = VideoCacheModel.fromMap(Map<String, dynamic>.from(cacheData));
        totalSize += model.fileSize;
      }
    }
    
    return totalSize;
  }
  
  Future<void> cleanOldCache({int maxAgeDays = 30}) async {
    if (_cacheBox == null) await init();
    
    final cutoffDate = DateTime.now().subtract(Duration(days: maxAgeDays));
    
    for (final key in _cacheBox!.keys) {
      final cacheData = _cacheBox!.get(key);
      if (cacheData != null) {
        final model = VideoCacheModel.fromMap(Map<String, dynamic>.from(cacheData));
        
        if (model.cachedAt.isBefore(cutoffDate)) {
          // Eliminar archivo
          final file = File(model.localPath);
          if (await file.exists()) {
            await file.delete();
          }
          
          // Eliminar entrada de la base de datos
          await _cacheBox!.delete(key);
        }
      }
      
  /// Obtener archivo cacheado por URL
  Future<String?> getCachedFile(String url) async {
    // Caché no disponible en Web
    if (kIsWeb) {
      return null;
    }

    if (_cacheBox == null) await init();

    final cacheData = _cacheBox!.get(url);
    if (cacheData != null) {
      final model = VideoCacheModel.fromMap(Map<String, dynamic>.from(cacheData));
      final file = File(model.localPath);

      if (await file.exists()) {
        return model.localPath;
      } else {
        // El archivo no existe, limpiar la entrada
        await _cacheBox!.delete(url);
      }
    }
    return null;
  }
  
  /// Cachear archivo desde URL
  Future<String?> cacheFile(String url, {Function(double)? onProgress}) async {
    // Caché no disponible en Web, retornar la URL original
    if (kIsWeb) {
      return null;
    }

    if (_cacheBox == null) await init();

    try {
      // Verificar si ya está cacheado
      final cachedPath = await getCachedFile(url);
      if (cachedPath != null) {
        return cachedPath;
      }

      // Descargar el archivo
      final dio = Dio();
      // Configurar headers de autenticación si es necesario
      final apiService = ApiService();
      final token = await apiService.getToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final fileName = url.split('/').last.replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
      final savePath = '${_cacheDir!.path}/$fileName';

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      // Guardar en la base de datos local
      final file = File(savePath);
      final stat = await file.stat();

      final cacheModel = VideoCacheModel(
        videoUrl: url,
        localPath: savePath,
        cachedAt: DateTime.now(),
        fileSize: stat.size,
      );

      await _cacheBox!.put(url, cacheModel.toMap());

      return savePath;
    } catch (e) {
      // Error al cachear archivo
      rethrow;
    }
  }
      
      /// Limpiar caché antiguo según límites
      Future<void> cleanOldCache() async {
        if (_cacheBox == null) await init();
        
        const int maxCacheSizeMb = 100; // 100 MB
        const int maxCacheAgeDays = 7;
        
        final files = _cacheDir!.listSync();
        final now = DateTime.now().millisecondsSinceEpoch;
    
        // 1. Eliminar archivos expirados
        for (final file in files) {
          if (await file.exists()) {
            final hash = file.path.split('/').last;
            final timestamp = _cacheBox!.get('cache_$hash');
            if (timestamp == null) continue;
            if ((now - timestamp) > (maxCacheAgeDays * 24 * 60 * 60 * 1000)) {
              await file.delete();
              await _cacheBox!.delete('cache_$hash');
              await _cacheBox!.delete('url_$hash');
            }
          }
        }
    
        // 2. Verificar tamaño total y limpiar si excede límite
        int totalSize = 0;
        for (final file in files) {
          if (file is File && await file.exists()) {
            totalSize += await file.length();
          }
        }
        
        if (totalSize > (maxCacheSizeMb * 1024 * 1024)) {
          // Ordenar por fecha de acceso (timestamp) y eliminar los más antiguos
          final sortedFiles = <Map<String, dynamic>>[];
          
          for (final file in files) {
            if (file is File && await file.exists()) {
              final hash = file.path.split('/').last;
              final ts = _cacheBox!.get('cache_$hash') ?? 0;
              sortedFiles.add({'file': file, 'ts': ts});
            }
          }
          
          sortedFiles.sort((a, b) => a['ts']!.compareTo(b['ts']!));
    
          int currentSize = totalSize;
          for (final item in sortedFiles) {
            if (currentSize <= (maxCacheSizeMb * 1024 * 1024)) break;
            final f = item['file'] as File;
            final hash = f.path.split('/').last;
            await f.delete();
            await _cacheBox!.delete('cache_$hash');
            await _cacheBox!.delete('url_$hash');
            currentSize -= await f.length();
          }
        }
      }
    }
  }
}

