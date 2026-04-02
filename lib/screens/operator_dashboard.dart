import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/unit.dart';
import '../models/fuel_entry_hive.dart';
import '../providers/auth_provider.dart';
import '../services/hive_database_service.dart';
import '../config/branding.dart';
import '../config/app_config.dart';
import 'operator_fuel_form.dart';
import 'history_screen.dart';
import 'alert_screen.dart';
import 'qr_scanner_screen.dart';
import 'operator_notification_page.dart';

class OperatorDashboard extends StatefulWidget {
  final User user;
  final Unit? unit;

  const OperatorDashboard({Key? key, required this.user, this.unit}) : super(key: key);

  @override
  State<OperatorDashboard> createState() => _OperatorDashboardState();
}

class _OperatorDashboardState extends State<OperatorDashboard> {
  late Unit _currentUnit;
  final HiveDatabaseService _dbService = HiveDatabaseService();
  int _notificationCount = 0;
  bool _isLoadingNotifications = true;

  @override
  void initState() {
    super.initState();
    _initUnit();
    _loadNotificationCount();
  }

  void _initUnit() {
    if (widget.unit != null) {
      _currentUnit = widget.unit!;
      return;
    }
    
    if (widget.user.unitCode != null && widget.user.unitCode!.isNotEmpty) {
      _currentUnit = Unit(
        unitCode: widget.user.unitCode!,
        unitName: 'Unit ${widget.user.unitCode}',
        type: 'Alat Berat',
        category: 'Excavator',
        qrCode: widget.user.unitCode!,
        isActive: true,
      );
    } else {
      _currentUnit = Unit(
        unitCode: 'EXC-01',
        unitName: 'Excavator PC2000',
        type: 'Excavator',
        category: 'Alat Berat',
        qrCode: 'EXC-01',
        isActive: true,
      );
    }
  }

  Future<void> _loadNotificationCount() async {
    setState(() => _isLoadingNotifications = true);
    try {
      final count = await _dbService.getOperatorNotificationCount(widget.user.username);
      setState(() {
        _notificationCount = count;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      setState(() => _isLoadingNotifications = false);
      print('Error loading notification count: $e');
    }
  }

  void _navigateToFuelForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OperatorFuelForm(
          user: widget.user,
          initialUnit: _currentUnit,
        ),
      ),
    ).then((result) {
      if (result == true && mounted) {
        setState(() {});
      }
    });
  }

  void _navigateToQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          user: widget.user,
          onScan: (scannedUnit) {
            if (scannedUnit.unitCode != _currentUnit.unitCode) {
              setState(() {
                _currentUnit = scannedUnit;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Unit berubah: ${scannedUnit.unitCode} - ${scannedUnit.unitName}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          user: widget.user,
          unit: _currentUnit,
        ),
      ),
    );
  }

  void _navigateToAlerts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlertScreen(
          user: widget.user,
          unit: _currentUnit,
        ),
      ),
    );
  }

  void _navigateToNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OperatorNotificationPage(user: widget.user),
      ),
    );
    _loadNotificationCount(); // Refresh setelah kembali
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('LOGOUT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getCurrentShift() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour >= AppConfig.shiftStartHour && hour < AppConfig.shiftEndHour) {
      return 'PAGI';
    } else {
      return 'MALAM';
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OPERATOR DASHBOARD',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotificationCount,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Branding.primaryColor, Branding.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Branding.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat Datang,',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                widget.user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  _getCurrentShift(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white30),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UNIT SAAT INI',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentUnit.unitCode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_currentUnit.unitName.isNotEmpty)
                                Text(
                                  _currentUnit.unitName,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _getCurrentTime(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'WIB',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons Grid
              const Text(
                'AKSI CEPAT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _buildActionCard(
                    icon: Icons.local_gas_station,
                    title: 'ISI FUEL',
                    subtitle: 'Input pengisian BBM',
                    color: Branding.primaryColor,
                    onTap: _navigateToFuelForm,
                  ),
                  _buildActionCard(
                    icon: Icons.qr_code_scanner,
                    title: 'SCAN QR',
                    subtitle: 'Identifikasi unit',
                    color: const Color(0xFF2196F3),
                    onTap: _navigateToQRScanner,
                  ),
                  _buildActionCard(
                    icon: Icons.history,
                    title: 'RIWAYAT',
                    subtitle: 'Lihat history',
                    color: const Color(0xFFFF9800),
                    onTap: _navigateToHistory,
                  ),
                  _buildActionCard(
                    icon: Icons.notifications,
                    title: 'NOTIFIKASI',
                    subtitle: '$_notificationCount pesan baru',
                    color: const Color(0xFFF44336),
                    onTap: _navigateToNotifications,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Info Card
              Card(
                elevation: 0,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Branding.primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pastikan foto bukti terlihat jelas. Data akan tersimpan offline jika tidak ada sinyal.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Footer with Personal Mark
              Center(
                child: Column(
                  children: [
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text(
                      Branding.copyrightText,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}