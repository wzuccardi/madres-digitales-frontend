import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
      
      // URL de subida por defecto
      final url = uploadUrl ?? 'https://api.madresdigitales.com/upload';
      
      // Crear solicitud multipart
      final request = http.MultipartRequest('POST', Uri.parse(url));
      
      // AÃ±adir headers
      if (headers != null) {
        request.headers.addAll(headers);
      }
      
      // AÃ±adir campos adicionales
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }
      
      // AÃ±adir archivo
      final fileSize = await file.length();
      final stream = file.openRead();
      final multipartFile = http.MultipartFile(
        'file',
        stream,
        fileSize,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);
      
      // Enviar solicitud con reintentos
      http.Response response = await _sendRequestWithRetries(
        request,
        timeout,
        maxRetries,
      );
      
      // Procesar respuesta
      final duration = DateTime.now().difference(startTime);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _logPerformance('uploadFile', duration.inMilliseconds, {
          'status': 'success',
          'fileSize': fileSize,
          'fileName': file.path.split('/').last,
        });
        
        return FileUploadResult(
          success: true,
          fileUrl: _extractFileUrl(response.body),
          response: response.body,
          statusCode: response.statusCode,
        );
      } else {
        _logError('uploadFile', Exception('Error subiendo archivo: ${response.statusCode} - ${response.body}'));
        return FileUploadResult(
          success: false,
          errorMessage: 'Error del servidor: ${response.statusCode}',
          statusCode: response.statusCode,
          response: response.body,
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
  
  // Enviar solicitud con reintentos
  static Future<http.Response> _sendRequestWithRetries(
    http.MultipartRequest request,
    Duration timeout,
    int maxRetries,
  ) async {
    int retryCount = 0;
    
    while (retryCount <= maxRetries) {
      try {
        final streamedResponse = await request.send().timeout(timeout);
        return await http.Response.fromStream(streamedResponse);
      } catch (e) {
        retryCount++;
        
        if (retryCount > maxRetries) {
          rethrow;
        }
        
        // Esperar antes de reintentar (backoff exponencial)
        final waitTime = Duration(milliseconds: 1000 * (1 << (retryCount - 1)));
        await Future.delayed(waitTime);
      }
    }
    
    throw Exception('Max retries exceeded');
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
    final startTime = DateTime.now();
    
    try {
      // Crear cliente HTTP
      final client = http.Client();
      
      // Realizar solicitud con reintentos
      http.Response response = await _downloadWithRetries(
        client,
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
      await file.writeAsBytes(response.bodyBytes);
      
      final duration = DateTime.now().difference(startTime);
      _logPerformance('downloadFile', duration.inMilliseconds, {
        'status': 'success',
        'fileSize': response.bodyBytes.length,
        'url': url,
      });
      
      return FileDownloadResult(
        success: true,
        filePath: filePath,
        fileSize: response.bodyBytes.length,
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
  static Future<http.Response> _downloadWithRetries(
    http.Client client,
    String url,
    Duration timeout,
    int maxRetries,
  ) async {
    int retryCount = 0;
    
    while (retryCount <= maxRetries) {
      try {
        return await client.get(Uri.parse(url)).timeout(timeout);
      } catch (e) {
        retryCount++;
        
        if (retryCount > maxRetries) {
          rethrow;
        }
        
        // Esperar antes de reintentar (backoff exponencial)
        final waitTime = Duration(milliseconds: 1000 * (1 << (retryCount - 1)));
        await Future.delayed(waitTime);
      }
    }
    
    throw Exception('Max retries exceeded');
  }
  
  // Obtener ruta de guardado por defecto
  static String _getDefaultSavePath(String url) {
    final fileName = url.split('/').last;
    final directory = kIsWeb ? '/downloads' : '${Directory.systemTemp.path}/madres_digitales';
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
  final bool isValid;
  final String? errorMessage;
  final int? fileSize;
  final String? fileName;
  final String? mimeType;

  FileValidationResult({
    required this.isValid,
    this.errorMessage,
    this.fileSize,
    this.fileName,
    this.mimeType,
  });
}

// Resultado de subida de archivo
class FileUploadResult {
  final bool success;
  final String? fileUrl;
  final String? errorMessage;
  final String? response;
  final int? statusCode;

  FileUploadResult({
    required this.success,
    this.fileUrl,
    this.errorMessage,
    this.response,
    this.statusCode,
  });
}

// Resultado de descarga de archivo
class FileDownloadResult {
  final bool success;
  final String? filePath;
  final int? fileSize;
  final String? errorMessage;

  FileDownloadResult({
    required this.success,
    this.filePath,
    this.fileSize,
    this.errorMessage,
  });
}
