import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/inscription_service.dart';
import '../../../../data/services/authorized_scanners_service.dart';
import '../../../../data/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Page de scan QR Code
class ScanQrPage extends ConsumerStatefulWidget {
  const ScanQrPage({super.key});

  @override
  ConsumerState<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends ConsumerState<ScanQrPage> {
  late MobileScannerController controller;
  bool isScanning = true;
  String? lastScannedCode;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        actions: [
          IconButton(
            icon: Icon(isScanning ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleScanning,
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone de scan avec overlay moderne
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                isScanning
                    ? MobileScanner(
                        controller: controller,
                        onDetect: _onDetect,
                      )
                    : _buildScanningPaused(theme),
                // Overlay avec cadre de scan
                if (isScanning)
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          // Coins du cadre
                          Positioned(
                            top: -2,
                            left: -2,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: theme.colorScheme.primary, width: 6),
                                  left: BorderSide(color: theme.colorScheme.primary, width: 6),
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: theme.colorScheme.primary, width: 6),
                                  right: BorderSide(color: theme.colorScheme.primary, width: 6),
                                ),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            left: -2,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: theme.colorScheme.primary, width: 6),
                                  left: BorderSide(color: theme.colorScheme.primary, width: 6),
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: theme.colorScheme.primary, width: 6),
                                  right: BorderSide(color: theme.colorScheme.primary, width: 6),
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Instructions
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scannez le QR Code d\'un participant',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Positionnez le code QR dans le cadre pour le scanner',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Boutons d'action
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (lastScannedCode != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Code scanné avec succès',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastScannedCode!,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleFlash,
                        icon: const Icon(Icons.flashlight_on_rounded),
                        label: const Text('Éclairer'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _toggleScanning,
                        icon: Icon(isScanning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                        label: Text(isScanning ? 'Pause' : 'Reprendre'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningPaused(ThemeData theme) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pause_circle_outline,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Scan en pause',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur "Reprendre" pour continuer',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue != lastScannedCode) {
        setState(() {
          lastScannedCode = barcode.rawValue;
        });
        _handleScannedCode(barcode.rawValue!);
      }
    }
  }

  void _handleScannedCode(String code) {
    if (isProcessing) return;
    
    // Pause le scan pendant le traitement
    setState(() {
      isScanning = false;
      isProcessing = true;
    });
    controller.stop();
    
    _processScannedCode(code);
  }

  Future<void> _processScannedCode(String code) async {
    try {
      // Extraire l'eventId du code QR (format: eventId_userId_timestamp)
      final parts = code.split('_');
      if (parts.length < 2) {
        throw Exception('QR code invalide');
      }
      final eventId = parts[0];
      
      // Récupérer l'utilisateur actuel
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('Vous devez être connecté pour scanner');
      }
      
      // Vérifier si l'utilisateur est autorisé à scanner
      final isAuthorized = await AuthorizedScannersService.isAuthorizedToScan(
        eventId: eventId,
        userId: currentUser.id,
      );
      
      if (!isAuthorized) {
        throw Exception('Vous n\'êtes pas autorisé à scanner pour cet événement');
      }
      
      // Effectuer le check-in
      await InscriptionService.checkIn(code);
      
      // Vibration de succès
      HapticFeedback.heavyImpact();
      
      if (mounted) {
        // Afficher le succès
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            title: const Text('Check-in réussi !'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Le participant a été enregistré avec succès.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Code: ${code.substring(0, 20)}...',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resumeScanning();
                },
                child: const Text('Scanner un autre'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Retour à la page précédente
                },
                child: const Text('Terminer'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Vibration d'erreur
      HapticFeedback.vibrate();
      
      if (mounted) {
        // Afficher l'erreur
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            title: const Text('Erreur'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  e.toString().replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Vérifiez que le QR code est valide et que le participant n\'a pas déjà effectué son check-in.',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Retour à la page précédente
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resumeScanning();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        );
      }
    }
  }
  
  void _resumeScanning() {
    setState(() {
      isScanning = true;
      isProcessing = false;
      lastScannedCode = null;
    });
    controller.start();
  }

  void _toggleScanning() {
    setState(() {
      isScanning = !isScanning;
    });
    
    if (isScanning) {
      controller.start();
    } else {
      controller.stop();
    }
  }

  void _toggleFlash() async {
    await controller.toggleTorch();
  }
}

