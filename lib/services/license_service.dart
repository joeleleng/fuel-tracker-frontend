/// License Service
/// Untuk manajemen trial dan subscription
/// MS: Trial System

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class LicenseService {
  static const String baseUrl = 'http://localhost:3000/api';

  /// Cek status subscription perusahaan
  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscription/status'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to get subscription status');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Get license info (alias untuk subscription status)
  static Future<Map<String, dynamic>> getLicenseInfo() async {
    return await getSubscriptionStatus();
  }

  /// Dapatkan opsi upgrade
  static Future<Map<String, dynamic>> getUpgradeOptions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscription/upgrade-options'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to get upgrade options');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Upgrade subscription
  static Future<Map<String, dynamic>> upgradeSubscription({
    required String tier,
    String duration = 'monthly',
    String? paymentMethod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscription/upgrade'),
        headers: await _getHeaders(),
        body: json.encode({
          'tier': tier,
          'duration': duration,
          'payment_method': paymentMethod,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to upgrade');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Cek akses fitur
  static Future<bool> checkFeatureAccess(String feature) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscription/check-feature/$feature'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['has_access'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Dapatkan statistik penggunaan
  static Future<Map<String, dynamic>> getUsageStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscription/usage'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to get usage stats');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Perpanjang subscription
  static Future<Map<String, dynamic>> renewSubscription({
    String duration = 'monthly',
    String? paymentMethod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscription/renew'),
        headers: await _getHeaders(),
        body: json.encode({
          'duration': duration,
          'payment_method': paymentMethod,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to renew');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Batalkan subscription
  static Future<Map<String, dynamic>> cancelSubscription({String? reason}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscription/cancel'),
        headers: await _getHeaders(),
        body: json.encode({'reason': reason}),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to cancel');
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

/// Model untuk subscription status
class SubscriptionStatus {
  final String companyCode;
  final String companyName;
  final String tier;
  final String tierName;
  final String status;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final int daysLeft;
  final int maxUsers;
  final int maxUnits;
  final List<String> features;

  SubscriptionStatus({
    required this.companyCode,
    required this.companyName,
    required this.tier,
    required this.tierName,
    required this.status,
    required this.isActive,
    this.startDate,
    this.endDate,
    required this.daysLeft,
    required this.maxUsers,
    required this.maxUnits,
    required this.features,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      companyCode: json['company_code'] ?? '',
      companyName: json['company_name'] ?? '',
      tier: json['tier'] ?? 'basic',
      tierName: json['tier_name'] ?? 'Basic',
      status: json['status'] ?? 'active',
      isActive: json['is_active'] ?? true,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      daysLeft: json['days_left'] ?? 0,
      maxUsers: json['max_users'] ?? 10,
      maxUnits: json['max_units'] ?? 5,
      features: List<String>.from(json['features'] ?? []),
    );
  }

  bool get isTrial => tier == 'trial';
  bool get isBasic => tier == 'basic';
  bool get isPremium => tier == 'premium';
  bool get isSuite => tier == 'suite';

  String get daysLeftText {
    if (daysLeft <= 0) return 'Expired';
    if (daysLeft == 1) return '1 day left';
    return '$daysLeft days left';
  }

  // Helper method untuk mendapatkan warna status (tanpa Color type di model)
  String get statusColorName {
    if (!isActive) return 'red';
    if (daysLeft <= 7) return 'orange';
    return 'green';
  }
}