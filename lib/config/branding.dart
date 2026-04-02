import 'package:flutter/material.dart';

class Branding {
  // ============================================
  // PERSONAL MARK (TETAP PERTAHANKAN)
  // ============================================
  static const String developerName = 'YOHANES KRISTOFEL SENTOSA LELENG';
  static const String copyrightYear = '2026';
  static const String appName = 'Fuel Tracker & Control System';
  static const String appVersion = '1.0.0';
  static const String appIcon = '⛽';
  
  static String get copyrightText => '© $copyrightYear $developerName. All rights reserved.';
  
  static const String licenseText = '''
  Fuel Tracker System - Proprietary Software
  
  This software is the exclusive property of YOHANES KRISTOFEL SENTOSA LELENG.
  Unauthorized copying, modification, distribution, or use of this software
  without explicit permission is strictly prohibited.
  
  For licensing inquiries, please contact the developer.
  ''';
  
  // ============================================
  // WARNA BIRU (SESUAI KEINGINAN ANDA)
  // ============================================
  static const Color primaryColor = Color(0xFF1E88E5);      // Biru Google
  static const Color secondaryColor = Color(0xFF0D47A1);    // Biru Tua
  static const Color accentColor = Color(0xFF42A5F5);       // Biru Muda
  static const Color dangerColor = Color(0xFFDC3545);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color successColor = Color(0xFF28A745);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  
  // ============================================
  // TEXT STYLES
  // ============================================
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle bodyLarge = TextStyle(fontSize: 16);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, color: Colors.grey);
  
  // ============================================
  // SHIFT CONFIGURATION
  // ============================================
  static const int shiftStartHour = 6;   // Shift Pagi mulai jam 06:00
  static const int shiftEndHour = 18;    // Shift Pagi berakhir jam 18:00
  
  // ============================================
  // FUEL CONFIGURATION
  // ============================================
  static const double defaultTankCapacity = 800.0;  // Liter
  static const double varianceThreshold = 5.0;       // Persen toleransi
  
  // ============================================
  // METHOD UNTUK MENDAPATKAN SHIFT SAAT INI
  // ============================================
  static String getCurrentShift() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour >= shiftStartHour && hour < shiftEndHour) {
      return 'PAGI';
    } else {
      return 'MALAM';
    }
  }
  
  // ============================================
  // METHOD UNTUK MENDAPATKAN WAKTU SAAT INI (FORMAT)
  // ============================================
  static String getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
  
  // ============================================
  // METHOD UNTUK MENDAPATKAN TANGGAL SAAT INI (FORMAT)
  // ============================================
  static String getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }
  
  // ============================================
  // METHOD UNTUK HITUNG LITER DARI PERUBAHAN LEVEL
  // ============================================
  static double calculateLiter(String levelBefore, String levelAfter, {double tankCapacity = defaultTankCapacity}) {
    final Map<String, double> levelMap = {
      '1/4': 0.25,
      '2/4': 0.50,
      '3/4': 0.75,
      'FULL': 1.00,
    };
    
    final double beforePercent = levelMap[levelBefore] ?? 0;
    final double afterPercent = levelMap[levelAfter] ?? 0;
    
    if (afterPercent <= beforePercent) return 0;
    
    return (afterPercent - beforePercent) * tankCapacity;
  }
}