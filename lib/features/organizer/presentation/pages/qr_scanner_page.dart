import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import '../../../../data/services/firebase_service.dart';
import '../../../../data/models/registration_model.dart';
import '../../../../data/models/event_model.dart';
import 'scan_result_page.dart';

/// Page de scan de QR codes pour valider les tickets
class QRScannerPage extends StatefulWidget {
  final EventModel? event; // Optionnel : pour filtrer par événement

  const QRScannerPage({
    super.key,
    this.event,
  });

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _flashOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null 
            ? 'Scanner - ${widget.event!.title}' 
            : 'Scanner de tickets'),
        centerTitle: true,
        actions: [
          // Bouton flash
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() {
                _flashOn = !_flashOn;
              });
              _controller.toggleTorch();
            },
          ),
          // Bouton pour changer de caméra
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (!_isProcessing) {
                _handleBarcode(capture);
              }
            },
          ),

          // Overlay avec cadre de scan
          _buildScanOverlay(theme),

          // Instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Placez le QR code dans le cadre',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Le scan se fera automatiquement',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Loader pendant le traitement
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay(ThemeData theme) {
    return CustomPaint(
      painter: ScannerOverlayPainter(),
      child: Container(),
    );
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Décoder les données du QR code
      final Map<String, dynamic> qrData = jsonDecode(code);

      // Vérifier les champs requis
      if (!qrData.containsKey('registrationId') || 
          !qrData.containsKey('eventId')) {
        throw Exception('QR code invalide');
      }

      final String registrationId = qrData['registrationId'];
      final String eventId = qrData['eventId'];

      // Si on scanne pour un événement spécifique, vérifier la correspondance
      if (widget.event != null && widget.event!.id != eventId) {
        throw Exception('Ce ticket n\'est pas pour cet événement');
      }

      // Récupérer l'inscription depuis Firestore
      final registration = await _getRegistration(registrationId);
      
      if (registration == null) {
        throw Exception('Inscription introuvable');
      }

      if (!registration.isActive) {
        throw Exception('Ce ticket a été annulé');
      }

      // Récupérer l'événement
      final event = await FirebaseService.getEvent(eventId);
      
      if (event == null) {
        throw Exception('Événement introuvable');
      }

      // Naviguer vers la page de résultat
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultPage(
              registration: registration,
              event: event,
              qrData: qrData,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<RegistrationModel?> _getRegistration(String registrationId) async {
    try {
      final doc = await FirebaseService.registrationsCollection
          .doc(registrationId)
          .get();
      
      if (doc.exists) {
        return RegistrationModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            const Text('Erreur'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Painter pour dessiner le cadre de scan
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;

    // Fond semi-transparent
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Zone de scan transparente
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
        const Radius.circular(16),
      ),
      clearPaint,
    );

    // Bordure du cadre
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Coins du cadre
    final cornerLength = 30.0;
    
    // Coin supérieur gauche
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + cornerLength),
      borderPaint,
    );

    // Coin supérieur droit
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top),
      Offset(left + scanAreaSize, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize, top + cornerLength),
      borderPaint,
    );

    // Coin inférieur gauche
    canvas.drawLine(
      Offset(left, top + scanAreaSize - cornerLength),
      Offset(left, top + scanAreaSize),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left + cornerLength, top + scanAreaSize),
      borderPaint,
    );

    // Coin inférieur droit
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize - cornerLength),
      Offset(left + scanAreaSize, top + scanAreaSize),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
