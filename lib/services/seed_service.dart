// ============================================
// SEED SERVICE - DISABLED FOR WEB TESTING
// ============================================
// Seed service ini akan digunakan nanti saat:
// 1. Migrasi ke backend dengan PostgreSQL
// 2. Deploy ke Android/iOS dengan SQLite
// 3. Setup data awal untuk production
// ============================================

// import 'package:sqflite/sqflite.dart';
// import 'database_service.dart';

class SeedService {
  // final DatabaseService _dbService = DatabaseService();

  Future<void> seedInitialData() async {
    // DISABLED FOR WEB TESTING
    print('⚠️ SeedService is disabled - Using hardcoded auth');
    
    // Uncomment below when migrating to mobile (Android/iOS)
    /*
    try {
      final db = await _dbService.database;
      
      // Check if users table exists and has data
      try {
        final List<Map<String, dynamic>> userCount = await db.rawQuery('SELECT COUNT(*) as count FROM users');
        final int count = Sqflite.firstIntValue(userCount) ?? 0;
        
        if (count == 0) {
          print('🌱 Seeding initial data...');
          
          // OPERATORS
          await db.insert('users', {
            'username': 'opr001',
            'name': 'Budi Santoso',
            'email': 'budi@company.com',
            'password': 'password123',
            'role': 'operator',
            'unit_code': 'EXC-01',
            'employee_id': 'OPR-001',
            'is_active': 1,
          });
          
          await db.insert('users', {
            'username': 'opr002',
            'name': 'Samsul',
            'email': 'samsul@company.com',
            'password': 'password123',
            'role': 'operator',
            'unit_code': 'HD-465-01',
            'employee_id': 'OPR-002',
            'is_active': 1,
          });
          
          // FUELMAN
          await db.insert('users', {
            'username': 'fml001',
            'name': 'Ahmad Fauzi',
            'email': 'ahmad@company.com',
            'password': 'password123',
            'role': 'fuelman',
            'unit_code': null,
            'employee_id': 'FML-001',
            'is_active': 1,
          });
          
          await db.insert('users', {
            'username': 'fml002',
            'name': 'Rudi Hartono',
            'email': 'rudi@company.com',
            'password': 'password123',
            'role': 'fuelman',
            'unit_code': null,
            'employee_id': 'FML-002',
            'is_active': 1,
          });
          
          // SUPERVISOR
          await db.insert('users', {
            'username': 'spv001',
            'name': 'Supervisor Site',
            'email': 'supervisor@company.com',
            'password': 'password123',
            'role': 'supervisor',
            'unit_code': null,
            'employee_id': 'SPV-001',
            'is_active': 1,
          });
          
          // ADMIN
          await db.insert('users', {
            'username': 'admin',
            'name': 'System Administrator',
            'email': 'admin@company.com',
            'password': 'admin123',
            'role': 'admin',
            'unit_code': null,
            'employee_id': 'ADMIN-001',
            'is_active': 1,
          });
          
          print('✅ Users seeded successfully');
        } else {
          print('✅ Users already exist, skipping seed');
        }
        
        // Check units
        final List<Map<String, dynamic>> unitCount = await db.rawQuery('SELECT COUNT(*) as count FROM units');
        final int unitCountValue = Sqflite.firstIntValue(unitCount) ?? 0;
        
        if (unitCountValue == 0) {
          await db.insert('units', {
            'unit_code': 'EXC-01',
            'unit_name': 'Komatsu PC2000',
            'type': 'Excavator',
            'category': 'Alat Berat',
            'qr_code': 'EXC-01',
            'is_active': 1,
          });
          
          await db.insert('units', {
            'unit_code': 'EXC-02',
            'unit_name': 'Hitachi EX1200',
            'type': 'Excavator',
            'category': 'Alat Berat',
            'qr_code': 'EXC-02',
            'is_active': 1,
          });
          
          await db.insert('units', {
            'unit_code': 'HD-465-01',
            'unit_name': 'Komatsu HD465',
            'type': 'Dump Truck',
            'category': 'Alat Berat',
            'qr_code': 'HD-465-01',
            'is_active': 1,
          });
          
          await db.insert('units', {
            'unit_code': 'HD-465-02',
            'unit_name': 'Komatsu HD465',
            'type': 'Dump Truck',
            'category': 'Alat Berat',
            'qr_code': 'HD-465-02',
            'is_active': 1,
          });
          
          await db.insert('units', {
            'unit_code': 'SKT-105-01',
            'unit_name': 'SANY SKT105S',
            'type': 'Dump Truck',
            'category': 'Alat Berat',
            'qr_code': 'SKT-105-01',
            'is_active': 1,
          });
          
          await db.insert('units', {
            'unit_code': 'SKT-105-02',
            'unit_name': 'SANY SKT105S',
            'type': 'Dump Truck',
            'category': 'Alat Berat',
            'qr_code': 'SKT-105-02',
            'is_active': 1,
          });
          
          print('✅ Units seeded successfully');
        }
        
      } catch (e) {
        print('⚠️ Error checking data: $e');
      }
      
    } catch (e) {
      print('❌ Error seeding data: $e');
    }
    */
  }
}