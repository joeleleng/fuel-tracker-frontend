import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';
import '../models/fuel_entry_hive.dart';
import '../models/unit.dart';
import '../models/user.dart';
import '../services/hive_database_service.dart';
import '../services/detection_service.dart';
import '../services/tracking_service.dart';
import '../widgets/fuel_gauge_widget.dart';
import '../config/branding.dart';
import 'qr_scanner_screen.dart';

class OperatorFuelForm extends StatefulWidget {
  final User user;
  final Unit? initialUnit;

  const OperatorFuelForm({
    Key? key,
    required this.user,
    this.initialUnit,
  }) : super(key: key);

  @override
  State<OperatorFuelForm> createState() => _OperatorFuelFormState();
}

class _OperatorFuelFormState extends State<OperatorFuelForm> {
  final _formKey = GlobalKey<FormState>();
  final HiveDatabaseService _dbService = HiveDatabaseService();
  final DetectionService _detectionService = DetectionService();
  final TrackingService _trackingService = TrackingService();
  final Uuid _uuid = Uuid();

  // Form fields
  Unit? _selectedUnit;
  final TextEditingController _hmController = TextEditingController();
  String? _fuelLevelBefore;
  String? _fuelLevelAfter;
  double? _calculatedLiter;

  // Photo paths
  String? _photoBeforePath;
  String? _photoAfterPath;

  // Location
  Position? _currentPosition;
  String? _currentAddress;

  // Loading states
  bool _isLoading = false;
  bool _isScanning = false;

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
    _getCurrentLocation();
    if (widget.initialUnit != null) {
      setState(() {
        _selectedUnit = widget.initialUnit;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktifkan GPS untuk mengambil lokasi')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _currentPosition = position);

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _currentAddress = '${place.street}, ${place.subLocality}, ${place.locality}';
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateLiter() {
    if (_fuelLevelBefore != null && _fuelLevelAfter != null) {
      double liter = Branding.calculateLiter(
        _fuelLevelBefore!,
        _fuelLevelAfter!,
      );
      setState(() {
        _calculatedLiter = liter;
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
        if (type == 'before') {
          _photoBeforePath = photo.path;
        } else {
          _photoAfterPath = photo.path;
        }
      });
    }
  }

  void _startQRScan() {
    setState(() => _isScanning = true);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          user: widget.user,
          onScan: (scannedUnit) {
            setState(() {
              _selectedUnit = scannedUnit;
              _isScanning = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unit ${scannedUnit.unitCode} berhasil discan')),
            );
          },
        ),
      ),
    ).then((_) {
      setState(() => _isScanning = false);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih unit terlebih dahulu')),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tunggu GPS mendapatkan lokasi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current shift
      String shift = Branding.getCurrentShift();
      double hourMeterValue = double.parse(_hmController.text);

      // Create fuel entry
      FuelEntryHive entry = FuelEntryHive(
        id: _uuid.v4(),
        unitCode: _selectedUnit!.unitCode,
        operatorId: widget.user.username,
        operatorName: widget.user.name,
        hourMeter: hourMeterValue,
        fuelLevelBefore: _fuelLevelBefore!,
        fuelLevelAfter: _fuelLevelAfter!,
        estimatedLiter: _calculatedLiter!,
        photoBeforePath: _photoBeforePath ?? 'demo_photo.jpg',
        photoAfterPath: _photoAfterPath ?? 'demo_photo.jpg',
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        locationAddress: _currentAddress ?? 'Unknown',
        timestamp: DateTime.now(),
        shift: shift,
        status: 'pending',
        isSynced: false,
      );

      // ============================================
      // AUTO-DETECT MANIPULATION & GAP
      // ============================================
      
      // Run all detections
      final detectionResult = await _detectionService.runAllDetections(entry, true);
      
      // Update entry dengan hasil deteksi
      entry.isManipulationFlag = detectionResult['isManipulationFlag'];
      entry.manipulationType = detectionResult['manipulationType'];
      entry.manipulationReason = detectionResult['manipulationReason'];
      entry.estimatedLoss = detectionResult['estimatedLoss'];
      entry.isGapDetected = detectionResult['isGapDetected'];
      entry.gapValue = detectionResult['gapValue'];
      entry.isDuplicateFueling = detectionResult['isDuplicateFueling'];
      entry.duplicateCount = detectionResult['duplicateCount'];
      
      // Jika ada deteksi manipulasi atau gap, set status khusus
      if (detectionResult['isManipulationFlag'] || detectionResult['isGapDetected']) {
        entry.status = 'flagged_for_review';
      }

      // SAVE TO HIVE DATABASE
      await _dbService.saveFuelEntry(entry);
      
      // Update tracking HM
      await _trackingService.saveLastHM(
        entry.unitCode,
        entry.hourMeter,
        entry.id,
      );

      print('📝 Fuel Entry Saved to Hive:');
      print('   ID: ${entry.id}');
      print('   Unit: ${entry.unitCode}');
      print('   Liter: ${entry.estimatedLiter}');
      print('   HM: ${entry.hourMeter}');
      print('   Status: ${entry.status}');
      
      if (detectionResult['isManipulationFlag']) {
        print('   ⚠️ MANIPULATION DETECTED: ${detectionResult['manipulationReason']}');
        print('   💰 Estimated Loss: Rp ${detectionResult['estimatedLoss']?.toStringAsFixed(0)}');
      }
      if (detectionResult['isGapDetected']) {
        print('   ⚠️ GAP DETECTED: ${detectionResult['reason'] ?? detectionResult['manipulationReason']}');
      }
      if (detectionResult['isDuplicateFueling']) {
        print('   ⚠️ DUPLICATE FUELING: ${detectionResult['duplicateCount']}x dalam shift');
      }

      if (mounted) {
        // Tampilkan alert jika ada deteksi
        String alertMessage = '';
        Color alertColor = Branding.successColor;
        
        if (detectionResult['isManipulationFlag']) {
          alertMessage = '⚠️ ${detectionResult['manipulationReason']}\n'
                        'Estimasi kerugian: Rp ${detectionResult['estimatedLoss']?.toStringAsFixed(0)}';
          alertColor = Colors.orange;
        } else if (detectionResult['isGapDetected']) {
          alertMessage = '⚠️ Terdeteksi gap data: ${detectionResult['gapValue']} jam\n'
                        'Data akan direview supervisor';
          alertColor = Colors.orange;
        } else if (detectionResult['isDuplicateFueling']) {
          alertMessage = '⚠️ Pengisian berulang terdeteksi (${detectionResult['duplicateCount']}x dalam shift)';
          alertColor = Colors.orange;
        } else {
          alertMessage = 'Data pengisian ${_calculatedLiter!.toStringAsFixed(0)}L berhasil disimpan. '
                        'Menunggu verifikasi Fuelman.';
          alertColor = Branding.successColor;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(alertMessage),
            backgroundColor: alertColor,
            duration: const Duration(seconds: 5),
          ),
        );

        // Clear form
        _hmController.clear();
        setState(() {
          _fuelLevelBefore = null;
          _fuelLevelAfter = null;
          _calculatedLiter = null;
          _photoBeforePath = null;
          _photoAfterPath = null;
        });

        // Navigate back
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error saving fuel entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Branding.dangerColor),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISI FUEL'),
        backgroundColor: Branding.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _startQRScan,
            tooltip: 'Scan QR Unit',
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
                            label: const Text('SCAN QR'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Unit>(
                        value: _selectedUnit,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Pilih Unit',
                        ),
                        items: _units.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text('${unit.unitCode} - ${unit.unitName}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedUnit = value);
                        },
                        validator: (value) =>
                            value == null ? 'Pilih unit' : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Hour Meter
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hour Meter (HM)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _hmController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Contoh: 1234.5',
                          prefixIcon: Icon(Icons.speed),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan HM';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Fuel Level Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Level Tangki',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text('SEBELUM'),
                                const SizedBox(height: 8),
                                FuelGaugeWidget(
                                  selectedLevel: _fuelLevelBefore,
                                  onLevelSelected: (level) {
                                    setState(() {
                                      _fuelLevelBefore = level;
                                      _calculateLiter();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                const Text('SESUDAH'),
                                const SizedBox(height: 8),
                                FuelGaugeWidget(
                                  selectedLevel: _fuelLevelAfter,
                                  onLevelSelected: (level) {
                                    setState(() {
                                      _fuelLevelAfter = level;
                                      _calculateLiter();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_calculatedLiter != null && _calculatedLiter! > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Branding.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Branding.primaryColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Jumlah Liter Terisi:',
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

              // Photos
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dokumentasi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPhotoButton(
                              label: 'Foto SEBELUM',
                              icon: Icons.camera_alt,
                              photoPath: _photoBeforePath,
                              onTap: () => _takePhoto('before'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPhotoButton(
                              label: 'Foto SESUDAH',
                              icon: Icons.camera_alt,
                              photoPath: _photoAfterPath,
                              onTap: () => _takePhoto('after'),
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

              const SizedBox(height: 16),

              // Location Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: _currentPosition != null
                            ? Branding.successColor
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi Pengisian',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _currentAddress ?? 'Mendapatkan lokasi...',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _getCurrentLocation,
                        tooltip: 'Refresh Lokasi',
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
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Branding.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'SIMPAN DATA PENGISIAN',
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