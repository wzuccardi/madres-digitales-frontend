import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';

class OfflineService {
  static OfflineService? _instance;
  static OfflineService get instance => _instance ??= OfflineService._();
  OfflineService._();
  
  Database? _database;
  final ApiService _apiService = ApiService();
  
  // Inicializar base de datos local
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'madres_digitales_offline.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _createTables(Database db, int version) async {
    // Tabla para controles prenatales offline
    await db.execute('''
      CREATE TABLE controles_offline (
        id TEXT PRIMARY KEY,
        gestante_id TEXT NOT NULL,
        fecha_control TEXT NOT NULL,
        peso REAL,
        presion_sistolica INTEGER,
        presion_diastolica INTEGER,
        frecuencia_cardiaca INTEGER,
        temperatura REAL,
        observaciones TEXT,
        ubicacion_latitud REAL,
        ubicacion_longitud REAL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
    
    // Tabla para alertas offline
    await db.execute('''
      CREATE TABLE alertas_offline (
        id TEXT PRIMARY KEY,
        gestante_id TEXT NOT NULL,
        tipo_alerta TEXT NOT NULL,
        nivel_prioridad TEXT NOT NULL,
        mensaje TEXT NOT NULL,
        ubicacion_latitud REAL,
        ubicacion_longitud REAL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
    
    // Tabla para gestantes (cache)
    await db.execute('''
      CREATE TABLE gestantes_cache (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        apellido TEXT NOT NULL,
        documento TEXT NOT NULL,
        telefono TEXT,
        fecha_nacimiento TEXT,
        direccion TEXT,
        ubicacion_latitud REAL,
        ubicacion_longitud REAL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Tabla para sincronización pendiente
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    
    // Tabla para caché de contenidos
    await db.execute('''
      CREATE TABLE contenidos_cache (
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        categoria TEXT NOT NULL,
        tipo TEXT NOT NULL,
        nivel TEXT NOT NULL,
        url_contenido TEXT NOT NULL,
        url_miniatura TEXT,
        duracion INTEGER,
        tags TEXT,
        activo INTEGER DEFAULT 1,
        ruta_local TEXT,
        fecha_creacion TEXT NOT NULL,
        fecha_actualizacion TEXT
      )
    ''');
    
    // Tabla para progreso de contenido
    await db.execute('''
      CREATE TABLE progreso_contenido_cache (
        contenido_id TEXT NOT NULL,
        usuario_id TEXT NOT NULL,
        tiempo_visto INTEGER DEFAULT 0,
        porcentaje_completado REAL DEFAULT 0.0,
        completado INTEGER DEFAULT 0,
        fecha_actualizacion TEXT NOT NULL,
        PRIMARY KEY (contenido_id, usuario_id)
      )
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar tablas de contenido en la versión 2
      await db.execute('''
        CREATE TABLE contenidos_cache (
          id TEXT PRIMARY KEY,
          titulo TEXT NOT NULL,
          descripcion TEXT,
          categoria TEXT NOT NULL,
          tipo TEXT NOT NULL,
          nivel TEXT NOT NULL,
          url_contenido TEXT NOT NULL,
          url_miniatura TEXT,
          duracion INTEGER,
          tags TEXT,
          activo INTEGER DEFAULT 1,
          ruta_local TEXT,
          fecha_creacion TEXT NOT NULL,
          fecha_actualizacion TEXT
        )
      ''');
      
      await db.execute('''
        CREATE TABLE progreso_contenido_cache (
          contenido_id TEXT NOT NULL,
          usuario_id TEXT NOT NULL,
          tiempo_visto INTEGER DEFAULT 0,
          porcentaje_completado REAL DEFAULT 0.0,
          completado INTEGER DEFAULT 0,
          fecha_actualizacion TEXT NOT NULL,
          PRIMARY KEY (contenido_id, usuario_id)
        )
      ''');
    }
  }
  
  // Verificar conectividad
  Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  // Stream de conectividad
  Stream<ConnectivityResult> get connectivityStream {
    return Connectivity().onConnectivityChanged;
  }
  
  // Guardar control prenatal offline
  Future<void> saveControlOffline(Map<String, dynamic> controlData) async {
    final db = await database;
    
    await db.insert(
      'controles_offline',
      {
        ...controlData,
        'created_at': DateTime.now().toIso8601String(),
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Agregar a cola de sincronización
    await _addToSyncQueue('controles_offline', controlData['id'], 'INSERT', controlData);
  }
  
  // Guardar alerta offline
  Future<void> saveAlertaOffline(Map<String, dynamic> alertaData) async {
    final db = await database;
    
    await db.insert(
      'alertas_offline',
      {
        ...alertaData,
        'created_at': DateTime.now().toIso8601String(),
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Agregar a cola de sincronización
    await _addToSyncQueue('alertas_offline', alertaData['id'], 'INSERT', alertaData);
  }
  
  // Cache de gestantes
  Future<void> cacheGestante(Map<String, dynamic> gestanteData) async {
    final db = await database;
    
    await db.insert(
      'gestantes_cache',
      {
        ...gestanteData,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Obtener gestantes desde cache
  Future<List<Map<String, dynamic>>> getCachedGestantes() async {
    final db = await database;
    return await db.query('gestantes_cache');
  }
  
  // Obtener controles offline
  Future<List<Map<String, dynamic>>> getOfflineControles() async {
    final db = await database;
    return await db.query('controles_offline', where: 'synced = ?', whereArgs: [0]);
  }
  
  // Obtener alertas offline
  Future<List<Map<String, dynamic>>> getOfflineAlertas() async {
    final db = await database;
    return await db.query('alertas_offline', where: 'synced = ?', whereArgs: [0]);
  }
  
  // Agregar a cola de sincronización
  Future<void> _addToSyncQueue(
    String tableName,
    String recordId,
    String action,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    
    await db.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'data': jsonEncode(data),
      'created_at': DateTime.now().toIso8601String(),
    });
  }
  
  // Sincronizar datos pendientes
  Future<SyncResult> syncPendingData() async {
    if (!await isConnected()) {
      return SyncResult(success: false, message: 'Sin conexión a internet');
    }
    
    final db = await database;
    final pendingItems = await db.query('sync_queue', orderBy: 'created_at ASC');
    
    int successCount = 0;
    int errorCount = 0;
    List<String> errors = [];
    
    for (final item in pendingItems) {
      try {
        final data = jsonDecode(item['data'] as String);
        bool synced = false;
        
        switch (item['table_name']) {
          case 'controles_offline':
            synced = await _syncControl(data);
            break;
          case 'alertas_offline':
            synced = await _syncAlerta(data);
            break;
        }
        
        if (synced) {
          // Marcar como sincronizado
          await db.update(
            item['table_name'] as String,
            {'synced': 1},
            where: 'id = ?',
            whereArgs: [item['record_id']],
          );
          
          // Eliminar de cola de sincronización
          await db.delete('sync_queue', where: 'id = ?', whereArgs: [item['id']]);
          
          successCount++;
        } else {
          errorCount++;
        }
      } catch (e) {
        errors.add('Error sincronizando ${item['table_name']}: $e');
        errorCount++;
      }
    }
    
    return SyncResult(
      success: errorCount == 0,
      message: 'Sincronizados: $successCount, Errores: $errorCount',
      syncedCount: successCount,
      errorCount: errorCount,
      errors: errors,
    );
  }
  
  // Sincronizar control prenatal
  Future<bool> _syncControl(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/controles', data: data);
      return response.statusCode == 201;
    } catch (e) {
      print('Error sincronizando control: $e');
      return false;
    }
  }
  
  // Sincronizar alerta
  Future<bool> _syncAlerta(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/alertas', data: data);
      return response.statusCode == 201;
    } catch (e) {
      print('Error sincronizando alerta: $e');
      return false;
    }
  }
  
  // Limpiar datos sincronizados antiguos
  Future<void> cleanupSyncedData() async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
    
    await db.delete(
      'controles_offline',
      where: 'synced = ? AND created_at < ?',
      whereArgs: [1, cutoffDate.toIso8601String()],
    );
    
    await db.delete(
      'alertas_offline',
      where: 'synced = ? AND created_at < ?',
      whereArgs: [1, cutoffDate.toIso8601String()],
    );
  }
  
  // Obtener estadísticas de sincronización
  Future<SyncStats> getSyncStats() async {
    final db = await database;
    
    final controlesPendientes = await db.rawQuery(
      'SELECT COUNT(*) as count FROM controles_offline WHERE synced = 0'
    );
    
    final alertasPendientes = await db.rawQuery(
      'SELECT COUNT(*) as count FROM alertas_offline WHERE synced = 0'
    );
    
    final queueSize = await db.rawQuery('SELECT COUNT(*) as count FROM sync_queue');
    
    return SyncStats(
      controlesPendientes: controlesPendientes.first['count'] as int,
      alertasPendientes: alertasPendientes.first['count'] as int,
      queueSize: queueSize.first['count'] as int,
    );
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int errorCount;
  final List<String> errors;
  
  SyncResult({
    required this.success,
    required this.message,
    this.syncedCount = 0,
    this.errorCount = 0,
    this.errors = const [],
  });
}

class SyncStats {
  final int controlesPendientes;
  final int alertasPendientes;
  final int queueSize;
  
  SyncStats({
    required this.controlesPendientes,
    required this.alertasPendientes,
    required this.queueSize,
  });
  
  int get totalPendientes => controlesPendientes + alertasPendientes;
}