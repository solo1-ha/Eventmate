import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/inscription_service.dart';
import '../../../../data/models/registration_model.dart';
import '../../../../widgets/loading_widget.dart';

/// Page listant tous les participants d'un événement
class ParticipantsListPage extends ConsumerWidget {
  final String eventId;
  final String eventTitle;

  const ParticipantsListPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Participants - $eventTitle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _scanQrCode(context),
            tooltip: 'Scanner QR Code',
          ),
        ],
      ),
      body: StreamBuilder<List<RegistrationModel>>(
        stream: InscriptionService.getEventRegistrations(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Chargement des participants...');
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur lors du chargement',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun participant',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les inscriptions apparaîtront ici',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          final registrations = snapshot.data!;
          final checkedInCount = registrations.where((r) => r.hasCheckedIn).length;
          final totalRevenue = registrations
              .where((r) => r.ticketPrice != null)
              .fold<double>(0, (sum, r) => sum + (r.ticketPrice ?? 0));

          return Column(
            children: [
              // Statistiques
              _buildStatisticsCard(
                theme,
                registrations.length,
                checkedInCount,
                totalRevenue,
              ),

              // Filtres
              _buildFilters(theme),

              // Liste des participants
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: registrations.length,
                  itemBuilder: (context, index) {
                    final registration = registrations[index];
                    return _buildParticipantCard(
                      context,
                      theme,
                      registration,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Carte des statistiques
  Widget _buildStatisticsCard(
    ThemeData theme,
    int totalParticipants,
    int checkedIn,
    double revenue,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    Icons.people,
                    'Total',
                    totalParticipants.toString(),
                    theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    Icons.check_circle,
                    'Check-in',
                    checkedIn.toString(),
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    Icons.payments,
                    'Revenus',
                    '${revenue.toStringAsFixed(0)} GNF',
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// Filtres
  Widget _buildFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'all',
                  label: Text('Tous'),
                  icon: Icon(Icons.people),
                ),
                ButtonSegment(
                  value: 'checked',
                  label: Text('Check-in'),
                  icon: Icon(Icons.check_circle),
                ),
                ButtonSegment(
                  value: 'pending',
                  label: Text('En attente'),
                  icon: Icon(Icons.pending),
                ),
              ],
              selected: const {'all'},
              onSelectionChanged: (Set<String> newSelection) {
                // TODO: Implémenter le filtrage
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Carte d'un participant
  Widget _buildParticipantCard(
    BuildContext context,
    ThemeData theme,
    RegistrationModel registration,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showParticipantDetails(context, registration),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: registration.hasCheckedIn
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                child: Icon(
                  registration.hasCheckedIn
                      ? Icons.check_circle
                      : Icons.pending,
                  color: registration.hasCheckedIn
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      registration.userName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      registration.userEmail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          registration.ticketType ?? 'Gratuit',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (registration.ticketPrice != null &&
                            registration.ticketPrice! > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${registration.ticketPrice!.toStringAsFixed(0)} GNF',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Statut et date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: registration.hasCheckedIn
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      registration.hasCheckedIn ? 'Présent' : 'En attente',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: registration.hasCheckedIn
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(registration.registeredAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (registration.hasCheckedIn) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Check-in: ${DateFormat('HH:mm').format(registration.checkedInAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Afficher les détails d'un participant
  void _showParticipantDetails(
    BuildContext context,
    RegistrationModel registration,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Détails du participant',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Contenu
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statut
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: registration.hasCheckedIn
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              registration.hasCheckedIn
                                  ? Icons.check_circle
                                  : Icons.pending,
                              size: 64,
                              color: registration.hasCheckedIn
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              registration.hasCheckedIn
                                  ? 'Check-in effectué'
                                  : 'En attente de check-in',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: registration.hasCheckedIn
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Informations
                    _buildDetailRow(
                      Icons.person,
                      'Nom',
                      registration.userName,
                    ),
                    _buildDetailRow(
                      Icons.email,
                      'Email',
                      registration.userEmail,
                    ),
                    if (registration.userPhone != null)
                      _buildDetailRow(
                        Icons.phone,
                        'Téléphone',
                        registration.userPhone!,
                      ),
                    _buildDetailRow(
                      Icons.confirmation_number,
                      'Type de ticket',
                      registration.ticketType ?? 'Gratuit',
                    ),
                    if (registration.ticketPrice != null &&
                        registration.ticketPrice! > 0)
                      _buildDetailRow(
                        Icons.payments,
                        'Prix',
                        '${registration.ticketPrice!.toStringAsFixed(0)} GNF',
                      ),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Date d\'inscription',
                      DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR')
                          .format(registration.registeredAt),
                    ),
                    if (registration.hasCheckedIn)
                      _buildDetailRow(
                        Icons.access_time,
                        'Check-in effectué',
                        DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR')
                            .format(registration.checkedInAt!),
                      ),
                    _buildDetailRow(
                      Icons.tag,
                      'ID Ticket',
                      registration.id.substring(0, 8).toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!registration.hasCheckedIn)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _scanQrCode(context);
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scanner le QR Code'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scanQrCode(BuildContext context) {
    Navigator.pushNamed(context, '/scan-qr');
  }
}
