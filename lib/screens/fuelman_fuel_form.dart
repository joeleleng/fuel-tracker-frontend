import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/fuel_entry_hive.dart';
import '../models/unit.dart';
import '../models/user.dart';
import '../services/hive_database_service.dart';
import '../services/detection_service.dart';
import '../services/tracking_service.dart';
import '../services/supervisor_notification_service.dart';
import '../config/branding.dart';
import 'qr_scanner_screen.dart';

class FuelmanFuelForm extends StatefulWidget {
  final User user;

  const FuelmanFuelForm({Key? key, required this.user}) : super(key: key);

  @override
  State<FuelmanFuelForm> createState() => _FuelmanFuelFormState();
}

class _FuelmanFuelFormState extends State<FuelmanFuelForm> {
  final _formKey = GlobalKey<FormState>();
  final HiveDatabaseService _dbService = HiveDatabaseService();
  final DetectionService _detectionService = DetectionService();
  final TrackingService _trackingService = TrackingService();
  final SupervisorNotificationService _notificationService = SupervisorNotificationService();
  final Uuid _uuid = Uuid();

  // Form fields
  Unit? _selectedUnit;
  String? _tankerId;
  String? _tankerCapacity;
  TextEditingController _totalizerAwalController = TextEditingController();
  TextEditingController _totalizerAkhirController = TextEditingController();
  double? _calculatedLiter;
  double? _operatorLiter;
  double? _variance;
  bool _isVarianceExceeded = false;

  // Photo paths
  String? _photoTotalizerAwalPath;
  String? _photoTotalizerAkhirPath;

  // Operator data (from pending entry)
  FuelEntryHive? _operatorEntry;
  bool _isLoadingOperator = false;
  bool _isSubmitting = false;

  // Units list - DATA DUMMY untuk testing
  List<Unit> _units = [
    Unit(
      unitCode: 'EXC-01',
      unitName: 'Komatsu PC2000',
      type: 'Excavator',
      category: 'Alat Berat',
      qrCode: 'EXC-01',
      isActive: true,
    ),
    Unit(
      unitCode: 'HD-465-01',
      unitName: 'Komatsu HD465',
      type: 'Dump Truck',
      category: 'Alat Berat',
      qrCode: 'HD-465-01',
      isActive: true,
    ),
    Unit(
      unitCode: 'SKT-105-01',
      unitName: 'SANY SKT105S',
      type: 'Dump Truck',
      category: 'Alat Berat',
      qrCode: 'SKT-105-01',
      isActive: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadOperatorPendingData() async {
    if (_selectedUnit == null) return;
    
    setState(() => _isLoadingOperator = true);
    
    try {
      // Get pending entries from Hive
      final allEntries = await _dbService.getEntriesByUnit(_selectedUnit!.unitCode);
      final pendingEntry = allEntries.firstWhere(
        (e) => e.status == 'pending' && e.fuelmanId == null,
        orElse: () => throw Exception('No pending entry found'),
      );
      
      setState(() {
        _operatorEntry = pendingEntry;
        _operatorLiter = pendingEntry.estimatedLiter;
        _isLoadingOperator = false;
      });
      
      _calculateVariance();
      
    } catch (e) {
      setState(() => _isLoadingOperator = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak ada data pending untuk unit ini. Operator harus input fuel terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _calculateLiter() {
    if (_totalizerAwalController.text.isNotEmpty && 
        _totalizerAkhirController.text.isNotEmpty) {
      double awal = double.tryParse(_totalizerAwalController.text) ?? 0;
      double akhir = double.tryParse(_totalizerAkhirController.text) ?? 0;
      setState(() {
        _calculatedLiter = akhir - awal;
      });
      _calculateVariance();
    }
  }

  void _calculateVariance() {
    if (_operatorLiter != null && _calculatedLiter != null) {
      double varianceValue = (_operatorLiter! - _calculatedLiter!).abs();
      double variancePercent = (_operatorLiter! > 0) 
          ? (varianceValue / _operatorLiter!) * 100 
          : 0;
      
      setState(() {
        _variance = varianceValue;
        _isVarianceExceeded = variancePercent > Branding.varianceThreshold;
      });
    }
  }

  Future<void> _takePhoto(String type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (photo != null) {
      setState(() {
        if (type == 'awal') {
          _photoTotalizerAwalPath = photo.path;
        } else {
          _photoTotalizerAkhirPath = photo.path;
        }
      });
    }
  }

  void _startQRScan() {
    // Untuk web testing, gunakan dropdown manual
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Unit (Web Mode)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._units.map((unit) => ListTile(
                leading: const Icon(Icons.construction),
                title: Text('${unit.unitCode} - ${unit.unitName}'),
                onTap: () {
                  setState(() {
                    _selectedUnit = unit;
                  });
                  Navigator.pop(context);
                  _loadOperatorPendingData();
                },
              )),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Batal'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih unit terlebih dahulu')),
      );
      return;
    }

    if (_operatorEntry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data pending dari operator')),
      );
      return;
    }

    if (_totalizerAwalController.text.isEmpty || 
        _totalizerAkhirController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Input totalizer awal dan akhir')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Create updated entry
      final updatedEntry = FuelEntryHive(
        id: _operatorEntry!.id,
        unitCode: _selectedUnit!.unitCode,
        operatorId: _operatorEntry!.operatorId,
        operatorName: _operatorEntry!.operatorName,
        hourMeter: _operatorEntry!.hourMeter,
        fuelLevelBefore: _operatorEntry!.fuelLevelBefore,
        fuelLevelAfter: _operatorEntry!.fuelLevelAfter,
        estimatedLiter: _operatorEntry!.estimatedLiter,
        photoBeforePath: _operatorEntry!.photoBeforePath,
        photoAfterPath: _operatorEntry!.photoAfterPath,
        latitude: _operatorEntry!.latitude,
        longitude: _operatorEntry!.longitude,
        locationAddress: _operatorEntry!.locationAddress,
        timestamp: _operatorEntry!.timestamp,
        shift: _operatorEntry!.shift,
        status: _isVarianceExceeded ? 'pending_approval' : 'auto_approved',
        fuelmanLiter: _calculatedLiter,
        fuelmanId: widget.user.username,
        fuelmanName: widget.user.name,
        totalizerBefore: _totalizerAwalController.text,
        totalizerAfter: _totalizerAkhirController.text,
        photoTotalizerPath: _photoTotalizerAkhirPath,
        isSynced: false,
      );

      // ============================================
      // AUTO-DETECT TOTALIZER MANIPULATION & GAP
      // ============================================
      
      // Run detection for totalizer
      final detectionResult = await _detectionService.runAllDetections(updatedEntry, false);
      
      // Update entry dengan hasil deteksi
      updatedEntry.isManipulationFlag = detectionResult['isManipulationFlag'];
      updatedEntry.manipulationType = detectionResult['manipulationType'];
      updatedEntry.manipulationReason = detectionResult['manipulationReason'];
      updatedEntry.estimatedLoss = detectionResult['estimatedLoss'];
      updatedEntry.isGapDetected = detectionResult['isGapDetected'];
      updatedEntry.gapValue = detectionResult['gapValue'];
      
      // Jika ada deteksi manipulasi atau gap, set status khusus
      if (detectionResult['isManipulationFlag'] || detectionResult['isGapDetected']) {
        updatedEntry.status = 'flagged_for_review';
        
        // Kirim notifikasi ke supervisor
        await _notificationService.notifySupervisorAboutFlaggedEntry(updatedEntry);
      }

      // Update tracking totalizer
      if (updatedEntry.totalizerAfter != null) {
        await _trackingService.saveLastTotalizer(
          updatedEntry.unitCode,
          double.parse(updatedEntry.totalizerAfter!),
          updatedEntry.id,
        );
      }

      // Save to Hive database
      await _dbService.updateEntry(updatedEntry);

      print('📝 Fuel Entry Updated:');
      print('   ID: ${updatedEntry.id}');
      print('   Unit: ${updatedEntry.unitCode}');
      print('   Operator: ${updatedEntry.operatorName}');
      print('   Operator Liter: ${updatedEntry.estimatedLiter}');
      print('   Fuelman Liter: ${updatedEntry.fuelmanLiter}');
      print('   Variance: ${_variance?.toStringAsFixed(0)} L');
      print('   Status: ${updatedEntry.status}');
      
      if (detectionResult['isManipulationFlag']) {
        print('   ⚠️ TOTALIZER MANIPULATION DETECTED: ${detectionResult['manipulationReason']}');
        print('   💰 Estimated Loss: Rp ${detectionResult['estimatedLoss']?.toStringAsFixed(0)}');
      }
      if (detectionResult['isGapDetected']) {
        print('   ⚠️ TOTALIZER GAP DETECTED: ${detectionResult['gapValue']} L');
      }

      if (mounted) {
        // Tampilkan alert yang sesuai
        String message = '';
        Color alertColor = Colors.green;
        
        if (detectionResult['isManipulationFlag']) {
          message = '⚠️ TERINDIKASI MANIPULASI TOTALIZER!\n'
                    'Selisih: ${detectionResult['gapValue']} L\n'
                    'Estimasi Kerugian: Rp ${detectionResult['estimatedLoss']?.toStringAsFixed(0)}\n'
                    'Data akan direview supervisor.';
          alertColor = Colors.red;
        } else if (detectionResult['isGapDetected']) {
          message = '⚠️ TERINDIKASI GAP TOTALIZER!\n'
                    'Fuel tidak tercatat: ${detectionResult['gapValue']} L\n'
                    'Estimasi Kerugian: Rp ${detectionResult['estimatedLoss']?.toStringAsFixed(0)}\n'
                    'Data akan direview supervisor.';
          alertColor = Colors.orange;
        } else if (_isVarianceExceeded) {
          message = 'Data diverifikasi. Variance ${_variance!.toStringAsFixed(0)}L '
                    '(${((_variance! / _operatorLiter!) * 100).toStringAsFixed(0)}%) '
                    'melebihi toleransi. Menunggu approval supervisor.';
          alertColor = Colors.orange;
        } else {
          message = 'Data diverifikasi. Tidak ada variance. Status: APPROVED';
          alertColor = Colors.green;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: alertColor,
            duration: const Duration(seconds: 5),
          ),
        );

        // Clear form
        _totalizerAwalController.clear();
        _totalizerAkhirController.clear();
        setState(() {
          _calculatedLiter = null;
          _photoTotalizerAwalPath = null;
          _photoTotalizerAkhirPath = null;
          _operatorEntry = null;
          _operatorLiter = null;
          _variance = null;
          _isVarianceExceeded = false;
          _selectedUnit = null;
        });

        // Navigate back
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error updating fuel entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VERIFIKASI FUEL'),
        backgroundColor: Branding.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _startQRScan,
            tooltip: 'Pilih Unit (Web Mode)',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unit Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.construction, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Unit Alat Berat',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _startQRScan,
                            icon: const Icon(Icons.qr_code_scanner, size: 18),
                            label: const Text('PILIH UNIT'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_selectedUnit != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Branding.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${_selectedUnit!.unitCode} - ${_selectedUnit!.unitName}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const Text('Belum ada unit dipilih'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Operator Data
              if (_selectedUnit != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Data Operator',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingOperator)
                          const Center(child: CircularProgressIndicator())
                        else if (_operatorEntry != null)
                          Column(
                            children: [
                              _buildInfoRow('Operator', _operatorEntry!.operatorName),
                              const SizedBox(height: 8),
                              _buildInfoRow('Hour Meter', '${_operatorEntry!.hourMeter.toStringAsFixed(1)} jam'),
                              const SizedBox(height: 8),
                              _buildInfoRow('Level', '${_operatorEntry!.fuelLevelBefore} → ${_operatorEntry!.fuelLevelAfter}'),
                              const SizedBox(height: 8),
                              _buildInfoRow('Estimasi Liter', '${_operatorEntry!.estimatedLiter.toStringAsFixed(0)} L',
                                  isHighlight: true),
                            ],
                          )
                        else
                          const Text('Tidak ada data pending'),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Totalizer Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Totalizer / Flowmeter',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _totalizerAwalController,
                        decoration: const InputDecoration(
                          labelText: 'Totalizer AWAL (Liter)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.speed),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateLiter(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan totalizer awal';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _totalizerAkhirController,
                        decoration: const InputDecoration(
                          labelText: 'Totalizer AKHIR (Liter)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.speed),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateLiter(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan totalizer akhir';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_calculatedLiter != null && _calculatedLiter! > 0)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Branding.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Jumlah Fuel Terisi:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${_calculatedLiter!.toStringAsFixed(0)} Liter',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Branding.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Variance Info
              if (_operatorLiter != null && _calculatedLiter != null)
                Card(
                  color: _isVarianceExceeded ? Colors.red.shade50 : Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Variance Analysis',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Operator', '${_operatorLiter!.toStringAsFixed(0)} L'),
                        _buildInfoRow('Fuelman', '${_calculatedLiter!.toStringAsFixed(0)} L'),
                        const Divider(),
                        _buildInfoRow('Selisih', '${_variance!.toStringAsFixed(0)} L',
                            isHighlight: true),
                        _buildInfoRow('Toleransi', '${Branding.varianceThreshold}%'),
                        const SizedBox(height: 8),
                        if (_isVarianceExceeded)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Variance melebihi toleransi. Data akan dikirim ke supervisor untuk approval.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_variance! > 0)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Variance dalam toleransi. Data akan auto-approve.',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Photos
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dokumentasi Totalizer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPhotoButton(
                              label: 'Foto AWAL',
                              icon: Icons.camera_alt,
                              photoPath: _photoTotalizerAwalPath,
                              onTap: () => _takePhoto('awal'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPhotoButton(
                              label: 'Foto AKHIR',
                              icon: Icons.camera_alt,
                              photoPath: _photoTotalizerAkhirPath,
                              onTap: () => _takePhoto('akhir'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '* Foto opsional untuk testing web, bisa dikosongkan',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _operatorEntry == null ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Branding.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'KONFIRMASI & SIMPAN',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Copyright footer
              Center(
                child: Text(
                  Branding.copyrightText,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlight ? 16 : 14,
              color: isHighlight ? Branding.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoButton({
    required String label,
    required IconData icon,
    required String? photoPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: photoPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(photoPath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(Opsional)',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}