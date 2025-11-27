import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String scanResult = "🔍 Recherche de QR Code...";
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (!status.isGranted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Permission caméra requise"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String qrData = barcodes.first.rawValue ?? "";

      setState(() {
        _isScanning = false;
        scanResult = "✅ QR Code détecté !";
      });

      // Petit délai pour montrer la confirmation
      Future.delayed(Duration(milliseconds: 1000), () {
        Navigator.pop(context, qrData);
      });
    }
  }

  void _toggleFlash() {
    cameraController.toggleTorch();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scanner Camera
          MobileScanner(
            controller: cameraController,
            onDetect: _onBarcodeDetect,
          ),

          // Overlay sombre
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          // Contenu overlay
          Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                  color: Color(0xCC1A237E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      "Scanner QR Code",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Groupelec QR Scanner",
                      style: TextStyle(
                        color: Color(0xFFFFD180),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),

              // Cadre du scanner
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFFF6F00),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Ligne de scan animée
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 2000),
                        curve: Curves.easeInOut,
                        height: 4,
                        color: Color(0xFFFF6F00),
                      ),
                    ),
                  ],
                ),
              ),

              // Message de statut
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(30),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scanResult,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),

              // Boutons en bas
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bouton Flash
                    _buildRoundButton("⚡", _toggleFlash),
                    SizedBox(width: 20),

                    // Bouton Scan principal
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isScanning = true;
                          scanResult = "🔍 Recherche de QR Code...";
                        });
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6F00),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),

                    // Bouton Retour
                    _buildRoundButton("❌", () => Navigator.pop(context)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton(String icon, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            icon,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}