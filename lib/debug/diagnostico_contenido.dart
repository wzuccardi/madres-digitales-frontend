import 'package:madres_digitales_flutter_new/utils/logger.dart';
import 'package:madres_digitales_flutter_new/models/contenido_model.dart' as ContenidoModelAlias;
import 'package:madres_digitales_flutter_new/features/contenido/data/models/contenido_model.dart' as ContenidoModelCompleto;
import 'package:madres_digitales_flutter_new/models/simple_models.dart';

/// Clase de diagnóstico para validar los problemas de contenido
class DiagnosticoContenido {
  static void ejecutarDiagnostico() {
    appLogger.info('=== INICIANDO DIAGNÓSTICO DE CONTENIDO ===');
    
    // 1. Verificar importación del archivo contenido.dart
    _verificarImportacionContenido();
    
    // 2. Verificar compatibilidad entre modelos
    _verificarCompatibilidadModelos();
    
    // 3. Verificar consistencia de propiedades
    _verificarConsistenciaPropiedades();
    
    // 4. Verificar mapeo de categorías
    _verificarMapeoCategorias();
    
    appLogger.info('=== DIAGNÓSTICO DE CONTENIDO COMPLETADO ===');
  }
  
  static void _verificarImportacionContenido() {
    appLogger.info('1. Verificando importación de contenido.dart');
    
    try {
      // Intentar crear una instancia del modelo básico
      final contenidoBasico = ContenidoModelAlias.ContenidoModel(
        id: 'test',
        titulo: 'Test',
        descripcion: 'Test',
        categoria: 'test',
        tipoContenido: 'test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Intentar convertir a ContenidoUnificado (usando el método correcto)
      try {
        final contenido = contenidoBasico.toContenidoUnificado();
        appLogger.info('✅ Conversión a ContenidoUnificado exitosa');
      } catch (e) {
        appLogger.error('❌ Error en conversión a ContenidoUnificado', error: e);
      }
    } catch (e) {
      appLogger.error('❌ Error creando ContenidoModel básico', error: e);
    }
  }
  
  static void _verificarCompatibilidadModelos() {
    appLogger.info('2. Verificando compatibilidad entre modelos');
    
    try {
      // Crear instancia del modelo básico
      final contenidoBasico = ContenidoModelAlias.ContenidoModel(
        id: 'test',
        titulo: 'Test',
        descripcion: 'Test',
        categoria: 'test',
        tipoContenido: 'test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Crear instancia del modelo completo
      final contenidoCompleto = ContenidoModelCompleto.ContenidoModel(
        id: 'test',
        titulo: 'Test',
        descripcion: 'Test',
        categoria: 'test',
        tipo: 'test',
        nivel: 'basico',
        fechaPublicacion: DateTime.now(),
        fechaCreacion: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Crear instancia del modelo simple
      final contenidoSimple = SimpleContenido(
        id: 'test',
        titulo: 'Test',
        descripcion: 'Test',
        tipo: 'test',
        categoria: 'test',
        tags: [],
        activo: true,
        created_at: DateTime.now(),
      );
      
      appLogger.info('✅ Todos los modelos se pueden instanciar correctamente');
      
      // Verificar propiedades comunes
      _verificarPropiedadComun('id', contenidoBasico.id, contenidoCompleto.id, contenidoSimple.id);
      _verificarPropiedadComun('titulo', contenidoBasico.titulo, contenidoCompleto.titulo, contenidoSimple.titulo);
      _verificarPropiedadComun('descripcion', contenidoBasico.descripcion, contenidoCompleto.descripcion, contenidoSimple.descripcion);
      
      // Verificar propiedades diferentes
      appLogger.warn('⚠️ Propiedades con nombres diferentes:');
      appLogger.warn('  - URL: urlContenido (${contenidoBasico.urlContenido}) vs url (${contenidoCompleto.url}) vs url (${contenidoSimple.url})');
      appLogger.warn('  - Fecha: createdAt (${contenidoBasico.createdAt}) vs createdAt (${contenidoCompleto.createdAt}) vs created_at (${contenidoSimple.created_at})');
      appLogger.warn('  - Tipo: tipoContenido (${contenidoBasico.tipoContenido}) vs tipo (${contenidoCompleto.tipo}) vs tipo (${contenidoSimple.tipo})');
      
    } catch (e) {
      appLogger.error('❌ Error en compatibilidad de modelos', error: e);
    }
  }
  
  static void _verificarPropiedadComun(String nombre, dynamic valor1, dynamic valor2, dynamic valor3) {
    if (valor1 == valor2 && valor2 == valor3) {
      appLogger.info('✅ Propiedad $nombre consistente: $valor1');
    } else {
      appLogger.warn('⚠️ Propiedad $nombre inconsistente: $valor1, $valor2, $valor3');
    }
  }
  
  static void _verificarConsistenciaPropiedades() {
    appLogger.info('3. Verificando consistencia de propiedades');
    
    // Verificar mapeo de categorías
    final categorias = ['nutricion', 'cuidado_prenatal', 'parto', 'posparto'];
    for (final categoria in categorias) {
      try {
        final categoriaEnum = CategoriaContenido.fromBackendValue(categoria);
        appLogger.info('✅ Categoría $categoria mapeada a ${categoriaEnum.name}');
      } catch (e) {
        appLogger.error('❌ Error mapeando categoría $categoria', error: e);
      }
    }
    
    // Verificar mapeo de tipos
    final tipos = ['video', 'audio', 'documento', 'imagen'];
    for (final tipo in tipos) {
      try {
        final tipoEnum = TipoContenido.fromBackendValue(tipo);
        appLogger.info('✅ Tipo $tipo mapeado a ${tipoEnum.name}');
      } catch (e) {
        appLogger.error('❌ Error mapeando tipo $tipo', error: e);
      }
    }
  }
  
  static void _verificarMapeoCategorias() {
    appLogger.info('4. Verificando mapeo de categorías entre frontend y backend');
    
    // Categorías del frontend
    const categoriasFrontend = CategoriaContenido.values;
    
    // Categorías esperadas del backend
    final categoriasBackend = [
      'nutricion', 'cuidado_prenatal', 'signos_alarma', 'lactancia',
      'parto', 'posparto', 'planificacion', 'salud_mental',
      'ejercicio', 'higiene', 'derechos', 'otros'
    ];
    
    appLogger.info('Categorías del frontend:');
    for (final categoria in categoriasFrontend) {
      appLogger.info('  - ${categoria.name} -> ${categoria.backendValue}');
    }
    
    appLogger.info('Categorías del backend:');
    for (final categoria in categoriasBackend) {
      try {
        final categoriaEnum = CategoriaContenido.fromBackendValue(categoria);
        appLogger.info('  - $categoria -> ${categoriaEnum.name}');
      } catch (e) {
        appLogger.error('  - ❌ $categoria no tiene mapeo');
      }
    }
  }
}