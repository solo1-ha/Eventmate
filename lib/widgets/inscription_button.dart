import 'package:flutter/material.dart';
import '../data/models/event_model.dart';
import '../data/models/user_model.dart';
import '../data/services/inscription_service.dart';
import 'modal_inscription.dart';
import 'qr_code_ticket.dart';

/// Widget bouton d'inscription à un événement
/// Gère automatiquement tous les états : chargement, inscrit, complet, passé, etc.
/// 
/// Fonctionnalités :
/// - Détection automatique des événements passés
/// - Vérification si l'utilisateur est déjà inscrit
/// - Protection si l'utilisateur est l'organisateur
/// - Affichage du nombre de places disponibles
class InscriptionButton extends StatefulWidget {
  final EventModel event;  // L'événement concerné
  final UserModel user;    // L'utilisateur connecté

  const InscriptionButton({
    super.key,
    required this.event,
    required this.user,
  });

  @override
  State<InscriptionButton> createState() => _InscriptionButtonState();
}

class _InscriptionButtonState extends State<InscriptionButton> {
  // État du chargement de la vérification d'inscription
  bool _isLoading = true;
  // Si l'utilisateur est déjà inscrit à cet événement
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    // Vérifier dès le chargement si l'utilisateur est inscrit
    _checkRegistration();
  }

  @override
  void didUpdateWidget(InscriptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si l'événement change, revérifier l'inscription
    if (oldWidget.event.id != widget.event.id) {
      _checkRegistration();
    }
  }

  /// Vérifie si l'utilisateur est déjà inscrit à cet événement
  /// Appelle le service d'inscription pour interroger Firestore
  Future<void> _checkRegistration() async {
    try {
      // Appel au service pour vérifier l'inscription
      final isRegistered = await InscriptionService.isUserRegistered(
        widget.event.id,
        widget.user.id,
      );
      
      // Mettre à jour l'état seulement si le widget est toujours monté
      if (mounted) {
        setState(() {
          _isRegistered = isRegistered;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur vérification inscription: $e');
      // En cas d'erreur, considérer que l'utilisateur n'est pas inscrit
      if (mounted) {
        setState(() {
          _isRegistered = false;
          _isLoading = false;
        });
      }
    }
  }

  /// Ouvre la modal d'inscription avec toutes les vérifications
  Future<void> _openInscriptionModal() async {
    print('Ouverture modal inscription...');
    
    // VÉRIFICATION 1 : L'utilisateur ne peut pas s'inscrire à son propre événement
    if (widget.event.organizerId == widget.user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous êtes l\'organisateur de cet événement'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Vérifier si l'événement est complet
    if (widget.event.currentParticipants >= widget.event.maxCapacity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Désolé, cet événement est complet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Vérifier si l'événement est passé
    if (widget.event.dateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cet événement est déjà passé'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Ouvrir la modal
    await ModalInscription.show(
      context,
      event: widget.event,
      user: widget.user,
    );

    // Recharger l'état après fermeture de la modal
    _checkRegistration();
  }

  /// Affiche le ticket existant
  Future<void> _showExistingTicket() async {
    try {
      final registration = await InscriptionService.getUserRegistration(
        widget.event.id,
        widget.user.id,
      );

      if (registration != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRCodeTicket(
              registration: registration,
              event: widget.event,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ========================================
    // VÉRIFICATION PRIORITAIRE : Événement passé
    // ========================================
    // Cette vérification est EN PREMIER pour empêcher toute inscription
    // aux événements dont la date est déjà passée
    if (widget.event.dateTime.isBefore(DateTime.now())) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,  // Bouton désactivé (non cliquable)
          icon: const Icon(Icons.event_busy),
          label: const Text('Événement terminé'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.grey.shade300,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.black54,
          ),
        ),
      );
    }

    // ========================================
    // VÉRIFICATION 2 : Organisateur
    // ========================================
    // L'organisateur ne peut pas s'inscrire à son propre événement
    if (widget.event.organizerId == widget.user.id) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.manage_accounts),
          label: const Text('Vous êtes l\'organisateur'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    if (_isLoading) {
      return const SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: null,
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_isRegistered) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showExistingTicket,
          icon: const Icon(Icons.confirmation_number),
          label: const Text('Voir mon ticket'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // Vérifier si l'événement est complet
    if (widget.event.currentParticipants >= widget.event.maxCapacity) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.block),
          label: const Text('Événement complet'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      );
    }

    // Calculer les places disponibles
    final placesDisponibles = widget.event.maxCapacity - widget.event.currentParticipants;
    final pourcentageRempli = (widget.event.currentParticipants / widget.event.maxCapacity * 100).round();
    
    // Déterminer la couleur selon la disponibilité
    Color? buttonColor;
    if (placesDisponibles <= 5) {
      buttonColor = Colors.orange; // Presque complet
    } else if (placesDisponibles <= 2) {
      buttonColor = Colors.red.shade600; // Très peu de places
    }

    // Bouton d'inscription normal avec places disponibles
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Indicateur de places disponibles
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: placesDisponibles <= 5 
                ? Colors.orange.shade50 
                : theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    placesDisponibles <= 5 ? Icons.warning_amber : Icons.event_seat,
                    size: 16,
                    color: placesDisponibles <= 5 ? Colors.orange : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$placesDisponibles place${placesDisponibles > 1 ? 's' : ''} disponible${placesDisponibles > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: placesDisponibles <= 5 ? Colors.orange.shade900 : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                '${widget.event.currentParticipants}/${widget.event.maxCapacity}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Barre de progression
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: widget.event.currentParticipants / widget.event.maxCapacity,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              placesDisponibles <= 5 ? Colors.orange : theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Bouton d'inscription
        ElevatedButton.icon(
          onPressed: _openInscriptionModal,
          icon: const Icon(Icons.person_add),
          label: Text(
            widget.event.isPaid ? 'S\'inscrire et payer' : 'S\'inscrire gratuitement',
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: buttonColor,
          ),
        ),
      ],
    );
  }
}
