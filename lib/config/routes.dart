/**
 * APP ROUTES
 * Named routes configuration for the entire application
 * 
 * UPDATE: 30 Maret 2026
 * - Menambahkan routes untuk MS-49, MS-50, MS-51
 * - Admin panel routes: User Position Management, Temporary Assignment, Position History
 * - Escalation dashboard routes for all management levels
 */

import 'package:flutter/material.dart';

// ============================================
// SCREEN IMPORTS
// ============================================

// Auth Screens
import '../screens/login_screen.dart';

// Dashboard Screens (9 Levels)
import '../screens/dashboard_operator.dart';
import '../screens/dashboard_fuelman.dart';
import '../screens/dashboard_supervisor.dart';
import '../screens/dashboard_section_head.dart';
import '../screens/dashboard_dept_head.dart';
import '../screens/dashboard_deputy_manager.dart';
import '../screens/dashboard_pjo.dart';
import '../screens/dashboard_direksi.dart';
import '../screens/dashboard_admin.dart';

// Core Feature Screens
import '../screens/form_isi_fuel.dart';
import '../screens/form_verifikasi.dart';
import '../screens/history_screen.dart';
import '../screens/approval_list_screen.dart';
import '../screens/approval_detail_screen.dart';
import '../screens/operator_notification.dart';
import '../screens/fuelman_notification.dart';
import '../screens/admin_notification_monitor.dart';
import '../screens/notification_stats.dart';

// Report & Audit Screens
import '../screens/monthly_report_screen.dart';
import '../screens/operator_ranking_screen.dart';
import '../screens/audit_trail_screen.dart';

// Alert Screens
import '../screens/alert_dashboard_screen.dart';

// ============================================
// MS-49, MS-50, MS-51: ADMIN SCREENS
// ============================================
import '../screens/admin/user_position_management.dart';
import '../screens/admin/temporary_assignment_screen.dart';
import '../screens/admin/position_history_screen.dart';
import '../screens/admin/organization_structure_screen.dart';

// ============================================
// MS-53 & MS-54: ESCALATION DASHBOARD SCREENS
// ============================================
import '../screens/escalation/escalation_dashboard_section_head.dart';
import '../screens/escalation/escalation_dashboard_dept_head.dart';
import '../screens/escalation/escalation_dashboard_deputy.dart';
import '../screens/escalation/escalation_dashboard_pjo.dart';
import '../screens/escalation/executive_dashboard_enhanced.dart';

// ============================================
// ROUTE CONSTANTS
// ============================================

class AppRoutes {
  // ============================================
  // AUTH ROUTES
  // ============================================
  static const String login = '/';
  static const String logout = '/logout';

  // ============================================
  // DASHBOARD ROUTES (9 Levels)
  // ============================================
  static const String dashboardOperator = '/dashboard/operator';
  static const String dashboardFuelman = '/dashboard/fuelman';
  static const String dashboardSupervisor = '/dashboard/supervisor';
  static const String dashboardSectionHead = '/dashboard/section-head';
  static const String dashboardDepartmentHead = '/dashboard/department-head';
  static const String dashboardDeputyManager = '/dashboard/deputy-manager';
  static const String dashboardPjo = '/dashboard/pjo';
  static const String dashboardDireksi = '/dashboard/direksi';
  static const String dashboardAdmin = '/dashboard/admin';

  // ============================================
  // CORE FEATURE ROUTES
  // ============================================
  static const String formIsiFuel = '/fuel/entry';
  static const String formVerifikasi = '/fuel/verify';
  static const String history = '/history';
  static const String approvalList = '/approvals';
  static const String approvalDetail = '/approvals/detail';
  static const String operatorNotification = '/notifications/operator';
  static const String fuelmanNotification = '/notifications/fuelman';
  static const String adminNotificationMonitor = '/notifications/admin/monitor';
  static const String notificationStats = '/notifications/stats';

  // ============================================
  // REPORT & AUDIT ROUTES
  // ============================================
  static const String monthlyReport = '/reports/monthly';
  static const String operatorRanking = '/reports/ranking';
  static const String auditTrail = '/audit';

  // ============================================
  // ALERT ROUTES
  // ============================================
  static const String alertDashboard = '/alerts';

  // ============================================
  // MS-49 & MS-51: ADMIN MANAGEMENT ROUTES
  // ============================================
  static const String adminUserPositions = '/admin/user-positions';
  static const String adminTemporaryAssignments = '/admin/temporary-assignments';
  static const String adminPositionHistory = '/admin/position-history';
  static const String adminOrganizationStructure = '/admin/organization-structure';

  // ============================================
  // MS-53 & MS-54: ESCALATION DASHBOARD ROUTES
  // ============================================
  static const String escalationSectionHead = '/escalation/section-head';
  static const String escalationDepartmentHead = '/escalation/department-head';
  static const String escalationDeputy = '/escalation/deputy';
  static const String escalationPjo = '/escalation/pjo';
  static const String executiveDashboard = '/executive/dashboard';

  // ============================================
  // HELPER METHOD: Get dashboard route by role
  // ============================================
  static String getDashboardRoute(String role) {
    switch (role.toLowerCase()) {
      case 'operator':
        return dashboardOperator;
      case 'fuelman':
        return dashboardFuelman;
      case 'supervisor':
        return dashboardSupervisor;
      case 'section_head':
        return dashboardSectionHead;
      case 'department_head':
        return dashboardDepartmentHead;
      case 'deputy_manager':
        return dashboardDeputyManager;
      case 'pjo':
        return dashboardPjo;
      case 'direksi':
        return dashboardDireksi;
      case 'admin':
      case 'super_admin':
        return dashboardAdmin;
      default:
        return dashboardOperator;
    }
  }
}

// ============================================
// ROUTE CONFIGURATION
// ============================================

class RouteConfig {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    
    switch (settings.name) {
      // ============================================
      // AUTH ROUTES
      // ============================================
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      // ============================================
      // DASHBOARD ROUTES (9 Levels)
      // ============================================
      case AppRoutes.dashboardOperator:
        return MaterialPageRoute(builder: (_) => const DashboardOperator());
      case AppRoutes.dashboardFuelman:
        return MaterialPageRoute(builder: (_) => const DashboardFuelman());
      case AppRoutes.dashboardSupervisor:
        return MaterialPageRoute(builder: (_) => const DashboardSupervisor());
      case AppRoutes.dashboardSectionHead:
        return MaterialPageRoute(builder: (_) => const DashboardSectionHead());
      case AppRoutes.dashboardDepartmentHead:
        return MaterialPageRoute(builder: (_) => const DashboardDepartmentHead());
      case AppRoutes.dashboardDeputyManager:
        return MaterialPageRoute(builder: (_) => const DashboardDeputyManager());
      case AppRoutes.dashboardPjo:
        return MaterialPageRoute(builder: (_) => const DashboardPjo());
      case AppRoutes.dashboardDireksi:
        return MaterialPageRoute(builder: (_) => const DashboardDireksi());
      case AppRoutes.dashboardAdmin:
        return MaterialPageRoute(builder: (_) => const DashboardAdmin());
      
      // ============================================
      // CORE FEATURE ROUTES
      // ============================================
      case AppRoutes.formIsiFuel:
        return MaterialPageRoute(builder: (_) => const FormIsiFuel());
      case AppRoutes.formVerifikasi:
        return MaterialPageRoute(builder: (_) => const FormVerifikasi());
      case AppRoutes.history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case AppRoutes.approvalList:
        return MaterialPageRoute(builder: (_) => const ApprovalListScreen());
      case AppRoutes.approvalDetail:
        return MaterialPageRoute(
          builder: (_) => ApprovalDetailScreen(
            approvalId: args as String? ?? '',
          ),
        );
      case AppRoutes.operatorNotification:
        return MaterialPageRoute(builder: (_) => const OperatorNotificationPage());
      case AppRoutes.fuelmanNotification:
        return MaterialPageRoute(builder: (_) => const FuelmanNotificationPage());
      case AppRoutes.adminNotificationMonitor:
        return MaterialPageRoute(builder: (_) => const AdminNotificationMonitor());
      case AppRoutes.notificationStats:
        return MaterialPageRoute(builder: (_) => const NotificationStatsDashboard());
      
      // ============================================
      // REPORT & AUDIT ROUTES
      // ============================================
      case AppRoutes.monthlyReport:
        return MaterialPageRoute(builder: (_) => const MonthlyReportScreen());
      case AppRoutes.operatorRanking:
        return MaterialPageRoute(builder: (_) => const OperatorRankingScreen());
      case AppRoutes.auditTrail:
        return MaterialPageRoute(builder: (_) => const AuditTrailScreen());
      
      // ============================================
      // ALERT ROUTES
      // ============================================
      case AppRoutes.alertDashboard:
        return MaterialPageRoute(builder: (_) => const AlertDashboardScreen());
      
      // ============================================
      // MS-49 & MS-51: ADMIN MANAGEMENT ROUTES
      // ============================================
      case AppRoutes.adminUserPositions:
        return MaterialPageRoute(builder: (_) => const UserPositionManagementScreen());
      case AppRoutes.adminTemporaryAssignments:
        return MaterialPageRoute(builder: (_) => const TemporaryAssignmentScreen());
      case AppRoutes.adminPositionHistory:
        return MaterialPageRoute(
          builder: (_) => PositionHistoryScreen(
            userId: args as String?,
          ),
        );
      case AppRoutes.adminOrganizationStructure:
        return MaterialPageRoute(builder: (_) => const OrganizationStructureScreen());
      
      // ============================================
      // MS-53 & MS-54: ESCALATION DASHBOARD ROUTES
      // ============================================
      case AppRoutes.escalationSectionHead:
        return MaterialPageRoute(builder: (_) => const EscalationDashboardSectionHead());
      case AppRoutes.escalationDepartmentHead:
        return MaterialPageRoute(builder: (_) => const EscalationDashboardDepartmentHead());
      case AppRoutes.escalationDeputy:
        return MaterialPageRoute(builder: (_) => const EscalationDashboardDeputy());
      case AppRoutes.escalationPjo:
        return MaterialPageRoute(builder: (_) => const EscalationDashboardPjo());
      case AppRoutes.executiveDashboard:
        return MaterialPageRoute(builder: (_) => const ExecutiveDashboardEnhanced());
      
      // ============================================
      // DEFAULT: 404
      // ============================================
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Route not found: ${settings.name}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to login
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
  
  // ============================================
  // ALL ROUTES MAP (for navigation)
  // ============================================
  static Map<String, WidgetBuilder> get allRoutes {
    return {
      AppRoutes.login: (context) => const LoginScreen(),
      AppRoutes.dashboardOperator: (context) => const DashboardOperator(),
      AppRoutes.dashboardFuelman: (context) => const DashboardFuelman(),
      AppRoutes.dashboardSupervisor: (context) => const DashboardSupervisor(),
      AppRoutes.dashboardSectionHead: (context) => const DashboardSectionHead(),
      AppRoutes.dashboardDepartmentHead: (context) => const DashboardDepartmentHead(),
      AppRoutes.dashboardDeputyManager: (context) => const DashboardDeputyManager(),
      AppRoutes.dashboardPjo: (context) => const DashboardPjo(),
      AppRoutes.dashboardDireksi: (context) => const DashboardDireksi(),
      AppRoutes.dashboardAdmin: (context) => const DashboardAdmin(),
      AppRoutes.formIsiFuel: (context) => const FormIsiFuel(),
      AppRoutes.formVerifikasi: (context) => const FormVerifikasi(),
      AppRoutes.history: (context) => const HistoryScreen(),
      AppRoutes.approvalList: (context) => const ApprovalListScreen(),
      AppRoutes.operatorNotification: (context) => const OperatorNotificationPage(),
      AppRoutes.fuelmanNotification: (context) => const FuelmanNotificationPage(),
      AppRoutes.adminNotificationMonitor: (context) => const AdminNotificationMonitor(),
      AppRoutes.notificationStats: (context) => const NotificationStatsDashboard(),
      AppRoutes.monthlyReport: (context) => const MonthlyReportScreen(),
      AppRoutes.operatorRanking: (context) => const OperatorRankingScreen(),
      AppRoutes.auditTrail: (context) => const AuditTrailScreen(),
      AppRoutes.alertDashboard: (context) => const AlertDashboardScreen(),
      // MS-49 & MS-51: Admin Routes
      AppRoutes.adminUserPositions: (context) => const UserPositionManagementScreen(),
      AppRoutes.adminTemporaryAssignments: (context) => const TemporaryAssignmentScreen(),
      AppRoutes.adminOrganizationStructure: (context) => const OrganizationStructureScreen(),
      // MS-53 & MS-54: Escalation Routes
      AppRoutes.escalationSectionHead: (context) => const EscalationDashboardSectionHead(),
      AppRoutes.escalationDepartmentHead: (context) => const EscalationDashboardDepartmentHead(),
      AppRoutes.escalationDeputy: (context) => const EscalationDashboardDeputy(),
      AppRoutes.escalationPjo: (context) => const EscalationDashboardPjo(),
      AppRoutes.executiveDashboard: (context) => const ExecutiveDashboardEnhanced(),
    };
  }
}