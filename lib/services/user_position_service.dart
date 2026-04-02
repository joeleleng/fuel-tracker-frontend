/// User Position Service
/// Service untuk API calls user position management
/// MS-51: User Position Management (Admin Panel)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/organization_structure.dart';
import '../models/user_model.dart';

class UserPositionService {
  static const String baseUrl = 'http://localhost:3000/api'; // Sesuaikan dengan backend

  /// Get all users with their current positions
  static Future<List<User>> getAllUsersWithPositions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-positions/users'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> usersJson = data['data'];
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Get all available positions
  static Future<List<OrganizationStructure>> getAllPositions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-positions/positions'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> positionsJson = data['data'];
        return positionsJson.map((json) => OrganizationStructure.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load positions');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Get user position history
  static Future<List<UserPositionHistory>> getUserPositionHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-positions/history/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> historyJson = data['data'];
        return historyJson.map((json) => UserPositionHistory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Change user position (mutasi/promosi/demosi)
  static Future<Map<String, dynamic>> changeUserPosition({
    required String userId,
    required int newPositionId,
    String? department,
    String? reason,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user-positions/change'),
        headers: await _getHeaders(),
        body: json.encode({
          'userId': userId,
          'newPositionId': newPositionId,
          'department': department,
          'reason': reason,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to change position');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Get user escalation path
  static Future<List<Map<String, dynamic>>> getUserEscalationPath(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-positions/escalation-path/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load escalation path');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Get all temporary assignments
  static Future<List<TemporaryAssignment>> getAllTemporaryAssignments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/temporary-assignments'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> assignmentsJson = data['data'];
        return assignmentsJson.map((json) => TemporaryAssignment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load assignments');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Create temporary assignment
  static Future<TemporaryAssignment> createTemporaryAssignment({
    required String userId,
    required int originalPositionId,
    int? temporaryPositionId,
    String? assignedUserId,
    required String assignmentType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/temporary-assignments'),
        headers: await _getHeaders(),
        body: json.encode({
          'user_id': userId,
          'original_position_id': originalPositionId,
          'temporary_position_id': temporaryPositionId,
          'assigned_user_id': assignedUserId,
          'assignment_type': assignmentType,
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
          'reason': reason,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return TemporaryAssignment.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to create assignment');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// End temporary assignment
  static Future<void> endTemporaryAssignment(int assignmentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/temporary-assignments/$assignmentId'),
        headers: await _getHeaders(),
      );

      final data = json.decode(response.body);
      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to end assignment');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Helper: Get headers with authentication token
  static Future<Map<String, String>> _getHeaders() async {
    // TODO: Get token from secure storage
    final token = ''; // await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}