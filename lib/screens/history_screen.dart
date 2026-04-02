import 'package:flutter/material.dart';
import '../config/branding.dart';
import '../models/user.dart';
import '../models/unit.dart';
import '../models/fuel_entry_hive.dart';
import '../services/hive_database_service.dart';

class HistoryScreen extends StatefulWidget {
  final User user;
  final Unit unit;

  const HistoryScreen({Key? key, required this.user, required this.unit})
      : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HiveDatabaseService _dbService = HiveDatabaseService();
  List<FuelEntryHive> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final entries = await _dbService.getEntriesByUnit(widget.unit.unitCode);
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading history: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
      case 'auto_approved':
        return Branding.successColor;
      case 'pending':
      case 'pending_approval':
        return Branding.warningColor;
      case 'rejected':
        return Branding.dangerColor;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'DISETUJUI';
      case 'auto_approved':
        return 'AUTO APPROVED';
      case 'pending':
        return 'MENUNGGU FUELMAN';
      case 'pending_approval':
        return 'MENUNGGU SUPERVISOR';
      case 'rejected':
        return 'DITOLAK';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RIWAYAT - ${widget.unit.unitCode}'),
        backgroundColor: Branding.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada riwayat pengisian untuk ${widget.unit.unitCode}',
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final hasOperatorNote = entry.operatorNote != null && entry.operatorNote!.isNotEmpty;
                    final hasFuelmanNote = entry.fuelmanNote != null && entry.fuelmanNote!.isNotEmpty;
                    final hasInternalNote = entry.internalNote != null && entry.internalNote!.isNotEmpty;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Content
                          ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getStatusColor(entry.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.local_gas_station,
                                color: _getStatusColor(entry.status),
                              ),
                            ),
                            title: Text(
                              '${entry.estimatedLiter.toStringAsFixed(0)} Liter',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('HM: ${entry.hourMeter.toStringAsFixed(1)}'),
                                Text('Shift: ${entry.shift}'),
                                if (entry.fuelmanName != null)
                                  Text('Fuelman: ${entry.fuelmanName}'),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _formatDate(entry.timestamp),
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(entry.status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getStatusText(entry.status),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Approval Info
                          if (entry.approvedBy != null && entry.approvedAt != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, size: 12, color: Colors.green.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Approved by ${entry.approvedBy} at ${_formatDate(entry.approvedAt!)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Internal Note (Hanya untuk Admin/Supervisor)
                          if (hasInternalNote && (widget.user.isAdmin || widget.user.isSupervisor))
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.lock, size: 12, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Catatan Internal',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.internalNote!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Operator Note (Hanya untuk Operator dan Admin/Supervisor)
                          if (hasOperatorNote && (widget.user.isOperator || widget.user.isAdmin || widget.user.isSupervisor))
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.person, size: 12, color: Colors.blue.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Catatan untuk Operator',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: entry.operatorNoteRead 
                                              ? Colors.green.shade100 
                                              : Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              entry.operatorNoteRead 
                                                  ? Icons.check_circle 
                                                  : Icons.access_time,
                                              size: 10,
                                              color: entry.operatorNoteRead 
                                                  ? Colors.green.shade700 
                                                  : Colors.orange.shade700,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              entry.operatorNoteRead ? 'Dibaca' : 'Belum Dibaca',
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: entry.operatorNoteRead 
                                                    ? Colors.green.shade700 
                                                    : Colors.orange.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.operatorNote!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Fuelman Note (Hanya untuk Fuelman dan Admin/Supervisor)
                          if (hasFuelmanNote && (widget.user.isFuelman || widget.user.isAdmin || widget.user.isSupervisor))
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.local_gas_station, size: 12, color: Colors.green.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Catatan untuk Fuelman',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: entry.fuelmanNoteRead 
                                              ? Colors.green.shade100 
                                              : Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              entry.fuelmanNoteRead 
                                                  ? Icons.check_circle 
                                                  : Icons.access_time,
                                              size: 10,
                                              color: entry.fuelmanNoteRead 
                                                  ? Colors.green.shade700 
                                                  : Colors.orange.shade700,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              entry.fuelmanNoteRead ? 'Dibaca' : 'Belum Dibaca',
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: entry.fuelmanNoteRead 
                                                    ? Colors.green.shade700 
                                                    : Colors.orange.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.fuelmanNote!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}