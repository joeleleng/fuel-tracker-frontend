import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Admin Dashboard'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  _buildWelcomeCard(),
                  const SizedBox(height: 24),
                  
                  // Statistics Cards
                  _buildStatisticsSection(),
                  const SizedBox(height: 24),
                  
                  // Quick Actions Section
                  _buildQuickActionsSection(),
                  const SizedBox(height: 24),
                  
                  // Management Cards Grid
                  _buildManagementGrid(),
                  const SizedBox(height: 24),
                  
                  // Recent Activity Section
                  _buildRecentActivitySection(),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentUser?.name ?? 'Admin',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fuel Tracker & Control System v2.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Administrator Access',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              icon: Icons.people,
              title: 'Total Users',
              value: '12',
              color: Colors.blue,
              onTap: () => _navigateTo('/admin/users'),
            ),
            _buildStatCard(
              icon: Icons.work,
              title: 'Active Positions',
              value: '9',
              color: Colors.green,
              onTap: () => _navigateTo('/admin/positions'),
            ),
            _buildStatCard(
              icon: Icons.local_gas_station,
              title: 'Fuel Entries',
              value: '156',
              color: Colors.orange,
              onTap: () => _navigateTo('/admin/fuel-entries'),
            ),
            _buildStatCard(
              icon: Icons.warning,
              title: 'Active Alerts',
              value: '3',
              color: Colors.red,
              onTap: () => _navigateTo('/admin/alerts'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickActionButton(
                icon: Icons.person_add,
                label: 'Add User',
                color: Colors.green,
                onTap: () => _navigateTo('/admin/users/add'),
              ),
              const SizedBox(width: 12),
              _buildQuickActionButton(
                icon: Icons.assignment_add,
                label: 'New Assignment',
                color: Colors.blue,
                onTap: () => _navigateTo('/admin/temporary-assignments/add'),
              ),
              const SizedBox(width: 12),
              _buildQuickActionButton(
                icon: Icons.upload_file,
                label: 'Export Report',
                color: Colors.orange,
                onTap: () => _showExportDialog(),
              ),
              const SizedBox(width: 12),
              _buildQuickActionButton(
                icon: Icons.sync,
                label: 'Sync Data',
                color: Colors.purple,
                onTap: () => _syncData(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildManagementGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildManagementCard(
              icon: Icons.people,
              title: 'User Position',
              subtitle: 'Manage mutasi & promosi',
              color: Colors.blue,
              onTap: () => _navigateTo('/admin/user-positions'),
            ),
            _buildManagementCard(
              icon: Icons.beach_access,
              title: 'Temporary Assignment',
              subtitle: 'Cuti, sakit, tugas luar',
              color: Colors.teal,
              onTap: () => _navigateTo('/admin/temporary-assignments'),
            ),
            _buildManagementCard(
              icon: Icons.history,
              title: 'Position History',
              subtitle: 'Audit trail perubahan',
              color: Colors.orange,
              onTap: () => _navigateTo('/admin/position-history'),
            ),
            _buildManagementCard(
              icon: Icons.bar_chart,
              title: 'Reports',
              subtitle: 'Laporan bulanan & audit',
              color: Colors.purple,
              onTap: () => _navigateTo('/admin/reports'),
            ),
            _buildManagementCard(
              icon: Icons.security,
              title: 'Audit Trail',
              subtitle: 'Log semua perubahan',
              color: Colors.red,
              onTap: () => _navigateTo('/admin/audit'),
            ),
            _buildManagementCard(
              icon: Icons.settings,
              title: 'System Config',
              subtitle: 'Konfigurasi sistem',
              color: Colors.grey,
              onTap: () => _navigateTo('/admin/config'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActivityColor(index),
                  child: Icon(_getActivityIcon(index), size: 18, color: Colors.white),
                ),
                title: Text(_getActivityTitle(index)),
                subtitle: Text(_getActivitySubtitle(index)),
                trailing: Text(
                  _getActivityTime(index),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getActivityColor(int index) {
    const colors = [Colors.green, Colors.blue, Colors.orange, Colors.red, Colors.purple];
    return colors[index % colors.length];
  }

  IconData _getActivityIcon(int index) {
    const icons = [Icons.person_add, Icons.swap_horiz, Icons.check_circle, Icons.warning, Icons.upload];
    return icons[index % icons.length];
  }

  String _getActivityTitle(int index) {
    const titles = [
      'New user registered',
      'Position changed',
      'Fuel entry approved',
      'Alert triggered',
      'Report generated',
    ];
    return titles[index % titles.length];
  }

  String _getActivitySubtitle(int index) {
    const subtitles = [
      'Operator opr003 added by Admin',
      'opr001 promoted to Supervisor',
      'Fuel entry #156 approved',
      'High variance detected on Unit EXC-01',
      'Monthly report exported',
    ];
    return subtitles[index % subtitles.length];
  }

  String _getActivityTime(int index) {
    const times = ['5 min ago', '1 hour ago', '2 hours ago', '3 hours ago', 'Yesterday'];
    return times[index % times.length];
  }

  void _navigateTo(String route) {
    Navigator.pushNamed(context, route);
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: const Text('Select report type:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export started...')),
              );
            },
            child: const Text('Export Excel'),
          ),
        ],
      ),
    );
  }

  void _syncData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing data...')),
    );
    // TODO: Implement sync logic
    await Future.delayed(const Duration(seconds: 2));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync completed!')),
    );
  }
}