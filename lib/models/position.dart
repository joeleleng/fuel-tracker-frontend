class Position {
  final int id;
  final String positionCode;
  final String positionName;
  final int positionLevel;
  final int? escalationLevel;
  final bool canApprove;
  final bool canManageUsers;
  final bool canViewAllReports;
  final bool isActive;

  Position({
    required this.id,
    required this.positionCode,
    required this.positionName,
    required this.positionLevel,
    this.escalationLevel,
    this.canApprove = false,
    this.canManageUsers = false,
    this.canViewAllReports = false,
    this.isActive = true,
  });

  factory Position.fromMap(Map<String, dynamic> map) {
    return Position(
      id: map['id'],
      positionCode: map['position_code'],
      positionName: map['position_name'],
      positionLevel: map['position_level'],
      escalationLevel: map['escalation_level'],
      canApprove: map['can_approve'] == 1,
      canManageUsers: map['can_manage_users'] == 1,
      canViewAllReports: map['can_view_all_reports'] == 1,
      isActive: map['is_active'] == 1,
    );
  }
}

// Data positions (hardcoded untuk sementara)
final List<Position> defaultPositions = [
  Position(id: 1, positionCode: 'OPR', positionName: 'Operator', positionLevel: 1),
  Position(id: 2, positionCode: 'FML', positionName: 'Fuelman', positionLevel: 2),
  Position(id: 3, positionCode: 'SPV', positionName: 'Supervisor', positionLevel: 3, escalationLevel: 1, canApprove: true),
  Position(id: 4, positionCode: 'SH', positionName: 'Section Head', positionLevel: 4, escalationLevel: 2, canApprove: true),
  Position(id: 5, positionCode: 'DH', positionName: 'Department Head', positionLevel: 5, escalationLevel: 3, canApprove: true, canManageUsers: true),
  Position(id: 6, positionCode: 'DEP', positionName: 'Deputy Manager', positionLevel: 6, escalationLevel: 4, canApprove: true, canManageUsers: true, canViewAllReports: true),
  Position(id: 7, positionCode: 'PJO', positionName: 'Penanggung Jawab Operasional', positionLevel: 7, escalationLevel: 4, canApprove: true, canManageUsers: true, canViewAllReports: true),
  Position(id: 8, positionCode: 'DIR', positionName: 'Direksi', positionLevel: 8, escalationLevel: 4, canApprove: true, canManageUsers: true, canViewAllReports: true),
  Position(id: 9, positionCode: 'ADM', positionName: 'Administrator', positionLevel: 9, canApprove: true, canManageUsers: true, canViewAllReports: true),
];