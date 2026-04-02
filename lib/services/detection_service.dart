import 'package:flutter/material.dart';
import '../models/fuel_entry_hive.dart';
import '../services/tracking_service.dart';
import '../services/hive_database_service.dart';

class DetectionService {
  final TrackingService _trackingService = TrackingService();
  final HiveDatabaseService _dbService = HiveDatabaseService();
  
  // Konstanta parameter
  static const double MAX_HM_PER_SHIFT = 12.0;        // Maksimal 12 jam per shift
  static const double MAX_TOTALIZER_GAP = 100.0;       // Gap >100L mencurigakan
  static const double FUEL_PRICE_PER_LITER = 15000.0;  // Rp 15.000/Liter
  
  /// Deteksi manipulasi HM
  Future<Map<String, dynamic>?> detectHMManipulation(
    String unitCode,
    double newHM,
    String currentEntryId,
  ) async {
    final lastData = await _trackingService.getLastHM(unitCode);
    
    if (lastData != null) {
      final lastHM = lastData['last_hm'] as double;
      
      // Deteksi: HM baru lebih kecil dari HM sebelumnya
      if (newHM < lastHM) {
        final loss = (lastHM - newHM) * 22; // Asumsi 22 L/jam
        final estimatedLossRp = loss * FUEL_PRICE_PER_LITER;
        
        return {
          'isManipulation': true,
          'type': 'HM_MANIPULATION',
          'reason': 'HM baru ($newHM jam) lebih rendah dari HM sebelumnya ($lastHM jam)',
          'gap': lastHM - newHM,
          'estimatedLoss': estimatedLossRp,
          'severity': 'high',
        };
      }
    }
    
    return null;
  }
  
  /// Deteksi gap HM (data hilang)
  Future<Map<String, dynamic>?> detectHMGap(
    String unitCode,
    double newHM,
    String currentEntryId,
  ) async {
    final lastData = await _trackingService.getLastHM(unitCode);
    
    if (lastData != null) {
      final lastHM = lastData['last_hm'] as double;
      final gap = newHM - lastHM;
      
      // Deteksi: gap > 12 jam (indikasi data hilang)
      if (gap > MAX_HM_PER_SHIFT) {
        final loss = gap * 22; // Asumsi 22 L/jam
        final estimatedLossRp = loss * FUEL_PRICE_PER_LITER;
        
        return {
          'isGap': true,
          'type': 'HM_GAP',
          'reason': 'Terdapat gap ${gap.toStringAsFixed(1)} jam dari HM sebelumnya ($lastHM jam)',
          'gapValue': gap,
          'estimatedLoss': estimatedLossRp,
          'severity': gap > 12 ? 'high' : 'medium',
        };
      }
    }
    
    return null;
  }
  
  /// Deteksi pengisian berulang dalam 1 shift
  Future<Map<String, dynamic>?> detectDuplicateFueling(
    String unitCode,
    String shift,
    DateTime fuelingTime,
    double newHM,
  ) async {
    // Ambil semua pengisian di shift yang sama
    final shiftEntries = await _dbService.getEntriesByUnitAndShift(
      unitCode,
      shift,
      fuelingTime,
    );
    
    if (shiftEntries.isNotEmpty) {
      final duplicateCount = shiftEntries.length + 1;
      double totalHM = 0;
      
      for (var entry in shiftEntries) {
        totalHM += entry.hourMeter;
      }
      totalHM += newHM;
      
      // Deteksi: total HM > 12 jam
      if (totalHM > MAX_HM_PER_SHIFT) {
        return {
          'isDuplicate': true,
          'type': 'HM_INCONSISTENT',
          'reason': 'Total HM dalam shift $shift: ${totalHM.toStringAsFixed(1)} jam '
                   'melebihi durasi shift (12 jam)',
          'duplicateCount': duplicateCount,
          'totalHM': totalHM,
          'severity': 'high',
        };
      }
      
      // Deteksi: pengisian berulang (tanpa batasan HM)
      if (duplicateCount >= 2) {
        return {
          'isDuplicate': true,
          'type': 'DUPLICATE_FUELING',
          'reason': 'Pengisian fuel ke-$duplicateCount dalam shift $shift untuk unit $unitCode',
          'duplicateCount': duplicateCount,
          'severity': 'medium',
        };
      }
    }
    
    return null;
  }
  
  /// Deteksi manipulasi totalizer
  Future<Map<String, dynamic>?> detectTotalizerManipulation(
    String tankerCode,
    double newTotalizer,
    String currentEntryId,
  ) async {
    final lastData = await _trackingService.getLastTotalizer(tankerCode);
    
    if (lastData != null) {
      final lastTotalizer = lastData['last_totalizer'] as double;
      
      // Deteksi: totalizer baru lebih kecil dari sebelumnya
      if (newTotalizer < lastTotalizer) {
        final loss = lastTotalizer - newTotalizer;
        final estimatedLossRp = loss * FUEL_PRICE_PER_LITER;
        
        return {
          'isManipulation': true,
          'type': 'TOTALIZER_MANIPULATION',
          'reason': 'Totalizer baru ($newTotalizer L) lebih rendah dari totalizer sebelumnya ($lastTotalizer L)',
          'gap': lastTotalizer - newTotalizer,
          'estimatedLoss': estimatedLossRp,
          'severity': 'high',
        };
      }
    }
    
    return null;
  }
  
  /// Deteksi gap totalizer (fuel tidak tercatat)
  Future<Map<String, dynamic>?> detectTotalizerGap(
    String tankerCode,
    double newTotalizer,
    String currentEntryId,
  ) async {
    final lastData = await _trackingService.getLastTotalizer(tankerCode);
    
    if (lastData != null) {
      final lastTotalizer = lastData['last_totalizer'] as double;
      final gap = newTotalizer - lastTotalizer;
      
      // Deteksi: gap positif tapi kecil (<100L) - indikasi fuel tidak tercatat
      if (gap > 0 && gap < MAX_TOTALIZER_GAP) {
        final estimatedLossRp = gap * FUEL_PRICE_PER_LITER;
        
        return {
          'isGap': true,
          'type': 'TOTALIZER_GAP',
          'reason': 'Terdapat gap ${gap.toStringAsFixed(0)} L dari totalizer sebelumnya ($lastTotalizer L)',
          'gapValue': gap,
          'estimatedLoss': estimatedLossRp,
          'severity': 'medium',
        };
      }
      
      // Deteksi: gap sangat besar (>1000L)
      if (gap > 1000) {
        final estimatedLossRp = gap * FUEL_PRICE_PER_LITER;
        
        return {
          'isGap': true,
          'type': 'TOTALIZER_LARGE_GAP',
          'reason': 'Totalizer melonjak ${gap.toStringAsFixed(0)} L dari $lastTotalizer L',
          'gapValue': gap,
          'estimatedLoss': estimatedLossRp,
          'severity': 'high',
        };
      }
    }
    
    return null;
  }
  
  /// Run all detections untuk fuel entry
  Future<Map<String, dynamic>> runAllDetections(
    FuelEntryHive entry,
    bool isOperatorEntry,
  ) async {
    Map<String, dynamic> detectionResult = {
      'isManipulationFlag': false,
      'manipulationType': null,
      'manipulationReason': null,
      'estimatedLoss': null,
      'isGapDetected': false,
      'gapValue': null,
      'isDuplicateFueling': false,
      'duplicateCount': null,
      'severity': 'normal',
    };
    
    if (isOperatorEntry) {
      // Deteksi untuk operator
      final hmManipulation = await detectHMManipulation(
        entry.unitCode,
        entry.hourMeter,
        entry.id,
      );
      
      if (hmManipulation != null) {
        detectionResult['isManipulationFlag'] = true;
        detectionResult['manipulationType'] = hmManipulation['type'];
        detectionResult['manipulationReason'] = hmManipulation['reason'];
        detectionResult['estimatedLoss'] = hmManipulation['estimatedLoss'];
        detectionResult['severity'] = hmManipulation['severity'];
      }
      
      final hmGap = await detectHMGap(
        entry.unitCode,
        entry.hourMeter,
        entry.id,
      );
      
      if (hmGap != null) {
        detectionResult['isGapDetected'] = true;
        detectionResult['gapValue'] = hmGap['gapValue'];
        if (detectionResult['estimatedLoss'] == null) {
          detectionResult['estimatedLoss'] = hmGap['estimatedLoss'];
        } else {
          detectionResult['estimatedLoss'] = (detectionResult['estimatedLoss'] + hmGap['estimatedLoss']);
        }
        detectionResult['severity'] = hmGap['severity'];
      }
      
      final duplicate = await detectDuplicateFueling(
        entry.unitCode,
        entry.shift,
        entry.timestamp,
        entry.hourMeter,
      );
      
      if (duplicate != null) {
        detectionResult['isDuplicateFueling'] = true;
        detectionResult['duplicateCount'] = duplicate['duplicateCount'];
        if (duplicate['severity'] == 'high') {
          detectionResult['severity'] = 'high';
        }
      }
    } else {
      // Deteksi untuk fuelman (totalizer)
      if (entry.totalizerAfter != null) {
        final totalizerManipulation = await detectTotalizerManipulation(
          entry.unitCode, // tanker code
          double.parse(entry.totalizerAfter!),
          entry.id,
        );
        
        if (totalizerManipulation != null) {
          detectionResult['isManipulationFlag'] = true;
          detectionResult['manipulationType'] = totalizerManipulation['type'];
          detectionResult['manipulationReason'] = totalizerManipulation['reason'];
          detectionResult['estimatedLoss'] = totalizerManipulation['estimatedLoss'];
          detectionResult['severity'] = totalizerManipulation['severity'];
        }
        
        final totalizerGap = await detectTotalizerGap(
          entry.unitCode,
          double.parse(entry.totalizerAfter!),
          entry.id,
        );
        
        if (totalizerGap != null) {
          detectionResult['isGapDetected'] = true;
          detectionResult['gapValue'] = totalizerGap['gapValue'];
          if (detectionResult['estimatedLoss'] == null) {
            detectionResult['estimatedLoss'] = totalizerGap['estimatedLoss'];
          } else {
            detectionResult['estimatedLoss'] = (detectionResult['estimatedLoss'] + totalizerGap['estimatedLoss']);
          }
          if (totalizerGap['severity'] == 'high') {
            detectionResult['severity'] = 'high';
          }
        }
      }
    }
    
    return detectionResult;
  }
}