/// User Model
/// MS-51: User Position Management

import 'organization_structure.dart';

class User {
  final String userId;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final List<UserPosition>? positions;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.positions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<UserPosition>? positionsList;
    if (json['positions'] != null) {
      positionsList = (json['positions'] as List)
          .map((p) => UserPosition.fromJson(p))
          .toList();
    }

    return User(
      userId: json['user_id'] ?? json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'operator',
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      positions: positionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role,
      'is_active': isActive,
    };
  }
}