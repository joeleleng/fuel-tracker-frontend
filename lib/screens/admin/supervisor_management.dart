import 'package:flutter/material.dart';
import '../../config/branding.dart';
import '../../models/department.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class SupervisorManagement extends StatefulWidget {
  const SupervisorManagement({Key? key}) : super(key: key);

  @override
  State<SupervisorManagement> createState() => _SupervisorManagementState();
}

class _SupervisorManagementState extends State<SupervisorManagement> {
  List<Department> _departments = [];
  List<User> _availableSupervisors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // TODO: Load from API when server ready
    // _departments = await ApiService.getDepartments();
    // _availableSupervisors = await ApiService.getUsersByRole('supervisor');
    setState(() => _isLoading = false);
  }

  Future<void> _assignSupervisor(Department dept, String supervisorId, String assignmentType) async {
    // TODO: API call to assign supervisor
    // await ApiService.assignSupervisor(dept.id, supervisorId, assignmentType);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Supervisor assigned to ${dept.departmentName}'),
        backgroundColor: Colors.green,
      ),
    );
    _loadData();
  }

  Future<void> _setTemporarySupervisor(Department dept, String supervisorId, DateTime start, DateTime end) async {
    // TODO: API call for temporary assignment
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temporary Assignment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set temporary supervisor for:'),
            const SizedBox(height: 8),
            Text(dept.departmentName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Date pickers would go here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement
              Navigator.pop(context);
            },
            child: const Text('Set Temporary'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Management'),
        backgroundColor: Branding.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _departments.length,
              itemBuilder: (context, index) {
                final dept = _departments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Branding.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  dept.departmentCode,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Branding.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dept.departmentName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Code: ${dept.departmentCode}',
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
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildSupervisorInfo(
                          label: 'Primary Supervisor',
                          supervisorId: dept.supervisorId,
                          supervisorName: dept.supervisorName,
                          onAssign: () => _showAssignDialog(dept, 'primary'),
                        ),
                        const SizedBox(height: 12),
                        _buildSupervisorInfo(
                          label: 'Backup Supervisor',
                          supervisorId: dept.backupSupervisorId,
                          supervisorName: dept.backupSupervisorName,
                          onAssign: () => _showAssignDialog(dept, 'backup'),
                        ),
                        const SizedBox(height: 12),
                        _buildSupervisorInfo(
                          label: 'Temporary Supervisor',
                          supervisorId: dept.tempSupervisorId,
                          supervisorName: dept.tempSupervisorName,
                          onAssign: () => _showTemporaryDialog(dept),
                          isTemporary: true,
                          tempPeriod: dept.tempSupervisorStart != null && dept.tempSupervisorEnd != null
                              ? '${_formatDate(dept.tempSupervisorStart!)} - ${_formatDate(dept.tempSupervisorEnd!)}'
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSupervisorInfo({
    required String label,
    String? supervisorId,
    String? supervisorName,
    required VoidCallback onAssign,
    bool isTemporary = false,
    String? tempPeriod,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: supervisorId != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supervisorName ?? supervisorId,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (tempPeriod != null)
                      Text(
                        tempPeriod,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.shade600,
                        ),
                      ),
                  ],
                )
              : Text(
                  'Not assigned',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
        ),
        TextButton(
          onPressed: onAssign,
          child: Text(
            supervisorId != null ? 'Change' : 'Assign',
            style: TextStyle(color: Branding.primaryColor),
          ),
        ),
      ],
    );
  }

  void _showAssignDialog(Department dept, String type) {
    // TODO: Show dialog to select supervisor
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign ${type.toUpperCase()} Supervisor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Department: ${dept.departmentName}'),
            const SizedBox(height: 16),
            // Dropdown for supervisor selection would go here
            const Text('Supervisor list will appear here'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement assignment
              Navigator.pop(context);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showTemporaryDialog(Department dept) {
    // TODO: Show dialog for temporary assignment with date pickers
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temporary Assignment'),
        content: const Text('Temporary supervisor assignment will be implemented'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}