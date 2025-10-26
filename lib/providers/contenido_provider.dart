import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/models/contenido_unificado.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';
import 'package:madres_digitales_flutter_new/providers/service_providers.dart';
// Hot reload trigger - 2025-10-24 02:46

/// Provider para todos los contenidos
final contenidosProvider = FutureProvider<List<ContenidoUnificado>>((ref) async {
  appLogger.debug('ContenidoProvider: Obteniendo todos los contenidos');
  
  try {
    final service = await ref.read(contenidoServiceProvider.future);
    final contenidos = await service.getAllContenidos();
    
    appLogger.debug('ContenidoProvider: ${contenidos.length} contenidos obtenidos');
    return contenidos;
  } catch (e) {
    appLogger.error('ContenidoProvider: Error obteniendo contenidos', error: e);
    return [];
  }
});

/// Provider para contenidos por categoría
final contenidosPorCategoriaProvider = FutureProvider.family<List<ContenidoUnificado>, String>((ref, categoria) async {
  appLogger.debug('ContenidoProvider: Obteniendo contenidos de la categoría: $categoria');
  
  try {
    final service = await ref.read(contenidoServiceProvider.future);
    final contenidos = await service.getContenidosByCategoria(categoria);
    
    appLogger.debug('ContenidoProvider: ${contenidos.length} contenidos obtenidos de la categoría $categoria');
    return contenidos;
  } catch (e) {
    appLogger.error('ContenidoProvider: Error obteniendo contenidos de la categoría $categoria', error: e);
    return [];
  }
});

/// Provider para contenido específico por ID
final contenidoPorIdProvider = FutureProvider.family<ContenidoUnificado?, String>((ref, contenidoId) async {
  appLogger.debug('ContenidoProvider: Obteniendo contenido con ID: $contenidoId');
  
  try {
    final service = await ref.read(contenidoServiceProvider.future);
    final contenido = await service.getContenidoById(contenidoId);
    
    if (contenido != null) {
      appLogger.debug('ContenidoProvider: Contenido obtenido: ${contenido.titulo}');
      return contenido;
    } else {
      appLogger.warn('ContenidoProvider: Contenido con ID $contenidoId no encontrado');
      return null;
    }
  } catch (e) {
    appLogger.error('ContenidoProvider: Error obteniendo contenido con ID $contenidoId', error: e);
    return null;
  }
});

/// Provider para contenidos recomendados para una gestante
final contenidosRecomendadosProvider = FutureProvider.family<List<ContenidoUnificado>, String>((ref, gestanteId) async {
  appLogger.debug('ContenidoProvider: Obteniendo contenidos recomendados para gestante: $gestanteId');
  
  try {
    final service = await ref.read(contenidoServiceProvider.future);
    
    // En una implementación real, aquí se llamaría a un método específico
    // Por ahora, obtenemos todos los contenidos y filtramos
    final contenidos = await service.getAllContenidos();
    
    // Simular recomendaciones basadas en la gestante
    final recomendados = contenidos.take(5).toList();
    
    appLogger.debug('ContenidoProvider: ${recomendados.length} contenidos recomendados obtenidos');
    return recomendados;
  } catch (e) {
    appLogger.error('ContenidoProvider: Error obteniendo contenidos recomendados', error: e);
    return [];
  }
});

/// Provider para búsqueda de contenidos
final busquedaContenidosProvider = FutureProvider.family<List<ContenidoUnificado>, String>((ref, query) async {
  appLogger.debug('ContenidoProvider: Buscando contenidos con query: $query');
  
  try {
    final service = await ref.read(contenidoServiceProvider.future);
    final contenidos = await service.getAllContenidos();
    
    // Filtrar contenidos que coincidan con la búsqueda
    final resultados = contenidos.where((contenido) {
      return contenido.titulo.toLowerCase().contains(query.toLowerCase()) ||
             (contenido.descripcion?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             contenido.categoria.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    appLogger.debug('ContenidoProvider: ${resultados.length} resultados encontrados');
    return resultados;
  } catch (e) {
    appLogger.error('ContenidoProvider: Error buscando contenidos', error: e);
    return [];
  }
});

/// Provider para estado de carga de contenidos
final contenidoLoadingProvider = StateNotifierProvider<ContenidoLoadingNotifier, bool>((ref) {
  return ContenidoLoadingNotifier();
});

/// Notificador para estado de carga de contenidos
class ContenidoLoadingNotifier extends StateNotifier<bool> {
  ContenidoLoadingNotifier() : super(false);
  
  void setLoading(bool loading) {
    state = loading;
    appLogger.debug('ContenidoLoadingNotifier: Estado de carga actualizado a $loading');
  }
}

/// Provider para mensajes de error de contenidos
final contenidoErrorProvider = StateNotifierProvider<ContenidoErrorNotifier, String?>((ref) {
  return ContenidoErrorNotifier();
});

/// Notificador para mensajes de error de contenidos
class ContenidoErrorNotifier extends StateNotifier<String?> {
  ContenidoErrorNotifier() : super(null);
  
  void setError(String? error) {
    state = error;
    if (error != null) {
      appLogger.error('ContenidoErrorNotifier: Error establecido: $error');
    }
  }
  
  void clearError() {
    state = null;
    appLogger.debug('ContenidoErrorNotifier: Error limpiado');
  }
}

/// Provider para operación de guardado de contenido
final guardarContenidoProvider = FutureProvider.family<bool, ContenidoUnificado>((ref, contenido) async {
  appLogger.debug('ContenidoProvider: Guardando contenido: ${contenido.titulo}');
  
  try {
    // Establecer estado de carga
    ref.read(contenidoLoadingProvider.notifier).setLoading(true);
    ref.read(contenidoErrorProvider.notifier).clearError();
    
    final service = await ref.read(contenidoServiceProvider.future);
    
    // Convertir a formato esperado por el servicio
    await service.saveContenido(contenido);
    
    // Limpiar estado de carga
    ref.read(contenidoLoadingProvider.notifier).setLoading(false);
    
    appLogger.debug('ContenidoProvider: Contenido guardado exitosamente');
    return true;
  } catch (e) {
    // Establecer error y limpiar estado de carga
    ref.read(contenidoErrorProvider.notifier).setError(e.toString());
    ref.read(contenidoLoadingProvider.notifier).setLoading(false);
    
    appLogger.error('ContenidoProvider: Error guardando contenido', error: e);
    return false;
  }
});

/// Provider para operación de eliminación de contenido
final eliminarContenidoProvider = FutureProvider.family<bool, String>((ref, contenidoId) async {
  appLogger.debug('ContenidoProvider: Eliminando contenido con ID: $contenidoId');
  
  try {
    // Establecer estado de carga
    ref.read(contenidoLoadingProvider.notifier).setLoading(true);
    ref.read(contenidoErrorProvider.notifier).clearError();
    
    final service = await ref.read(contenidoServiceProvider.future);
    await service.deleteContenido(contenidoId);
    
    // Limpiar estado de carga
    ref.read(contenidoLoadingProvider.notifier).setLoading(false);
    
    appLogger.debug('ContenidoProvider: Contenido eliminado exitosamente');
    return true;
  } catch (e) {
    // Establecer error y limpiar estado de carga
    ref.read(contenidoErrorProvider.notifier).setError(e.toString());
    ref.read(contenidoLoadingProvider.notifier).setLoading(false);
    
    appLogger.error('ContenidoProvider: Error eliminando contenido', error: e);
    return false;
  }
});

/// Provider para sincronización de contenidos
final sincronizarContenidosProvider = FutureProvider<bool>((ref) async {
  appLogger.debug('ContenidoProvider: Sincronizando contenidos');
  
  try {
    // Establecer estado de carga
    ref.read(contenidoLoadingProvider.notifier).setLoading(true);
    ref.read(contenidoErrorProvider.notifier).clearError();
    
    final service = await ref.read(contenidoServiceProvider.future);
    await service.syncContenidos();
    
    // Limpiar estado de carga
    ref.read(contenidoLoadingProvider.notifier).setLoading(false);
    
    // Invalidar providers para forzar recarga
    ref.invalidate(contenidosProvider);
    
    appLogger.debug('ContenidoProvider: Contenidos sincronizados exitosamente');
    return true;
  } catch (e) {
    // Establecer error y limpiar estado de carga
    ref.read(contenidoErrorProvider.notifier).setError(e.toString());
    ref.read(contenidoLoadingProvider.notifier).setLoading(false);
    
    appLogger.error('ContenidoProvider: Error sincronizando contenidos', error: e);
    return false;
  }
});
