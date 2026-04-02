import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/fuel_entry.dart';
import '../models/unit.dart';
import '../models/user.dart';

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
    // Table users
    await db.execute('''
      CREATE TABLE users(
        username TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        password TEXT,
        role TEXT,
        unit_code TEXT,
        employee_id TEXT,
        is_active INTEGER
      )
    ''');
    
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

  // ============================================
  // USER METHODS
  // ============================================
  
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND is_active = 1',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }
  
  Future<User?> authenticate(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ? AND is_active = 1',
      whereArgs: [username, password],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }
  
  // Save user
  Future<void> saveUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Get all users
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // ============================================
  // FUEL ENTRY METHODS
  // ============================================
  
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

  // Get all fuel entries
  Future<List<FuelEntry>> getAllEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fuel_entries',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => FuelEntry.fromMap(maps[i]));
  }

  // Get fuel entries by date range
  Future<List<FuelEntry>> getEntriesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fuel_entries',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
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

  // ============================================
  // UNIT METHODS
  // ============================================
  
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

  // Get unit by unit code
  Future<Unit?> getUnitByCode(String unitCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'units',
      where: 'unit_code = ?',
      whereArgs: [unitCode],
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

  // Delete all data (for testing/reset)
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('fuel_entries');
    await db.delete('sync_queue');
    await db.delete('units');
    await db.delete('users');
  }

  // Get statistics for dashboard
  Future<Map<String, dynamic>> getStatistics(String unitCode) async {
    final db = await database;
    
    // Get total fuel by unit
    final totalFuel = await db.rawQuery('''
      SELECT COALESCE(SUM(estimated_liter), 0) as total 
      FROM fuel_entries 
      WHERE unit_code = ? AND status != 'rejected'
    ''', [unitCode]);
    
    // Get total entries count
    final totalEntries = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM fuel_entries 
      WHERE unit_code = ?
    ''', [unitCode]);
    
    // Get last entry
    final lastEntry = await db.query(
      'fuel_entries',
      where: 'unit_code = ?',
      whereArgs: [unitCode],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    
    return {
      'total_fuel': totalFuel.first['total'],
      'total_entries': totalEntries.first['count'],
      'last_entry': lastEntry.isNotEmpty ? FuelEntry.fromMap(lastEntry.first) : null,
    };
  }
}