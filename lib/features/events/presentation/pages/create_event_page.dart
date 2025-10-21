import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/models/event_model.dart';
import '../../../../data/models/ticket_type.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/events_provider.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/ticket_type_dialog.dart';
import '../../../../widgets/map_picker_web_safe.dart';
import '../../../../core/constants.dart';

/// Page de création d'événement
class CreateEventPage extends ConsumerStatefulWidget {
  const CreateEventPage({super.key});

  @override
  ConsumerState<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends ConsumerState<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;
  String? _imageUrl;
  bool _isPaid = false;
  String _selectedCategory = 'Autre';
  
  // Coordonnées GPS
  double? _latitude;
  double? _longitude;
  
  // Gestion des types de tickets
  List<TicketType> _ticketTypes = [];
  bool _useMultipleTickets = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un événement'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveEvent,
            child: Text(
              'Sauvegarder',
              style: TextStyle(
                color: _isLoading 
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('Utilisateur non connecté'))
          : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image de l'événement
                  _buildImageSection(theme),
                  const SizedBox(height: 24),
                  // Informations de base
                  Text(
                    'Informations de base',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Titre de l\'événement',
                    hint: 'Ex: Concert au Palais du Peuple',
                    controller: _titleController,
                    maxLength: AppConstants.maxEventTitleLength,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un titre';
                      }
                      if (value.length < 3) {
                        return 'Le titre doit contenir au moins 3 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Description',
                    hint: 'Décrivez votre événement...',
                    controller: _descriptionController,
                    maxLines: 4,
                    maxLength: AppConstants.maxEventDescriptionLength,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une description';
                      }
                      if (value.length < 10) {
                        return 'La description doit contenir au moins 10 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Date et heure
                  Text(
                    'Date et heure',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(theme),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeField(theme),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Lieu
                  Text(
                    'Lieu',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Adresse',
                    hint: 'Ex: Palais du Peuple, Conakry',
                    controller: _locationController,
                    prefixIcon: const Icon(Icons.location_on),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une adresse';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Sélectionner sur la carte',
                    onPressed: _selectLocationOnMap,
                    type: ButtonType.secondary,
                    icon: Icons.map,
                  ),
                  const SizedBox(height: 24),
                  // Capacité
                  Text(
                    'Capacité',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Nombre maximum de participants',
                    hint: 'Ex: 100',
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.people),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une capacité';
                      }
                      final capacity = int.tryParse(value);
                      if (capacity == null || capacity < 1) {
                        return 'La capacité doit être un nombre positif';
                      }
                      if (capacity > AppConstants.maxEventCapacity) {
                        return 'La capacité ne peut pas dépasser ${AppConstants.maxEventCapacity}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Catégorie
                  Text(
                    'Catégorie',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategorySelector(theme),
                  const SizedBox(height: 24),
                  // Type d'événement (Gratuit/Payant)
                  Text(
                    'Type d\'événement',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEventTypeSelector(theme),
                  if (_isPaid) ...[
                    const SizedBox(height: 16),
                    // Option pour plusieurs types de tickets
                    CheckboxListTile(
                      title: const Text('Plusieurs types de tickets'),
                      subtitle: const Text('Standard, VIP, Super VIP, etc.'),
                      value: _useMultipleTickets,
                      onChanged: (value) {
                        setState(() {
                          _useMultipleTickets = value ?? false;
                          if (_useMultipleTickets && _ticketTypes.isEmpty) {
                            // Ajouter un ticket par défaut
                            _ticketTypes.add(const TicketType(type: 'Standard', price: 5000));
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_useMultipleTickets)
                      _buildTicketTypesSection(theme)
                    else
                      CustomTextField(
                        label: 'Prix du ticket (GNF)',
                        hint: 'Ex: 50000',
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                        validator: (value) {
                          if (_isPaid && !_useMultipleTickets && (value == null || value.isEmpty)) {
                            return 'Veuillez entrer un prix';
                          }
                          if (_isPaid && !_useMultipleTickets) {
                            final price = double.tryParse(value!);
                            if (price == null || price < 0) {
                              return 'Le prix doit être un nombre positif';
                            }
                          }
                          return null;
                        },
                      ),
                  ],
                  const SizedBox(height: 32),
                  // Bouton de sauvegarde
                  CustomButton(
                    text: 'Créer l\'événement',
                    onPressed: _isLoading ? null : _saveEvent,
                    type: ButtonType.primary,
                    size: ButtonSize.large,
                    isLoading: _isLoading,
                    icon: Icons.event,
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image de l\'événement',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: _imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder(theme);
                      },
                    ),
                  )
                : _buildImagePlaceholder(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'Ajouter une image',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heure',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      print('🖼️ Début sélection image...');
      final storage = ref.read(storageService);
      
      // Sélectionner l'image directement depuis la galerie
      print('📁 Ouverture galerie...');
      final imageFile = await storage.pickImageFromGallery();

      if (imageFile == null) {
        print('❌ Aucune image sélectionnée');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucune image sélectionnée')),
          );
        }
        return;
      }

      print('✅ Image sélectionnée: ${imageFile.name}');

      // Afficher loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload en cours...'),
            duration: Duration(seconds: 10),
          ),
        );
      }

      // Upload l'image
      final eventId = const Uuid().v4();
      print('📤 Upload vers Firebase Storage...');
      final imageUrl = await storage.uploadEventImage(imageFile, eventId);
      print('✅ Upload terminé: $imageUrl');

      if (mounted) {
        setState(() {
          _imageUrl = imageUrl;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image ajoutée avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Erreur upload image: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _selectLocationOnMap() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerWebSafe(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
          initialAddress: _locationController.text,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _locationController.text = result['address'] ?? '';
      });
    }
  }

  Widget _buildCategorySelector(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.eventCategories.map((category) {
        final isSelected = _selectedCategory == category;
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = category;
            });
          },
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          selectedColor: theme.colorScheme.primaryContainer,
          checkmarkColor: theme.colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildEventTypeSelector(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Carte Gratuit
        InkWell(
          onTap: () {
            setState(() {
              _isPaid = false;
              _priceController.clear();
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 140,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: !_isPaid
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: !_isPaid
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.card_giftcard_rounded,
                  size: 36,
                  color: !_isPaid
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 10),
                Text(
                  'Gratuit',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: !_isPaid
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Carte Payant
        InkWell(
          onTap: () {
            setState(() {
              _isPaid = true;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 140,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: _isPaid
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isPaid
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.payments_rounded,
                  size: 36,
                  color: _isPaid
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 10),
                Text(
                  'Payant',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isPaid
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketTypesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Types de tickets',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _addTicketType,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._ticketTypes.asMap().entries.map((entry) {
          final index = entry.key;
          final ticket = entry.value;
          return _buildTicketTypeCard(theme, ticket, index);
        }),
        if (_ticketTypes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: const Center(
              child: Text('Aucun type de ticket ajouté'),
            ),
          ),
      ],
    );
  }

  Widget _buildTicketTypeCard(ThemeData theme, TicketType ticket, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.confirmation_number,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
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
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editTicketType(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: Colors.red,
              onPressed: () => _removeTicketType(index),
            ),
          ],
        ),
      ),
    );
  }

  void _addTicketType() {
    showDialog(
      context: context,
      builder: (context) => TicketTypeDialog(
        onSave: (type, price) {
          setState(() {
            _ticketTypes.add(TicketType(type: type, price: price));
          });
        },
      ),
    );
  }

  void _editTicketType(int index) {
    final ticket = _ticketTypes[index];
    showDialog(
      context: context,
      builder: (context) => TicketTypeDialog(
        initialType: ticket.type,
        initialPrice: ticket.price,
        onSave: (type, price) {
          setState(() {
            _ticketTypes[index] = TicketType(type: type, price: price);
          });
        },
      ),
    );
  }

  void _removeTicketType(int index) {
    setState(() {
      _ticketTypes.removeAt(index);
    });
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final event = EventModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dateTime: eventDateTime,
        location: _locationController.text.trim(),
        latitude: _latitude ?? 9.6412, // Conakry par défaut si non défini
        longitude: _longitude ?? -13.5784,
        maxCapacity: int.parse(_capacityController.text),
        currentParticipants: 0,
        imageUrl: _imageUrl,
        organizerId: currentUser.id,
        organizerName: currentUser.fullName,
        participantIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        isPaid: _isPaid,
        price: _isPaid && !_useMultipleTickets && _priceController.text.isNotEmpty 
            ? double.parse(_priceController.text) 
            : null,
        ticketTypes: _useMultipleTickets ? _ticketTypes : [],
        currency: 'GNF',
        soldTickets: 0,
        category: _selectedCategory,
      );

      await FirebaseService.saveEvent(event);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.successEventCreated),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création: $e'),
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

