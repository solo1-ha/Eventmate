import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../../../../data/models/event_model.dart';
import '../../../../data/models/registration_model.dart';
import '../../../../data/models/ticket_type.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../../widgets/custom_button.dart';
import 'ticket_qr_code_page.dart';

/// Page de sélection de ticket pour un événement payant
class TicketSelectionPage extends ConsumerStatefulWidget {
  final EventModel event;

  const TicketSelectionPage({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<TicketSelectionPage> createState() => _TicketSelectionPageState();
}

class _TicketSelectionPageState extends ConsumerState<TicketSelectionPage> {
  TicketType? _selectedTicket;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);

    // Vérifier si l'utilisateur est l'organisateur
    final isOrganizer = currentUser?.id == widget.event.organizerId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un ticket'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informations de l'événement
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.event.dateTime.day}/${widget.event.dateTime.month}/${widget.event.dateTime.year}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.event.dateTime.hour}:${widget.event.dateTime.minute.toString().padLeft(2, '0')}',
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
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.event.location,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Message si c'est l'organisateur
            if (isOrganizer) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vous êtes l\'organisateur de cet événement. Vous ne pouvez pas vous inscrire.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Titre de la section
            Text(
              'Sélectionnez votre ticket',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Liste des types de tickets
            ...widget.event.ticketTypes.map((ticket) {
              final isSelected = _selectedTicket == ticket;
              return _buildTicketCard(context, ticket, isSelected);
            }),

            const SizedBox(height: 32),

            // Bouton de confirmation
            if (!isOrganizer)
              CustomButton(
                text: _selectedTicket == null
                    ? 'Sélectionnez un ticket'
                    : 'Confirmer l\'inscription',
                onPressed: _selectedTicket == null || _isLoading
                    ? null
                    : _registerForEvent,
                type: ButtonType.primary,
                size: ButtonSize.large,
                isLoading: _isLoading,
                icon: Icons.check_circle,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, TicketType ticket, bool isSelected) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTicket = ticket;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône de sélection
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: 2,
                  ),
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: theme.colorScheme.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Informations du ticket
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.type,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticket.formattedPrice,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              // Icône de ticket
              Icon(
                Icons.confirmation_number,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerForEvent() async {
    if (_selectedTicket == null) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour vous inscrire'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Générer un QR code unique
      final registrationId = const Uuid().v4();
      final qrData = jsonEncode({
        'registrationId': registrationId,
        'userId': currentUser.id,
        'userName': currentUser.fullName,
        'eventId': widget.event.id,
        'eventTitle': widget.event.title,
        'ticketType': _selectedTicket!.type,
        'ticketPrice': _selectedTicket!.price,
        'registeredAt': DateTime.now().toIso8601String(),
      });

      // Créer l'inscription
      final registration = RegistrationModel(
        id: registrationId,
        eventId: widget.event.id,
        userId: currentUser.id,
        userName: currentUser.fullName,
        userEmail: currentUser.email,
        userPhone: currentUser.phone,
        registeredAt: DateTime.now(),
        qrCode: qrData,
        isActive: true,
        ticketType: _selectedTicket!.type,
        ticketPrice: _selectedTicket!.price,
      );

      // Sauvegarder dans Firestore
      await FirebaseService.registerForEvent(registration);

      // Mettre à jour le nombre de participants de l'événement
      await FirebaseService.updateEvent(
        widget.event.copyWith(
          currentParticipants: widget.event.currentParticipants + 1,
          participantIds: [...widget.event.participantIds, currentUser.id],
        ),
      );

      if (mounted) {
        // Naviguer vers la page du QR code
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicketQRCodePage(
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
            content: Text('Erreur lors de l\'inscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
