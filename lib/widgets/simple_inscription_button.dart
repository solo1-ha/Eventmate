import 'package:flutter/material.dart';
import '../data/models/event_model.dart';
import '../data/models/user_model.dart';

/// Bouton d'inscription SIMPLIFIÉ pour tester
class SimpleInscriptionButton extends StatelessWidget {
  final EventModel event;
  final UserModel user;

  const SimpleInscriptionButton({
    super.key,
    required this.event,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final eventDate = event.dateTime;
    final isPast = eventDate.isBefore(now);
    
    // TOUJOURS afficher les infos de debug
    print('═══════════════════════════════════════');
    print('🔍 SIMPLE INSCRIPTION BUTTON');
    print('Event: ${event.title}');
    print('Date événement: $eventDate');
    print('Date actuelle: $now');
    print('Différence: ${now.difference(eventDate).inHours} heures');
    print('Est passé? $isPast');
    print('═══════════════════════════════════════');

    // 1. Vérifier si organisateur
    if (event.organizerId == user.id) {
      return _buildDisabledButton(
        context,
        icon: Icons.manage_accounts,
        label: 'Vous êtes l\'organisateur',
        color: theme.colorScheme.primaryContainer,
      );
    }

    // 2. Vérifier si événement passé
    if (isPast) {
      return _buildDisabledButton(
        context,
        icon: Icons.event_busy,
        label: 'Événement terminé',
        color: Colors.grey.shade300,
      );
    }

    // 3. Vérifier si complet
    if (event.currentParticipants >= event.maxCapacity) {
      return _buildDisabledButton(
        context,
        icon: Icons.block,
        label: 'Événement complet',
        color: Colors.orange.shade200,
      );
    }

    // 4. Bouton actif
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription en cours...'),
            ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('S\'inscrire'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDisabledButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: null, // DÉSACTIVÉ
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: color,
          disabledBackgroundColor: color,
          disabledForegroundColor: Colors.black54,
        ),
      ),
    );
  }
}
