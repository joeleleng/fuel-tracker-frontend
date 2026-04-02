/// Temporary Assignment Screen
/// Admin panel untuk mengelola cuti/sakit/tugas luar karyawan
/// MS-51: User Position Management (Admin Panel)

import 'package:flutter/material.dart';
import '../../services/user_position_service.dart';
import '../../models/organization_structure.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_appbar.dart';

class TemporaryAssignmentScreen extends StatefulWidget {
  const TemporaryAssignmentScreen({Key? key}) : super(key: key);

  @override
  State<TemporaryAssignmentScreen> createState() => _TemporaryAssignmentScreenState();
}

class _TemporaryAssignmentScreenState extends State<TemporaryAssignmentScreen> {
  List<TemporaryAssignment> _assignments = [];
  List<User> _users = [];
  List<OrganizationStructure> _positions = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedTab = 0; // 0 = Active, 1 = History

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final assignments = await UserPositionService.getAllTemporaryAssignments();
      final users = await UserPositionService.getAllUsersWithPositions();
      final positions = await UserPositionService.getAllPositions();

      setState(() {
        _assignments = assignments.cast<TemporaryAssignment>();
        _users = users.cast<User>();
        _positions = positions.cast<OrganizationStructure>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<TemporaryAssignment> get _activeAssignments {
    return _assignments.where((a) => a.isActiveAssignment).toList();
  }

  List<TemporaryAssignment> get _historyAssignments {
    return _assignments.where((a) => !a.isActiveAssignment).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Temporary Assignment Management'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton(
              onPressed: _showCreateDialog,
              child: const Icon(Icons.add),
              tooltip: 'Create Temporary Assignment',
            )
          : null,
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildTabs(),
        Expanded(
          child: _selectedTab == 0
              ? _buildAssignmentList(_activeAssignments, isActive: true)
              : _buildAssignmentList(_historyAssignments, isActive: false),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              icon: Icons.play_circle_filled,
              label: 'Active',
              count: _activeAssignments.length,
              isActive: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTab(
              icon: Icons.history,
              label: 'History',
              count: _historyAssignments.length,
              isActive: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Theme.of(context).primaryColor : Colors.grey,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentList(List<TemporaryAssignment> assignments, {required bool isActive}) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.beach_access : Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active assignments' : 'No history records',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (isActive)
              const SizedBox(height: 16),
            if (isActive)
              ElevatedButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Assignment'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return _buildAssignmentCard(assignment);
      },
    );
  }

  Widget _buildAssignmentCard(TemporaryAssignment assignment) {
    final user = _users.firstWhere(
      (u) => u.userId == assignment.userId,
      orElse: () => User(userId: assignment.userId, name: assignment.userId, email: '', role: 'operator'),
    );

    final isActive = assignment.isActiveAssignment;
    final daysLeft = assignment.endDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: Colors.green, width: 1)
              : null,
        ),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: _getAssignmentTypeColor(assignment.assignmentType),
                child: Icon(
                  _getAssignmentTypeIcon(assignment.assignmentType),
                  color: Colors.white,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  if (!isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ENDED',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${assignment.assignmentTypeDisplay} • ${user.userId}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDate(assignment.startDate)} - ${_formatDate(assignment.endDate)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (isActive && daysLeft >= 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$daysLeft days remaining',
                        style: TextStyle(
                          fontSize: 12,
                          color: daysLeft <= 3 ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (assignment.reason != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Reason: ${assignment.reason}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  if (assignment.assignedUserId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.swap_horiz, size: 12, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            'Delegate: ${assignment.assignedUserId}',
                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              trailing: isActive
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _endAssignmentDialog(assignment),
                      tooltip: 'End Assignment',
                    )
                  : null,
            ),
            if (assignment.temporaryPositionId != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.work, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Temporary position assigned',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getAssignmentTypeColor(String type) {
    switch (type) {
      case 'LEAVE':
        return Colors.orange;
      case 'SICK':
        return Colors.red;
      case 'OUT_OF_OFFICE':
        return Colors.purple;
      case 'DELEGATION':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getAssignmentTypeIcon(String type) {
    switch (type) {
      case 'LEAVE':
        return Icons.beach_access;
      case 'SICK':
        return Icons.local_hospital;
      case 'OUT_OF_OFFICE':
        return Icons.business_center;
      case 'DELEGATION':
        return Icons.swap_horiz;
      default:
        return Icons.event;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateDialog() {
    String? selectedUserId;
    String? selectedAssignmentType;
    DateTime? startDate;
    DateTime? endDate;
    String? selectedDelegateId;
    String? reason;

    final userOptions = _users.map((user) {
      return DropdownMenuItem(
        value: user.userId,
        child: Text('${user.name} (${user.userId})'),
      );
    }).toList();

    final assignmentTypes = [
      {'value': 'LEAVE', 'label': 'Cuti'},
      {'value': 'SICK', 'label': 'Sakit'},
      {'value': 'OUT_OF_OFFICE', 'label': 'Tugas Luar'},
      {'value': 'DELEGATION', 'label': 'Delegasi'},
    ];

    final delegateOptions = [
      const DropdownMenuItem(value: null, child: Text('None')),
      ...userOptions,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create Temporary Assignment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User Selection
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select User',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    value: selectedUserId,
                    items: userOptions,
                    onChanged: (value) {
                      setState(() {
                        selectedUserId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Assignment Type
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Assignment Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    value: selectedAssignmentType,
                    items: assignmentTypes.map((type) {
                      return DropdownMenuItem(
                        value: type['value'],
                        child: Text(type['label'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedAssignmentType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Start Date
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          startDate = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            startDate == null
                                ? 'Start Date'
                                : _formatDate(startDate!),
                            style: TextStyle(
                              color: startDate == null ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // End Date
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          endDate = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            endDate == null
                                ? 'End Date'
                                : _formatDate(endDate!),
                            style: TextStyle(
                              color: endDate == null ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Delegate (optional)
                  DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(
                      labelText: 'Delegate (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.swap_horiz),
                    ),
                    value: selectedDelegateId,
                    items: delegateOptions,
                    onChanged: (value) {
                      setState(() {
                        selectedDelegateId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Reason
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      reason = value;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedUserId == null) {
                    _showSnackBar('Please select a user');
                    return;
                  }
                  if (selectedAssignmentType == null) {
                    _showSnackBar('Please select assignment type');
                    return;
                  }
                  if (startDate == null) {
                    _showSnackBar('Please select start date');
                    return;
                  }
                  if (endDate == null) {
                    _showSnackBar('Please select end date');
                    return;
                  }
                  if (endDate!.isBefore(startDate!)) {
                    _showSnackBar('End date must be after start date');
                    return;
                  }

                  final selectedUser = _users.firstWhere(
                    (u) => u.userId == selectedUserId,
                    orElse: () => User(userId: '', name: '', email: '', role: 'operator'),
                  );
                  final userPosition = selectedUser.positions?.isNotEmpty == true ? selectedUser.positions?.first : null;
                  final positionId = userPosition?.positionId;

                  if (positionId == null) {
                    _showSnackBar('User does not have a position assigned');
                    return;
                  }

                  try {
                    await UserPositionService.createTemporaryAssignment(
                      userId: selectedUserId!,
                      originalPositionId: positionId,
                      assignedUserId: selectedDelegateId,
                      assignmentType: selectedAssignmentType!,
                      startDate: startDate!,
                      endDate: endDate!,
                      reason: reason,
                    );
                    Navigator.pop(context);
                    _loadData();
                    _showSnackBar('Temporary assignment created successfully');
                  } catch (e) {
                    _showSnackBar('Error: $e');
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _endAssignmentDialog(TemporaryAssignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Assignment'),
        content: Text(
          'Are you sure you want to end this assignment for ${assignment.userId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await UserPositionService.endTemporaryAssignment(assignment.id!);
                Navigator.pop(context);
                _loadData();
                _showSnackBar('Assignment ended successfully');
              } catch (e) {
                _showSnackBar('Error: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Assignment'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}