import 'package:flutter/material.dart';
import '../../../../data/models/registration_model.dart';
import '../../../../data/models/event_model.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../../widgets/custom_button.dart';

/// Page affichant le résultat du scan d'un ticket
class ScanResultPage extends StatefulWidget {
  final RegistrationModel registration;
  final EventModel event;
  final Map<String, dynamic> qrData;

  const ScanResultPage({
    super.key,
    required this.registration,
    required this.event,
    required this.qrData,
  });

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  bool _isValidating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCheckedIn = widget.registration.hasCheckedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du scan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Statut du ticket
            _buildStatusCard(theme, hasCheckedIn),
            const SizedBox(height: 24),

            // Informations du participant
            _buildInfoCard(
              theme,
              'Participant',
              Icons.person,
              [
                _InfoRow('Nom', widget.registration.userName),
                _InfoRow('Email', widget.registration.userEmail),
                if (widget.registration.userPhone != null)
                  _InfoRow('Téléphone', widget.registration.userPhone!),
              ],
            ),
            const SizedBox(height: 16),

            // Informations du ticket
            _buildInfoCard(
              theme,
              'Ticket',
              Icons.confirmation_number,
              [
                if (widget.registration.ticketType != null)
                  _InfoRow('Type', widget.registration.ticketType!),
                if (widget.registration.ticketPrice != null)
                  _InfoRow('Prix', '${widget.registration.ticketPrice!.toStringAsFixed(0)} GNF'),
                _InfoRow(
                  'Inscrit le',
                  _formatDateTime(widget.registration.registeredAt),
                ),
                if (hasCheckedIn)
                  _InfoRow(
                    'Check-in',
                    _formatDateTime(widget.registration.checkedInAt!),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Informations de l'événement
            _buildInfoCard(
              theme,
              'Événement',
              Icons.event,
              [
                _InfoRow('Titre', widget.event.title),
                _InfoRow('Date', _formatDate(widget.event.dateTime)),
                _InfoRow('Heure', _formatTime(widget.event.dateTime)),
                _InfoRow('Lieu', widget.event.location),
              ],
            ),
            const SizedBox(height: 32),

            // Bouton de validation
            if (!hasCheckedIn)
              CustomButton(
                text: 'Valider l\'entrée',
                onPressed: _isValidating ? null : _validateEntry,
                type: ButtonType.primary,
                size: ButtonSize.large,
                isLoading: _isValidating,
                icon: Icons.check_circle,
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Text(
                      'Entrée déjà validée',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Bouton retour
            CustomButton(
              text: 'Scanner un autre ticket',
              onPressed: () => Navigator.pop(context),
              type: ButtonType.secondary,
              size: ButtonSize.large,
              icon: Icons.qr_code_scanner,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme, bool hasCheckedIn) {
    final color = hasCheckedIn ? Colors.orange : Colors.green;
    final icon = hasCheckedIn ? Icons.info_outline : Icons.check_circle_outline;
    final title = hasCheckedIn ? 'Déjà validé' : 'Ticket valide';
    final subtitle = hasCheckedIn
        ? 'Ce ticket a déjà été utilisé'
        : 'Ce ticket est valide et peut être utilisé';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color.shade900,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    String title,
    IconData icon,
    List<_InfoRow> rows,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...rows.map((row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      row.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _validateEntry() async {
    setState(() {
      _isValidating = true;
    });

    try {
      // Marquer le check-in dans Firestore
      await FirebaseService.checkInParticipant(widget.registration.id);

      if (mounted) {
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Entrée validée avec succès pour ${widget.registration.userName}'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Retourner au scanner après 2 secondes
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la validation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow {
  final String label;
  final String value;

  _InfoRow(this.label, this.value);
}
