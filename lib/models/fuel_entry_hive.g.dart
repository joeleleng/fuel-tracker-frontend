// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_entry_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FuelEntryHiveAdapter extends TypeAdapter<FuelEntryHive> {
  @override
  final int typeId = 0;

  @override
  FuelEntryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FuelEntryHive(
      id: fields[0] as String,
      unitCode: fields[1] as String,
      operatorId: fields[2] as String,
      operatorName: fields[3] as String,
      hourMeter: fields[4] as double,
      fuelLevelBefore: fields[5] as String,
      fuelLevelAfter: fields[6] as String,
      estimatedLiter: fields[7] as double,
      photoBeforePath: fields[8] as String,
      photoAfterPath: fields[9] as String,
      latitude: fields[10] as double,
      longitude: fields[11] as double,
      locationAddress: fields[12] as String,
      timestamp: fields[13] as DateTime,
      shift: fields[14] as String,
      status: fields[15] as String,
      fuelmanLiter: fields[16] as double?,
      fuelmanId: fields[17] as String?,
      fuelmanName: fields[18] as String?,
      totalizerBefore: fields[19] as String?,
      totalizerAfter: fields[20] as String?,
      photoTotalizerPath: fields[21] as String?,
      supervisorNote: fields[22] as String?,
      syncTime: fields[23] as DateTime?,
      isSynced: fields[24] as bool,
      internalNote: fields[25] as String?,
      operatorNote: fields[26] as String?,
      fuelmanNote: fields[27] as String?,
      operatorNoteRead: fields[28] as bool,
      fuelmanNoteRead: fields[29] as bool,
      noteCreatedAt: fields[30] as DateTime?,
      approvedBy: fields[31] as String?,
      approvedAt: fields[32] as DateTime?,
      approvedChoice: fields[33] as String?,
      isManipulationFlag: fields[34] as bool,
      manipulationType: fields[35] as String?,
      manipulationReason: fields[36] as String?,
      estimatedLoss: fields[37] as double?,
      isGapDetected: fields[38] as bool,
      gapValue: fields[39] as double?,
      isDuplicateFueling: fields[40] as bool,
      duplicateCount: fields[41] as int?,
      detectionSeverity: fields[42] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FuelEntryHive obj) {
    writer
      ..writeByte(43)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.unitCode)
      ..writeByte(2)
      ..write(obj.operatorId)
      ..writeByte(3)
      ..write(obj.operatorName)
      ..writeByte(4)
      ..write(obj.hourMeter)
      ..writeByte(5)
      ..write(obj.fuelLevelBefore)
      ..writeByte(6)
      ..write(obj.fuelLevelAfter)
      ..writeByte(7)
      ..write(obj.estimatedLiter)
      ..writeByte(8)
      ..write(obj.photoBeforePath)
      ..writeByte(9)
      ..write(obj.photoAfterPath)
      ..writeByte(10)
      ..write(obj.latitude)
      ..writeByte(11)
      ..write(obj.longitude)
      ..writeByte(12)
      ..write(obj.locationAddress)
      ..writeByte(13)
      ..write(obj.timestamp)
      ..writeByte(14)
      ..write(obj.shift)
      ..writeByte(15)
      ..write(obj.status)
      ..writeByte(16)
      ..write(obj.fuelmanLiter)
      ..writeByte(17)
      ..write(obj.fuelmanId)
      ..writeByte(18)
      ..write(obj.fuelmanName)
      ..writeByte(19)
      ..write(obj.totalizerBefore)
      ..writeByte(20)
      ..write(obj.totalizerAfter)
      ..writeByte(21)
      ..write(obj.photoTotalizerPath)
      ..writeByte(22)
      ..write(obj.supervisorNote)
      ..writeByte(23)
      ..write(obj.syncTime)
      ..writeByte(24)
      ..write(obj.isSynced)
      ..writeByte(25)
      ..write(obj.internalNote)
      ..writeByte(26)
      ..write(obj.operatorNote)
      ..writeByte(27)
      ..write(obj.fuelmanNote)
      ..writeByte(28)
      ..write(obj.operatorNoteRead)
      ..writeByte(29)
      ..write(obj.fuelmanNoteRead)
      ..writeByte(30)
      ..write(obj.noteCreatedAt)
      ..writeByte(31)
      ..write(obj.approvedBy)
      ..writeByte(32)
      ..write(obj.approvedAt)
      ..writeByte(33)
      ..write(obj.approvedChoice)
      ..writeByte(34)
      ..write(obj.isManipulationFlag)
      ..writeByte(35)
      ..write(obj.manipulationType)
      ..writeByte(36)
      ..write(obj.manipulationReason)
      ..writeByte(37)
      ..write(obj.estimatedLoss)
      ..writeByte(38)
      ..write(obj.isGapDetected)
      ..writeByte(39)
      ..write(obj.gapValue)
      ..writeByte(40)
      ..write(obj.isDuplicateFueling)
      ..writeByte(41)
      ..write(obj.duplicateCount)
      ..writeByte(42)
      ..write(obj.detectionSeverity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FuelEntryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
