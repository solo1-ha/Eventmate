import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import '../../../../data/models/event_model.dart';
import '../../../../data/models/registration_model.dart';
import '../../../../widgets/custom_button.dart';

/// Page d'affichage du QR code du ticket
class TicketQRCodePage extends StatefulWidget {
  final RegistrationModel registration;
  final EventModel event;

  const TicketQRCodePage({
    super.key,
    required this.registration,
    required this.event,
  });

  @override
  State<TicketQRCodePage> createState() => _TicketQRCodePageState();
}

class _TicketQRCodePageState extends State<TicketQRCodePage> {
  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre ticket'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Message de succès
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inscription réussie !',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Présentez ce QR code à l\'entrée',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Carte du ticket
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Informations de l'événement
                    Text(
                      widget.event.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Type de ticket
                    if (widget.registration.ticketType != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.registration.ticketType!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.registration.ticketPrice != null)
                        Text(
                          '${widget.registration.ticketPrice!.toStringAsFixed(0)} GNF',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],

                    // QR Code
                    RepaintBoundary(
                      key: _qrKey,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: widget.registration.qrCode,
                          version: QrVersions.auto,
                          size: 250,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Informations du participant
                    Divider(),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.person,
                      'Nom',
                      widget.registration.userName,
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.email,
                      'Email',
                      widget.registration.userEmail,
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Date',
                      '${widget.event.dateTime.day}/${widget.event.dateTime.month}/${widget.event.dateTime.year}',
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.access_time,
                      'Heure',
                      '${widget.event.dateTime.hour}:${widget.event.dateTime.minute.toString().padLeft(2, '0')}',
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.location_on,
                      'Lieu',
                      widget.event.location,
                      theme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Partager',
                    onPressed: _shareTicket,
                    type: ButtonType.secondary,
                    size: ButtonSize.large,
                    icon: Icons.share,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Télécharger',
                    onPressed: _downloadTicket,
                    type: ButtonType.primary,
                    size: ButtonSize.large,
                    icon: Icons.download,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Retour à l\'accueil',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              type: ButtonType.text,
              size: ButtonSize.large,
              icon: Icons.home,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _shareTicket() async {
    try {
      // Capturer le QR code comme image
      final boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // Partager via share_plus
      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'image/png', name: 'ticket_${widget.registration.id}.png')],
        text: 'Mon ticket pour ${widget.event.title}\n'
            'Type: ${widget.registration.ticketType ?? "Standard"}\n'
            'Date: ${widget.event.dateTime.day}/${widget.event.dateTime.month}/${widget.event.dateTime.year}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadTicket() async {
    try {
      // Capturer le QR code comme image
      final boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // Sur web, déclencher le téléchargement
      // Sur mobile, sauvegarder dans la galerie
      // Pour l'instant, on utilise share_plus qui gère les deux cas
      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'image/png', name: 'ticket_${widget.registration.id}.png')],
        subject: 'Ticket - ${widget.event.title}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket téléchargé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
