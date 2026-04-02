import 'dart:async';
import 'package:flutter/material.dart';

/// Service untuk mengelola session timeout dan auto logout
class SessionService extends ChangeNotifier {
  static const int _defaultTimeoutMinutes = 30; // 30 MENIT
  static const Duration _resetDuration = Duration(seconds: 1);
  
  Timer? _activityTimer;
  Timer? _countdownTimer;
  
  DateTime? _lastActivity;
  bool _isSessionActive = true;
  int _remainingSeconds = _defaultTimeoutMinutes * 60;
  
  // Callback untuk logout
  VoidCallback? onLogout;
  
  /// Sisa waktu session dalam detik
  int get remainingSeconds => _remainingSeconds;
  
  /// Apakah session masih aktif
  bool get isSessionActive => _isSessionActive;
  
  /// Format sisa waktu menjadi string (MM:SS)
  String get formattedRemainingTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// Start session setelah login berhasil
  void startSession() {
    print('🟢 SESSION: Start session with $_defaultTimeoutMinutes minutes timeout');
    _resetTimer();
    _isSessionActive = true;
    _remainingSeconds = _defaultTimeoutMinutes * 60;
    _startCountdown();
    notifyListeners();
  }
  
  /// Reset timer setiap ada aktivitas user
  void resetTimer() {
    if (!_isSessionActive) return;
    print('🔄 SESSION: Timer reset - activity detected');
    _resetTimer();
    _remainingSeconds = _defaultTimeoutMinutes * 60;
    notifyListeners();
  }
  
  void _resetTimer() {
    _activityTimer?.cancel();
    _activityTimer = Timer(_resetDuration, () {
      _lastActivity = DateTime.now();
    });
  }
  
  void _startCountdown() {
    _countdownTimer?.cancel();
    print('⏱️ SESSION: Countdown started - $_remainingSeconds seconds');
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isSessionActive) {
        print('⏸️ SESSION: Session inactive, stopping countdown');
        timer.cancel();
        return;
      }
      
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        
        // Log setiap 5 menit atau saat kritis
        if (_remainingSeconds % 300 == 0 || _remainingSeconds <= 30) {
          int minutesLeft = _remainingSeconds ~/ 60;
          print('⏰ SESSION: $minutesLeft minutes remaining ($_remainingSeconds seconds)');
        }
        
        notifyListeners();
        
        // Warning 30 detik sebelum logout
        if (_remainingSeconds == 30) {
          print('⚠️ SESSION: 30 seconds warning!');
          _showWarningNotification();
        }
      } else {
        // Session expired
        print('💀 SESSION: Session expired!');
        timer.cancel();
        _logout();
      }
    });
  }
  
  void _showWarningNotification() {
    onLogout?.call();
  }
  
  void _logout() {
    if (!_isSessionActive) return;
    
    _isSessionActive = false;
    _activityTimer?.cancel();
    _countdownTimer?.cancel();
    _activityTimer = null;
    _countdownTimer = null;
    
    notifyListeners();
    
    if (onLogout != null) {
      onLogout!();
    }
  }
  
  /// Manual logout
  void logout() {
    _logout();
  }
  
  /// Pause session (saat app di background)
  void pauseSession() {
    print('⏸️ SESSION: Pause session');
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }
  
  /// Resume session (saat app kembali ke foreground)
  void resumeSession() {
    print('▶️ SESSION: Resume session');
    if (_isSessionActive && _countdownTimer == null && _remainingSeconds > 0) {
      _startCountdown();
    }
  }
  
  /// Update session activity (dipanggil dari main.dart)
  void onUserActivity() {
    if (_isSessionActive) {
      resetTimer();
    }
  }
  
  @override
  void dispose() {
    _activityTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}