import 'package:flutter/material.dart';
import '../models/user.dart';
import '../config/branding.dart';

class DireksiDashboard extends StatefulWidget {
  final User user;

  const DireksiDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<DireksiDashboard> createState() => _DireksiDashboardState();
}

class _DireksiDashboardState extends State<DireksiDashboard> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DireksiHomePage(user: widget.user),
      const DireksiAlertsPage(),
      const DireksiReportsPage(),
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
            const Text('Direksi'),
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

class DireksiHomePage extends StatelessWidget {
  final User user;

  const DireksiHomePage({Key? key, required this.user}) : super(key: key);

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
            'Executive Dashboard',
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
                title: 'Variance (Company)',
                value: '0%',
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
              _buildStatCard(
                title: 'Total Loss',
                value: 'Rp 0',
                icon: Icons.money_off,
                color: Colors.red,
              ),
              _buildStatCard(
                title: 'Active Units',
                value: '0',
                icon: Icons.construction,
                color: Colors.green,
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
                    'Executive Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const ListTile(
                    leading: Icon(Icons.business_center),
                    title: Text('Corporate Fuel Performance'),
                    subtitle: Text('Overall company fuel efficiency metrics'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.trending_down),
                    title: Text('Monthly Variance Trend'),
                    subtitle: Text('Last 6 months performance'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Export Reports'),
                    subtitle: Text('Download monthly reports in Excel/PDF'),
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

class DireksiAlertsPage extends StatelessWidget {
  const DireksiAlertsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Corporate Alerts',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.warning, color: Colors.orange),
                    title: Text('Critical Alerts'),
                    subtitle: Text('Alerts that require immediate attention'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.info, color: Colors.blue),
                    title: Text('Information Alerts'),
                    subtitle: Text('General information for awareness'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DireksiReportsPage extends StatelessWidget {
  const DireksiReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Corporate Reports',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Monthly Fuel Report'),
                    subtitle: const Text('Download full monthly report'),
                    onTap: () {
                      // TODO: Implement export
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Export feature coming soon'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.trending_up),
                    title: const Text('Performance Dashboard'),
                    subtitle: const Text('View executive dashboard'),
                    onTap: () {
                      // TODO: Navigate to executive dashboard
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.business),
                    title: const Text('Department Performance'),
                    subtitle: const Text('Compare performance by department'),
                    onTap: () {
                      // TODO: Navigate to department comparison
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}