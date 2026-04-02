class User {
  final String username;
  final String name;
  final String role;
  final String? unitCode;
  final int? positionLevel;      // Level jabatan (1:Operator, 2:Fuelman, 3:Supervisor, 4:Section Head, 5:Dept Head, 6:Deputy, 7:PJO, 8:Direksi, 9:Admin, 10:Super Admin)
  final String? positionName;     // Nama jabatan
  final String? departmentCode;   // Kode department
  final String? departmentName;   // Nama department
  final String? sectionCode;      // Kode section
  final String? sectionName;      // Nama section
  final bool isActive;            // Status aktif
  
  // Additional fields untuk Super Admin
  final String? email;            // Email user
  final String? phone;            // Nomor telepon
  final int? companyId;           // ID perusahaan

  User({
    required this.username,
    required this.name,
    required this.role,
    this.unitCode,
    this.positionLevel,
    this.positionName,
    this.departmentCode,
    this.departmentName,
    this.sectionCode,
    this.sectionName,
    this.isActive = true,
    this.email,
    this.phone,
    this.companyId,
  });

  // Role checkers
  bool get isOperator => role == 'operator';
  bool get isFuelman => role == 'fuelman';
  bool get isSupervisor => role == 'supervisor';
  bool get isSectionHead => role == 'section_head';
  bool get isDepartmentHead => role == 'dept_head';
  bool get isDeputyManager => role == 'deputy';
  bool get isPJO => role == 'pjo';
  bool get isDireksi => role == 'direksi';
  bool get isAdmin => role == 'admin';
  bool get isSuperAdmin => role == 'super_admin';

  // Helper untuk menentukan level escalation
  int get escalationLevel {
    if (positionLevel != null) return positionLevel!;
    switch (role) {
      case 'operator': return 1;
      case 'fuelman': return 2;
      case 'supervisor': return 3;
      case 'section_head': return 4;
      case 'dept_head': return 5;
      case 'deputy': return 6;
      case 'pjo': return 7;
      case 'direksi': return 8;
      case 'admin': return 9;
      case 'super_admin': return 10;
      default: return 0;
    }
  }

  // Factory method to create User from database Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] ?? map['user_id'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'operator',
      unitCode: map['unit_code'],
      positionLevel: map['position_level'],
      positionName: map['position_name'],
      departmentCode: map['department_code'],
      departmentName: map['department_name'],
      sectionCode: map['section_code'],
      sectionName: map['section_name'],
      isActive: map['is_active'] == 1 || map['is_active'] == true,
      email: map['email'],
      phone: map['phone'],
      companyId: map['company_id'],
    );
  }

  // Factory method from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? json['user_id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'operator',
      unitCode: json['unit_code'],
      positionLevel: json['position_level'],
      positionName: json['position_name'],
      departmentCode: json['department_code'],
      departmentName: json['department_name'],
      sectionCode: json['section_code'],
      sectionName: json['section_name'],
      isActive: json['is_active'] ?? true,
      email: json['email'],
      phone: json['phone'],
      companyId: json['company_id'],
    );
  }

  // Convert User to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'role': role,
      'unit_code': unitCode,
      'position_level': positionLevel,
      'position_name': positionName,
      'department_code': departmentCode,
      'department_name': departmentName,
      'section_code': sectionCode,
      'section_name': sectionName,
      'is_active': isActive ? 1 : 0,
      'email': email,
      'phone': phone,
      'company_id': companyId,
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'role': role,
      'unit_code': unitCode,
      'position_level': positionLevel,
      'position_name': positionName,
      'department_code': departmentCode,
      'department_name': departmentName,
      'section_code': sectionCode,
      'section_name': sectionName,
      'is_active': isActive,
      'email': email,
      'phone': phone,
      'company_id': companyId,
    };
  }

  // Copy with method
  User copyWith({
    String? username,
    String? name,
    String? role,
    String? unitCode,
    int? positionLevel,
    String? positionName,
    String? departmentCode,
    String? departmentName,
    String? sectionCode,
    String? sectionName,
    bool? isActive,
    String? email,
    String? phone,
    int? companyId,
  }) {
    return User(
      username: username ?? this.username,
      name: name ?? this.name,
      role: role ?? this.role,
      unitCode: unitCode ?? this.unitCode,
      positionLevel: positionLevel ?? this.positionLevel,
      positionName: positionName ?? this.positionName,
      departmentCode: departmentCode ?? this.departmentCode,
      departmentName: departmentName ?? this.departmentName,
      sectionCode: sectionCode ?? this.sectionCode,
      sectionName: sectionName ?? this.sectionName,
      isActive: isActive ?? this.isActive,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      companyId: companyId ?? this.companyId,
    );
  }
}