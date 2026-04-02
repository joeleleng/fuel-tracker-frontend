import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/fuel_entry_hive.dart';
import '../services/hive_database_service.dart';
import '../config/branding.dart';

class FuelmanNotificationPage extends StatefulWidget {
  final User user;

  const FuelmanNotificationPage({Key? key, required this.user}) : super(key: key);

  @override
  State<FuelmanNotificationPage> createState() => _FuelmanNotificationPageState();
}

class _FuelmanNotificationPageState extends State<FuelmanNotificationPage> {
  final HiveDatabaseService _dbService = HiveDatabaseService();
  List<FuelEntryHive> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _dbService.getFuelmanNotifications(widget.user.username);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading notifications: $e');
    }
  }

  Future<void> _markAsRead(String entryId) async {
    await _dbService.markFuelmanNoteAsRead(entryId);
    setState(() {
      _notifications = _notifications.where((n) => n.id != entryId).toList();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Branding.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: () async {
                for (var n in _notifications) {
                  await _dbService.markFuelmanNoteAsRead(n.id);
                }
                _loadNotifications();
              },
              child: const Text(
                'Tandai Semua',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada notifikasi',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Notifikasi dari supervisor akan muncul di sini',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.orange),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Pesan dari Supervisor',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatDate(notification.noteCreatedAt ?? notification.timestamp),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                notification.fuelmanNote ?? 'Tidak ada pesan',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            if (notification.unitCode != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Unit: ${notification.unitCode}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _markAsRead(notification.id),
                                  child: const Text('Tandai Dibaca'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}