import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/fuel_entry.dart';
import '../models/unit.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fuel_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table units
    await db.execute('''
      CREATE TABLE units(
        unit_code TEXT PRIMARY KEY,
        unit_name TEXT,
        type TEXT,
        category TEXT,
        qr_code TEXT,
        is_active INTEGER
      )
    ''');

    // Table fuel_entries
    await db.execute('''
      CREATE TABLE fuel_entries(
        id TEXT PRIMARY KEY,
        unit_code TEXT,
        operator_id TEXT,
        operator_name TEXT,
        hour_meter REAL,
        fuel_level_before TEXT,
        fuel_level_after TEXT,
        estimated_liter REAL,
        photo_before_path TEXT,
        photo_after_path TEXT,
        latitude REAL,
        longitude REAL,
        location_address TEXT,
        timestamp TEXT,
        shift TEXT,
        status TEXT,
        fuelman_liter REAL,
        fuelman_id TEXT,
        fuelman_name TEXT,
        totalizer_before TEXT,
        totalizer_after TEXT,
        photo_totalizer_path TEXT,
        supervisor_note TEXT,
        sync_time TEXT,
        is_synced INTEGER
      )
    ''');

    // Table sync_queue (for offline sync)
    await db.execute('''
      CREATE TABLE sync_queue(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fuel_entry_id TEXT,
        action TEXT,
        created_at TEXT,
        retry_count INTEGER DEFAULT 0
      )
    ''');
  }

  // Save fuel entry (offline)
  Future<void> saveFuelEntry(FuelEntry entry) async {
    final db = await database;
    await db.insert(
      'fuel_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Add to sync queue
    await db.insert(
      'sync_queue',
      {
        'fuel_entry_id': entry.id,
        'action': 'CREATE',
        'created_at': DateTime.now().toIso8601String(),
        'retry_count': 0,
      },
    );
  }

  // Get all pending fuel entries (not synced)
  Future<List<FuelEntry>> getPendingEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fuel_entries',
      where: 'is_synced = 0',
    );
    return List.generate(maps.length, (i) => FuelEntry.fromMap(maps[i]));
  }

  // Get fuel entries by unit
  Future<List<FuelEntry>> getEntriesByUnit(String unitCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fuel_entries',
      where: 'unit_code = ?',
      whereArgs: [unitCode],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => FuelEntry.fromMap(maps[i]));
  }

  // Update sync status
  Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      'fuel_entries',
      {
        'is_synced': 1,
        'sync_time': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    
    // Remove from sync queue
    await db.delete(
      'sync_queue',
      where: 'fuel_entry_id = ?',
      whereArgs: [id],
    );
  }

  // Get sync queue count
  Future<int> getSyncQueueCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sync_queue');
    return result.first['count'] as int;
  }

  // Save units locally
  Future<void> saveUnits(List<Unit> units) async {
    final db = await database;
    for (var unit in units) {
      await db.insert(
        'units',
        {
          'unit_code': unit.unitCode,
          'unit_name': unit.unitName,
          'type': unit.type,
          'category': unit.category,
          'qr_code': unit.qrCode,
          'is_active': unit.isActive ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Get unit by QR code
  Future<Unit?> getUnitByQRCode(String qrCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'units',
      where: 'qr_code = ?',
      whereArgs: [qrCode],
    );
    if (maps.isEmpty) return null;
    return Unit.fromMap(maps.first);
  }

  // Get all active units
  Future<List<Unit>> getAllUnits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'units',
      where: 'is_active = 1',
    );
    return List.generate(maps.length, (i) => Unit.fromMap(maps[i]));
  }
}