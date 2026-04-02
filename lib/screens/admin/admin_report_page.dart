import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/report_service.dart';
import '../../services/audit_service.dart';
import '../../config/branding.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({Key? key}) : super(key: key);

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  final ReportService _reportService = ReportService();
  final AuditService _auditService = AuditService();
  
  DateTime _selectedMonth = DateTime.now();
  Map<String, dynamic>? _monthlyReport;
  List<Map<String, dynamic>> _auditTrail = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0: Report, 1: Audit Trail

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final report = await _reportService.getMonthlyFuelReport(_selectedMonth);
      final audit = await _auditService.getAuditTrail(
        startDate: DateTime(_selectedMonth.year, _selectedMonth.month, 1),
        endDate: DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0),
      );
      setState(() {
        _monthlyReport = report;
        _auditTrail = audit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading report: $e');
    }
  }

  Future<void> _exportToExcel() async {
    // TODO: Implement export to Excel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur export Excel sedang dalam pengembangan'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan & Audit'),
          backgroundColor: Branding.primaryColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.report), text: 'Laporan Bulanan'),
              Tab(icon: Icon(Icons.history), text: 'Audit Trail'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportToExcel,
              tooltip: 'Export ke Excel',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildMonthlyReportTab(),
            _buildAuditTrailTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyReportTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_monthlyReport == null) {
      return const Center(child: Text('Tidak ada data'));
    }
    
    final summary = _monthlyReport!['summary'];
    final byCategory = _monthlyReport!['by_category'] as List;
    final byOperator = _monthlyReport!['by_operator'] as List;
    final alerts = _monthlyReport!['alerts'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Periode: ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                        _loadData();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                        _loadData();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Summary Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildSummaryCard(
                title: 'Total Fuel Masuk',
                value: '${(summary['total_fuel_in'] / 1000).toStringAsFixed(0)} KL',
                icon: Icons.download,
                color: Colors.blue,
              ),
              _buildSummaryCard(
                title: 'Total Fuel Ke Alat',
                value: '${(summary['total_fuel_to_equipment'] / 1000).toStringAsFixed(0)} KL',
                icon: Icons.local_gas_station,
                color: Colors.green,
              ),
              _buildSummaryCard(
                title: 'Variance',
                value: '${summary['average_variance_percent'].toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
              _buildSummaryCard(
                title: 'Estimasi Kerugian',
                value: 'Rp ${(summary['total_estimated_loss'] / 1000000).toStringAsFixed(1)} Jt',
                icon: Icons.money_off,
                color: Colors.red,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Alert Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Alert',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _buildAlertChip('Flagged Review', alerts['total_flagged'], Colors.red),
                      _buildAlertChip('Manipulasi', alerts['manipulation'], Colors.orange),
                      _buildAlertChip('Gap Data', alerts['gap_detected'], Colors.blue),
                      _buildAlertChip('Duplicate', alerts['duplicate_fueling'], Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Operator Performance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ranking Efisiensi Operator',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: byOperator.length > 5 ? 5 : byOperator.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final op = byOperator[index];
                      return ListTile(
                        leading: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: op['rank'] == 1 
                                ? Colors.amber 
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${op['rank']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: op['rank'] == 1 ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        title: Text(op['operator_name']),
                        subtitle: Text(
                          '${op['fuel_per_hour'].toStringAsFixed(1)} L/jam',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getEfficiencyColor(op['efficiency_status']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            op['efficiency_status'],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (byOperator.length > 5)
                    TextButton(
                      onPressed: () {
                        // TODO: Show all operators
                      },
                      child: const Text('Lihat Semua'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditTrailTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _auditTrail.length,
      itemBuilder: (context, index) {
        final log = _auditTrail[index];
        final timestamp = DateTime.parse(log['timestamp']);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: _getAuditIcon(log['action']),
            title: Text(
              '${log['action']} - ${log['entity_type']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${log['entity_id']}'),
                Text('Oleh: ${log['user_name']}'),
                if (log['reason'] != null)
                  Text('Alasan: ${log['reason']}'),
              ],
            ),
            trailing: Text(
              '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildAlertChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: color)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Icon _getAuditIcon(String action) {
    switch (action) {
      case 'CREATE':
        return const Icon(Icons.add_circle, color: Colors.green);
      case 'UPDATE':
        return const Icon(Icons.edit, color: Colors.blue);
      case 'DELETE':
        return const Icon(Icons.delete, color: Colors.red);
      case 'APPROVE':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'REJECT':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }

  Color _getEfficiencyColor(String status) {
    switch (status) {
      case 'HEMAT':
        return Colors.green;
      case 'NORMAL':
        return Colors.blue;
      case 'BOROS':
        return Colors.orange;
      case 'SANGAT BOROS':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}