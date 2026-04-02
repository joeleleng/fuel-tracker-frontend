import 'package:flutter/material.dart';
import '../services/hive_database_service.dart';
import '../models/fuel_entry_hive.dart';
import '../config/branding.dart';

class SupervisorNotificationList extends StatefulWidget {
  const SupervisorNotificationList({Key? key}) : super(key: key);

  @override
  State<SupervisorNotificationList> createState() => _SupervisorNotificationListState();
}

class _SupervisorNotificationListState extends State<SupervisorNotificationList> {
  final HiveDatabaseService _dbService = HiveDatabaseService();
  List<FuelEntryHive> _flaggedEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlaggedEntries();
  }

  Future<void> _loadFlaggedEntries() async {
    setState(() => _isLoading = true);
    try {
      final allEntries = await _dbService.getAllEntries();
      final flagged = allEntries.where((e) => 
          e.status == 'flagged_for_review' ||
          e.isManipulationFlag ||
          e.isGapDetected).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      setState(() {
        _flaggedEntries = flagged;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading flagged entries: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getSeverityColor(String type) {
    if (type.contains('MANIPULATION')) return Colors.red;
    if (type.contains('GAP')) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Sistem'),
        backgroundColor: Branding.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFlaggedEntries,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _flaggedEntries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 64, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada notifikasi',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Semua transaksi dalam kondisi normal',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _flaggedEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _flaggedEntries[index];
                    final type = entry.manipulationType ?? 
                                (entry.isGapDetected ? 'GAP_DATA' : 'FLAGGED');
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: _getSeverityColor(type).withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: _getSeverityColor(type),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    type.replaceAll('_', ' '),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getSeverityColor(type),
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatDate(entry.timestamp),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Unit: ${entry.unitCode}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Operator: ${entry.operatorName}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            if (entry.fuelmanName != null)
                              Text(
                                'Fuelman: ${entry.fuelmanName}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                entry.manipulationReason ?? 'Perlu review oleh supervisor',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            if (entry.estimatedLoss != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Estimasi Kerugian: Rp ${entry.estimatedLoss!.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // Navigate to detail
                                  },
                                  child: const Text('LIHAT DETAIL'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Mark as reviewed
                                    final updatedEntry = entry;
                                    updatedEntry.status = 'reviewed';
                                    await _dbService.updateEntry(updatedEntry);
                                    _loadFlaggedEntries();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Notifikasi ditandai selesai'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('TINDAK LANJUT'),
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