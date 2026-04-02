import 'package:hive/hive.dart';
import '../models/fuel_entry_hive.dart';

class HiveDatabaseService {
  static const String fuelEntriesBox = 'fuel_entries';
  
  Future<Box<FuelEntryHive>> _getBox() async {
    return await Hive.openBox<FuelEntryHive>(fuelEntriesBox);
  }

  // ============================================
  // BASIC CRUD METHODS
  // ============================================
  
  // Save fuel entry
  Future<void> saveFuelEntry(FuelEntryHive entry) async {
    final box = await _getBox();
    await box.put(entry.id, entry);
    print('✅ Fuel entry saved to Hive: ${entry.id}');
  }

  // Get all fuel entries
  Future<List<FuelEntryHive>> getAllEntries() async {
    final box = await _getBox();
    return box.values.toList();
  }

  // Get entries by unit
  Future<List<FuelEntryHive>> getEntriesByUnit(String unitCode) async {
    final box = await _getBox();
    return box.values
        .where((entry) => entry.unitCode == unitCode)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get pending entries (not synced and not yet verified by fuelman)
  Future<List<FuelEntryHive>> getPendingEntries() async {
    final box = await _getBox();
    return box.values
        .where((entry) => entry.status == 'pending' && entry.fuelmanId == null)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Update entry
  Future<void> updateEntry(FuelEntryHive entry) async {
    final box = await _getBox();
    await box.put(entry.id, entry);
    print('📝 Fuel entry updated: ${entry.id}');
  }

  // Delete all data (for testing)
  Future<void> deleteAll() async {
    final box = await _getBox();
    await box.clear();
    print('🗑️ All data deleted from Hive');
  }

  // ============================================
  // 🆕 AUTO-DETECT METHODS
  // ============================================
  
  /// Mendapatkan entries per unit dan shift (untuk deteksi pengisian berulang)
  Future<List<FuelEntryHive>> getEntriesByUnitAndShift(
    String unitCode,
    String shift,
    DateTime currentTime,
  ) async {
    final box = await _getBox();
    final startOfShift = _getShiftStartTime(currentTime, shift);
    final endOfShift = _getShiftEndTime(currentTime, shift);
    
    return box.values
        .where((entry) => 
            entry.unitCode == unitCode &&
            entry.shift == shift &&
            entry.timestamp.isAfter(startOfShift) &&
            entry.timestamp.isBefore(endOfShift))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  
  DateTime _getShiftStartTime(DateTime currentTime, String shift) {
    if (shift == 'PAGI') {
      return DateTime(currentTime.year, currentTime.month, currentTime.day, 6, 0);
    } else {
      return DateTime(currentTime.year, currentTime.month, currentTime.day, 18, 0);
    }
  }
  
  DateTime _getShiftEndTime(DateTime currentTime, String shift) {
    if (shift == 'PAGI') {
      return DateTime(currentTime.year, currentTime.month, currentTime.day, 18, 0);
    } else {
      return DateTime(currentTime.year, currentTime.month, currentTime.day + 1, 6, 0);
    }
  }
  
  /// Mendapatkan entry terakhir untuk unit (untuk tracking HM)
  Future<FuelEntryHive?> getLastEntryByUnit(String unitCode) async {
    final box = await _getBox();
    final entries = box.values
        .where((entry) => entry.unitCode == unitCode)
        .toList();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries.isEmpty ? null : entries.first;
  }
  
  /// Mendapatkan entry terakhir untuk tanker (untuk tracking totalizer)
  Future<FuelEntryHive?> getLastEntryByTanker(String tankerCode) async {
    final box = await _getBox();
    final entries = box.values
        .where((entry) => entry.unitCode == tankerCode && entry.totalizerAfter != null)
        .toList();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries.isEmpty ? null : entries.first;
  }
  
  /// Mendapatkan entries dengan flag manipulasi
  Future<List<FuelEntryHive>> getManipulationAlerts() async {
    final box = await _getBox();
    return box.values
        .where((entry) => entry.isManipulationFlag == true)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  /// Mendapatkan entries dengan gap terdeteksi
  Future<List<FuelEntryHive>> getGapAlerts() async {
    final box = await _getBox();
    return box.values
        .where((entry) => entry.isGapDetected == true)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  /// Mendapatkan entries dengan pengisian berulang
  Future<List<FuelEntryHive>> getDuplicateFuelingAlerts() async {
    final box = await _getBox();
    return box.values
        .where((entry) => entry.isDuplicateFueling == true)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  /// Mendapatkan total estimasi kerugian dari semua alert
  Future<double> getTotalEstimatedLoss() async {
    final box = await _getBox();
    double totalLoss = 0;
    for (var entry in box.values) {
      if (entry.estimatedLoss != null) {
        totalLoss += entry.estimatedLoss!;
      }
    }
    return totalLoss;
  }

  // ============================================
  // SUPERVISOR APPROVAL METHODS (Dengan 3 Catatan)
  // ============================================
  
  /// Mendapatkan semua transaksi yang menunggu approval supervisor
  Future<List<FuelEntryHive>> getPendingApprovals() async {
    final box = await _getBox();
    return box.values
        .where((entry) => entry.status == 'pending_approval')
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  /// Mendapatkan jumlah pending approval
  Future<int> getPendingApprovalCount() async {
    final box = await _getBox();
    return box.values.where((entry) => entry.status == 'pending_approval').length;
  }
  
  /// Menyetujui transaksi dengan 3 jenis catatan
  Future<void> approveEntryWithNotes({
    required String entryId,
    required String approvedBy,
    required String choice, // 'operator' or 'fuelman'
    String? internalNote,
    String? operatorNote,
    String? fuelmanNote,
  }) async {
    final box = await _getBox();
    final entry = box.get(entryId);
    
    if (entry != null) {
      entry.status = 'approved';
      entry.approvedBy = approvedBy;
      entry.approvedAt = DateTime.now();
      entry.approvedChoice = choice;
      entry.noteCreatedAt = DateTime.now();
      
      // Simpan catatan terpisah
      if (internalNote != null && internalNote.isNotEmpty) {
        entry.internalNote = internalNote;
      }
      if (operatorNote != null && operatorNote.isNotEmpty) {
        entry.operatorNote = operatorNote;
        entry.operatorNoteRead = false;
      }
      if (fuelmanNote != null && fuelmanNote.isNotEmpty) {
        entry.fuelmanNote = fuelmanNote;
        entry.fuelmanNoteRead = false;
      }
      
      entry.syncTime = DateTime.now();
      
      await box.put(entryId, entry);
      print('✅ Entry $entryId approved by $approvedBy, choice: $choice');
    } else {
      print('❌ Entry $entryId not found');
    }
  }
  
  /// Menolak transaksi dengan catatan
  Future<void> rejectEntryWithNotes({
    required String entryId,
    required String rejectedBy,
    required String reason,
    String? internalNote,
    String? operatorNote,
    String? fuelmanNote,
  }) async {
    final box = await _getBox();
    final entry = box.get(entryId);
    
    if (entry != null) {
      entry.status = 'rejected';
      entry.approvedBy = rejectedBy;
      entry.approvedAt = DateTime.now();
      entry.approvedChoice = 'reject';
      entry.noteCreatedAt = DateTime.now();
      
      // Simpan catatan
      if (internalNote != null && internalNote.isNotEmpty) {
        entry.internalNote = internalNote;
      } else {
        entry.internalNote = reason;
      }
      
      if (operatorNote != null && operatorNote.isNotEmpty) {
        entry.operatorNote = operatorNote;
        entry.operatorNoteRead = false;
      }
      if (fuelmanNote != null && fuelmanNote.isNotEmpty) {
        entry.fuelmanNote = fuelmanNote;
        entry.fuelmanNoteRead = false;
      }
      
      entry.syncTime = DateTime.now();
      
      await box.put(entryId, entry);
      print('❌ Entry $entryId rejected by $rejectedBy, reason: $reason');
    } else {
      print('❌ Entry $entryId not found');
    }
  }
  
  // ============================================
  // NOTIFICATION METHODS
  // ============================================
  
  /// Mendapatkan notifikasi untuk operator (belum dibaca)
  Future<List<FuelEntryHive>> getOperatorNotifications(String operatorId) async {
    final box = await _getBox();
    return box.values
        .where((entry) => 
            entry.operatorId == operatorId &&
            entry.operatorNote != null &&
            entry.operatorNote!.isNotEmpty &&
            !entry.operatorNoteRead)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  /// Mendapatkan jumlah notifikasi operator yang belum dibaca
  Future<int> getOperatorNotificationCount(String operatorId) async {
    final box = await _getBox();
    return box.values
        .where((entry) => 
            entry.operatorId == operatorId &&
            entry.operatorNote != null &&
            entry.operatorNote!.isNotEmpty &&
            !entry.operatorNoteRead)
        .length;
  }
  
  /// Mendapatkan notifikasi untuk fuelman (belum dibaca)
  Future<List<FuelEntryHive>> getFuelmanNotifications(String fuelmanId) async {
    final box = await _getBox();
    return box.values
        .where((entry) => 
            entry.fuelmanId == fuelmanId &&
            entry.fuelmanNote != null &&
            entry.fuelmanNote!.isNotEmpty &&
            !entry.fuelmanNoteRead)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  /// Mendapatkan jumlah notifikasi fuelman yang belum dibaca
  Future<int> getFuelmanNotificationCount(String fuelmanId) async {
    final box = await _getBox();
    return box.values
        .where((entry) => 
            entry.fuelmanId == fuelmanId &&
            entry.fuelmanNote != null &&
            entry.fuelmanNote!.isNotEmpty &&
            !entry.fuelmanNoteRead)
        .length;
  }
  
  /// Menandai notifikasi operator sudah dibaca
  Future<void> markOperatorNoteAsRead(String entryId) async {
    final box = await _getBox();
    final entry = box.get(entryId);
    if (entry != null) {
      entry.operatorNoteRead = true;
      await box.put(entryId, entry);
      print('✅ Operator note marked as read for entry $entryId');
    }
  }
  
  /// Menandai notifikasi fuelman sudah dibaca
  Future<void> markFuelmanNoteAsRead(String entryId) async {
    final box = await _getBox();
    final entry = box.get(entryId);
    if (entry != null) {
      entry.fuelmanNoteRead = true;
      await box.put(entryId, entry);
      print('✅ Fuelman note marked as read for entry $entryId');
    }
  }
  
  // ============================================
  // ADMIN MONITORING METHODS
  // ============================================

  /// Mendapatkan statistik notifikasi untuk admin
  Future<Map<String, dynamic>> getNotificationStatistics() async {
    final box = await _getBox();
    
    int totalOperatorNotes = 0;
    int readOperatorNotes = 0;
    int totalFuelmanNotes = 0;
    int readFuelmanNotes = 0;
    
    for (var entry in box.values) {
      if (entry.operatorNote != null && entry.operatorNote!.isNotEmpty) {
        totalOperatorNotes++;
        if (entry.operatorNoteRead) readOperatorNotes++;
      }
      if (entry.fuelmanNote != null && entry.fuelmanNote!.isNotEmpty) {
        totalFuelmanNotes++;
        if (entry.fuelmanNoteRead) readFuelmanNotes++;
      }
    }
    
    return {
      'total_operator_notes': totalOperatorNotes,
      'read_operator_notes': readOperatorNotes,
      'unread_operator_notes': totalOperatorNotes - readOperatorNotes,
      'total_fuelman_notes': totalFuelmanNotes,
      'read_fuelman_notes': readFuelmanNotes,
      'unread_fuelman_notes': totalFuelmanNotes - readFuelmanNotes,
    };
  }

  /// Mendapatkan semua notifikasi dengan status baca (untuk admin)
  Future<List<Map<String, dynamic>>> getAllNotificationsWithStatus() async {
    final box = await _getBox();
    final List<Map<String, dynamic>> notifications = [];
    
    for (var entry in box.values) {
      if (entry.operatorNote != null && entry.operatorNote!.isNotEmpty) {
        notifications.add({
          'type': 'operator',
          'recipient': entry.operatorName,
          'recipientId': entry.operatorId,
          'unitCode': entry.unitCode,
          'note': entry.operatorNote,
          'isRead': entry.operatorNoteRead,
          'createdAt': entry.noteCreatedAt ?? entry.timestamp,
          'approvedBy': entry.approvedBy,
          'entryId': entry.id,
        });
      }
      
      if (entry.fuelmanNote != null && entry.fuelmanNote!.isNotEmpty) {
        notifications.add({
          'type': 'fuelman',
          'recipient': entry.fuelmanName ?? '-',
          'recipientId': entry.fuelmanId ?? '-',
          'unitCode': entry.unitCode,
          'note': entry.fuelmanNote,
          'isRead': entry.fuelmanNoteRead,
          'createdAt': entry.noteCreatedAt ?? entry.timestamp,
          'approvedBy': entry.approvedBy,
          'entryId': entry.id,
        });
      }
    }
    
    // Urutkan berdasarkan tanggal terbaru
    notifications.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
    return notifications;
  }
  
  // ============================================
  // LEGACY METHODS (Untuk kompatibilitas)
  // ============================================
  
  /// Legacy approve method (masih dipertahankan untuk kompatibilitas)
  Future<void> approveEntry({
    required String entryId,
    required String approvedBy,
    required String choice,
    String? note,
  }) async {
    await approveEntryWithNotes(
      entryId: entryId,
      approvedBy: approvedBy,
      choice: choice,
      internalNote: note,
    );
  }
  
  /// Legacy reject method (masih dipertahankan untuk kompatibilitas)
  Future<void> rejectEntry({
    required String entryId,
    required String rejectedBy,
    required String reason,
  }) async {
    await rejectEntryWithNotes(
      entryId: entryId,
      rejectedBy: rejectedBy,
      reason: reason,
      internalNote: reason,
    );
  }
  
  // ============================================
  // HISTORY & STATISTICS METHODS
  // ============================================
  
  /// Mendapatkan history approval (untuk audit)
  Future<List<FuelEntryHive>> getApprovalHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? unitCode,
  }) async {
    final box = await _getBox();
    var entries = box.values
        .where((entry) => 
            entry.status == 'approved' || 
            entry.status == 'rejected' ||
            entry.status == 'auto_approved')
        .toList();
    
    if (startDate != null) {
      entries = entries.where((e) => e.timestamp.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      entries = entries.where((e) => e.timestamp.isBefore(endDate)).toList();
    }
    if (unitCode != null) {
      entries = entries.where((e) => e.unitCode == unitCode).toList();
    }
    
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }
  
  /// Mendapatkan transaksi berdasarkan ID
  Future<FuelEntryHive?> getEntryById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }
  
  /// Mendapatkan transaksi dengan variance > toleransi (pending approval)
  Future<List<FuelEntryHive>> getEntriesWithHighVariance(double threshold) async {
    final box = await _getBox();
    return box.values
        .where((entry) => 
            entry.fuelmanLiter != null && 
            entry.estimatedLiter > 0 &&
            ((entry.estimatedLiter - entry.fuelmanLiter!).abs() / entry.estimatedLiter * 100) > threshold)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  /// Mendapatkan statistik variance untuk dashboard supervisor
  Future<Map<String, dynamic>> getVarianceStatistics() async {
    final box = await _getBox();
    final entries = box.values.toList();
    
    int totalEntries = entries.length;
    int pendingCount = entries.where((e) => e.status == 'pending_approval').length;
    int autoApprovedCount = entries.where((e) => e.status == 'auto_approved').length;
    int approvedCount = entries.where((e) => e.status == 'approved').length;
    int rejectedCount = entries.where((e) => e.status == 'rejected').length;
    
    // Hitung rata-rata variance untuk entries yang sudah diverifikasi
    double totalVariance = 0;
    int verifiedCount = 0;
    
    for (var entry in entries) {
      if (entry.fuelmanLiter != null && entry.estimatedLiter > 0) {
        double variancePercent = (entry.estimatedLiter - entry.fuelmanLiter!).abs() / entry.estimatedLiter * 100;
        totalVariance += variancePercent;
        verifiedCount++;
      }
    }
    
    double averageVariance = verifiedCount > 0 ? totalVariance / verifiedCount : 0;
    
    return {
      'total_entries': totalEntries,
      'pending_approval': pendingCount,
      'auto_approved': autoApprovedCount,
      'approved': approvedCount,
      'rejected': rejectedCount,
      'average_variance_percent': averageVariance,
    };
  }
}