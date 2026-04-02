/// User Position Management Screen
/// Admin panel untuk manajemen posisi user (mutasi/promosi/demosi)
/// MS-51: User Position Management (Admin Panel)

import 'package:flutter/material.dart';
import '../../models/organization_structure.dart';
import '../../models/user_model.dart';
import '../../services/user_position_service.dart';
import '../../widgets/custom_appbar.dart';

class UserPositionManagementScreen extends StatefulWidget {
  const UserPositionManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserPositionManagementScreen> createState() => _UserPositionManagementScreenState();
}

class _UserPositionManagementScreenState extends State<UserPositionManagementScreen> {
  List<User> _users = [];
  List<OrganizationStructure> _positions = [];
  bool _isLoading = true;
  String _errorMessage = '';

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
      final users = await UserPositionService.getAllUsersWithPositions();
      final positions = await UserPositionService.getAllPositions();

      setState(() {
        _users = users;
        _positions = positions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'User Position Management'),
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
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildTabs(),
        Expanded(
          child: _buildUsersList(),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              icon: Icons.people,
              label: 'Users',
              isActive: true,
              onTap: () {},
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTab(
              icon: Icons.history,
              label: 'History',
              isActive: false,
              onTap: () {
                // TODO: Navigate to history screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Position History - Coming Soon')),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTab(
              icon: Icons.beach_access,
              label: 'Temporary',
              isActive: false,
              onTap: () {
                // TODO: Navigate to temporary assignment screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Temporary Assignment - Coming Soon')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
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
            Icon(icon, size: 20, color: isActive ? Theme.of(context).primaryColor : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    if (_users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        // Get position from positions list if available
        final currentPosition = (user.positions != null && user.positions!.isNotEmpty)
            ? (user.positions!.first as dynamic).position as OrganizationStructure?
            : null;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showChangePositionDialog(user),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getLevelColor(currentPosition?.positionLevel ?? 1),
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.userId,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showChangePositionDialog(user),
                        tooltip: 'Change Position',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getLevelColor(currentPosition?.positionLevel ?? 1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.work,
                          size: 16,
                          color: _getLevelColor(currentPosition?.positionLevel ?? 1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentPosition?.positionName ?? 'No Position',
                          style: TextStyle(
                            color: _getLevelColor(currentPosition?.positionLevel ?? 1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (currentPosition != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getLevelColor(currentPosition.positionLevel),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Level ${currentPosition.positionLevel}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (currentPosition?.department != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.business, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          currentPosition!.department!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1: return Colors.green;
      case 2: return Colors.lightGreen;
      case 3: return Colors.orange;
      case 4: return Colors.amber;
      case 5: return Colors.yellow.shade700;
      case 6: return Colors.lightBlue;
      case 7: return Colors.blue;
      case 8: return Colors.purple;
      case 9: return Colors.red;
      case 10: return Colors.black;
      default: return Colors.grey;
    }
  }

  void _showChangePositionDialog(User user) {
    OrganizationStructure? selectedPosition;
    final departmentController = TextEditingController();
    final reasonController = TextEditingController();

    // Set initial department from current position
    final currentPosition = (user.positions != null && user.positions!.isNotEmpty)
        ? (user.positions!.first as dynamic).position as OrganizationStructure?
        : null;
    if (currentPosition?.department != null) {
      departmentController.text = currentPosition!.department!;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Change Position: ${user.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<OrganizationStructure>(
                    decoration: const InputDecoration(
                      labelText: 'New Position',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedPosition,
                    items: _positions.map((pos) {
                      return DropdownMenuItem(
                        value: pos,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getLevelColor(pos.positionLevel),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${pos.positionName} (Level ${pos.positionLevel})'),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPosition = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
                  if (selectedPosition == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a position')),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  
                  try {
                    await UserPositionService.changeUserPosition(
                      userId: user.userId,
                      newPositionId: selectedPosition!.id!,
                      department: departmentController.text.isNotEmpty ? departmentController.text : null,
                      reason: reasonController.text.isNotEmpty ? reasonController.text : null,
                    );
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Position changed successfully')),
                      );
                      _loadData();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }
}