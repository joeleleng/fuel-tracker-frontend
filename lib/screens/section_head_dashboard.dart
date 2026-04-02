import 'package:flutter/material.dart';
import '../models/user.dart';
import '../config/branding.dart';

class SectionHeadDashboard extends StatefulWidget {
  final User user;

  const SectionHeadDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<SectionHeadDashboard> createState() => _SectionHeadDashboardState();
}

class _SectionHeadDashboardState extends State<SectionHeadDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      SectionHeadHomePage(user: widget.user),
      const SectionHeadAlertsPage(),
      const SectionHeadReportsPage(),
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
            const Text('Section Head Dashboard'),
            Text(
              '${widget.user.name} | ${widget.user.sectionName ?? "Section"}',
              style: const TextStyle(fontSize: 12),
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

class SectionHeadHomePage extends StatelessWidget {
  final User user;

  const SectionHeadHomePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Branding.primaryColor, Branding.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Section: ${user.sectionName ?? "N/A"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // KPI Cards
          const Text(
            'Section Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
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

          // Recent Activity Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.blue),
                    title: const Text('Section Head Dashboard'),
                    subtitle: Text('Monitoring fuel usage in ${user.sectionName ?? "your section"}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to details
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.local_gas_station, color: Colors.green),
                    title: const Text('Fuel Summary'),
                    subtitle: const Text('View fuel consumption report'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to fuel summary
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

class SectionHeadAlertsPage extends StatelessWidget {
  const SectionHeadAlertsPage({Key? key}) : super(key: key);

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
                const Text(
                  'Alerts & Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('No pending alerts'),
                  subtitle: Text('All systems are operating normally'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SectionHeadReportsPage extends StatelessWidget {
  const SectionHeadReportsPage({Key? key}) : super(key: key);

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
                const Text(
                  'Reports',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('Coming Soon - Section Reports'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Export Section Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Branding.primaryColor,
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