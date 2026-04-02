import 'package:flutter/material.dart';
import '../../services/user_position_service.dart';
import '../../models/organization_structure.dart';
import '../../widgets/custom_appbar.dart';

class PositionHistoryScreen extends StatefulWidget {
  final String? userId;
  const PositionHistoryScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<PositionHistoryScreen> createState() => _PositionHistoryScreenState();
}

class _PositionHistoryScreenState extends State<PositionHistoryScreen> {
  List<UserPositionHistory> _history = [];
  bool _isLoading = true;
  String _selectedUserId = '';

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.userId ?? '';
    if (_selectedUserId.isNotEmpty) {
      _loadHistory();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHistory() async {
    if (_selectedUserId.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final history = await UserPositionService.getUserPositionHistory(_selectedUserId);
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Position History'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'User ID (e.g., opr001, fml001, spv001)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                helperText: 'Enter user ID to view position change history',
              ),
              onSubmitted: (value) {
                setState(() {
                  _selectedUserId = value.trim();
                  _loadHistory();
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty && _selectedUserId.isNotEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No position history found',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'User may not have any position changes yet',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : _history.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search, size: 48, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Enter a User ID to search',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              final h = _history[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: CircleAvatar(
                                    backgroundColor: _getChangeTypeColor(h.changeType),
                                    radius: 24,
                                    child: Icon(
                                      _getChangeTypeIcon(h.changeType),
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    h.changeTypeDisplay,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoRow(
                                              'From',
                                              h.oldPositionId?.toString() ?? 'N/A',
                                            ),
                                          ),
                                          const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                                          Expanded(
                                            child: _buildInfoRow(
                                              'To',
                                              h.newPositionId?.toString() ?? 'N/A',
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (h.reason != null) ...[
                                        const SizedBox(height: 8),
                                        _buildInfoRow('Reason', h.reason!),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.person, size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            h.changedBy,
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDateTime(h.changedAt),
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getChangeTypeColor(String type) {
    switch (type) {
      case 'PROMOTION':
        return Colors.green;
      case 'DEMOTION':
        return Colors.red;
      case 'TRANSFER':
        return Colors.orange;
      case 'MUTATION':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getChangeTypeIcon(String type) {
    switch (type) {
      case 'PROMOTION':
        return Icons.arrow_upward;
      case 'DEMOTION':
        return Icons.arrow_downward;
      case 'TRANSFER':
        return Icons.swap_horiz;
      case 'MUTATION':
        return Icons.edit;
      default:
        return Icons.history;
    }
  }
}