/// Organization Structure Model
/// MS-49: Organization Structure Database

class OrganizationStructure {
  final int? id;
  final String positionName;
  final int positionLevel;
  final String? department;
  final int? parentPositionId;
  final int escalationTimeoutMinutes;
  final bool requiresApproval;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrganizationStructure({
    this.id,
    required this.positionName,
    required this.positionLevel,
    this.department,
    this.parentPositionId,
    this.escalationTimeoutMinutes = 60,
    this.requiresApproval = true,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory OrganizationStructure.fromJson(Map<String, dynamic> json) {
    return OrganizationStructure(
      id: json['id'],
      positionName: json['position_name'] ?? json['positionName'] ?? '',
      positionLevel: json['position_level'] ?? json['positionLevel'] ?? 1,
      department: json['department'],
      parentPositionId: json['parent_position_id'] ?? json['parentPositionId'],
      escalationTimeoutMinutes: json['escalation_timeout_minutes'] ?? json['escalationTimeoutMinutes'] ?? 60,
      requiresApproval: json['requires_approval'] ?? json['requiresApproval'] ?? true,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position_name': positionName,
      'position_level': positionLevel,
      'department': department,
      'parent_position_id': parentPositionId,
      'escalation_timeout_minutes': escalationTimeoutMinutes,
      'requires_approval': requiresApproval,
      'is_active': isActive,
    };
  }

  String get levelName {
    switch (positionLevel) {
      case 1: return 'Operator';
      case 2: return 'Fuelman';
      case 3: return 'Supervisor';
      case 4: return 'Section Head';
      case 5: return 'Department Head';
      case 6: return 'Deputy Manager';
      case 7: return 'PJO';
      case 8: return 'Direksi';
      case 9: return 'Admin';
      case 10: return 'Super Admin';
      default: return 'Unknown';
    }
  }
}

class UserPosition {
  final int? id;
  final String userId;
  final int positionId;
  final String? department;
  final bool isActive;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final OrganizationStructure? position;

  UserPosition({
    this.id,
    required this.userId,
    required this.positionId,
    this.department,
    this.isActive = true,
    this.startedAt,
    this.endedAt,
    this.position,
  });

  factory UserPosition.fromJson(Map<String, dynamic> json) {
    return UserPosition(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'] ?? '',
      positionId: json['position_id'] ?? json['positionId'] ?? 0,
      department: json['department'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at']) : null,
      endedAt: json['ended_at'] != null ? DateTime.tryParse(json['ended_at']) : null,
      position: json['position'] != null ? OrganizationStructure.fromJson(json['position']) : null,
    );
  }
}

class UserPositionHistory {
  final int? id;
  final String userId;
  final int? oldPositionId;
  final int? newPositionId;
  final String? oldDepartment;
  final String? newDepartment;
  final String changeType;
  final String? reason;
  final String changedBy;
  final DateTime changedAt;

  UserPositionHistory({
    this.id,
    required this.userId,
    this.oldPositionId,
    this.newPositionId,
    this.oldDepartment,
    this.newDepartment,
    required this.changeType,
    this.reason,
    required this.changedBy,
    required this.changedAt,
  });

  factory UserPositionHistory.fromJson(Map<String, dynamic> json) {
    return UserPositionHistory(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'] ?? '',
      oldPositionId: json['old_position_id'] ?? json['oldPositionId'],
      newPositionId: json['new_position_id'] ?? json['newPositionId'],
      oldDepartment: json['old_department'] ?? json['oldDepartment'],
      newDepartment: json['new_department'] ?? json['newDepartment'],
      changeType: json['change_type'] ?? json['changeType'] ?? 'MUTATION',
      reason: json['reason'],
      changedBy: json['changed_by'] ?? json['changedBy'] ?? '',
      changedAt: json['changed_at'] != null ? DateTime.tryParse(json['changed_at']) ?? DateTime.now() : DateTime.now(),
    );
  }

  String get changeTypeDisplay {
    switch (changeType) {
      case 'PROMOTION': return 'Promosi';
      case 'DEMOTION': return 'Demosi';
      case 'TRANSFER': return 'Transfer';
      case 'MUTATION': return 'Mutasi';
      default: return changeType;
    }
  }
}

class TemporaryAssignment {
  final int? id;
  final String userId;
  final int originalPositionId;
  final int? temporaryPositionId;
  final String? assignedUserId;
  final String assignmentType;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;

  TemporaryAssignment({
    this.id,
    required this.userId,
    required this.originalPositionId,
    this.temporaryPositionId,
    this.assignedUserId,
    required this.assignmentType,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
  });

  factory TemporaryAssignment.fromJson(Map<String, dynamic> json) {
    return TemporaryAssignment(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'] ?? '',
      originalPositionId: json['original_position_id'] ?? json['originalPositionId'] ?? 0,
      temporaryPositionId: json['temporary_position_id'] ?? json['temporaryPositionId'],
      assignedUserId: json['assigned_user_id'] ?? json['assignedUserId'],
      assignmentType: json['assignment_type'] ?? json['assignmentType'] ?? 'LEAVE',
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) ?? DateTime.now() : DateTime.now(),
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) ?? DateTime.now() : DateTime.now(),
      reason: json['reason'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdBy: json['created_by'] ?? json['createdBy'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) ?? DateTime.now() : DateTime.now(),
    );
  }

  String get assignmentTypeDisplay {
    switch (assignmentType) {
      case 'LEAVE': return 'Cuti';
      case 'SICK': return 'Sakit';
      case 'OUT_OF_OFFICE': return 'Tugas Luar';
      case 'DELEGATION': return 'Delegasi';
      default: return assignmentType;
    }
  }

  bool get isActiveAssignment {
    final now = DateTime.now();
    return isActive && startDate.isBefore(now) && endDate.isAfter(now);
  }
}