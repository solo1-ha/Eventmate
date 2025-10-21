import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/event_model.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../../data/providers/events_provider.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../core/constants.dart';

/// Page de modification d'événement
class EditEventPage extends ConsumerStatefulWidget {
  final EventModel event;

  const EditEventPage({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends ConsumerState<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _capacityController;
  late final TextEditingController _priceController;
  
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isLoading = false;
  String? _imageUrl;
  late bool _isPaid;
  late String _selectedCategory;

  // Liste des catégories disponibles
  final List<String> _categories = [
    'Musique',
    'Sport',
    'Culture',
    'Technologie',
    'Éducation',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser avec les valeurs de l'événement existant
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _locationController = TextEditingController(text: widget.event.location);
    _capacityController = TextEditingController(text: widget.event.maxCapacity.toString());
    _priceController = TextEditingController(text: widget.event.price?.toString() ?? '');
    
    _selectedDate = widget.event.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.event.dateTime);
    _imageUrl = widget.event.imageUrl;
    _isPaid = widget.event.isPaid;
    
    // Vérifier que la catégorie existe dans la liste, sinon utiliser 'Autre'
    final eventCategory = widget.event.category ?? 'Autre';
    _selectedCategory = _categories.contains(eventCategory) ? eventCategory : 'Autre';
  }

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'événement'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateEvent,
            child: Text(
              'Enregistrer',
              style: TextStyle(
                color: _isLoading 
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 16),
              // Catégorie
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
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
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
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
                    return 'Veuillez entrer un lieu';
                  }
                  return null;
                },
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
                  if (capacity == null || capacity <= 0) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  if (capacity > AppConstants.maxEventCapacity) {
                    return 'La capacité maximale est de ${AppConstants.maxEventCapacity}';
                  }
                  // Vérifier que la nouvelle capacité n'est pas inférieure au nombre actuel de participants
                  if (capacity < widget.event.currentParticipants) {
                    return 'La capacité ne peut pas être inférieure au nombre actuel de participants (${widget.event.currentParticipants})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Tarification
              Text(
                'Tarification',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Événement payant'),
                subtitle: Text(
                  _isPaid ? 'Les participants devront payer' : 'Événement gratuit',
                ),
                value: _isPaid,
                onChanged: (value) {
                  setState(() {
                    _isPaid = value;
                    if (!value) {
                      _priceController.clear();
                    }
                  });
                },
              ),
              if (_isPaid) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Prix (GNF)',
                  hint: 'Ex: 50000',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.attach_money),
                  validator: (value) {
                    if (_isPaid && (value == null || value.isEmpty)) {
                      return 'Veuillez entrer un prix';
                    }
                    if (_isPaid) {
                      final price = double.tryParse(value!);
                      if (price == null || price <= 0) {
                        return 'Veuillez entrer un prix valide';
                      }
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 32),
              // Bouton de sauvegarde
              CustomButton(
                text: 'Enregistrer les modifications',
                onPressed: _isLoading ? null : _updateEvent,
                type: ButtonType.primary,
                size: ButtonSize.large,
                isLoading: _isLoading,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Créer la date et heure combinées
      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Créer l'événement mis à jour
      final updatedEvent = widget.event.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dateTime: eventDateTime,
        location: _locationController.text.trim(),
        maxCapacity: int.parse(_capacityController.text),
        isPaid: _isPaid,
        price: _isPaid ? double.parse(_priceController.text) : null,
        category: _selectedCategory,
        updatedAt: DateTime.now(),
      );

      // Sauvegarder dans Firestore
      await FirebaseService.updateEvent(updatedEvent);

      // Invalider le cache des événements
      ref.invalidate(eventsProvider);
      ref.invalidate(organizerEventsProvider(widget.event.organizerId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Événement modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
