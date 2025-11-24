import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';

/// Helper para operaciones de base de datos SQLite
class DatabaseHelper {
  static const String _databaseName = 'madres_digitales.db';
  static const int _databaseVersion = 1;

  /// Obtiene la ruta de la base de datos
  static Future<String> getDatabasePath(String databasesPath) async {
    final path = join(databasesPath, _databaseName);
    AppLogger.info('Database path: $path');
    return path;
  }

  /// Abre la base de datos
  static Future<sqflite.Database> openDatabase() async {
    try {
      final databasesPath = await sqflite.getDatabasesPath();
      final path = await getDatabasePath(databasesPath);
      
      return await sqflite.openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      AppLogger.error('Error opening database: $e');
      rethrow;
    }
  }

  /// Crea las tablas iniciales
  static Future<void> _onCreate(sqflite.Database db, int version) async {
    try {
      // Tabla de usuarios
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          email TEXT UNIQUE NOT NULL,
          name TEXT NOT NULL,
          role TEXT NOT NULL,
          municipalityId TEXT,
          phone TEXT,
          document TEXT,
          documentType TEXT,
          active INTEGER NOT NULL DEFAULT 1,
          lastAccess TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          municipalityName TEXT,
          departmentName TEXT,
          profileImageUrl TEXT,
          preferences TEXT,
          metadata TEXT
        )
      ''');

      // Tabla de gestantes
      await db.execute('''
        CREATE TABLE gestantes (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          document TEXT,
          documentType TEXT,
          birthDate TEXT,
          phone TEXT,
          address TEXT,
          coordinates TEXT,
          lastMenstruation TEXT,
          probableDelivery TEXT,
          eps TEXT,
          healthRegime TEXT,
          municipalityId TEXT,
          madrinaId TEXT,
          medicoTratanteId TEXT,
          ipsAsignadaId TEXT,
          active INTEGER NOT NULL DEFAULT 1,
          highRisk INTEGER NOT NULL DEFAULT 0,
          lastControlDate TEXT,
          nextControlDate TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT,
          municipalityName TEXT,
          departmentName TEXT,
          madrinaName TEXT,
          medicoTratanteName TEXT,
          ipsAsignadaName TEXT,
          riskFactors TEXT,
          controls TEXT,
          notes TEXT,
          metadata TEXT
        )
      ''');

      // Tabla de controles
      await db.execute('''
        CREATE TABLE controls (
          id TEXT PRIMARY KEY,
          gestanteId TEXT NOT NULL,
          fecha TEXT NOT NULL,
          peso REAL,
          tensionArterial REAL,
          frecuenciaCardiaca REAL,
          presionArterial REAL,
          alturaUterina REAL,
          comentarios TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT
        )
      ''');

      // Tabla de contenidos
      await db.execute('''
        CREATE TABLE contenidos (
          id TEXT PRIMARY KEY,
          titulo TEXT NOT NULL,
          descripcion TEXT,
          tipo TEXT NOT NULL,
          url TEXT,
          activo INTEGER NOT NULL DEFAULT 1,
          createdAt TEXT NOT NULL,
          updatedAt TEXT
        )
      ''');

      // Tabla de alertas
      await db.execute('''
        CREATE TABLE alertas (
          id TEXT PRIMARY KEY,
          gestanteId TEXT NOT NULL,
          tipo TEXT NOT NULL,
          mensaje TEXT,
          leida INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL,
          updatedAt TEXT
        )
      ''');

      // Tabla de mensajes
      await db.execute('''
        CREATE TABLE mensajes (
          id TEXT PRIMARY KEY,
          remitenteId TEXT,
          destinatarioId TEXT,
          asunto TEXT,
          contenido TEXT,
          leido INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL,
          updatedAt TEXT
        )
      ''');

      // Tabla de municipios
      await db.execute('''
        CREATE TABLE municipios (
          id TEXT PRIMARY KEY,
          nombre TEXT NOT NULL,
          departamentoId TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT
        )
      ''');

      // Tabla de IPS
      await db.execute('''
        CREATE TABLE ips (
          id TEXT PRIMARY KEY,
          nombre TEXT NOT NULL,
          direccion TEXT,
          telefono TEXT,
          municipioId TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT
        )
      ''');

      // Tabla de médicos
      await db.execute('''
        CREATE TABLE medicos (
          id TEXT PRIMARY KEY,
          nombre TEXT NOT NULL,
          especialidad TEXT,
          registroMedico TEXT,
          telefono TEXT,
          municipioId TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT
        )
      ''');

      AppLogger.info('Database tables created successfully');
    } catch (e) {
      AppLogger.error('Error creating database tables: $e');
      rethrow;
    }
  }

  /// Maneja actualizaciones de la base de datos
  static Future<void> _onUpgrade(sqflite.Database db, int oldVersion, int newVersion) async {
    try {
      // Por ahora, solo incrementamos la versión
      // En el futuro, aquí se pueden agregar migraciones
      AppLogger.info('Database upgraded from version $oldVersion to $newVersion');
    } catch (e) {
      AppLogger.error('Error upgrading database: $e');
      rethrow;
    }
  }

  /// Cierra la base de datos
  static Future<void> closeDatabase(sqflite.Database db) async {
    try {
      await db.close();
      AppLogger.info('Database closed successfully');
    } catch (e) {
      AppLogger.error('Error closing database: $e');
      rethrow;
    }
  }
}
