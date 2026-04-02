import 'package:flutter/material.dart';

class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:3000/api';
  static const int apiTimeout = 30000; // 30 seconds
  
  // App Configuration
  static const String appName = 'Fuel Tracker System';
  static const String appVersion = '1.0.0';
  
  // Shift Configuration (Default)
  static const int shiftStartHour = 6;  // 06:00
  static const int shiftEndHour = 18;   // 18:00
  
  // Fuel Calculation
  static const double defaultTankCapacity = 800.0; // Liters
  static const double varianceThreshold = 5.0; // 5% tolerance
  
  // UI Configuration
  static const Color primaryColor = Color(0xFF1E5F3A);
  static const Color secondaryColor = Color(0xFF2E8B57);
  static const Color accentColor = Color(0xFFFFA500);
  static const Color errorColor = Color(0xFFDC3545);
  static const Color successColor = Color(0xFF28A745);
  static const Color warningColor = Color(0xFFFFC107);
  
  // Offline Mode
  static const bool offlineModeEnabled = true;
  static const int syncIntervalMinutes = 5;
  
  // Feature Flags
  static const bool enableGpsTracking = true;
  static const bool enableQrScanner = true;
  static const bool enablePhotoEvidence = true;
}