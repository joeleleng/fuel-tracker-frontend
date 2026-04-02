import 'package:hive/hive.dart';
import '../models/fuel_entry_hive.dart';

class TrackingService {
  static const String hmTrackingBox = 'hm_tracking';
  static const String totalizerTrackingBox = 'totalizer_tracking';
  
  // ============================================
  // HM TRACKING
  // ============================================
  
  /// Menyimpan tracking HM terakhir per unit
  Future<void> saveLastHM(String unitCode, double lastHM, String lastEntryId) async {
    final box = await Hive.openBox(hmTrackingBox);
    await box.put(unitCode, {
      'last_hm': lastHM,
      'last_entry_id': lastEntryId,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
  
  /// Mendapatkan HM terakhir untuk unit
  Future<Map<String, dynamic>?> getLastHM(String unitCode) async {
    final box = await Hive.openBox(hmTrackingBox);
    return box.get(unitCode);
  }
  
  // ============================================
  // TOTALIZER TRACKING
  // ============================================
  
  /// Menyimpan tracking totalizer terakhir per tanker
  Future<void> saveLastTotalizer(String tankerCode, double lastTotalizer, String lastEntryId) async {
    final box = await Hive.openBox(totalizerTrackingBox);
    await box.put(tankerCode, {
      'last_totalizer': lastTotalizer,
      'last_entry_id': lastEntryId,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
  
  /// Mendapatkan totalizer terakhir untuk tanker
  Future<Map<String, dynamic>?> getLastTotalizer(String tankerCode) async {
    final box = await Hive.openBox(totalizerTrackingBox);
    return box.get(tankerCode);
  }
}