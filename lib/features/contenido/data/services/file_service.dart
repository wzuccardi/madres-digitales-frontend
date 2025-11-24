import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import '../../../../config/app_config.dart';

class FileService {
  
  // Tipos de archivo permitidos
  static const List<String> _allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
  ];
  
  static const List<String> _allowedVideoTypes = [
    'video/mp4',
    'video/mpeg',
    'video/quicktime',
    'video/x-msvideo',
    'video/webm',
  ];
  
  static const List<String> _allowedAudioTypes = [
    'audio/mpeg',
    'audio/wav',
    'audio/ogg',
    'audio/mp4',
    'audio/webm',
  ];
  
  static const List<String> _allowedDocumentTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/plain',
    'text/csv',
  ];
  
  // TamaÃ±o mÃ¡ximo de archivo en bytes (10 MB por defecto)
  static const int _maxFileSize = 10 * 1024 * 1024;
  
  // Validar archivo
  static FileValidationResult validateFile(File file, {List<String>? allowedTypes, int? maxSizeBytes}) {
    try {
      // Verificar que el archivo existe
      if (!file.existsSync()) {
        return FileValidationResult(
          isValid: false,
          errorMessage: 'El archivo no existe',
        );
      }
      
      // Obtener informaciÃ³n del archivo
      final fileSize = file.lengthSync();
      final fileName = file.path.split('/').last;
      
      // Determinar tipo MIME basado en la extensiÃ³n
      String mimeType = '';
      final extension = fileName.split('.').last.toLowerCase();
      if (['jpg', 'jpeg'].contains(extension)) {
        mimeType = 'image/jpeg';
      } else if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'gif') {
        mimeType = 'image/gif';
      } else if (extension == 'webp') {
        mimeType = 'image/webp';
      } else if (extension == 'mp4') {
        mimeType = 'video/mp4';
      } else if (extension == 'pdf') {
        mimeType = 'application/pdf';
      } else if (['doc', 'docx'].contains(extension)) {
        mimeType = 'application/msword';
      } else if (extension == 'txt') {
        mimeType = 'text/plain';
      }
      
      // Validar tamaÃ±o
      final maxSize = maxSizeBytes ?? _maxFileSize;
      if (fileSize > maxSize) {
        return FileValidationResult(
          isValid: false,
          errorMessage: 'El archivo es demasiado grande. TamaÃ±o mÃ¡ximo: ${_formatFileSize(maxSize)}',
        );
      }
      
      // Validar tipo MIME
      if (allowedTypes != null && allowedTypes.isNotEmpty) {
        if (!allowedTypes.contains(mimeType)) {
          return FileValidationResult(
            isValid: false,
            errorMessage: 'Tipo de archivo no permitido: $mimeType',
          );
        }
      }
      
      return FileValidationResult(
        isValid: true,
        fileSize: fileSize,
        fileName: fileName,
        mimeType: mimeType,
      );
    } catch (e) {
      _logError('validateFile', Exception('Error validando archivo: $e'));
      return FileValidationResult(
        isValid: false,
        errorMessage: 'Error al validar el archivo: ${e.toString()}',
      );
    }
  }
  
  // Validar imagen
  static FileValidationResult validateImage(File file, {int? maxSizeBytes}) {
    return validateFile(
      file,
      allowedTypes: _allowedImageTypes,
      maxSizeBytes: maxSizeBytes,
    );
  }
  
  // Validar video
  static FileValidationResult validateVideo(File file, {int? maxSizeBytes}) {
    return validateFile(
      file,
      allowedTypes: _allowedVideoTypes,
      maxSizeBytes: maxSizeBytes ?? 50 * 1024 * 1024, // 50 MB para videos
    );
  }
  
  // Validar audio
  static FileValidationResult validateAudio(File file, {int? maxSizeBytes}) {
    return validateFile(
      file,
      allowedTypes: _allowedAudioTypes,
      maxSizeBytes: maxSizeBytes ?? 20 * 1024 * 1024, // 20 MB para audios
    );
  }
  
  // Validar documento
  static FileValidationResult validateDocument(File file, {int? maxSizeBytes}) {
    return validateFile(
      file,
      allowedTypes: _allowedDocumentTypes,
      maxSizeBytes: maxSizeBytes ?? 20 * 1024 * 1024, // 20 MB para documentos
    );
  }
  
  // Subir archivo a servidor
  static Future<FileUploadResult> uploadFile(
    File file, {
    String? uploadUrl,
    Map<String, String>? headers,
    Map<String, String>? additionalFields,
    Duration timeout = const Duration(minutes: 5),
    int maxRetries = 3,
  }) async {
    final startTime = DateTime.now();
    
    try {
      // Validar archivo antes de subir
      final validation = validateFile(file);
      if (!validation.isValid) {
        return FileUploadResult(
          success: false,
          errorMessage: validation.errorMessage,
        );
      }
      
      final url = uploadUrl ?? '${AppConfig.apiBaseUrl}/upload';
      final api = ApiService();
      final fileSize = await file.length();
      final resp = await api.uploadFile<Map<String, dynamic>>(
        url.replaceFirst(AppConfig.apiBaseUrl, ''),
        file,
        fields: additionalFields,
        options: Options(headers: headers, sendTimeout: timeout),
      );
      
      // Procesar respuesta
      final duration = DateTime.now().difference(startTime);
      
      if (resp.success) {
        _logPerformance('uploadFile', duration.inMilliseconds, {
          'status': 'success',
          'fileSize': fileSize,
          'fileName': file.path.split('/').last,
        });
        
        return FileUploadResult(
          success: true,
          fileUrl: _extractFileUrl(resp.message ?? ''),
          response: resp.message,
          statusCode: resp.statusCode,
        );
      } else {
        _logError('uploadFile', Exception('Error subiendo archivo: ${resp.statusCode}'));
        return FileUploadResult(
          success: false,
          errorMessage: 'Error del servidor: ${resp.statusCode}',
          statusCode: resp.statusCode,
          response: resp.message,
        );
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logError('uploadFile', Exception('Error subiendo archivo: $e'));
      _logPerformance('uploadFile', duration.inMilliseconds, {
        'status': 'error',
        'error': e.toString(),
      });
      
      return FileUploadResult(
        success: false,
        errorMessage: 'Error al subir el archivo: ${e.toString()}',
      );
    }
  }
  
  
  
  // Extraer URL de archivo de respuesta
  static String _extractFileUrl(String responseBody) {
    try {
      // Intentar parsear como JSON
      if (responseBody.startsWith('{')) {
        final Map<String, dynamic> data = _parseJsonSafely(responseBody);
        return data['url'] ?? data['fileUrl'] ?? data['file_url'] ?? '';
      }
      
      // Si no es JSON, devolver el cuerpo completo
      return responseBody;
    } catch (e) {
      return responseBody;
    }
  }
  
  // Parsear JSON de forma segura
  static Map<String, dynamic> _parseJsonSafely(String jsonString) {
    try {
      // ImplementaciÃ³n simple de parseo JSON para evitar dependencias
      final result = <String, dynamic>{};
      
      // Buscar clave url en el string
      final urlPattern = RegExp(r'"(url|fileUrl|file_url)"\s*:\s*"([^"]+)"');
      final match = urlPattern.firstMatch(jsonString);
      
      if (match != null) {
        final key = match.group(1)!;
        final value = match.group(2)!;
        result[key] = value;
      }
      
      return result;
    } catch (e) {
      return {};
    }
  }
  
  // Descargar archivo
  static Future<FileDownloadResult> downloadFile(
    String url, {
    String? savePath,
    Duration timeout = const Duration(minutes: 5),
    int maxRetries = 3,
  }) async {
    if (kIsWeb) {
      return FileDownloadResult(
        success: false,
        errorMessage: 'Descarga de archivos no soportada directamente en Web desde FileService',
      );
    }
    final startTime = DateTime.now();
    
    try {
      final dio = Dio(BaseOptions(connectTimeout: timeout, receiveTimeout: timeout));
      Response<ResponseBody> response = await _downloadWithRetriesDio(
        dio,
        url,
        timeout,
        maxRetries,
      );
      
      // Verificar respuesta
      if (response.statusCode != 200) {
        return FileDownloadResult(
          success: false,
          errorMessage: 'Error del servidor: ${response.statusCode}',
        );
      }
      
      // Determinar ruta de guardado
      String filePath = savePath ?? _getDefaultSavePath(url);
      final file = File(filePath);
      
      // Crear directorio si no existe
      final directory = file.parent;
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      
      // Guardar archivo
      final bytes = await _collectStreamBytes(response.data!.stream);
      await file.writeAsBytes(bytes);
      
      final duration = DateTime.now().difference(startTime);
      _logPerformance('downloadFile', duration.inMilliseconds, {
        'status': 'success',
        'fileSize': bytes.length,
        'url': url,
      });
      
      return FileDownloadResult(
        success: true,
        filePath: filePath,
        fileSize: bytes.length,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logError('downloadFile', Exception('Error descargando archivo: $e'));
      _logPerformance('downloadFile', duration.inMilliseconds, {
        'status': 'error',
        'error': e.toString(),
        'url': url,
      });
      
      return FileDownloadResult(
        success: false,
        errorMessage: 'Error al descargar el archivo: ${e.toString()}',
      );
    }
  }
  
  // Descargar con reintentos
  static Future<Response<ResponseBody>> _downloadWithRetriesDio(
    Dio dio,
    String url,
    Duration timeout,
    int maxRetries,
  ) async {
    int retryCount = 0;
    while (retryCount <= maxRetries) {
      try {
        return await dio.get<ResponseBody>(url, options: Options(responseType: ResponseType.stream, receiveTimeout: timeout));
      } catch (e) {
        retryCount++;
        if (retryCount > maxRetries) rethrow;
        final waitTime = Duration(milliseconds: 1000 * (1 << (retryCount - 1)));
        await Future.delayed(waitTime);
      }
    }
    throw Exception('Max retries exceeded');
  }
  
  // Recolectar bytes de un Stream<List<int>> de forma segura
  static Future<List<int>> _collectStreamBytes(Stream<List<int>> stream) async {
    final buffer = <int>[];
    await for (final chunk in stream) {
      buffer.addAll(chunk);
    }
    return buffer;
  }
  
  // Obtener ruta de guardado por defecto
  static String _getDefaultSavePath(String url) {
    final fileName = url.split('/').last;
    final directory = '${Directory.systemTemp.path}/madres_digitales';
    return '$directory/$fileName';
  }
  
  // Formatear tamaÃ±o de archivo
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  // Método privado para registrar logs de rendimiento
  static void _logPerformance(String operation, int durationMs, Map<String, dynamic> info) {
    // Logging deshabilitado en producción
  }

  // Método privado para registrar logs de errores
  static void _logError(String operation, Exception exception) {
    // Logging deshabilitado en producción
  }
}

// Resultado de validaciÃ³n de archivo
class FileValidationResult {

  FileValidationResult({
    required this.isValid,
    this.errorMessage,
    this.fileSize,
    this.fileName,
    this.mimeType,
  });
  final bool isValid;
  final String? errorMessage;
  final int? fileSize;
  final String? fileName;
  final String? mimeType;
}

// Resultado de subida de archivo
class FileUploadResult {

  FileUploadResult({
    required this.success,
    this.fileUrl,
    this.errorMessage,
    this.response,
    this.statusCode,
  });
  final bool success;
  final String? fileUrl;
  final String? errorMessage;
  final String? response;
  final int? statusCode;
}

// Resultado de descarga de archivo
class FileDownloadResult {

  FileDownloadResult({
    required this.success,
    this.filePath,
    this.fileSize,
    this.errorMessage,
  });
  final bool success;
  final String? filePath;
  final int? fileSize;
  final String? errorMessage;
}
