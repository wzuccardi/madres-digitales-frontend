import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../logger_service.dart';

/// Servicio de base de datos local SQLite
/// Maneja todas las operaciones de base de datos offline
class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _database;
  final _logger = LoggerService();

  factory LocalDatabase() => _instance;

  LocalDatabase._internal();

  /// Obtener instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializar base de datos
  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'madres_digitales.db');

      _logger.info('Inicializando base de datos local', data: {'path': path});

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e, stackTrace) {
      _logger.error('Error inicializando base de datos', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Crear tablas de la base de datos
  Future<void> _onCreate(Database db, int version) async {
    _logger.info('Creando tablas de base de datos', data: {'version': version});

    // Tabla de gestantes
    await db.execute('''
      CREATE TABLE gestantes (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        documento TEXT,
        tipo_documento TEXT,
        fecha_nacimiento TEXT,
        edad INTEGER,
        telefono TEXT,
        direccion TEXT,
        municipio_id TEXT,
        municipio_nombre TEXT,
        barrio TEXT,
        coordenadas TEXT,
        eps TEXT,
        regimen TEXT,
        fecha_ultima_menstruacion TEXT,
        fecha_probable_parto TEXT,
        semanas_gestacion INTEGER,
        nivel_riesgo TEXT,
        puntaje_riesgo REAL,
        madrina_id TEXT,
        madrina_nombre TEXT,
        ips_id TEXT,
        ips_nombre TEXT,
        activo INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        version INTEGER DEFAULT 1
      )
    ''');

    // Tabla de controles prenatales
    await db.execute('''
      CREATE TABLE controles (
        id TEXT PRIMARY KEY,
        gestante_id TEXT NOT NULL,
        fecha_control TEXT NOT NULL,
        semanas_gestacion INTEGER,
        peso REAL,
        presion_arterial TEXT,
        altura_uterina REAL,
        frecuencia_cardiaca_fetal INTEGER,
        presentacion_fetal TEXT,
        edema INTEGER,
        proteinuria INTEGER,
        glucosuria INTEGER,
        observaciones TEXT,
        proximo_control TEXT,
        medico_id TEXT,
        medico_nombre TEXT,
        ips_id TEXT,
        ips_nombre TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        version INTEGER DEFAULT 1,
        FOREIGN KEY (gestante_id) REFERENCES gestantes (id)
      )
    ''');

    // Tabla de alertas
    await db.execute('''
      CREATE TABLE alertas (
        id TEXT PRIMARY KEY,
        gestante_id TEXT NOT NULL,
        tipo_alerta TEXT NOT NULL,
        nivel_prioridad TEXT NOT NULL,
        mensaje TEXT NOT NULL,
        sintomas TEXT,
        coordenadas_alerta TEXT,
        madrina_id TEXT,
        medico_asignado_id TEXT,
        ips_derivada_id TEXT,
        resuelta INTEGER DEFAULT 0,
        resuelto_por_id TEXT,
        fecha_resolucion TEXT,
        tiempo_respuesta INTEGER,
        generado_por_id TEXT,
        es_automatica INTEGER DEFAULT 0,
        control_origen_id TEXT,
        algoritmo_version TEXT,
        created_at TEXT,
        synced INTEGER DEFAULT 0,
        version INTEGER DEFAULT 1,
        FOREIGN KEY (gestante_id) REFERENCES gestantes (id)
      )
    ''');

    // Tabla de cola de sincronización
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        version INTEGER DEFAULT 1,
        error_message TEXT,
        retry_count INTEGER DEFAULT 0,
        max_retries INTEGER DEFAULT 3,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT
      )
    ''');

    // Tabla de conflictos
    await db.execute('''
      CREATE TABLE sync_conflicts (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        local_version INTEGER NOT NULL,
        server_version INTEGER NOT NULL,
        local_data TEXT NOT NULL,
        server_data TEXT NOT NULL,
        resolved INTEGER DEFAULT 0,
        resolution TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla de metadata de sincronización
    await db.execute('''
      CREATE TABLE sync_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla de IPS
    await db.execute('''
      CREATE TABLE ips (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        codigo TEXT,
        nivel TEXT,
        direccion TEXT,
        telefono TEXT,
        email TEXT,
        municipio_id TEXT,
        municipio_nombre TEXT,
        coordenadas TEXT,
        activo INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        version INTEGER DEFAULT 1
      )
    ''');

    // Tabla de médicos
    await db.execute('''
      CREATE TABLE medicos (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        documento TEXT,
        especialidad TEXT,
        registro_medico TEXT,
        telefono TEXT,
        email TEXT,
        ips_id TEXT,
        ips_nombre TEXT,
        activo INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        version INTEGER DEFAULT 1
      )
    ''');

    // Tabla de municipios
    await db.execute('''
      CREATE TABLE municipios (
        id TEXT PRIMARY KEY,
        codigo_dane TEXT,
        nombre TEXT NOT NULL,
        departamento TEXT,
        coordenadas TEXT,
        activo INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        version INTEGER DEFAULT 1
      )
    ''');

    // Índices para mejorar rendimiento
    await db.execute('CREATE INDEX idx_gestantes_madrina ON gestantes(madrina_id)');
    await db.execute('CREATE INDEX idx_gestantes_municipio ON gestantes(municipio_id)');
    await db.execute('CREATE INDEX idx_gestantes_synced ON gestantes(synced)');
    
    await db.execute('CREATE INDEX idx_controles_gestante ON controles(gestante_id)');
    await db.execute('CREATE INDEX idx_controles_synced ON controles(synced)');
    
    await db.execute('CREATE INDEX idx_alertas_gestante ON alertas(gestante_id)');
    await db.execute('CREATE INDEX idx_alertas_resuelta ON alertas(resuelta)');
    await db.execute('CREATE INDEX idx_alertas_synced ON alertas(synced)');
    
    await db.execute('CREATE INDEX idx_sync_queue_status ON sync_queue(status)');
    await db.execute('CREATE INDEX idx_sync_queue_entity ON sync_queue(entity_type, entity_id)');
    
    await db.execute('CREATE INDEX idx_sync_conflicts_resolved ON sync_conflicts(resolved)');

    _logger.info('Tablas creadas exitosamente');
  }

  /// Actualizar esquema de base de datos
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.info('Actualizando base de datos', data: {
      'oldVersion': oldVersion,
      'newVersion': newVersion,
    });

    // Aquí se agregarían migraciones futuras
    // Por ejemplo:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE gestantes ADD COLUMN nueva_columna TEXT');
    // }
  }

  /// Cerrar base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    _logger.info('Base de datos cerrada');
  }

  /// Limpiar toda la base de datos (solo para desarrollo/testing)
  Future<void> clearAll() async {
    final db = await database;
    
    await db.delete('gestantes');
    await db.delete('controles');
    await db.delete('alertas');
    await db.delete('sync_queue');
    await db.delete('sync_conflicts');
    await db.delete('sync_metadata');
    await db.delete('ips');
    await db.delete('medicos');
    await db.delete('municipios');
    
    _logger.warning('Base de datos limpiada completamente');
  }

  /// Obtener estadísticas de la base de datos
  Future<Map<String, int>> getStats() async {
    final db = await database;
    
    final gestantesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM gestantes')
    ) ?? 0;
    
    final controlesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM controles')
    ) ?? 0;
    
    final alertasCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM alertas')
    ) ?? 0;
    
    final pendingSyncCount = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM sync_queue WHERE status = 'pending'")
    ) ?? 0;
    
    final conflictsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM sync_conflicts WHERE resolved = 0')
    ) ?? 0;

    return {
      'gestantes': gestantesCount,
      'controles': controlesCount,
      'alertas': alertasCount,
      'pendingSync': pendingSyncCount,
      'conflicts': conflictsCount,
    };
  }
}

