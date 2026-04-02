import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../models/unit.dart';

class QRScannerScreen extends StatefulWidget {
  final User user;
  final Function(Unit) onScan;

  const QRScannerScreen({Key? key, required this.user, required this.onScan})
      : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;
  bool _torchEnabled = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggleTorch() {
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
    controller.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SCAN QR CODE'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: _torchEnabled ? Colors.yellow : Colors.white,
            ),
            onPressed: _toggleTorch,
            tooltip: 'Flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (!_isScanning) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final scannedCode = barcode.rawValue;
                if (scannedCode != null) {
                  setState(() {
                    _isScanning = false;
                  });
                  
                  // Create unit from scan result
                  final scannedUnit = Unit(
                    unitCode: scannedCode,
                    unitName: scannedCode,
                    type: 'Unknown',
                    category: 'Unknown',
                    qrCode: scannedCode,
                    isActive: true,
                  );
                  
                  widget.onScan(scannedUnit);
                  
                  if (mounted) {
                    Navigator.pop(context);
                  }
                  return;
                }
              }
            },
          ),
          // Overlay guide with cutout
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            margin: const EdgeInsets.all(60),
            child: const Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Icon(Icons.crop_square, size: 30, color: Colors.white),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(Icons.crop_square, size: 30, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Icon(Icons.crop_square, size: 30, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(Icons.crop_square, size: 30, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Arahkan kamera ke QR Code unit',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          // Loading overlay
          if (!_isScanning)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Memproses...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}