import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/models/registration_model.dart';
import '../../../../data/models/event_model.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/event_ticket_screen.dart';
import '../../../../utils/ticket_converter.dart';
import '../widgets/profile_header.dart';

/// Page de profil utilisateur
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userData = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _cancelEdit,
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: _saveProfile,
                  child: const Text('Sauvegarder'),
                ),
              ],
            ),
        ],
      ),
      body: userData == null
          ? const Center(child: Text('Utilisateur non trouvé'))
          : Builder(
              builder: (context) {
                final user = userData;
                
                // Initialiser les contrôleurs si pas déjà fait
                if (_firstNameController.text.isEmpty) {
                  _firstNameController.text = user.firstName;
                  _lastNameController.text = user.lastName;
                  _phoneController.text = user.phone ?? '';
                }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête du profil
                  ProfileHeader(
                    user: user,
                    isEditing: _isEditing,
                    onImageTap: _isEditing ? _pickProfileImage : null,
                  ),
                  const SizedBox(height: 32),
                  // Informations personnelles
                  Text(
                    'Informations personnelles',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Prénom',
                          controller: _firstNameController,
                          enabled: _isEditing,
                          prefixIcon: const Icon(Icons.person),
                          validator: _isEditing ? (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre prénom';
                            }
                            return null;
                          } : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: 'Nom',
                          controller: _lastNameController,
                          enabled: _isEditing,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: _isEditing ? (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre nom';
                            }
                            return null;
                          } : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Email',
                    initialValue: user.email,
                    enabled: false,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Téléphone',
                    controller: _phoneController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone),
                    validator: _isEditing ? (value) {
                      if (value != null && value.isNotEmpty && value.length < 8) {
                        return 'Numéro de téléphone invalide';
                      }
                      return null;
                    } : null,
                  ),
                  const SizedBox(height: 32),
                  // Rôle et statistiques
                  Text(
                    'Informations du compte',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Membre depuis: ${_formatDate(user.createdAt)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Section Mes Tickets
                  _buildMyTicketsSection(theme),
                  
                  const SizedBox(height: 32),
                  // Bouton de déconnexion
                  CustomButton(
                    text: 'Se déconnecter',
                    onPressed: _logout,
                    type: ButtonType.secondary,
                    size: ButtonSize.large,
                    icon: Icons.logout,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    // Réinitialiser les champs
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phone ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final updatedUser = user.copyWith(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty 
              ? null 
              : _phoneController.text.trim(),
          updatedAt: DateTime.now(),
        );

        // Mise à jour Firebase
        final service = ref.read(authService);
        await service.updateUserProfile(
          firstName: updatedUser.firstName,
          lastName: updatedUser.lastName,
          phone: updatedUser.phone,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès'),
            ),
          );
          setState(() {
            _isEditing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
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

  Future<void> _pickProfileImage() async {
    // TODO: Implémenter la sélection d'image
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de sélection d\'image à implémenter'),
      ),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Déconnexion Firebase
      final service = ref.read(authService);
      await service.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Section Mes Tickets
  Widget _buildMyTicketsSection(ThemeData theme) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mes Tickets',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Afficher tous les tickets
                Navigator.pushNamed(context, '/my-tickets');
              },
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('registrations')
              .where('userId', isEqualTo: user.uid)
              .orderBy('registeredAt', descending: true)
              .limit(3) // Afficher seulement les 3 derniers tickets
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 48,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucun ticket',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Inscrivez-vous à un événement',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final registrations = snapshot.data!.docs
                .map((doc) => RegistrationModel.fromFirestore(doc))
                .toList();

            return Column(
              children: registrations.map((registration) {
                return _buildTicketPreviewCard(registration, theme);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// Carte de prévisualisation d'un ticket
  Widget _buildTicketPreviewCard(RegistrationModel registration, ThemeData theme) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('events')
          .doc(registration.eventId)
          .get(),
      builder: (context, eventSnapshot) {
        if (!eventSnapshot.hasData || !eventSnapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final event = EventModel.fromFirestore(eventSnapshot.data!);
        final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');
        final timeFormat = DateFormat('HH:mm', 'fr_FR');
        final isPastEvent = event.dateTime.isBefore(DateTime.now());

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              final ticket = TicketConverter.fromEventAndRegistration(
                event,
                registration,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventTicketScreen(ticket: ticket),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Icône
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isPastEvent
                          ? Colors.grey.withOpacity(0.2)
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.confirmation_number,
                      color: isPastEvent
                          ? Colors.grey
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Informations
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dateFormat.format(event.dateTime)} • ${timeFormat.format(event.dateTime)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge statut
                  if (isPastEvent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Passé',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          fontSize: 11,
                        ),
                      ),
                    )
                  else if (registration.hasCheckedIn)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Validé',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green[700],
                          fontSize: 11,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

