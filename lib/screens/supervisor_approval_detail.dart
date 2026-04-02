import 'package:flutter/material.dart';
import '../models/fuel_entry_hive.dart';
import '../services/hive_database_service.dart';
import '../config/branding.dart';

class SupervisorApprovalDetail extends StatefulWidget {
  final FuelEntryHive entry;

  const SupervisorApprovalDetail({Key? key, required this.entry})
      : super(key: key);

  @override
  State<SupervisorApprovalDetail> createState() => _SupervisorApprovalDetailState();
}

class _SupervisorApprovalDetailState extends State<SupervisorApprovalDetail> {
  final HiveDatabaseService _dbService = HiveDatabaseService();
  bool _isProcessing = false;
  String? _selectedChoice;
  
  // Controllers untuk 3 jenis catatan
  final TextEditingController _internalNoteController = TextEditingController();
  final TextEditingController _operatorNoteController = TextEditingController();
  final TextEditingController _fuelmanNoteController = TextEditingController();

  @override
  void dispose() {
    _internalNoteController.dispose();
    _operatorNoteController.dispose();
    _fuelmanNoteController.dispose();
    super.dispose();
  }

  Future<void> _approve(String choice) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Ambil entry yang sudah ada
      final updatedEntry = widget.entry;
      updatedEntry.status = 'approved';
      updatedEntry.approvedBy = 'Supervisor'; // TODO: Get from logged in user
      updatedEntry.approvedAt = DateTime.now();
      updatedEntry.approvedChoice = choice;
      updatedEntry.noteCreatedAt = DateTime.now();
      
      // Simpan catatan internal
      if (_internalNoteController.text.isNotEmpty) {
        updatedEntry.internalNote = _internalNoteController.text;
      }
      
      // Simpan catatan untuk operator
      if (_operatorNoteController.text.isNotEmpty) {
        updatedEntry.operatorNote = _operatorNoteController.text;
        updatedEntry.operatorNoteRead = false;
      }
      
      // Simpan catatan untuk fuelman
      if (_fuelmanNoteController.text.isNotEmpty) {
        updatedEntry.fuelmanNote = _fuelmanNoteController.text;
        updatedEntry.fuelmanNoteRead = false;
      }

      await _dbService.updateEntry(updatedEntry);

      if (mounted) {
        String message = 'Transaksi disetujui (Data $choice)';
        if (_operatorNoteController.text.isNotEmpty) {
          message += '\n📝 Notifikasi dikirim ke Operator';
        }
        if (_fuelmanNoteController.text.isNotEmpty) {
          message += '\n📝 Notifikasi dikirim ke Fuelman';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _reject() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final updatedEntry = widget.entry;
      updatedEntry.status = 'rejected';
      updatedEntry.approvedBy = 'Supervisor';
      updatedEntry.approvedAt = DateTime.now();
      updatedEntry.approvedChoice = 'reject';
      updatedEntry.noteCreatedAt = DateTime.now();
      
      // Simpan catatan internal
      if (_internalNoteController.text.isNotEmpty) {
        updatedEntry.internalNote = _internalNoteController.text;
      }
      
      // Untuk reject, catatan ke operator dan fuelman tetap bisa dikirim
      if (_operatorNoteController.text.isNotEmpty) {
        updatedEntry.operatorNote = _operatorNoteController.text;
        updatedEntry.operatorNoteRead = false;
      }
      if (_fuelmanNoteController.text.isNotEmpty) {
        updatedEntry.fuelmanNote = _fuelmanNoteController.text;
        updatedEntry.fuelmanNoteRead = false;
      }

      await _dbService.updateEntry(updatedEntry);

      if (mounted) {
        String message = 'Transaksi ditolak';
        if (_operatorNoteController.text.isNotEmpty) {
          message += '\n📝 Notifikasi dikirim ke Operator';
        }
        if (_fuelmanNoteController.text.isNotEmpty) {
          message += '\n📝 Notifikasi dikirim ke Fuelman';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final variance = (widget.entry.estimatedLiter - (widget.entry.fuelmanLiter ?? 0)).abs();
    final variancePercent = (variance / widget.entry.estimatedLiter * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: Text('Approval - ${widget.entry.unitCode}'),
        backgroundColor: Branding.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Variance Summary Card
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Variance',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$variancePercent%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Operator',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              Text(
                                '${widget.entry.estimatedLiter.toStringAsFixed(0)} L',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text('vs', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Fuelman',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              Text(
                                '${widget.entry.fuelmanLiter?.toStringAsFixed(0) ?? '-'} L',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Selisih'),
                        Text(
                          '${variance.toStringAsFixed(0)} L',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Toleransi'),
                        Text('${Branding.varianceThreshold}%'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Operator Data Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Data Operator',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Radio(
                          value: 'operator',
                          groupValue: _selectedChoice,
                          onChanged: (value) {
                            setState(() => _selectedChoice = value);
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildInfoRow('Nama Operator', widget.entry.operatorName),
                    _buildInfoRow('Hour Meter', '${widget.entry.hourMeter.toStringAsFixed(1)} jam'),
                    _buildInfoRow('Level Tangki', '${widget.entry.fuelLevelBefore} → ${widget.entry.fuelLevelAfter}'),
                    _buildInfoRow('Estimasi Liter', '${widget.entry.estimatedLiter.toStringAsFixed(0)} L'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Fuelman Data Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_gas_station, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'Data Fuelman',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Radio(
                          value: 'fuelman',
                          groupValue: _selectedChoice,
                          onChanged: (value) {
                            setState(() => _selectedChoice = value);
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildInfoRow('Nama Fuelman', widget.entry.fuelmanName ?? '-'),
                    _buildInfoRow('Totalizer Awal', widget.entry.totalizerBefore ?? '-'),
                    _buildInfoRow('Totalizer Akhir', widget.entry.totalizerAfter ?? '-'),
                    _buildInfoRow('Fuel Terisi', '${widget.entry.fuelmanLiter?.toStringAsFixed(0) ?? '-'} L'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ============================================
            // CATATAN TERPISAH (3 JENIS)
            // ============================================
            
            // 1. Internal Note (Hanya Supervisor & Admin)
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text(
                          'Catatan Internal (Hanya Supervisor & Admin)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _internalNoteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Catatan internal untuk manajemen...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🔒 Catatan ini TIDAK akan terlihat oleh operator/fuelman',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 2. Operator Note
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Catatan untuk Operator (${widget.entry.operatorName})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _operatorNoteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Besok menghadap ke kantor jam 08:00 untuk konfirmasi penggunaan fuel...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '💡 Operator akan mendapat notifikasi di dashboard',
                      style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 3. Fuelman Note
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_gas_station, size: 18, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Catatan untuk Fuelman (${widget.entry.fuelmanName ?? 'Belum ada fuelman'})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _fuelmanNoteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Besok menghadap ke kantor jam 10:00 untuk konfirmasi perbedaan data totalizer...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '💡 Fuelman akan mendapat notifikasi di dashboard',
                      style: TextStyle(fontSize: 10, color: Colors.green.shade700),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing || _selectedChoice == null
                        ? null
                        : () => _approve(_selectedChoice!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'SETUJUI',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _reject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'TOLAK',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}