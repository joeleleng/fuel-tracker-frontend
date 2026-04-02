import 'package:flutter/material.dart';
import '../models/fuel_entry_hive.dart';
import '../services/hive_database_service.dart';

class SupervisorNotificationService {
  final HiveDatabaseService _dbService = HiveDatabaseService();
  
  /// Kirim notifikasi ke supervisor tentang flagged entry
  Future<void> notifySupervisorAboutFlaggedEntry(FuelEntryHive entry) async {
    // Simpan notifikasi ke database (akan ditampilkan di dashboard supervisor)
    // Untuk sekarang, kita hanya print ke console
    print('🔔 NOTIFIKASI SUPERVISOR:');
    print('   Unit: ${entry.unitCode}');
    print('   Operator: ${entry.operatorName}');
    print('   Type: ${entry.manipulationType ?? "Flagged Entry"}');
    print('   Reason: ${entry.manipulationReason ?? "Perlu review"}');
    if (entry.estimatedLoss != null) {
      print('   Estimated Loss: Rp ${entry.estimatedLoss!.toStringAsFixed(0)}');
    }
    print('   Time: ${entry.timestamp}');
    print('─' * 50);
  }
  
  /// Kirim ringkasan notifikasi harian
  Future<void> sendDailySummary() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59);
    
    final entries = await _dbService.getAllEntries();
    final todayEntries = entries.where((e) => 
        e.timestamp.isAfter(startOfDay) && e.timestamp.isBefore(endOfDay)).toList();
    
    final flaggedCount = todayEntries.where((e) => e.status == 'flagged_for_review').length;
    final manipulationCount = todayEntries.where((e) => e.isManipulationFlag).length;
    final gapCount = todayEntries.where((e) => e.isGapDetected).length;
    
    double totalEstimatedLoss = 0;
    for (var entry in todayEntries) {
      if (entry.estimatedLoss != null) {
        totalEstimatedLoss += entry.estimatedLoss!;
      }
    }
    
    print('📊 RINGKASAN HARIAN SUPERVISOR:');
    print('   Tanggal: ${today.day}/${today.month}/${today.year}');
    print('   Total Transaksi: ${todayEntries.length}');
    print('   Flagged Review: $flaggedCount');
    print('   Manipulasi: $manipulationCount');
    print('   Gap Data: $gapCount');
    print('   Estimasi Kerugian: Rp ${totalEstimatedLoss.toStringAsFixed(0)}');
    print('─' * 50);
  }
}