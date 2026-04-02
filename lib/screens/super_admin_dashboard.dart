import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../config/branding.dart';

class SuperAdminDashboard extends StatefulWidget {
  final User user;

  const SuperAdminDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = false;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _initPages();
  }

  void _initPages() {
    _pages.addAll([
      _buildOverviewPage(),
      _buildCompaniesPage(),
      _buildUsersPage(),
      _buildSubscriptionsPage(),
      _buildSystemConfigPage(),
      _buildAuditLogsPage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        backgroundColor: Branding.primaryColor,
        elevation: 0,
        actions: [
          // Session timer indicator
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              final remaining = authProvider.sessionRemainingSeconds;
              final minutes = remaining ~/ 60;
              final seconds = remaining % 60;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, authProvider),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pages[_selectedIndex],
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.user.name),
            accountEmail: Text(widget.user.email ?? widget.user.username),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            decoration: BoxDecoration(
              color: Branding.primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Overview'),
            selected: _selectedIndex == 0,
            onTap: () => _onItemTapped(0),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Companies'),
            selected: _selectedIndex == 1,
            onTap: () => _onItemTapped(1),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            selected: _selectedIndex == 2,
            onTap: () => _onItemTapped(2),
          ),
          ListTile(
            leading: const Icon(Icons.subscriptions),
            title: const Text('Subscriptions'),
            selected: _selectedIndex == 3,
            onTap: () => _onItemTapped(3),
          ),
          ListTile(
            leading: const Icon(Icons.settings_applications),
            title: const Text('System Config'),
            selected: _selectedIndex == 4,
            onTap: () => _onItemTapped(4),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Audit Logs'),
            selected: _selectedIndex == 5,
            onTap: () => _onItemTapped(5),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close drawer
  }

  // ============================================
  // OVERVIEW PAGE
  // ============================================
  Widget _buildOverviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Branding.primaryColor, Branding.primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Super Admin!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have full control over the system.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Total Companies', '1', Icons.business),
                    const SizedBox(width: 12),
                    _buildStatCard('Total Users', '12', Icons.people),
                    const SizedBox(width: 12),
                    _buildStatCard('Active Subs', '1', Icons.subscriptions),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildQuickActionCard(
                icon: Icons.business,
                title: 'Add Company',
                color: Colors.blue,
                onTap: () {
                  _showAddCompanyDialog();
                },
              ),
              _buildQuickActionCard(
                icon: Icons.person_add,
                title: 'Add User',
                color: Colors.green,
                onTap: () {
                  _showAddUserDialog();
                },
              ),
              _buildQuickActionCard(
                icon: Icons.subscriptions,
                title: 'Manage Plans',
                color: Colors.orange,
                onTap: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
              ),
              _buildQuickActionCard(
                icon: Icons.security,
                title: 'System Logs',
                color: Colors.purple,
                onTap: () {
                  setState(() {
                    _selectedIndex = 5;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // COMPANIES PAGE
  // ============================================
  Widget _buildCompaniesPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Companies',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _showAddCompanyDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Company'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Company Code')),
              DataColumn(label: Text('Company Name')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              const DataRow(cells: [
                DataCell(Text('1')),
                DataCell(Text('DEMO01')),
                DataCell(Text('Demo Company')),
                DataCell(Icon(Icons.check_circle, color: Colors.green)),
                DataCell(Row(
                  children: [
                    IconButton(icon: Icon(Icons.edit), onPressed: null),
                    IconButton(icon: Icon(Icons.delete), onPressed: null),
                  ],
                )),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // USERS PAGE
  // ============================================
  Widget _buildUsersPage() {
    final users = [
      {'id': 'admin', 'name': 'System Administrator', 'role': 'admin', 'company': 'DEMO01'},
      {'id': 'superadmin', 'name': 'Super Administrator', 'role': 'super_admin', 'company': 'DEMO01'},
      {'id': 'opr001', 'name': 'Budi Santoso', 'role': 'operator', 'company': 'DEMO01'},
      {'id': 'fml001', 'name': 'Ahmad Fauzi', 'role': 'fuelman', 'company': 'DEMO01'},
      {'id': 'spv001', 'name': 'Supervisor Site', 'role': 'supervisor', 'company': 'DEMO01'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Users',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _showAddUserDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add User'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('User ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Company')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: users.map((user) {
                return DataRow(cells: [
                  DataCell(Text(user['id']!)),
                  DataCell(Text(user['name']!)),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user['role']!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user['role']!,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  )),
                  DataCell(Text(user['company']!)),
                  const DataCell(Icon(Icons.check_circle, color: Colors.green)),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => _showEditUserDialog(user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        onPressed: () => _confirmDeleteUser(user),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'super_admin':
        return Colors.purple;
      case 'admin':
        return Colors.red;
      case 'direksi':
        return Colors.orange;
      case 'pjo':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  // ============================================
  // SUBSCRIPTIONS PAGE
  // ============================================
  Widget _buildSubscriptionsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Subscription Plans',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildPlanCard('Basic', 'Rp 3.500.000', 'Per month', Colors.blue, false)),
            const SizedBox(width: 12),
            Expanded(child: _buildPlanCard('Premium', 'Rp 7.000.000', 'Per month', Colors.green, true)),
            const SizedBox(width: 12),
            Expanded(child: _buildPlanCard('Suite', 'Rp 15.000.000', 'Per month', Colors.purple, false)),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Active Subscriptions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Company')),
              DataColumn(label: Text('Plan')),
              DataColumn(label: Text('Start Date')),
              DataColumn(label: Text('End Date')),
              DataColumn(label: Text('Status')),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('Demo Company')),
                DataCell(Text('Premium')),
                DataCell(Text('2026-01-01')),
                DataCell(Text('2026-12-31')),
                DataCell(Icon(Icons.check_circle, color: Colors.green)),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(String name, String price, String period, Color color, bool isPopular) {
    return Card(
      elevation: isPopular ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPopular ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(price, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(period, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                minimumSize: const Size(double.infinity, 36),
              ),
              child: const Text('Select Plan'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // SYSTEM CONFIG PAGE
  // ============================================
  Widget _buildSystemConfigPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'System Configuration',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Session Timeout'),
                subtitle: const Text('30 minutes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Password Policy'),
                subtitle: const Text('Minimum 6 characters'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email Settings'),
                subtitle: const Text('SMTP configuration'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup & Restore'),
                subtitle: const Text('Database backup settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // AUDIT LOGS PAGE
  // ============================================
  Widget _buildAuditLogsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Audit Logs',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Timestamp')),
              DataColumn(label: Text('User')),
              DataColumn(label: Text('Action')),
              DataColumn(label: Text('Details')),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('2026-04-03 10:00:00')),
                DataCell(Text('admin')),
                DataCell(Text('Login')),
                DataCell(Text('Successful login')),
              ]),
              DataRow(cells: [
                DataCell(Text('2026-04-03 09:30:00')),
                DataCell(Text('opr001')),
                DataCell(Text('Fuel Entry')),
                DataCell(Text('Created new fuel entry')),
              ]),
              DataRow(cells: [
                DataCell(Text('2026-04-03 09:00:00')),
                DataCell(Text('spv001')),
                DataCell(Text('Approval')),
                DataCell(Text('Approved fuel entry')),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // DIALOGS
  // ============================================
  void _showAddCompanyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Company'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Company Code', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Company Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Company added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'User ID', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'operator', child: Text('Operator')),
                DropdownMenuItem(value: 'fuelman', child: Text('Fuelman')),
                DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, String> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User: ${user['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: user['name']),
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: user['email'] ?? ''),
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(Map<String, String> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete user ${user['id']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}