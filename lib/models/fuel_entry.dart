import 'dart:convert';

class FuelEntry {
  String? id;
  String unitCode;
  String operatorId;
  String operatorName;
  double hourMeter;
  String fuelLevelBefore;
  String fuelLevelAfter;
  double estimatedLiter;
  String photoBeforePath;
  String photoAfterPath;
  double latitude;
  double longitude;
  String locationAddress;
  DateTime timestamp;
  String shift;
  String status; // pending, auto_approved, approved, rejected
  double? fuelmanLiter;
  String? fuelmanId;
  String? fuelmanName;
  String? totalizerBefore;
  String? totalizerAfter;
  String? photoTotalizerPath;
  String? supervisorNote;
  DateTime? syncTime;
  bool isSynced;

  FuelEntry({
    this.id,
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
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'unit_code': unitCode,
      'operator_id': operatorId,
      'operator_name': operatorName,
      'hour_meter': hourMeter,
      'fuel_level_before': fuelLevelBefore,
      'fuel_level_after': fuelLevelAfter,
      'estimated_liter': estimatedLiter,
      'photo_before_path': photoBeforePath,
      'photo_after_path': photoAfterPath,
      'latitude': latitude,
      'longitude': longitude,
      'location_address': locationAddress,
      'timestamp': timestamp.toIso8601String(),
      'shift': shift,
      'status': status,
      'fuelman_liter': fuelmanLiter,
      'fuelman_id': fuelmanId,
      'fuelman_name': fuelmanName,
      'totalizer_before': totalizerBefore,
      'totalizer_after': totalizerAfter,
      'photo_totalizer_path': photoTotalizerPath,
      'supervisor_note': supervisorNote,
      'sync_time': syncTime?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory FuelEntry.fromMap(Map<String, dynamic> map) {
    return FuelEntry(
      id: map['id'],
      unitCode: map['unit_code'],
      operatorId: map['operator_id'],
      operatorName: map['operator_name'],
      hourMeter: map['hour_meter'].toDouble(),
      fuelLevelBefore: map['fuel_level_before'],
      fuelLevelAfter: map['fuel_level_after'],
      estimatedLiter: map['estimated_liter'].toDouble(),
      photoBeforePath: map['photo_before_path'],
      photoAfterPath: map['photo_after_path'],
      latitude: map['latitude'].toDouble(),
      longitude: map['longitude'].toDouble(),
      locationAddress: map['location_address'],
      timestamp: DateTime.parse(map['timestamp']),
      shift: map['shift'],
      status: map['status'],
      fuelmanLiter: map['fuelman_liter']?.toDouble(),
      fuelmanId: map['fuelman_id'],
      fuelmanName: map['fuelman_name'],
      totalizerBefore: map['totalizer_before'],
      totalizerAfter: map['totalizer_after'],
      photoTotalizerPath: map['photo_totalizer_path'],
      supervisorNote: map['supervisor_note'],
      syncTime: map['sync_time'] != null ? DateTime.parse(map['sync_time']) : null,
      isSynced: map['is_synced'] == 1,
    );
  }

  String toJson() => json.encode(toMap());
  factory FuelEntry.fromJson(String source) => FuelEntry.fromMap(json.decode(source));
}