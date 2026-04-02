import 'package:hive/hive.dart';

class AuditService {
  static const String auditBox = 'audit_trail';
  
  /// Log perubahan data
  Future<void> logChange({
    required String action, // CREATE, UPDATE, DELETE, APPROVE, REJECT
    required String entityType, // FUEL_ENTRY, USER, UNIT
    required String entityId,
    required String userId,
    required String userName,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    String? reason,
  }) async {
    final box = await Hive.openBox(auditBox);
    final auditId = DateTime.now().millisecondsSinceEpoch.toString();
    
    await box.put(auditId, {
      'id': auditId,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'user_id': userId,
      'user_name': userName,
      'old_data': oldData,
      'new_data': newData,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    print('📝 Audit Log: $action - $entityType - $entityId by $userName');
  }
  
  /// Mendapatkan audit trail berdasarkan filter
  Future<List<Map<String, dynamic>>> getAuditTrail({
    DateTime? startDate,
    DateTime? endDate,
    String? entityType,
    String? action,
    String? userId,
  }) async {
    final box = await Hive.openBox(auditBox);
    List<Map<String, dynamic>> logs = [];
    
    // Convert Hive values to List<Map<String, dynamic>>
    for (var value in box.values) {
      logs.add(Map<String, dynamic>.from(value as Map));
    }
    
    // Filter berdasarkan tanggal
    if (startDate != null) {
      logs = logs.where((log) => 
          DateTime.parse(log['timestamp']).isAfter(startDate)).toList();
    }
    if (endDate != null) {
      logs = logs.where((log) => 
          DateTime.parse(log['timestamp']).isBefore(endDate)).toList();
    }
    
    // Filter berdasarkan entity type
    if (entityType != null) {
      logs = logs.where((log) => log['entity_type'] == entityType).toList();
    }
    
    // Filter berdasarkan action
    if (action != null) {
      logs = logs.where((log) => log['action'] == action).toList();
    }
    
    // Filter berdasarkan user
    if (userId != null) {
      logs = logs.where((log) => log['user_id'] == userId).toList();
    }
    
    // Urutkan dari terbaru
    logs.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    
    return logs;
  }
}