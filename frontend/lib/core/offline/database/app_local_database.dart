import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppLocalDatabase {
  static const String _dbName = 'asset_track_offline.db';
  static const int _dbVersion = 1;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    try {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } catch (e) {
      debugPrint('[SQLite FFI Init] $e');
    }

    String path;
    if (kIsWeb) {
      path = inMemoryDatabasePath;
    } else {
      try {
        final dbPath = await getDatabasesPath();
        path = join(dbPath, _dbName);
      } catch (_) {
        path = _dbName;
      }
    }

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE local_tickets (
        id TEXT PRIMARY KEY,
        machine_id TEXT NOT NULL,
        machine_name TEXT,
        machine_code TEXT,
        description TEXT NOT NULL,
        severity TEXT NOT NULL,
        status TEXT NOT NULL,
        images_urls TEXT,
        local_image_paths TEXT,
        downtime_start TEXT,
        sync_status TEXT NOT NULL DEFAULT 'PENDING',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        action_type TEXT NOT NULL,
        endpoint TEXT NOT NULL,
        method TEXT NOT NULL,
        payload TEXT NOT NULL,
        local_record_id TEXT,
        retry_count INTEGER NOT NULL DEFAULT 0,
        max_retries INTEGER NOT NULL DEFAULT 5,
        status TEXT NOT NULL DEFAULT 'PENDING',
        error_message TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_sync_queue_status_created 
      ON sync_queue (status, created_at ASC)
    ''');

    await db.execute('''
      CREATE INDEX idx_local_tickets_sync_status 
      ON local_tickets (sync_status)
    ''');
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
