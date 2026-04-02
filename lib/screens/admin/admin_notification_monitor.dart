import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/fuel_entry_hive.dart';
import '../../services/hive_database_service.dart';
import '../../config/branding.dart';

class AdminNotificationMonitor extends StatefulWidget {
  final User user;

  const AdminNotificationMonitor({Key? key, required this.user}) : super(key: key);

  @override
  State<AdminNotificationMonitor> createState() => _AdminNotificationMonitorState();
}

class _AdminNotificationMonitorState extends State<AdminNotificationMonitor> {
  final HiveDatabaseService _dbService = HiveDatabaseService();
  List<FuelEntryHive> _allEntries = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, operator, fuelman
  String _filterStatus = 'all'; // all, read, unread

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final entries = await _dbService.getAllEntries();
      // Filter hanya yang memiliki notifikasi
      final notificationEntries = entries.where((e) =>
          (e.operatorNote != null && e.operatorNote!.isNotEmpty) ||
          (e.fuelmanNote != null && e.fuelmanNote!.isNotEmpty)).toList();
      setState(() {
        _allEntries = notificationEntries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading data: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Notifikasi'),
        backgroundColor: Branding.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('Filter:'),
                      const SizedBox(width: 12),
                      _buildFilterChip('Semua', 'all', _filterType),
                      const SizedBox(width: 8),
                      _buildFilterChip('Operator', 'operator', _filterType),
                      const SizedBox(width: 8),
                      _buildFilterChip('Fuelman', 'fuelman', _filterType),
                      const Spacer(),
                      const Text('Status:'),
                      const SizedBox(width: 12),
                      _buildStatusChip('Semua', 'all', _filterStatus),
                      const SizedBox(width: 8),
                      _buildStatusChip('Belum Dibaca', 'unread', _filterStatus),
                      const SizedBox(width: 8),
                      _buildStatusChip('Sudah Dibaca', 'read', _filterStatus),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _getFilteredEntries().length,
                    itemBuilder: (context, index) {
                      final entry = _getFilteredEntries()[index];
                      return _buildNotificationCard(entry);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentValue) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: currentValue == value,
      onSelected: (selected) {
        setState(() {
          _filterType = value;
        });
      },
      selectedColor: Branding.primaryColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: currentValue == value ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, String currentValue) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: currentValue == value,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      selectedColor: Branding.primaryColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: currentValue == value ? Colors.white : Colors.black87,
      ),
    );
  }

  List<FuelEntryHive> _getFilteredEntries() {
    var entries = _allEntries;

    // Filter by type
    if (_filterType == 'operator') {
      entries = entries.where((e) =>
          e.operatorNote != null && e.operatorNote!.isNotEmpty).toList();
    } else if (_filterType == 'fuelman') {
      entries = entries.where((e) =>
          e.fuelmanNote != null && e.fuelmanNote!.isNotEmpty).toList();
    }

    // Filter by status
    if (_filterStatus == 'read') {
      entries = entries.where((e) =>
          (_filterType == 'operator' ? e.operatorNoteRead : e.fuelmanNoteRead) == true).toList();
    } else if (_filterStatus == 'unread') {
      entries = entries.where((e) =>
          (_filterType == 'operator' ? e.operatorNoteRead : e.fuelmanNoteRead) == false).toList();
    }

    return entries;
  }

  Widget _buildNotificationCard(FuelEntryHive entry) {
    final hasOperatorNote = entry.operatorNote != null && entry.operatorNote!.isNotEmpty;
    final hasFuelmanNote = entry.fuelmanNote != null && entry.fuelmanNote!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Branding.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.unitCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(entry.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                if (entry.approvedBy != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Approved by: ${entry.approvedBy}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasOperatorNote) ...[
                  _buildNoteSection(
                    title: '📝 Pesan untuk Operator',
                    recipient: entry.operatorName,
                    note: entry.operatorNote!,
                    isRead: entry.operatorNoteRead,
                    readAt: entry.operatorNoteRead ? 'Sudah dibaca' : 'Belum dibaca',
                  ),
                ],
                if (hasOperatorNote && hasFuelmanNote)
                  const SizedBox(height: 12),
                if (hasFuelmanNote) ...[
                  _buildNoteSection(
                    title: '🛢️ Pesan untuk Fuelman',
                    recipient: entry.fuelmanName ?? '-',
                    note: entry.fuelmanNote!,
                    isRead: entry.fuelmanNoteRead,
                    readAt: entry.fuelmanNoteRead ? 'Sudah dibaca' : 'Belum dibaca',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection({
    required String title,
    required String recipient,
    required String note,
    required bool isRead,
    required String readAt,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRead ? Colors.grey.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isRead ? Colors.green.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isRead ? '✓ DIBACA' : '⏳ BELUM DIBACA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isRead ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Kepada: $recipient',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              note,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                isRead ? Icons.check_circle : Icons.access_time,
                size: 12,
                color: isRead ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                readAt,
                style: TextStyle(
                  fontSize: 10,
                  color: isRead ? Colors.green.shade600 : Colors.orange.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}