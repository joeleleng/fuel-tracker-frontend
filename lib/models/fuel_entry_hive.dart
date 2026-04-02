import 'package:hive/hive.dart';

part 'fuel_entry_hive.g.dart';

@HiveType(typeId: 0)
class FuelEntryHive {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String unitCode;
  
  @HiveField(2)
  String operatorId;
  
  @HiveField(3)
  String operatorName;
  
  @HiveField(4)
  double hourMeter;
  
  @HiveField(5)
  String fuelLevelBefore;
  
  @HiveField(6)
  String fuelLevelAfter;
  
  @HiveField(7)
  double estimatedLiter;
  
  @HiveField(8)
  String photoBeforePath;
  
  @HiveField(9)
  String photoAfterPath;
  
  @HiveField(10)
  double latitude;
  
  @HiveField(11)
  double longitude;
  
  @HiveField(12)
  String locationAddress;
  
  @HiveField(13)
  DateTime timestamp;
  
  @HiveField(14)
  String shift;
  
  @HiveField(15)
  String status;
  
  @HiveField(16)
  double? fuelmanLiter;
  
  @HiveField(17)
  String? fuelmanId;
  
  @HiveField(18)
  String? fuelmanName;
  
  @HiveField(19)
  String? totalizerBefore;
  
  @HiveField(20)
  String? totalizerAfter;
  
  @HiveField(21)
  String? photoTotalizerPath;
  
  // ============================================
  // CATATAN SUPERVISOR (Single note - kompatibilitas)
  // ============================================
  @HiveField(22)
  String? supervisorNote;
  
  // ============================================
  // SYNC INFORMATION
  // ============================================
  
  @HiveField(23)
  DateTime? syncTime;
  
  @HiveField(24)
  bool isSynced;
  
  // ============================================
  // CATATAN TERPISAH (Baru)
  // ============================================
  
  @HiveField(25)
  String? internalNote;        // Hanya Supervisor & Admin
  
  @HiveField(26)
  String? operatorNote;        // Untuk Operator
  
  @HiveField(27)
  String? fuelmanNote;         // Untuk Fuelman
  
  @HiveField(28)
  bool operatorNoteRead;       // Operator sudah baca?
  
  @HiveField(29)
  bool fuelmanNoteRead;        // Fuelman sudah baca?
  
  @HiveField(30)
  DateTime? noteCreatedAt;     // Waktu catatan dibuat
  
  // ============================================
  // APPROVAL INFORMATION
  // ============================================
  
  @HiveField(31)
  String? approvedBy;          // Supervisor yang approve
  
  @HiveField(32)
  DateTime? approvedAt;        // Waktu approval
  
  @HiveField(33)
  String? approvedChoice;      // operator / fuelman / reject
  
  // ============================================
  // 🆕 AUTO-DETECT FIELDS (Manipulation & Gap Detection)
  // ============================================
  
  @HiveField(34)
  bool isManipulationFlag;           // Apakah data ini terindikasi manipulasi?
  
  @HiveField(35)
  String? manipulationType;          // HM_MANIPULATION, TOTALIZER_MANIPULATION, etc
  
  @HiveField(36)
  String? manipulationReason;        // Alasan deteksi manipulasi
  
  @HiveField(37)
  double? estimatedLoss;              // Estimasi kerugian (Rp)
  
  @HiveField(38)
  bool isGapDetected;                 // Apakah ada gap?
  
  @HiveField(39)
  double? gapValue;                   // Nilai gap (jam atau liter)
  
  @HiveField(40)
  bool isDuplicateFueling;            // Apakah pengisian berulang?
  
  @HiveField(41)
  int? duplicateCount;                // Jumlah pengisian dalam shift
  
  @HiveField(42)
  String? detectionSeverity;          // normal, medium, high, critical

  FuelEntryHive({
    required this.id,
    required this.unitCode,
    required this.operatorId,
    required this.operatorName,
    required this.hourMeter,
    required this.fuelLevelBefore,
    required this.fuelLevelAfter,
    required this.estimatedLiter,
    required this.photoBeforePath,
    required this.photoAfterPath,
    required this.latitude,
    required this.longitude,
    required this.locationAddress,
    required this.timestamp,
    required this.shift,
    this.status = 'pending',
    this.fuelmanLiter,
    this.fuelmanId,
    this.fuelmanName,
    this.totalizerBefore,
    this.totalizerAfter,
    this.photoTotalizerPath,
    this.supervisorNote,
    this.syncTime,
    this.isSynced = false,
    this.internalNote,
    this.operatorNote,
    this.fuelmanNote,
    this.operatorNoteRead = false,
    this.fuelmanNoteRead = false,
    this.noteCreatedAt,
    this.approvedBy,
    this.approvedAt,
    this.approvedChoice,
    // Default values untuk auto-detect
    this.isManipulationFlag = false,
    this.manipulationType,
    this.manipulationReason,
    this.estimatedLoss,
    this.isGapDetected = false,
    this.gapValue,
    this.isDuplicateFueling = false,
    this.duplicateCount,
    this.detectionSeverity = 'normal',
  });
}