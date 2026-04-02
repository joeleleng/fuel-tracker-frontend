import 'package:flutter/material.dart';
import '../models/user.dart';
import '../config/branding.dart';

class DeputyDashboard extends StatefulWidget {
  final User user;

  const DeputyDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<DeputyDashboard> createState() => _DeputyDashboardState();
}

class _DeputyDashboardState extends State<DeputyDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DeputyHomePage(user: widget.user),
      const DeputyAlertsPage(),
      const DeputyReportsPage(),
    ];
  }

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Deputy Manager'),
            Text(
              widget.user.name,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Branding.primaryColor,
        foregroundColor: Colors.white,
        actions: [
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
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

class DeputyHomePage extends StatelessWidget {
  final User user;

  const DeputyHomePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${user.name}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Deputy Manager - ${user.departmentName ?? "Operasional"}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                title: 'Total Fuel (Company)',
                value: '0 KL',
                icon: Icons.local_gas_station,
                color: Branding.primaryColor,
              ),
              _buildStatCard(
                title: 'Avg Variance',
                value: '0%',
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
              _buildStatCard(
                title: 'Total Units',
                value: '0',
                icon: Icons.construction,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Critical Alerts',
                value: '0',
                icon: Icons.warning,
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Company Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const ListTile(
                    leading: Icon(Icons.business),
                    title: Text('Deputy Manager Dashboard'),
                    subtitle: Text('Monitoring fuel usage across all departments'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.trending_up),
                    title: Text('Performance Summary'),
                    subtitle: Text('Coming Soon'),
                  ),
                ],
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
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DeputyAlertsPage extends StatelessWidget {
  const DeputyAlertsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Alerts & Notifications for Deputy Manager'),
    );
  }
}

class DeputyReportsPage extends StatelessWidget {
  const DeputyReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Reports for Deputy Manager'),
    );
  }
}