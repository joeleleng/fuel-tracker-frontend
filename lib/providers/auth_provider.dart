import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/session_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  // Session service
  final SessionService _sessionService = SessionService();
  Timer? _sessionCheckTimer;
  
  // Callback untuk logout (dipanggil dari main.dart)
  VoidCallback? _onLogoutCallback;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAuthenticated => _user != null;
  
  // Get session service
  SessionService get sessionService => _sessionService;
  
  // Get sisa waktu session
  int get sessionRemainingSeconds => _sessionService.remainingSeconds;
  String get formattedSessionTime => _sessionService.formattedRemainingTime;
  bool get isSessionActive => _sessionService.isSessionActive;
  
  // Setter untuk logout callback
  set onLogoutCallback(VoidCallback? callback) {
    _onLogoutCallback = callback;
  }
  
  // Role-based access helpers
  bool get isAdmin => _user?.role == 'admin' || _user?.role == 'super_admin';
  bool get isSuperAdmin => _user?.role == 'super_admin';
  bool get isDireksi => _user?.role == 'direksi';
  bool get isPjo => _user?.role == 'pjo';
  bool get isDeputy => _user?.role == 'deputy';
  bool get isDeptHead => _user?.role == 'dept_head';
  bool get isSectionHead => _user?.role == 'section_head';
  bool get isSupervisor => _user?.role == 'supervisor';
  bool get isFuelman => _user?.role == 'fuelman';
  bool get isOperator => _user?.role == 'operator';
  
  // Get position level
  int get positionLevel => _user?.positionLevel ?? 0;
  
  // Get display name for current role
  String get roleDisplayName {
    switch (_user?.role) {
      case 'operator':
        return 'Operator';
      case 'fuelman':
        return 'Fuelman';
      case 'supervisor':
        return 'Supervisor';
      case 'section_head':
        return 'Section Head';
      case 'dept_head':
        return 'Department Head';
      case 'deputy':
        return 'Deputy Manager';
      case 'pjo':
        return 'PJO';
      case 'direksi':
        return 'Direksi';
      case 'admin':
        return 'Administrator';
      case 'super_admin':
        return 'Super Administrator';
      default:
        return 'User';
    }
  }
  
  // ============================================
  // SESSION MANAGEMENT METHODS
  // ============================================
  
  /// Setup session setelah login berhasil
  void _setupSession() {
    _sessionService.startSession();
    _sessionService.onLogout = () {
      // Auto logout saat session expired
      logout(isAutoLogout: true);
      // Panggil callback untuk navigasi
      _onLogoutCallback?.call();
    };
  }
  
  /// Reset session activity (dipanggil dari main.dart)
  void resetSessionActivity() {
    _sessionService.onUserActivity();
  }
  
  /// Pause session (app di background)
  void pauseSession() {
    _sessionService.pauseSession();
  }
  
  /// Resume session (app kembali ke foreground)
  void resumeSession() {
    _sessionService.resumeSession();
  }
  
  // ============================================
  // LOGIN METHOD
  // ============================================

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    
    // ============================================
    // HARCODED CREDENTIALS UNTUK SEMUA LEVEL
    // ============================================
    
    // OPERATOR (Level 1)
    if (username == 'opr001' && password == 'password123') {
      _user = User(
        username: 'opr001',
        name: 'Budi Santoso',
        role: 'operator',
        unitCode: 'EXC-01',
        positionLevel: 1,
        positionName: 'Operator',
        departmentCode: 'PROD',
        departmentName: 'Produksi',
        sectionCode: 'PIT-A',
        sectionName: 'Pit Selatan',
        isActive: true,
      );
    } 
    else if (username == 'opr002' && password == 'password123') {
      _user = User(
        username: 'opr002',
        name: 'Samsul',
        role: 'operator',
        unitCode: 'HD-465-01',
        positionLevel: 1,
        positionName: 'Operator',
        departmentCode: 'PROD',
        departmentName: 'Produksi',
        sectionCode: 'PIT-B',
        sectionName: 'Pit Utara',
        isActive: true,
      );
    }
    
    // FUELMAN (Level 2)
    else if (username == 'fml001' && password == 'password123') {
      _user = User(
        username: 'fml001',
        name: 'Ahmad Fauzi',
        role: 'fuelman',
        unitCode: null,
        positionLevel: 2,
        positionName: 'Fuelman',
        departmentCode: 'LOG',
        departmentName: 'Logistik',
        isActive: true,
      );
    }
    else if (username == 'fml002' && password == 'password123') {
      _user = User(
        username: 'fml002',
        name: 'Rudi Hartono',
        role: 'fuelman',
        unitCode: null,
        positionLevel: 2,
        positionName: 'Fuelman',
        departmentCode: 'LOG',
        departmentName: 'Logistik',
        isActive: true,
      );
    }
    
    // SUPERVISOR (Level 3)
    else if (username == 'spv001' && password == 'password123') {
      _user = User(
        username: 'spv001',
        name: 'Supervisor Site',
        role: 'supervisor',
        unitCode: null,
        positionLevel: 3,
        positionName: 'Supervisor',
        departmentCode: 'PROD',
        departmentName: 'Produksi',
        sectionCode: 'PIT-A',
        sectionName: 'Pit Selatan',
        isActive: true,
      );
    }
    
    // SECTION HEAD (Level 4)
    else if (username == 'sh001' && password == 'password123') {
      _user = User(
        username: 'sh001',
        name: 'Joko Widodo',
        role: 'section_head',
        unitCode: null,
        positionLevel: 4,
        positionName: 'Section Head',
        departmentCode: 'PROD',
        departmentName: 'Produksi',
        sectionCode: 'PIT-A',
        sectionName: 'Pit Selatan',
        isActive: true,
      );
    }
    
    // DEPARTMENT HEAD (Level 5)
    else if (username == 'dh001' && password == 'password123') {
      _user = User(
        username: 'dh001',
        name: 'Siti Aminah',
        role: 'dept_head',
        unitCode: null,
        positionLevel: 5,
        positionName: 'Department Head',
        departmentCode: 'PROD',
        departmentName: 'Produksi',
        isActive: true,
      );
    }
    
    // DEPUTY MANAGER (Level 6)
    else if (username == 'dep001' && password == 'password123') {
      _user = User(
        username: 'dep001',
        name: 'Bambang Sutopo',
        role: 'deputy',
        unitCode: null,
        positionLevel: 6,
        positionName: 'Deputy Manager',
        departmentCode: 'OPS',
        departmentName: 'Operasional',
        isActive: true,
      );
    }
    
    // PJO (Level 7)
    else if (username == 'pjo001' && password == 'password123') {
      _user = User(
        username: 'pjo001',
        name: 'Hendra Wijaya',
        role: 'pjo',
        unitCode: null,
        positionLevel: 7,
        positionName: 'Penanggung Jawab Operasional',
        departmentCode: 'OPS',
        departmentName: 'Operasional',
        isActive: true,
      );
    }
    
    // DIREKSI (Level 8)
    else if (username == 'dir001' && password == 'password123') {
      _user = User(
        username: 'dir001',
        name: 'Ir. Sutrisno',
        role: 'direksi',
        unitCode: null,
        positionLevel: 8,
        positionName: 'Direksi',
        departmentCode: 'CORP',
        departmentName: 'Corporate',
        isActive: true,
      );
    }
    
    // ADMIN (Level 9)
    else if (username == 'admin' && password == 'admin123') {
      _user = User(
        username: 'admin',
        name: 'System Administrator',
        role: 'admin',
        unitCode: null,
        positionLevel: 9,
        positionName: 'Administrator',
        departmentCode: 'IT',
        departmentName: 'IT Support',
        isActive: true,
      );
    }
    
    // SUPER ADMIN (Level 10)
    else if (username == 'superadmin' && password == 'super123') {
      _user = User(
        username: 'superadmin',
        name: 'Super Administrator',
        role: 'super_admin',
        unitCode: null,
        positionLevel: 10,
        positionName: 'Super Administrator',
        departmentCode: 'SYSTEM',
        departmentName: 'System Management',
        isActive: true,
      );
    }
    
    // Invalid credentials
    else {
      _error = 'Username atau password salah';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    print('✅ Login success: ${_user?.username} (${_user?.role}) - Level ${_user?.positionLevel}');
    
    // Setup session setelah login berhasil
    _setupSession();
    
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // ============================================
  // LOGOUT METHOD with session cleanup
  // ============================================
  
  Future<void> logout({bool isAutoLogout = false}) async {
    print('🔓 Logout: ${_user?.username} (${_user?.role}) - Auto: $isAutoLogout');
    
    // Hentikan session timer
    _sessionService.logout();
    
    // Cancel timer jika ada
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = null;
    
    // Clear user data
    _user = null;
    _error = null;
    
    notifyListeners();
    
    if (isAutoLogout) {
      print('⏰ Session expired - Auto logout triggered');
      // Panggil callback untuk navigasi
      _onLogoutCallback?.call();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // ============================================
  // GET MENU ITEMS BASED ON ROLE
  // ============================================
  List<NavigationItem> getMenuItems() {
    final role = _user?.role;
    
    // Base menu untuk semua user
    List<NavigationItem> items = [
      NavigationItem(
        icon: Icons.dashboard,
        label: 'Dashboard',
        route: '/dashboard',
      ),
    ];
    
    // Operator & Fuelman menu
    if (role == 'operator' || role == 'fuelman') {
      items.addAll([
        NavigationItem(
          icon: Icons.local_gas_station,
          label: 'Fuel Entry',
          route: '/fuel-entry',
        ),
        NavigationItem(
          icon: Icons.history,
          label: 'History',
          route: '/history',
        ),
        NavigationItem(
          icon: Icons.notifications,
          label: 'Notifications',
          route: '/notifications',
        ),
      ]);
    }
    
    // Supervisor menu
    if (role == 'supervisor') {
      items.addAll([
        NavigationItem(
          icon: Icons.check_circle,
          label: 'Approvals',
          route: '/approvals',
        ),
        NavigationItem(
          icon: Icons.warning,
          label: 'Alerts',
          route: '/alerts',
        ),
      ]);
    }
    
    // Section Head menu
    if (role == 'section_head') {
      items.addAll([
        NavigationItem(
          icon: Icons.assessment,
          label: 'Section Report',
          route: '/section-report',
        ),
        NavigationItem(
          icon: Icons.warning,
          label: 'Escalations',
          route: '/escalations',
        ),
      ]);
    }
    
    // Department Head menu
    if (role == 'dept_head') {
      items.addAll([
        NavigationItem(
          icon: Icons.bar_chart,
          label: 'Department Report',
          route: '/dept-report',
        ),
        NavigationItem(
          icon: Icons.trending_up,
          label: 'Performance',
          route: '/performance',
        ),
      ]);
    }
    
    // Deputy Manager menu
    if (role == 'deputy') {
      items.addAll([
        NavigationItem(
          icon: Icons.analytics,
          label: 'Operations Report',
          route: '/ops-report',
        ),
        NavigationItem(
          icon: Icons.people,
          label: 'Team Performance',
          route: '/team-performance',
        ),
      ]);
    }
    
    // PJO menu
    if (role == 'pjo') {
      items.addAll([
        NavigationItem(
          icon: Icons.factory,
          label: 'Site Overview',
          route: '/site-overview',
        ),
        NavigationItem(
          icon: Icons.security,
          label: 'Compliance',
          route: '/compliance',
        ),
      ]);
    }
    
    // Direksi menu
    if (role == 'direksi') {
      items.addAll([
        NavigationItem(
          icon: Icons.assessment,
          label: 'Executive Report',
          route: '/executive',
        ),
        NavigationItem(
          icon: Icons.trending_down,
          label: 'Loss Analysis',
          route: '/loss-analysis',
        ),
        NavigationItem(
          icon: Icons.leaderboard,
          label: 'Rankings',
          route: '/rankings',
        ),
      ]);
    }
    
    // Admin menu
    if (isAdmin || isSuperAdmin) {
      items.addAll([
        NavigationItem(
          icon: Icons.people,
          label: 'User Position',
          route: '/admin/user-positions',
        ),
        NavigationItem(
          icon: Icons.beach_access,
          label: 'Temporary Assignment',
          route: '/admin/temporary-assignments',
        ),
        NavigationItem(
          icon: Icons.history,
          label: 'Position History',
          route: '/admin/position-history',
        ),
        NavigationItem(
          icon: Icons.bar_chart,
          label: 'Reports',
          route: '/admin/reports',
        ),
        NavigationItem(
          icon: Icons.security,
          label: 'Audit Trail',
          route: '/admin/audit',
        ),
        NavigationItem(
          icon: Icons.settings,
          label: 'Organization Structure',
          route: '/admin/organization',
        ),
        NavigationItem(
          icon: Icons.rule,
          label: 'Escalation Rules',
          route: '/admin/escalation-rules',
        ),
      ]);
    }
    
    // Super Admin menu (full access + system management)
    if (role == 'super_admin') {
      items.addAll([
        NavigationItem(
          icon: Icons.business,
          label: 'Company Management',
          route: '/superadmin/companies',
        ),
        NavigationItem(
          icon: Icons.subscriptions,
          label: 'Subscriptions',
          route: '/superadmin/subscriptions',
        ),
        NavigationItem(
          icon: Icons.settings_applications,
          label: 'System Config',
          route: '/superadmin/config',
        ),
        NavigationItem(
          icon: Icons.storage,
          label: 'Database Admin',
          route: '/superadmin/database',
        ),
      ]);
    }
    
    // Logout menu untuk semua user
    items.add(
      NavigationItem(
        icon: Icons.logout,
        label: 'Logout',
        route: '/logout',
      ),
    );
    
    return items;
  }
  
  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    _sessionService.dispose();
    super.dispose();
  }
}

// ============================================
// Navigation Item Model
// ============================================
class NavigationItem {
  final IconData icon;
  final String label;
  final String route;
  
  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}