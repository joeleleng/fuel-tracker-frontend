import 'package:hive/hive.dart';
import '../models/fuel_entry_hive.dart';
import '../services/hive_database_service.dart';
import '../config/branding.dart';  // Tambahkan import ini

class ReportService {
  final HiveDatabaseService _dbService = HiveDatabaseService();
  
  /// Mendapatkan laporan fuel bulanan
  Future<Map<String, dynamic>> getMonthlyFuelReport(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59);
    
    final allEntries = await _dbService.getAllEntries();
    final monthEntries = allEntries.where((e) => 
        e.timestamp.isAfter(startOfMonth) && 
        e.timestamp.isBefore(endOfMonth)).toList();
    
    // Total fuel masuk (dari supplier - akan diimplementasikan nanti)
    double totalFuelIn = 0; // TODO: Ambil dari tabel supplier deliveries
    
    // Total fuel ke alat
    double totalFuelToEquipment = monthEntries
        .where((e) => e.status == 'approved' || e.status == 'auto_approved')
        .fold(0, (sum, e) => sum + e.estimatedLiter);
    
    // Total fuel terpakai berdasarkan HM
    double totalFuelConsumed = monthEntries
        .where((e) => e.status == 'approved' || e.status == 'auto_approved')
        .fold(0, (sum, e) => sum + e.estimatedLiter);
    
    // Total variance
    double totalVariance = 0;
    int varianceCount = 0;
    for (var entry in monthEntries) {
      if (entry.fuelmanLiter != null) {
        double variance = (entry.estimatedLiter - entry.fuelmanLiter!).abs();
        totalVariance += variance;
        varianceCount++;
      }
    }
    
    // Estimasi kerugian
    double totalEstimatedLoss = monthEntries
        .where((e) => e.estimatedLoss != null)
        .fold(0, (sum, e) => sum + (e.estimatedLoss ?? 0));
    
    return {
      'period': {
        'month': month.month,
        'year': month.year,
        'start_date': startOfMonth,
        'end_date': endOfMonth,
      },
      'summary': {
        'total_fuel_in': totalFuelIn,
        'total_fuel_to_equipment': totalFuelToEquipment,
        'total_fuel_consumed': totalFuelConsumed,
        'total_variance': totalVariance,
        'average_variance_percent': varianceCount > 0 
            ? (totalVariance / totalFuelConsumed * 100) 
            : 0,
        'total_estimated_loss': totalEstimatedLoss,
        'total_transactions': monthEntries.length,
      },
      'by_category': await _getReportByCategory(monthEntries),
      'by_operator': await _getReportByOperator(monthEntries),
      'alerts': await _getAlertSummary(monthEntries),
    };
  }
  
  /// Laporan per kategori alat
  Future<List<Map<String, dynamic>>> _getReportByCategory(List<FuelEntryHive> entries) async {
    final Map<String, Map<String, dynamic>> categoryStats = {};
    
    for (var entry in entries) {
      // TODO: Ambil kategori dari unit
      String category = 'Alat Berat'; // Default
      
      if (!categoryStats.containsKey(category)) {
        categoryStats[category] = {
          'total_fuel': 0.0,
          'total_transactions': 0,
          'total_variance': 0.0,
          'total_loss': 0.0,
        };
      }
      
      categoryStats[category]!['total_fuel'] += entry.estimatedLiter;
      categoryStats[category]!['total_transactions']++;
      
      if (entry.fuelmanLiter != null) {
        double variance = (entry.estimatedLiter - entry.fuelmanLiter!).abs();
        categoryStats[category]!['total_variance'] += variance;
      }
      
      if (entry.estimatedLoss != null) {
        categoryStats[category]!['total_loss'] += entry.estimatedLoss!;
      }
    }
    
    return categoryStats.entries.map((e) => {
      'category': e.key,
      'total_fuel': e.value['total_fuel'],
      'total_transactions': e.value['total_transactions'],
      'average_variance': e.value['total_variance'] / e.value['total_transactions'],
      'total_loss': e.value['total_loss'],
    }).toList();
  }
  
  /// Laporan per operator
  Future<List<Map<String, dynamic>>> _getReportByOperator(List<FuelEntryHive> entries) async {
    final Map<String, Map<String, dynamic>> operatorStats = {};
    
    for (var entry in entries) {
      if (!operatorStats.containsKey(entry.operatorId)) {
        operatorStats[entry.operatorId] = {
          'operator_name': entry.operatorName,
          'total_fuel': 0.0,
          'total_hours': 0.0,
          'total_transactions': 0,
          'variance_count': 0,
          'total_loss': 0.0,
          'manipulation_count': 0,
        };
      }
      
      operatorStats[entry.operatorId]!['total_fuel'] += entry.estimatedLiter;
      operatorStats[entry.operatorId]!['total_hours'] += entry.hourMeter;
      operatorStats[entry.operatorId]!['total_transactions']++;
      
      if (entry.fuelmanLiter != null) {
        double variance = (entry.estimatedLiter - entry.fuelmanLiter!).abs();
        if (variance / entry.estimatedLiter * 100 > Branding.varianceThreshold) {
          operatorStats[entry.operatorId]!['variance_count']++;
        }
      }
      
      if (entry.estimatedLoss != null) {
        operatorStats[entry.operatorId]!['total_loss'] += entry.estimatedLoss!;
      }
      
      if (entry.isManipulationFlag) {
        operatorStats[entry.operatorId]!['manipulation_count']++;
      }
    }
    
    // Hitung efisiensi dan ranking
    var operators = operatorStats.entries.map((e) => {
      'operator_id': e.key,
      'operator_name': e.value['operator_name'],
      'total_fuel': e.value['total_fuel'],
      'total_hours': e.value['total_hours'],
      'fuel_per_hour': e.value['total_hours'] > 0 
          ? e.value['total_fuel'] / e.value['total_hours'] 
          : 0,
      'total_transactions': e.value['total_transactions'],
      'variance_count': e.value['variance_count'],
      'variance_rate': e.value['total_transactions'] > 0
          ? (e.value['variance_count'] / e.value['total_transactions'] * 100)
          : 0,
      'total_loss': e.value['total_loss'],
      'manipulation_count': e.value['manipulation_count'],
    }).toList();
    
    // Urutkan berdasarkan efisiensi (fuel_per_hour terendah = paling hemat)
    operators.sort((a, b) => a['fuel_per_hour'].compareTo(b['fuel_per_hour']));
    
    // Tambahkan ranking
    for (int i = 0; i < operators.length; i++) {
      operators[i]['rank'] = i + 1;
      operators[i]['efficiency_status'] = _getEfficiencyStatus(operators[i]['fuel_per_hour']);
    }
    
    return operators;
  }
  
  /// Ringkasan alert
  Future<Map<String, dynamic>> _getAlertSummary(List<FuelEntryHive> entries) async {
    return {
      'total_flagged': entries.where((e) => e.status == 'flagged_for_review').length,
      'manipulation': entries.where((e) => e.isManipulationFlag).length,
      'gap_detected': entries.where((e) => e.isGapDetected).length,
      'duplicate_fueling': entries.where((e) => e.isDuplicateFueling).length,
    };
  }
  
  String _getEfficiencyStatus(double fuelPerHour) {
    if (fuelPerHour <= 22) return 'HEMAT';
    if (fuelPerHour <= 28) return 'NORMAL';
    if (fuelPerHour <= 35) return 'BOROS';
    return 'SANGAT BOROS';
  }
}