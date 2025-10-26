import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/logger.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'madres_digitales.db');

    AppLogger.instance.info('Inicializando base de datos en: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    AppLogger.instance.info('Creando tablas de base de datos...');

    // Tabla de contenidos educativos
    await db.execute('''
      CREATE TABLE contenidos (
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        tipo TEXT NOT NULL,
        categoria TEXT NOT NULL,
        nivel TEXT NOT NULL,
        archivo_url TEXT,
        archivo_nombre TEXT,
        archivo_tipo TEXT,
        archivo_tamano INTEGER,
        archivo_local_path TEXT,
        miniatura_url TEXT,
        miniatura_local_path TEXT,
        duracion INTEGER,
        autor TEXT,
        etiquetas TEXT,
        orden INTEGER DEFAULT 0,
        destacado INTEGER DEFAULT 0,
        publico INTEGER DEFAULT 1,
        vistas INTEGER DEFAULT 0,
        descargas INTEGER DEFAULT 0,
        calificacion REAL DEFAULT 0,
        total_votos INTEGER DEFAULT 0,
        descargado INTEGER DEFAULT 0,
        fecha_descarga TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_pending INTEGER DEFAULT 0
      )
    ''');

    // Tabla de progreso de contenidos
    await db.execute('''
      CREATE TABLE progreso_contenidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contenido_id TEXT NOT NULL,
        usuario_id TEXT NOT NULL,
        progreso INTEGER DEFAULT 0,
        completado INTEGER DEFAULT 0,
        tiempo_visto INTEGER DEFAULT 0,
        ultima_posicion INTEGER DEFAULT 0,
        fecha_inicio TEXT,
        fecha_completado TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (contenido_id) REFERENCES contenidos (id) ON DELETE CASCADE,
        UNIQUE(contenido_id, usuario_id)
      )
    ''');

    // Tabla de favoritos
    await db.execute('''
      CREATE TABLE favoritos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contenido_id TEXT NOT NULL,
        usuario_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (contenido_id) REFERENCES contenidos (id) ON DELETE CASCADE,
        UNIQUE(contenido_id, usuario_id)
      )
    ''');

    // Tabla de gestantes (cache offline)
    await db.execute('''
      CREATE TABLE gestantes (
        id TEXT PRIMARY KEY,
        nombres TEXT NOT NULL,
        apellidos TEXT NOT NULL,
        documento TEXT NOT NULL,
        fecha_nacimiento TEXT NOT NULL,
        telefono TEXT,
        direccion TEXT,
        municipio_id TEXT,
        zona TEXT,
        fur TEXT,
        fpp TEXT,
        semanas_gestacion INTEGER,
        estado TEXT,
        riesgo TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER DEFAULT 1
      )
    ''');

    // Tabla de controles prenatales (cache offline)
    await db.execute('''
      CREATE TABLE controles_prenatales (
        id TEXT PRIMARY KEY,
        gestante_id TEXT NOT NULL,
        fecha_control TEXT NOT NULL,
        semanas_gestacion INTEGER,
        peso REAL,
        presion_arterial TEXT,
        altura_uterina REAL,
        frecuencia_cardiaca_fetal INTEGER,
        observaciones TEXT,
        created_by TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER DEFAULT 1,
        FOREIGN KEY (gestante_id) REFERENCES gestantes (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de alertas (cache offline)
    await db.execute('''
      CREATE TABLE alertas (
        id TEXT PRIMARY KEY,
        gestante_id TEXT NOT NULL,
        tipo_alerta TEXT NOT NULL,
        nivel_riesgo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        estado TEXT NOT NULL,
        fecha_deteccion TEXT NOT NULL,
        fecha_resolucion TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER DEFAULT 1,
        FOREIGN KEY (gestante_id) REFERENCES gestantes (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de logs de actividad
    await db.execute('''
      CREATE TABLE activity_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id TEXT NOT NULL,
        accion TEXT NOT NULL,
        modulo TEXT NOT NULL,
        entidad_tipo TEXT,
        entidad_id TEXT,
        detalles TEXT,
        ip_address TEXT,
        user_agent TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Tabla de cola de sincronización
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL,
        accion TEXT NOT NULL,
        tabla TEXT NOT NULL,
        entidad_id TEXT NOT NULL,
        datos TEXT NOT NULL,
        intentos INTEGER DEFAULT 0,
        ultimo_intento TEXT,
        error TEXT,
        created_at TEXT NOT NULL,
        procesado INTEGER DEFAULT 0
      )
    ''');

    // Tabla de archivos descargados
    await db.execute('''
      CREATE TABLE archivos_descargados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contenido_id TEXT NOT NULL,
        tipo_archivo TEXT NOT NULL,
        url_original TEXT NOT NULL,
        path_local TEXT NOT NULL,
        nombre_archivo TEXT NOT NULL,
        tamaño INTEGER NOT NULL,
        mime_type TEXT NOT NULL,
        fecha_descarga TEXT NOT NULL,
        ultimo_acceso TEXT,
        FOREIGN KEY (contenido_id) REFERENCES contenidos (id) ON DELETE CASCADE,
        UNIQUE(contenido_id, tipo_archivo)
      )
    ''');

    // Índices para mejorar rendimiento
    await db.execute('CREATE INDEX idx_contenidos_categoria ON contenidos(categoria)');
    await db.execute('CREATE INDEX idx_contenidos_tipo ON contenidos(tipo)');
    await db.execute('CREATE INDEX idx_contenidos_descargado ON contenidos(descargado)');
    await db.execute('CREATE INDEX idx_contenidos_sync_pending ON contenidos(sync_pending)');
    await db.execute('CREATE INDEX idx_progreso_contenido_usuario ON progreso_contenidos(contenido_id, usuario_id)');
    await db.execute('CREATE INDEX idx_favoritos_usuario ON favoritos(usuario_id)');
    await db.execute('CREATE INDEX idx_gestantes_municipio ON gestantes(municipio_id)');
    await db.execute('CREATE INDEX idx_controles_gestante ON controles_prenatales(gestante_id)');
    await db.execute('CREATE INDEX idx_alertas_gestante ON alertas(gestante_id)');
    await db.execute('CREATE INDEX idx_alertas_estado ON alertas(estado)');
    await db.execute('CREATE INDEX idx_activity_logs_usuario ON activity_logs(usuario_id)');
    await db.execute('CREATE INDEX idx_sync_queue_procesado ON sync_queue(procesado)');

    AppLogger.instance.info('Base de datos creada exitosamente');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.instance.info('Actualizando base de datos de versión $oldVersion a $newVersion');
    
    // Aquí se agregarían migraciones futuras
    if (oldVersion < 2) {
      // Ejemplo de migración futura
      // await db.execute('ALTER TABLE contenidos ADD COLUMN nuevo_campo TEXT');
    }
  }

  // Métodos de utilidad

  /// Limpiar toda la base de datos
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('contenidos');
    await db.delete('progreso_contenidos');
    await db.delete('favoritos');
    await db.delete('gestantes');
    await db.delete('controles_prenatales');
    await db.delete('alertas');
    await db.delete('activity_logs');
    await db.delete('sync_queue');
    await db.delete('archivos_descargados');
    AppLogger.instance.info('Base de datos limpiada');
  }

  /// Obtener estadísticas de la base de datos
  Future<Map<String, int>> getStatistics() async {
    final db = await database;
    
    final contenidos = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM contenidos')
    ) ?? 0;
    
    final contenidosDescargados = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM contenidos WHERE descargado = 1')
    ) ?? 0;
    
    final gestantes = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM gestantes')
    ) ?? 0;
    
    final controles = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM controles_prenatales')
    ) ?? 0;
    
    final alertas = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM alertas')
    ) ?? 0;
    
    final syncPending = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM sync_queue WHERE procesado = 0')
    ) ?? 0;

    return {
      'contenidos': contenidos,
      'contenidosDescargados': contenidosDescargados,
      'gestantes': gestantes,
      'controles': controles,
      'alertas': alertas,
      'syncPending': syncPending,
    };
  }

  /// Cerrar base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    AppLogger.instance.info('Base de datos cerrada');
  }
}

