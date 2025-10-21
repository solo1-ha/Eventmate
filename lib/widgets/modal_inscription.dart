import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/event_model.dart';
import '../data/models/user_model.dart';
import '../data/models/registration_model.dart';
import '../data/models/ticket_type.dart';
import '../data/services/inscription_service.dart';
import '../utils/ticket_converter.dart';
import 'paiement_widget.dart';
import 'event_ticket_screen.dart';
import 'ticket_quantity_dialog.dart';

/// Modal pour gérer l'inscription à un événement
class ModalInscription extends StatefulWidget {
  final EventModel event;
  final UserModel user;

  const ModalInscription({
    super.key,
    required this.event,
    required this.user,
  });

  /// Affiche la modal d'inscription
  static Future<void> show(
    BuildContext context, {
    required EventModel event,
    required UserModel user,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalInscription(
        event: event,
        user: user,
      ),
    );
  }

  @override
  State<ModalInscription> createState() => _ModalInscriptionState();
}

class _ModalInscriptionState extends State<ModalInscription> {
  TicketType? _selectedTicket;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Sélectionner automatiquement le premier ticket pour les événements payants
    if (widget.event.isPaid && widget.event.ticketTypes.isNotEmpty) {
      _selectedTicket = widget.event.ticketTypes.first;
    }
  }

  /// Inscription à un événement gratuit
  Future<void> _registerToFreeEvent() async {
    // Afficher le dialog de sélection de quantité
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TicketQuantityDialog(
        maxQuantity: widget.event.maxCapacity - widget.event.currentParticipants,
        ticketPrice: 0, // Gratuit
        currency: widget.event.currency,
      ),
    );

    if (result == null) return; // Utilisateur a annulé

    final quantity = result['quantity'] as int;
    final attendeeNames = result['names'] as List<String>?;

    setState(() => _isProcessing = true);

    try {
      final registration = await InscriptionService.registerToFreeEvent(
        event: widget.event,
        user: widget.user,
        quantity: quantity,
        attendeeNames: attendeeNames,
      );

      if (mounted) {
        // Fermer la modal
        Navigator.pop(context);

        // Convertir en EventTicket et afficher le nouveau design
        final ticket = TicketConverter.fromEventAndRegistration(
          widget.event,
          registration,
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventTicketScreen(ticket: ticket),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Inscription à un événement payant
  Future<void> _registerToPaidEvent(String phoneNumber) async {
    if (_selectedTicket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un type de ticket'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Afficher le dialog de sélection de quantité
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TicketQuantityDialog(
        maxQuantity: widget.event.maxCapacity - widget.event.currentParticipants,
        ticketPrice: _selectedTicket!.price,
        currency: widget.event.currency,
      ),
    );

    if (result == null) return; // Utilisateur a annulé

    final quantity = result['quantity'] as int;
    final attendeeNames = result['names'] as List<String>?;

    setState(() => _isProcessing = true);

    try {
      final registration = await InscriptionService.registerToPaidEvent(
        event: widget.event,
        user: widget.user,
        ticketType: _selectedTicket!.type,
        ticketPrice: _selectedTicket!.price,
        paymentMethod: 'Orange Money',
        phoneNumber: phoneNumber,
        quantity: quantity,
        attendeeNames: attendeeNames,
      );

      if (mounted) {
        // Fermer la modal
        Navigator.pop(context);

        // Convertir en EventTicket et afficher le nouveau design
        final ticket = TicketConverter.fromEventAndRegistration(
          widget.event,
          registration,
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventTicketScreen(ticket: ticket),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
              color: theme.colorScheme.onSurface.withOpacity(0.3),
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
                    'Inscription',
                    style: theme.textTheme.titleLarge?.copyWith(
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Informations de l'événement
                  _buildEventInfo(theme),

                  const SizedBox(height: 24),

                  // Contenu selon le type d'événement
                  if (widget.event.isPaid)
                    _buildPaidEventContent(theme)
                  else
                    _buildFreeEventContent(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pour les informations de l'événement
  Widget _buildEventInfo(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(widget.event.dateTime),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.event.location,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.event.currentParticipants}/${widget.event.maxCapacity} participants',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Contenu pour événement gratuit
  Widget _buildFreeEventContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Badge gratuit
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Événement Gratuit',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Aucun paiement requis',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Informations participant
        Text(
          'Vos informations',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.person,
                  label: 'Nom',
                  value: widget.user.fullName,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.email,
                  label: 'Email',
                  value: widget.user.email,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Bouton de confirmation
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _registerToFreeEvent,
          icon: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(_isProcessing ? 'Inscription en cours...' : 'Confirmer l\'inscription'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  /// Contenu pour événement payant
  Widget _buildPaidEventContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sélection du type de ticket
        if (widget.event.ticketTypes.isNotEmpty) ...[
          Text(
            'Choisissez votre ticket',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.event.ticketTypes.map((ticket) {
            final isSelected = _selectedTicket?.type == ticket.type;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isSelected
                  ? theme.colorScheme.primaryContainer
                  : null,
              child: InkWell(
                onTap: _isProcessing
                    ? null
                    : () {
                        setState(() => _selectedTicket = ticket);
                      },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: ticket.type,
                        groupValue: _selectedTicket?.type,
                        onChanged: _isProcessing
                            ? null
                            : (value) {
                                setState(() => _selectedTicket = ticket);
                              },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.type,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ticket.formattedPrice,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],

        // Widget de paiement
        if (_selectedTicket != null)
          PaiementWidget(
            amount: _selectedTicket!.price,
            currency: widget.event.currency,
            onPaymentSuccess: _registerToPaidEvent,
          ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
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
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
