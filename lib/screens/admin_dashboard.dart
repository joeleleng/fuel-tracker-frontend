import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/hive_database_service.dart';
import '../config/branding.dart';
import 'admin/admin_notification_monitor.dart';
import 'admin/admin_report_page.dart';
import 'admin/user_position_management.dart';
import 'admin/temporary_assignment_screen.dart';
import 'admin/position_history_screen.dart';
import 'admin/audit_trail_screen.dart';

class AdminDashboard extends StatefulWidget {
  final User user;

  const AdminDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  final HiveDatabaseService _dbService = HiveDatabaseService();
  Map<String, dynamic> _notificationStats = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationStats();
    _pages = [
      AdminHomePage(notificationStats: _notificationStats, adminUser: widget.user),
      const AdminUsersPage(),
      const AdminUnitsPage(),
      const AdminReportPage(),
      AdminNotificationMonitor(user: widget.user),
    ];
  }

  Future<void> _loadNotificationStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final stats = await _dbService.getNotificationStatistics();
      setState(() {
        _notificationStats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() => _isLoadingStats = false);
      print('Error loading notification stats: $e');
    }
  }

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug log untuk role
    print('👑 Admin Dashboard - User role: ${widget.user.role}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard - ${widget.user.name}'),
        backgroundColor: Branding.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // MS-49, MS-50, MS-51: New Admin Menu Button
          PopupMenuButton<String>(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Menu',
            onSelected: (value) {
              switch (value) {
                case 'user_positions':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserPositionManagementScreen()),
                  );
                  break;
                case 'temporary':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TemporaryAssignmentScreen()),
                  );
                  break;
                case 'position_history':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PositionHistoryScreen()),
                  );
                  break;
                case 'audit_trail':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuditTrailScreen()),
                  );
                  break;
                case 'org_structure':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Organization Structure - Coming Soon')),
                  );
                  break;
                case 'escalation_rules':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Escalation Rules - Coming Soon in MS-52')),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              // Section Title
              const PopupMenuItem(
                enabled: false,
                child: Text(
                  '━━━ USER MANAGEMENT ━━━',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              const PopupMenuItem(
                value: 'user_positions',
                child: Row(
                  children: [
                    Icon(Icons.people, size: 20, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('User Position Management'),
                    SizedBox(width: 8),
                    Chip(
                      label: Text('NEW', style: TextStyle(fontSize: 9, color: Colors.white)),
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'temporary',
                child: Row(
                  children: [
                    Icon(Icons.beach_access, size: 20, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Temporary Assignment'),
                    SizedBox(width: 8),
                    Chip(
                      label: Text('NEW', style: TextStyle(fontSize: 9, color: Colors.white)),
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'position_history',
                child: Row(
                  children: [
                    Icon(Icons.history, size: 20, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Position History'),
                    SizedBox(width: 8),
                    Chip(
                      label: Text('NEW', style: TextStyle(fontSize: 9, color: Colors.white)),
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                enabled: false,
                child: Text(
                  '━━━ SYSTEM MANAGEMENT ━━━',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              const PopupMenuItem(
                value: 'audit_trail',
                child: Row(
                  children: [
                    Icon(Icons.security, size: 20, color: Colors.purple),
                    SizedBox(width: 12),
                    Text('Audit Trail'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'org_structure',
                child: Row(
                  children: [
                    Icon(Icons.account_tree, size: 20, color: Colors.teal),
                    SizedBox(width: 12),
                    Text('Organization Structure'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'escalation_rules',
                child: Row(
                  children: [
                    Icon(Icons.notifications_active, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Escalation Rules'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadNotificationStats();
              setState(() {
                _pages[0] = AdminHomePage(notificationStats: _notificationStats, adminUser: widget.user);
              });
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) {
              _loadNotificationStats();
              _pages[0] = AdminHomePage(notificationStats: _notificationStats, adminUser: widget.user);
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction),
            label: 'Units',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: 'Notifikasi',
          ),
        ],
      ),
    );
  }
}

class AdminHomePage extends StatelessWidget {
  final Map<String, dynamic> notificationStats;
  final User adminUser;

  const AdminHomePage({Key? key, this.notificationStats = const {}, required this.adminUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalOperatorNotes = notificationStats['total_operator_notes'] ?? 0;
    final unreadOperatorNotes = notificationStats['unread_operator_notes'] ?? 0;
    final totalFuelmanNotes = notificationStats['total_fuelman_notes'] ?? 0;
    final unreadFuelmanNotes = notificationStats['unread_fuelman_notes'] ?? 0;
    final totalUnread = unreadOperatorNotes + unreadFuelmanNotes;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Statistik Notifikasi - Card Khusus
          Card(
            color: totalUnread > 0 ? Colors.orange.shade50 : Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications,
                        color: totalUnread > 0 ? Colors.orange : Colors.green,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Status Notifikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNotifStat(
                          title: 'Operator',
                          total: totalOperatorNotes,
                          unread: unreadOperatorNotes,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildNotifStat(
                          title: 'Fuelman',
                          total: totalFuelmanNotes,
                          unread: unreadFuelmanNotes,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (totalUnread > 0)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${totalUnread} notifikasi belum dibaca oleh penerima',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminNotificationMonitor(user: adminUser),
                                  ),
                                );
                              },
                              child: const Text('Lihat Detail'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // MS-49, MS-50, MS-51: NEW SECTION - Organization Management
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.business_center, color: Colors.blue.shade700),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Organization Management',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Manage user positions, temporary assignments, and view history',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOrgMenuCard(
                          context: context,
                          icon: Icons.people,
                          title: 'User Position',
                          subtitle: 'Manage promotions & mutations',
                          color: Colors.blue,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const UserPositionManagementScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOrgMenuCard(
                          context: context,
                          icon: Icons.beach_access,
                          title: 'Temporary',
                          subtitle: 'Leave & sick assignments',
                          color: Colors.orange,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TemporaryAssignmentScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOrgMenuCard(
                          context: context,
                          icon: Icons.history,
                          title: 'History',
                          subtitle: 'View position changes',
                          color: Colors.green,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PositionHistoryScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // KPI Cards Grid - FIXED: Add SizedBox with constraints to prevent infinite width
          SizedBox(
            height: 180,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  title: 'Total Users',
                  value: '12',
                  icon: Icons.people,
                  color: Branding.primaryColor,
                ),
                _buildStatCard(
                  title: 'Active Units',
                  value: '6',
                  icon: Icons.construction,
                  color: Branding.successColor,
                ),
                _buildStatCard(
                  title: 'Fuel Entries (Today)',
                  value: '0',
                  icon: Icons.local_gas_station,
                  color: Branding.warningColor,
                ),
                _buildStatCard(
                  title: 'Pending Approvals',
                  value: '0',
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildActionChip(
                        icon: Icons.people,
                        label: 'User Position',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const UserPositionManagementScreen()),
                          );
                        },
                      ),
                      _buildActionChip(
                        icon: Icons.beach_access,
                        label: 'Temporary Assignment',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TemporaryAssignmentScreen()),
                          );
                        },
                      ),
                      _buildActionChip(
                        icon: Icons.history,
                        label: 'Position History',
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PositionHistoryScreen()),
                          );
                        },
                      ),
                      _buildActionChip(
                        icon: Icons.notifications_active,
                        label: 'Monitoring Notifikasi',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminNotificationMonitor(user: adminUser),
                            ),
                          );
                        },
                      ),
                      _buildActionChip(
                        icon: Icons.report,
                        label: 'Laporan Bulanan',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminReportPage(),
                            ),
                          );
                        },
                      ),
                      _buildActionChip(
                        icon: Icons.security,
                        label: 'Audit Trail',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AuditTrailScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Admin Login'),
                    subtitle: Text('${DateTime.now().toString().substring(0, 19)}'),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('System Ready'),
                    subtitle: const Text('All systems operational'),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrgMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifStat({
    required String title,
    required int total,
    required int unread,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$total',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Total',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: unread > 0 ? Colors.red.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$unread belum dibaca',
              style: TextStyle(
                fontSize: 10,
                color: unread > 0 ? Colors.red.shade700 : Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
    );
  }
}

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'User Management',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to User Position Management
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const UserPositionManagementScreen()),
                          );
                        },
                        icon: const Icon(Icons.people),
                        label: const Text('Manage Positions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Branding.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Use "User Position Management" from the admin menu to manage user positions, promotions, and mutations.'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PositionHistoryScreen()),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('View Position History'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AdminUnitsPage extends StatelessWidget {
  const AdminUnitsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Unit Management',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur Unit Management sedang dalam pengembangan'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Unit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Branding.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Coming Soon - Unit Management Features'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}