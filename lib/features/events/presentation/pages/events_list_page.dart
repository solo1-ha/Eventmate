import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/events_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../widgets/event_card.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/loading_widget.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/filter_modal.dart';
import '../../../../widgets/modal_inscription.dart';
import '../../../../core/constants.dart';
import 'event_detail_page.dart';
import 'create_event_page.dart';

/// Page de liste des événements
class EventsListPage extends ConsumerStatefulWidget {
  const EventsListPage({super.key});

  @override
  ConsumerState<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends ConsumerState<EventsListPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;
  
  // Filtres du modal
  Map<String, List<String>> _modalFilters = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tous les utilisateurs peuvent créer des événements
    return Scaffold(
      appBar: AppBar(
        title: const Text('Événements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tous'),
            Tab(text: 'À venir'),
            Tab(text: 'Passés'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Voir la carte',
            onPressed: () {
              Navigator.pushNamed(context, '/openstreetmap');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Créer un événement',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateEventPage(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEventPage(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Créer un événement'),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SearchTextField(
                    controller: _searchController,
                    hint: 'Rechercher un événement...',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Badge(
                    label: Text('${_getModalFiltersCount()}'),
                    isLabelVisible: _modalFilters.isNotEmpty,
                    child: Icon(
                      Icons.filter_alt,
                      color: _modalFilters.isNotEmpty 
                        ? Theme.of(context).colorScheme.primary 
                        : null,
                    ),
                  ),
                  tooltip: 'Filtres',
                  onPressed: _openFilterModal,
                ),
              ],
            ),
          ),
          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventsList(EventsFilter.all),
                _buildEventsList(EventsFilter.upcoming),
                _buildEventsList(EventsFilter.past),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(EventsFilter filter) {
    final eventsAsync = ref.watch(eventsProvider);

    return eventsAsync.when(
      data: (eventList) {
        // Filtrer par date
        List<dynamic> filteredByDate = eventList;
        switch (filter) {
          case EventsFilter.upcoming:
            filteredByDate = eventList.where((event) => 
              event.dateTime.isAfter(DateTime.now())
            ).toList();
            break;
          case EventsFilter.past:
            filteredByDate = eventList.where((event) => 
              event.dateTime.isBefore(DateTime.now())
            ).toList();
            break;
          case EventsFilter.all:
            // Tous les événements
            break;
        }

        // Appliquer tous les filtres
        final filteredEvents = _applyAllFilters(filteredByDate);

        if (filteredEvents.isEmpty) {
          return _buildEmptyState(
            _searchQuery.isNotEmpty 
              ? 'Aucun événement trouvé pour "$_searchQuery"'
              : _getEmptyStateMessage(filter)
          );
        }

        return _buildEventsListWidget(eventList: filteredEvents);
      },
      loading: () => const LoadingListTile(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildEventsListWidget({required List eventList}) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(eventsProvider);
      },
      child: ListView.builder(
        itemCount: eventList.length,
        itemBuilder: (context, index) {
          final event = eventList[index];
          return EventCard(
            event: event,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailPage(eventId: event.id),
                ),
              );
            },
            onRegister: () => _registerForEvent(event.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur lors du chargement',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Réessayer',
            onPressed: () {
              ref.invalidate(eventsProvider);
            },
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage(EventsFilter filter) {
    switch (filter) {
      case EventsFilter.all:
        return 'Aucun événement disponible';
      case EventsFilter.upcoming:
        return 'Aucun événement à venir';
      case EventsFilter.past:
        return 'Aucun événement passé';
    }
  }


  Future<void> _registerForEvent(String eventId) async {
    // Récupérer l'utilisateur connecté
    final currentUser = ref.read(currentUserProvider);
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour vous inscrire'),
          backgroundColor: Colors.orange,
        ),
      );
      // Rediriger vers la page de connexion
      Navigator.pushNamed(context, '/login');
      return;
    }
    
    // Récupérer l'événement depuis le provider
    final eventsAsync = ref.read(eventsProvider);
    final events = eventsAsync.value ?? [];
    
    try {
      final event = events.firstWhere((e) => e.id == eventId);
      
      // Ouvrir directement la modal d'inscription
      await ModalInscription.show(
        context,
        event: event,
        user: currentUser,
      );
      
      // Rafraîchir la liste après inscription
      ref.invalidate(eventsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Ouvrir le modal de filtres
  Future<void> _openFilterModal() async {
    final eventsAsync = ref.read(eventsProvider);
    final events = eventsAsync.value ?? [];
    
    // Compter les événements par catégorie
    int countByCategory(String category) {
      return events.where((e) => e.category == category).length;
    }
    
    int countByType(bool isPaid) {
      return events.where((e) => e.isPaid == isPaid).length;
    }
    
    int countByDate(String range) {
      final now = DateTime.now();
      switch (range) {
        case 'today':
          return events.where((e) => 
            e.dateTime.year == now.year &&
            e.dateTime.month == now.month &&
            e.dateTime.day == now.day
          ).length;
        case 'week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 7));
          return events.where((e) => 
            e.dateTime.isAfter(weekStart) && e.dateTime.isBefore(weekEnd)
          ).length;
        case 'month':
          return events.where((e) => 
            e.dateTime.year == now.year && e.dateTime.month == now.month
          ).length;
        default:
          return 0;
      }
    }
    
    // Définir les sections de filtres
    final sections = [
      FilterSection(
        id: 'category',
        title: 'Catégorie',
        allowMultiple: true,
        isExpanded: true,
        options: AppConstants.eventCategories.map((category) => 
          FilterOption(
            id: category, 
            label: category, 
            count: countByCategory(category)
          )
        ).toList(),
      ),
      FilterSection(
        id: 'type',
        title: 'Type d\'événement',
        allowMultiple: false,
        isExpanded: true,
        options: [
          FilterOption(id: 'free', label: 'Gratuit', count: countByType(false)),
          FilterOption(id: 'paid', label: 'Payant', count: countByType(true)),
        ],
      ),
      FilterSection(
        id: 'date',
        title: 'Période',
        allowMultiple: false,
        options: [
          FilterOption(id: 'today', label: 'Aujourd\'hui', count: countByDate('today')),
          FilterOption(id: 'week', label: 'Cette semaine', count: countByDate('week')),
          FilterOption(id: 'month', label: 'Ce mois', count: countByDate('month')),
        ],
      ),
    ];
    
    // Afficher le modal
    final result = await FilterModal.show(
      context: context,
      sections: sections,
      initialFilters: _modalFilters,
      title: 'Filtrer les événements',
      applyButtonText: 'APPLIQUER LES FILTRES',
      resetButtonText: 'Tout effacer',
    );
    
    // Traiter le résultat
    if (result != null && result.hasChanges) {
      setState(() {
        _modalFilters = result.selectedFilters;
      });
      
      // Afficher un message de confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _modalFilters.isEmpty
                  ? 'Tous les filtres ont été supprimés'
                  : 'Filtres appliqués avec succès',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  // Obtenir le nombre de filtres actifs
  int _getModalFiltersCount() {
    return _modalFilters.values.fold(0, (sum, list) => sum + list.length);
  }

  // Appliquer tous les filtres
  List _applyAllFilters(List events) {
    var filtered = events;

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((event) {
        return event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               event.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               event.location.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtres du modal
    if (_modalFilters.containsKey('category')) {
      final categories = _modalFilters['category']!;
      filtered = filtered.where((event) => categories.contains(event.category)).toList();
    }

    if (_modalFilters.containsKey('type')) {
      final type = _modalFilters['type']!.first;
      final isPaid = type == 'paid';
      filtered = filtered.where((event) => event.isPaid == isPaid).toList();
    }

    if (_modalFilters.containsKey('date')) {
      final dateFilter = _modalFilters['date']!.first;
      final now = DateTime.now();
      filtered = filtered.where((event) {
        switch (dateFilter) {
          case 'today':
            return event.dateTime.year == now.year &&
                   event.dateTime.month == now.month &&
                   event.dateTime.day == now.day;
          case 'week':
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            final weekEnd = weekStart.add(const Duration(days: 7));
            return event.dateTime.isAfter(weekStart) && event.dateTime.isBefore(weekEnd);
          case 'month':
            return event.dateTime.year == now.year && event.dateTime.month == now.month;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }
}

/// Filtres d'événements
enum EventsFilter {
  all,
  upcoming,
  past,
}
