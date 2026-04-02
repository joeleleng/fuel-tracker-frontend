import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/fuel_entry_hive.dart';
import '../services/hive_database_service.dart';
import '../config/branding.dart';
import 'fuelman_fuel_form.dart';
import 'fuelman_notification_page.dart';

class FuelmanDashboard extends StatefulWidget {
  final User user;

  const FuelmanDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<FuelmanDashboard> createState() => _FuelmanDashboardState();
}

class _FuelmanDashboardState extends State<FuelmanDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  final HiveDatabaseService _dbService = HiveDatabaseService();
  int _notificationCount = 0;
  bool _isLoadingNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
    _pages = [
      FuelmanHomePage(user: widget.user, notificationCount: _notificationCount),
      const FuelmanFuelFormPage(),
      const FuelmanHistoryPage(),
      FuelmanNotificationPage(user: widget.user),
    ];
  }

  Future<void> _loadNotificationCount() async {
    setState(() => _isLoadingNotifications = true);
    try {
      final count = await _dbService.getFuelmanNotificationCount(widget.user.username);
      setState(() {
        _notificationCount = count;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      setState(() => _isLoadingNotifications = false);
      print('Error loading notification count: $e');
    }
  }

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  void _navigateToNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FuelmanNotificationPage(user: widget.user),
      ),
    );
    _loadNotificationCount(); // Refresh setelah kembali
    // Update home page notification count
    setState(() {
      _pages[0] = FuelmanHomePage(user: widget.user, notificationCount: _notificationCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fuelman Dashboard - ${widget.user.name}'),
        backgroundColor: Branding.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Notifikasi Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _navigateToNotifications,
                tooltip: 'Notifikasi',
              ),
              if (_notificationCount > 0 && !_isLoadingNotifications)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
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
            if (index == 3) {
              _loadNotificationCount(); // Refresh saat buka notifikasi
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_gas_station),
            label: 'Isi Fuel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
        ],
      ),
    );
  }
}

class FuelmanHomePage extends StatelessWidget {
  final User user;
  final int notificationCount;

  const FuelmanHomePage({Key? key, required this.user, this.notificationCount = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Fuelman',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Verify and record fuel transactions',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          
          // Notifikasi Ringkasan Card
          if (notificationCount > 0)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FuelmanNotificationPage(user: user),
                  ),
                );
              },
              child: Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pesan dari Supervisor',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '$notificationCount notifikasi baru',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
                    ],
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Action Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 500;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildActionCard(
                    context: context,
                    title: 'Verify Fuel',
                    subtitle: 'Verify operator fuel entries',
                    icon: Icons.verified,
                    color: Branding.primaryColor,
                    isWide: isWide,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FuelmanFuelForm(user: user),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context: context,
                    title: 'Input Fuel',
                    subtitle: 'Record new fuel dispensing',
                    icon: Icons.local_gas_station,
                    color: Branding.secondaryColor,
                    isWide: isWide,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FuelmanFuelForm(user: user),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context: context,
                    title: 'View History',
                    subtitle: 'View recent transactions',
                    icon: Icons.history,
                    color: Colors.orange,
                    isWide: isWide,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('History feature coming soon'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context: context,
                    title: 'Reports',
                    subtitle: 'View daily summary',
                    icon: Icons.report,
                    color: Colors.blue,
                    isWide: isWide,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reports feature coming soon'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Today's Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Total Fuel', '0 L', Icons.local_gas_station),
                      _buildSummaryItem('Transactions', '0', Icons.receipt),
                      _buildSummaryItem('Pending', '0', Icons.pending),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Footer
          Center(
            child: Text(
              Branding.copyrightText,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isWide,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: isWide ? (MediaQuery.of(context).size.width / 2) - 24 : double.infinity,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Branding.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class FuelmanFuelFormPage extends StatelessWidget {
  const FuelmanFuelFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_gas_station, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Fuel Verification Form',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the "Input Fuel" button on the Home tab to start',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FuelmanHistoryPage extends StatelessWidget {
  const FuelmanHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction History',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('No transactions yet'),
                  const SizedBox(height: 8),
                  Text(
                    'Fuel transactions will appear here',
                    style: TextStyle(color: Colors.grey.shade600),
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