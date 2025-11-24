import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/models/contenido_model.dart' as contenido_model_completo;
import 'package:madres_digitales_flutter_new/data/models/contenido_unificado.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';

/// Clase de diagnóstico para validar los problemas de contenido
class DiagnosticoContenido {
  static void ejecutarDiagnostico() {
    AppLogger.info('=== INICIANDO DIAGNÓSTICO DE CONTENIDO ===');
    
    // 1. Verificar importación del archivo contenido.dart
    _verificarImportacionContenido();
    
    // 2. Verificar compatibilidad entre modelos
    _verificarCompatibilidadModelos();
    
    // 3. Verificar consistencia de propiedades
    _verificarConsistenciaPropiedades();
    
    // 4. Verificar mapeo de categorías
    _verificarMapeoCategorias();
    
    AppLogger.info('=== DIAGNÓSTICO DE CONTENIDO COMPLETADO ===');
  }
  
  static void _verificarImportacionContenido() {
    AppLogger.info('1. Verificando importación de contenido.dart');
    
    try {
      // Instanciar modelo completo de feature
      final contenidoCompleto = contenido_model_completo.ContenidoModel(
        id: 'test',
        titulo: 'Test',
        descripcion: 'Test',
        categoria: 'nutricion',
        tipo: 'video',
        nivel: 'basico',
        fechaPublicacion: DateTime.now(),
        fechaCreacion: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      AppLogger.info('✅ Modelo de feature instanciado: ${contenidoCompleto.id}');
    } catch (e) {
      AppLogger.error('❌ Error creando ContenidoModel de feature', error: e);
    }
  }
  
  static void _verificarCompatibilidadModelos() {
    AppLogger.info('2. Verificando compatibilidad entre modelos');
    
    try {
      // Crear instancia del modelo completo
      final contenidoCompleto = contenido_model_completo.ContenidoModel(
        id: 'test',
        titulo: 'Test',
        descripcion: 'Test',
        categoria: 'nutricion',
        tipo: 'video',
        nivel: 'basico',
        fechaPublicacion: DateTime.now(),
        fechaCreacion: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Crear instancia de DTO unificado
      final unificado = ContenidoUnificado(
        id: 'test',
        titulo: 'Test',
        descripcion: 'Test',
        categoria: 'nutricion',
        tipo: 'video',
        urlContenido: 'https://ejemplo.com',
        urlImagen: null,
        duracionMinutos: 10,
        nivel: 'basico',
        tags: const [],
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
        activo: true,
      );
      
      AppLogger.info('✅ Todos los modelos se pueden instanciar correctamente');
      
      // Verificar propiedades comunes
      _verificarPropiedadComun('id', unificado.id, contenidoCompleto.id, unificado.id);
      _verificarPropiedadComun('titulo', unificado.titulo, contenidoCompleto.titulo, unificado.titulo);
      _verificarPropiedadComun('descripcion', unificado.descripcion, contenidoCompleto.descripcion, unificado.descripcion);
      
      // Verificar propiedades diferentes
      AppLogger.warn('⚠️ Propiedades con nombres diferentes:');
      AppLogger.warn('  - URL: urlContenido (${unificado.urlContenido}) vs url (${contenidoCompleto.url})');
      AppLogger.warn('  - Fecha: createdAt (${unificado.createdAt}) vs createdAt (${contenidoCompleto.createdAt})');
      AppLogger.warn('  - Tipo: tipo (${unificado.tipo}) vs tipo (${contenidoCompleto.tipo})');
      
    } catch (e) {
      AppLogger.error('❌ Error en compatibilidad de modelos', error: e);
    }
  }
  
  static void _verificarPropiedadComun(String nombre, dynamic valor1, dynamic valor2, dynamic valor3) {
    if (valor1 == valor2 && valor2 == valor3) {
      AppLogger.info('✅ Propiedad $nombre consistente: $valor1');
    } else {
      AppLogger.warn('⚠️ Propiedad $nombre inconsistente: $valor1, $valor2, $valor3');
    }
  }
  
  static void _verificarConsistenciaPropiedades() {
    AppLogger.info('3. Verificando consistencia de propiedades');
    
    // Verificar mapeo de categorías
    final categorias = ['nutricion', 'cuidado_prenatal', 'parto', 'posparto'];
    for (final categoria in categorias) {
      try {
        final categoriaEnum = CategoriaContenido.fromString(categoria);
        AppLogger.info('✅ Categoría $categoria mapeada a ${categoriaEnum.name}');
      } catch (e) {
        AppLogger.error('❌ Error mapeando categoría $categoria', error: e);
      }
    }
    
    // Verificar mapeo de tipos
    final tipos = ['video', 'audio', 'documento', 'imagen'];
    for (final tipo in tipos) {
      try {
        final tipoEnum = TipoContenido.fromString(tipo);
        AppLogger.info('✅ Tipo $tipo mapeado a ${tipoEnum.name}');
      } catch (e) {
        AppLogger.error('❌ Error mapeando tipo $tipo', error: e);
      }
    }
  }
  
  static void _verificarMapeoCategorias() {
    AppLogger.info('4. Verificando mapeo de categorías entre frontend y backend');
    
    // Categorías del frontend
    const categoriasFrontend = CategoriaContenido.values;
    
    // Categorías esperadas del backend
    final categoriasBackend = [
      'nutricion', 'cuidado_prenatal', 'signos_alarma', 'lactancia',
      'parto', 'posparto', 'planificacion', 'salud_mental',
      'ejercicio', 'higiene', 'derechos', 'otros'
    ];
    
    AppLogger.info('Categorías del frontend:');
    for (final categoria in categoriasFrontend) {
      AppLogger.info('  - ${categoria.name} -> ${categoria.value}');
    }
    
    AppLogger.info('Categorías del backend:');
    for (final categoria in categoriasBackend) {
      try {
        final categoriaEnum = CategoriaContenido.fromString(categoria);
        AppLogger.info('  - $categoria -> ${categoriaEnum.name}');
      } catch (e) {
        AppLogger.error('  - ❌ $categoria no tiene mapeo');
      }
    }
  }
}
