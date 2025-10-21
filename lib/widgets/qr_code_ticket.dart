import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/registration_model.dart';
import '../data/models/event_model.dart';
import 'package:intl/intl.dart';

/// Widget pour afficher un ticket avec QR code
class QRCodeTicket extends StatelessWidget {
  final RegistrationModel registration;
  final EventModel event;

  const QRCodeTicket({
    super.key,
    required this.registration,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre Ticket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareTicket(context),
            tooltip: 'Partager',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec succès
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 80,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Inscription confirmée !',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre ticket a été généré avec succès',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Ticket principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: registration.qrCode,
                            version: QrVersions.auto,
                            size: 250,
                            backgroundColor: Colors.white,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Présentez ce QR code à l\'entrée',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Informations de l'événement
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre de l'événement
                          Text(
                            event.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Date et heure
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            label: 'Date',
                            value: dateFormat.format(event.dateTime),
                            theme: theme,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.access_time,
                            label: 'Heure',
                            value: timeFormat.format(event.dateTime),
                            theme: theme,
                          ),
                          const SizedBox(height: 12),

                          // Lieu
                          _buildInfoRow(
                            icon: Icons.location_on,
                            label: 'Lieu',
                            value: event.location,
                            theme: theme,
                          ),
                          const SizedBox(height: 12),

                          // Type de ticket
                          _buildInfoRow(
                            icon: Icons.confirmation_number,
                            label: 'Type de ticket',
                            value: registration.ticketType ?? 'Standard',
                            theme: theme,
                          ),

                          // Prix (si payant)
                          if (registration.ticketPrice != null &&
                              registration.ticketPrice! > 0) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.payments,
                              label: 'Prix',
                              value:
                                  '${registration.ticketPrice!.toStringAsFixed(0)} ${event.currency}',
                              theme: theme,
                            ),
                          ],

                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Informations du participant
                          Text(
                            'Participant',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.person,
                            label: 'Nom',
                            value: registration.userName,
                            theme: theme,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.email,
                            label: 'Email',
                            value: registration.userEmail,
                            theme: theme,
                          ),
                          if (registration.userPhone != null) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.phone,
                              label: 'Téléphone',
                              value: registration.userPhone!,
                              theme: theme,
                            ),
                          ],

                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Numéro de ticket
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.tag,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Numéro de ticket',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      Text(
                                        registration.id.substring(0, 8).toUpperCase(),
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Boutons d'action
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _shareTicket(context),
                      icon: const Icon(Icons.share),
                      label: const Text('Partager le ticket'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Fermer'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Note importante
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Conservez ce ticket. Il sera scanné à l\'entrée de l\'événement. '
                          'Vous pouvez également le retrouver dans vos événements.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _shareTicket(BuildContext context) {
    Share.share(
      'Mon ticket pour ${event.title}\n\n'
      'Date: ${DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(event.dateTime)}\n'
      'Lieu: ${event.location}\n'
      'Ticket: ${registration.id.substring(0, 8).toUpperCase()}\n\n'
      'Voir plus de détails dans l\'application EventMate',
      subject: 'Ticket - ${event.title}',
    );
  }
}
