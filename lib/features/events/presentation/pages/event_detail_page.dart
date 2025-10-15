import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/events_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/loading_widget.dart';
import '../../../../core/app_router.dart';
import '../widgets/event_info_section.dart';
import '../widgets/participants_section.dart';
import 'event_qr_page.dart';

/// Page de détail d'un événement
class EventDetailPage extends ConsumerWidget {
  final String eventId;

  const EventDetailPage({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final event = ref.watch(eventProvider(eventId));
    final currentUser = ref.watch(currentUserProvider);
    final isOwner = ref.watch(isOwnerProvider);

    return Scaffold(
      body: event.when(
        data: (eventData) {
          if (eventData == null) {
            return const Center(
              child: Text('Événement non trouvé'),
            );
          }

          return CustomScrollView(
            slivers: [
              // AppBar avec image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: eventData.imageUrl != null
                      ? Image.network(
                          eventData.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage(theme);
                          },
                        )
                      : _buildPlaceholderImage(theme),
                ),
                actions: [
                  if (isOwner && eventData.organizerId == currentUser?.id)
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Modifier'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Supprimer'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editEvent(context, eventData);
                        } else if (value == 'delete') {
                          _deleteEvent(context, eventData);
                        }
                      },
                    ),
                ],
              ),
              // Contenu principal
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Informations principales
                    EventInfoSection(event: eventData),
                    const SizedBox(height: 24),
                    // Section des participants
                    ParticipantsSection(eventId: eventId),
                    const SizedBox(height: 24),
                    // Boutons d'action
                    _buildActionButtons(context, eventData, isOwner, ref),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(message: 'Chargement de l\'événement...'),
        error: (error, stack) => Center(
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
                error.toString(),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Réessayer',
                onPressed: () {
                  ref.invalidate(eventProvider(eventId));
                },
                type: ButtonType.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.event,
          size: 64,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, eventData, bool isOwner, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider);
    final isRegistered = eventData.participantIds.contains(currentUser?.id);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isOwner && eventData.organizerId == currentUser?.id) ...[
          // Boutons pour l'organisateur
          CustomButton(
            text: 'Voir les participants',
            onPressed: () => _viewParticipants(context, eventData.id),
            type: ButtonType.primary,
            size: ButtonSize.large,
            icon: Icons.people,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Scanner QR Code',
            onPressed: () => _scanQrCode(context),
            type: ButtonType.secondary,
            size: ButtonSize.large,
            icon: Icons.qr_code_scanner,
          ),
        ] else ...[
          // Bouton QR Code si inscrit
          if (isRegistered) ...[
            CustomButton(
              text: 'Voir mon QR Code',
              onPressed: () => _showMyQRCode(context, eventData, currentUser!.id),
              type: ButtonType.primary,
              size: ButtonSize.large,
              icon: Icons.qr_code,
            ),
            const SizedBox(height: 12),
          ],
          // Boutons pour les participants
          if (eventData.isFull)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cet événement est complet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            CustomButton(
              text: 'S\'inscrire',
              onPressed: () => _registerForEvent(context, eventData.id),
              type: ButtonType.primary,
              size: ButtonSize.large,
              icon: Icons.person_add,
            ),
        ],
        const SizedBox(height: 12),
        // Bouton pour voir sur la carte
        CustomButton(
          text: 'Voir sur la carte',
          onPressed: () => _viewOnMap(context, eventData),
          type: ButtonType.secondary,
          size: ButtonSize.large,
          icon: Icons.map,
        ),
      ],
    );
  }

  void _editEvent(BuildContext context, eventData) {
    // TODO: Implémenter l'édition d'événement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'édition à implémenter'),
      ),
    );
  }

  void _deleteEvent(BuildContext context, eventData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'événement'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet événement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la suppression
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité de suppression à implémenter'),
                ),
              );
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _viewParticipants(BuildContext context, String eventId) {
    // TODO: Implémenter la vue des participants
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de participants à implémenter'),
      ),
    );
  }

  void _scanQrCode(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.scanQr);
  }

  void _showMyQRCode(BuildContext context, eventData, String userId) {
    // Générer l'ID de réservation (eventId_userId)
    final registrationId = '${eventData.id}_$userId';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventQRPage(
          event: eventData,
          registrationId: registrationId,
        ),
      ),
    );
  }

  void _registerForEvent(BuildContext context, String eventId) {
    // TODO: Implémenter l'inscription
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'inscription à implémenter'),
      ),
    );
  }

  void _viewOnMap(BuildContext context, eventData) {
    Navigator.pushNamed(
      context,
      AppRouter.map,
      arguments: {
        'latitude': eventData.latitude,
        'longitude': eventData.longitude,
        'title': eventData.title,
      },
    );
  }
}
