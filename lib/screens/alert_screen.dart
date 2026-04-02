import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../models/unit.dart';

class AlertScreen extends StatefulWidget {
  final User? user;
  final Unit? unit;

  const AlertScreen({Key? key, this.user, this.unit}) : super(key: key);

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Load from API/database
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _alerts = [
          {
            'id': 1,
            'type': 'variance',
            'title': 'Selisih Data Pengisian',
            'message': 'EXC-01: Selisih 200L (Operator 400L vs Fuelman 200L)',
            'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
            'severity': 'high',
            'read': false,
          },
          {
            'id': 2,
            'type': 'idle',
            'title': 'Idle Time Terdeteksi',
            'message': 'HD-465-01: Mesin menyala 45 menit tanpa aktivitas',
            'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
            'severity': 'medium',
            'read': false,
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading alerts: $e');
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return AppConfig.errorColor;
      case 'medium':
        return AppConfig.warningColor;
      case 'low':
        return AppConfig.secondaryColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'variance':
        return Icons.warning_amber_rounded;
      case 'idle':
        return Icons.timer_off;
      case 'geofence':
        return Icons.location_off;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  Future<void> _markAsRead(int id) async {
    setState(() {
      final index = _alerts.indexWhere((a) => a['id'] == id);
      if (index != -1) {
        _alerts[index]['read'] = true;
      }
    });
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      for (var alert in _alerts) {
        alert['read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua notifikasi ditandai telah dibaca')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALERT & NOTIFIKASI'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_alerts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Tandai semua telah dibaca',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alerts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada alert baru',
                        style: TextStyle(color: Colors.grey),
                      ),
                      if (widget.unit != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Unit: ${widget.unit!.unitCode}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _alerts.length,
                  itemBuilder: (context, index) {
                    final alert = _alerts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: alert['read'] ? null : Colors.blue.shade50,
                      child: ListTile(
                        leading: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: _getSeverityColor(alert['severity']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getAlertIcon(alert['type']),
                            color: _getSeverityColor(alert['severity']),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          alert['title'],
                          style: TextStyle(
                            fontWeight: alert['read'] ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert['message']),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(alert['timestamp']),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: !alert['read']
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                        onTap: () {
                          if (!alert['read']) {
                            _markAsRead(alert['id']);
                          }
                          // TODO: Show alert detail dialog
                        },
                      ),
                    );
                  },
                ),
    );
  }
}