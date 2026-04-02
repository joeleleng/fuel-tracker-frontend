import 'package:flutter/material.dart';
import '../models/user.dart';
import '../config/branding.dart';

class PJODashboard extends StatefulWidget {
  final User user;

  const PJODashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<PJODashboard> createState() => _PJODashboardState();
}

class _PJODashboardState extends State<PJODashboard> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      PJOHomePage(user: widget.user),
      const PJOAlertsPage(),
      const PJOReportsPage(),
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
            const Text('Penanggung Jawab Operasional'),
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

class PJOHomePage extends StatelessWidget {
  final User user;

  const PJOHomePage({Key? key, required this.user}) : super(key: key);

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
            'Penanggung Jawab Operasional',
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
                title: 'Total Fuel',
                value: '0 L',
                icon: Icons.local_gas_station,
                color: Branding.primaryColor,
              ),
              _buildStatCard(
                title: 'Variance',
                value: '0%',
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
              _buildStatCard(
                title: 'Active Units',
                value: '0',
                icon: Icons.construction,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Alerts',
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
                    'Operational Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const ListTile(
                    leading: Icon(Icons.engineering),
                    title: Text('PJO Dashboard'),
                    subtitle: Text('Monitor operational fuel efficiency'),
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

class PJOAlertsPage extends StatelessWidget {
  const PJOAlertsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Alerts & Notifications for PJO'),
    );
  }
}

class PJOReportsPage extends StatelessWidget {
  const PJOReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Reports for PJO'),
    );
  }
}