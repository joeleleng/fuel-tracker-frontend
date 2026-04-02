/**
 * CUSTOM DRAWER WIDGET
 * Navigation drawer dengan menu berdasarkan role user
 * 
 * UPDATE: 30 Maret 2026
 * - Menambahkan menu untuk MS-49, MS-50, MS-51
 * - User Position Management, Temporary Assignment, Position History
 * - Role-based menu untuk 9 level akses
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/dashboard_operator.dart';
import '../screens/dashboard_fuelman.dart';
import '../screens/dashboard_supervisor.dart';
import '../screens/dashboard_section_head.dart';
import '../screens/dashboard_dept_head.dart';
import '../screens/dashboard_deputy.dart';
import '../screens/dashboard_pjo.dart';
import '../screens/dashboard_direksi.dart';
import '../screens/dashboard_admin.dart';
import '../screens/form_isi_fuel.dart';
import '../screens/form_verifikasi.dart';
import '../screens/history_screen.dart';
import '../screens/approval_list_screen.dart';
import '../screens/operator_notification.dart';
import '../screens/fuelman_notification.dart';
import '../screens/admin/user_position_management.dart';
import '../screens/admin/temporary_assignment_screen.dart';
import '../screens/admin/position_history_screen.dart';
import '../screens/admin/audit_trail_screen.dart';
import '../screens/monthly_report_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final role = user?.role ?? '';

    return Drawer(
      child: Column(
        children: [
          // Header dengan informasi user
          _buildDrawerHeader(context, user),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildMenuItems(context, role),
            ),
          ),
          // Footer dengan versi
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, user) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              user?.name?.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.name ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _getRoleDisplay(user?.role ?? ''),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            user?.userId ?? '',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, String role) {
    List<Widget> items = [];

    // ============================================
    // DASHBOARD (All Roles)
    // ============================================
    items.add(_buildMenuItem(
      context: context,
      icon: Icons.dashboard,
      label: 'Dashboard',
      onTap: () => _navigateToDashboard(context, role),
    ));

    // ============================================
    // OPERATOR MENU (Role: operator)
    // ============================================
    if (role == 'operator' || role == 'opr001') {
      items.add(_buildDivider());
      items.add(_buildSectionTitle('Fuel Operations'));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.local_gas_station,
        label: 'Isi Fuel',
        onTap: () => _navigateTo(context, const FormIsiFuelScreen()),
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.history,
        label: 'History',
        onTap: () => _navigateTo(context, const HistoryScreen()),
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.notifications,
        label: 'Notifications',
        onTap: () => _navigateTo(context, const OperatorNotificationScreen()),
      ));
    }

    // ============================================
    // FUELMAN MENU (Role: fuelman)
    // ============================================
    if (role == 'fuelman' || role == 'fml001') {
      items.add(_buildDivider());
      items.add(_buildSectionTitle('Verification'));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.verified,
        label: 'Verifikasi Fuel',
        onTap: () => _navigateTo(context, const FormVerifikasiScreen()),
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.history,
        label: 'History',
        onTap: () => _navigateTo(context, const HistoryScreen()),
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.notifications,
        label: 'Notifications',
        onTap: () => _navigateTo(context, const FuelmanNotificationScreen()),
      ));
    }

    // ============================================
    // SUPERVISOR MENU (Role: supervisor)
    // ============================================
    if (role == 'supervisor' || role == 'spv001') {
      items.add(_buildDivider());
      items.add(_buildSectionTitle('Approval Management'));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.check_circle,
        label: 'Pending Approvals',
        onTap: () => _navigateTo(context, const ApprovalListScreen()),
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.warning,
        label: 'Alerts',
        onTap: () => _navigateTo(context, const AlertListScreen()),
      ));
    }

    // ============================================
    // SECTION HEAD MENU (Role: section_head)
    // ============================================
    if (role == 'section_head' || role == 'sh001') {
      items.add(_buildDivider());
      items.add(_buildSectionTitle('Section Overview'));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.assessment,
        label: 'Section Reports',
        onTap: () => _navigateTo(context, const MonthlyReportScreen()),
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.warning,
        label: 'Escalations',
        onTap: () => _navigateTo(context, const EscalationDashboardScreen()),
      ));
    }

    // ============================================
    // DEPARTMENT HEAD MENU (Role: department_head)
    // ============================================
    if (role == 'department_head' || role == 'dh001') {
      items.add(_buildDivider());
      items.add(_buildSectionTitle('Department Overview'));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.bar_chart,
        label: 'Department Reports',
        onTap: () => _navigateTo(context, const MonthlyReportScreen()),
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.trending_up,
        label: 'Performance',
        onTap: () => _navigateTo(context, const PerformanceScreen()),
      ));
    }

    // ============================================
    // DEPUTY MANAGER MENU (Role: deputy_manager)
    // ============================================
    if (role == 'deputy_manager' || role == 'dep001') {
      items.add(_buildDivider());
      items.add(_buildSectionTitle('Management Overview'));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.analytics,
        label: 'Analytics',
        onTap: () => _navigateTo(context, const MonthlyReportScreen()),
      ));
    }

    // ============================================
    // PJO MENU (Role: pjo)
    // ============================================
    if (role == 'pjo' || role == 'pjo001') {
      items.add(_buildDivider());
      items.add(_buildSectionTitle('Operational Control'));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.control_point,
        label: 'Operational Report',
        onTap: () => _navigateTo(context, const MonthlyReportScreen()),
      ));
    }

    // ============================================
    // DIREKSI MENU (Role: direksi)
    // ============================================
    if (role == 'direksi' || role == 'dir001') {
      items.add(_buildDivider());
      items.add(_buildSectionTitle('Executive Dashboard'));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.insights,
        label: 'Executive Report',
        onTap: () => _navigateTo(context, const ExecutiveDashboardScreen()),
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.download,
        label: 'Download Reports',
        onTap: () => _showDownloadDialog(context),
      ));
    }

    // ============================================
    // ADMIN MENU (Role: admin)
    // MS-49, MS-50, MS-51: Menu baru untuk admin
    // ============================================
    if (role == 'admin' || role == 'super_admin') {
      items.add(_buildDivider());
      items.add(_buildSectionTitle('👥 User Management'));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.people,
        label: 'User Position Management',
        onTap: () => _navigateTo(context, const UserPositionManagementScreen()),
        isNew: true,
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.beach_access,
        label: 'Temporary Assignment',
        onTap: () => _navigateTo(context, const TemporaryAssignmentScreen()),
        isNew: true,
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.history,
        label: 'Position History',
        onTap: () => _navigateTo(context, const PositionHistoryScreen()),
        isNew: true,
      ));

      items.add(_buildDivider());
      items.add(_buildSectionTitle('⚙️ System Management'));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.bar_chart,
        label: 'Reports & Analytics',
        onTap: () => _navigateTo(context, const MonthlyReportScreen()),
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.security,
        label: 'Audit Trail',
        onTap: () => _navigateTo(context, const AuditTrailScreen()),
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.account_tree,
        label: 'Organization Structure',
        onTap: () => _navigateTo(context, const OrganizationStructureScreen()),
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.notifications_active,
        label: 'Escalation Rules',
        onTap: () => _navigateTo(context, const EscalationRulesScreen()),
      ));
    }

    // ============================================
    // LOGOUT (All Roles)
    // ============================================
    items.add(_buildDivider());
    items.add(_buildMenuItem(
      context: context,
      icon: Icons.logout,
      label: 'Logout',
      onTap: () => _logout(context),
      isDestructive: true,
    ));

    return items;
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isNew = false,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDestructive ? Colors.red : null,
            ),
          ),
          if (isNew) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Fuel Tracker & Control System',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v2.0.0 | © 2026 Yohanes Kristofel Sentosa Leleng',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplay(String role) {
    switch (role) {
      case 'operator':
      case 'opr001':
        return 'Operator';
      case 'fuelman':
      case 'fml001':
        return 'Fuelman';
      case 'supervisor':
      case 'spv001':
        return 'Supervisor';
      case 'section_head':
      case 'sh001':
        return 'Section Head';
      case 'department_head':
      case 'dh001':
        return 'Department Head';
      case 'deputy_manager':
      case 'dep001':
        return 'Deputy Manager';
      case 'pjo':
      case 'pjo001':
        return 'PJO';
      case 'direksi':
      case 'dir001':
        return 'Direksi';
      case 'admin':
      case 'super_admin':
        return 'Administrator';
      default:
        return role;
    }
  }

  void _navigateToDashboard(BuildContext context, String role) {
    Widget dashboard;
    switch (role) {
      case 'operator':
      case 'opr001':
        dashboard = const DashboardOperatorScreen();
        break;
      case 'fuelman':
      case 'fml001':
        dashboard = const DashboardFuelmanScreen();
        break;
      case 'supervisor':
      case 'spv001':
        dashboard = const DashboardSupervisorScreen();
        break;
      case 'section_head':
      case 'sh001':
        dashboard = const DashboardSectionHeadScreen();
        break;
      case 'department_head':
      case 'dh001':
        dashboard = const DashboardDepartmentHeadScreen();
        break;
      case 'deputy_manager':
      case 'dep001':
        dashboard = const DashboardDeputyScreen();
        break;
      case 'pjo':
      case 'pjo001':
        dashboard = const DashboardPJOScreen();
        break;
      case 'direksi':
      case 'dir001':
        dashboard = const DashboardDireksiScreen();
        break;
      case 'admin':
      case 'super_admin':
        dashboard = const DashboardAdminScreen();
        break;
      default:
        dashboard = const DashboardOperatorScreen();
    }
    _navigateTo(context, dashboard);
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await authProvider.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Reports'),
        content: const Text('Select report format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Excel export coming soon in Phase 4-7')),
              );
            },
            child: const Text('Excel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF export coming soon in Phase 4-7')),
              );
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// PLACEHOLDER SCREENS (Akan diimplementasikan di fase selanjutnya)
// ============================================

class AlertListScreen extends StatelessWidget {
  const AlertListScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: const Center(
        child: Text('Alert list will be implemented in MS-53'),
      ),
    );
  }
}

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance')),
      body: const Center(
        child: Text('Performance dashboard will be implemented in MS-54'),
      ),
    );
  }
}

class ExecutiveDashboardScreen extends StatelessWidget {
  const ExecutiveDashboardScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Executive Dashboard')),
      body: const Center(
        child: Text('Executive dashboard will be implemented in MS-54'),
      ),
    );
  }
}

class EscalationDashboardScreen extends StatelessWidget {
  const EscalationDashboardScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escalation Dashboard')),
      body: const Center(
        child: Text('Escalation dashboard will be implemented in MS-53'),
      ),
    );
  }
}

class OrganizationStructureScreen extends StatelessWidget {
  const OrganizationStructureScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organization Structure')),
      body: const Center(
        child: Text('Organization structure view will be implemented'),
      ),
    );
  }
}

class EscalationRulesScreen extends StatelessWidget {
  const EscalationRulesScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escalation Rules')),
      body: const Center(
        child: Text('Escalation rules configuration will be implemented'),
      ),
    );
  }
}