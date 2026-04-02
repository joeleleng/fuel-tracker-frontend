import 'package:flutter/material.dart';
import '../models/user.dart';
import '../config/branding.dart';
import '../services/hive_database_service.dart';
import 'supervisor_approval_list.dart';
import 'supervisor_notification_list.dart';

class SupervisorDashboard extends StatefulWidget {
  final User user;

  const SupervisorDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      SupervisorHomePage(user: widget.user),
      const SupervisorNotificationList(),
      const SupervisorHistoryPage(),
      const SupervisorReportsPage(),
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
        title: Text('Supervisor Dashboard - ${widget.user.name}'),
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
            icon: Icon(Icons.history),
            label: 'History',
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

class SupervisorHomePage extends StatefulWidget {
  final User user;

  const SupervisorHomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<SupervisorHomePage> createState() => _SupervisorHomePageState();
}

class _SupervisorHomePageState extends State<SupervisorHomePage> {
  final HiveDatabaseService _dbService = HiveDatabaseService();
  int _pendingCount = 0;
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};
  
  // Alert counts
  int _flaggedCount = 0;
  int _manipulationCount = 0;
  int _hmGapCount = 0;
  int _totalizerGapCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final pendingCount = await _dbService.getPendingApprovalCount();
      final statistics = await _dbService.getVarianceStatistics();
      final allEntries = await _dbService.getAllEntries();
      
      // Hitung alert counts
      setState(() {
        _pendingCount = pendingCount;
        _statistics = statistics;
        _flaggedCount = allEntries.where((e) => e.status == 'flagged_for_review').length;
        _manipulationCount = allEntries.where((e) => e.isManipulationFlag).length;
        _hmGapCount = allEntries.where((e) => 
            e.isGapDetected && e.manipulationType == 'HM_GAP').length;
        _totalizerGapCount = allEntries.where((e) => 
            e.isGapDetected && e.manipulationType == 'TOTALIZER_GAP').length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAlerts = _flaggedCount > 0 || _manipulationCount > 0 || _hmGapCount > 0 || _totalizerGapCount > 0;
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Supervisor',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Monitoring fuel consumption and variances',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            
            // Pending Approval Card - Clickable
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupervisorApprovalList(),
                  ),
                ).then((_) => _loadData());
              },
              child: Card(
                color: _pendingCount > 0 ? Colors.orange.shade50 : Colors.grey.shade50,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _pendingCount > 0 ? Colors.orange : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.pending_actions,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending Approval',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (_isLoading)
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              Text(
                                '$_pendingCount Transaksi',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: _pendingCount > 0 ? Colors.orange : Colors.grey,
                                ),
                              ),
                            if (_pendingCount > 0)
                              Text(
                                'Klik untuk review',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_pendingCount > 0)
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 🆕 System Alert Card - Ringkasan Notifikasi Sistem
            Card(
              color: hasAlerts ? Colors.red.shade50 : Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: hasAlerts ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Alert Sistem',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: hasAlerts ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (!hasAlerts)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Semua sistem dalam kondisi normal',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (_flaggedCount > 0)
                            _buildAlertChip(
                              label: 'Flagged Review',
                              count: _flaggedCount,
                              color: Colors.red,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SupervisorNotificationList(),
                                  ),
                                );
                              },
                            ),
                          if (_manipulationCount > 0)
                            _buildAlertChip(
                              label: 'Manipulasi',
                              count: _manipulationCount,
                              color: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SupervisorNotificationList(),
                                  ),
                                );
                              },
                            ),
                          if (_hmGapCount > 0)
                            _buildAlertChip(
                              label: 'Gap HM',
                              count: _hmGapCount,
                              color: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SupervisorNotificationList(),
                                  ),
                                );
                              },
                            ),
                          if (_totalizerGapCount > 0)
                            _buildAlertChip(
                              label: 'Gap Totalizer',
                              count: _totalizerGapCount,
                              color: Colors.purple,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SupervisorNotificationList(),
                                  ),
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
            
            // KPI Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth > 600;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildStatCard(
                      context: context,
                      title: 'Total Fuel Today',
                      value: '0 L',
                      icon: Icons.local_gas_station,
                      color: Branding.primaryColor,
                      isWide: isWide,
                    ),
                    _buildStatCard(
                      context: context,
                      title: 'Avg Variance',
                      value: _statistics.containsKey('average_variance_percent')
                          ? '${_statistics['average_variance_percent'].toStringAsFixed(1)}%'
                          : '0%',
                      icon: Icons.trending_up,
                      color: Colors.orange,
                      isWide: isWide,
                    ),
                    _buildStatCard(
                      context: context,
                      title: 'Total Entries',
                      value: _statistics.containsKey('total_entries')
                          ? '${_statistics['total_entries']}'
                          : '0',
                      icon: Icons.receipt,
                      color: Colors.blue,
                      isWide: isWide,
                    ),
                    _buildStatCard(
                      context: context,
                      title: 'Active Units',
                      value: '6',
                      icon: Icons.construction,
                      color: Branding.successColor,
                      isWide: isWide,
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Recent Alerts
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
                    if (_pendingCount > 0)
                      ListTile(
                        leading: const Icon(Icons.warning, color: Colors.orange),
                        title: const Text('Pending Approvals'),
                        subtitle: Text('$_pendingCount transaksi menunggu persetujuan'),
                        trailing: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SupervisorApprovalList(),
                              ),
                            ).then((_) => _loadData());
                          },
                          child: const Text('REVIEW'),
                        ),
                      )
                    else if (hasAlerts)
                      ListTile(
                        leading: const Icon(Icons.warning, color: Colors.red),
                        title: const Text('System Alerts'),
                        subtitle: Text('$_flaggedCount flagged, $_manipulationCount manipulasi'),
                        trailing: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SupervisorNotificationList(),
                              ),
                            );
                          },
                          child: const Text('VIEW'),
                        ),
                      )
                    else
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
        ),
      ),
    );
  }

  Widget _buildAlertChip({
    required String label,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isWide,
  }) {
    double cardWidth = isWide ? (MediaQuery.of(context).size.width / 2) - 24 : double.infinity;
    
    return Container(
      width: cardWidth,
      constraints: const BoxConstraints(minWidth: 150),
      child: Card(
        elevation: 2,
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
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupervisorHistoryPage extends StatelessWidget {
  const SupervisorHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fuel History',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('No fuel entries yet'),
                  const SizedBox(height: 8),
                  Text(
                    'Fuel entries will appear here',
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

class SupervisorReportsPage extends StatelessWidget {
  const SupervisorReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reports',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Coming Soon'),
                  const SizedBox(height: 8),
                  Text(
                    'Export monthly reports and analytics',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    label: const Text('Export Report'),
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