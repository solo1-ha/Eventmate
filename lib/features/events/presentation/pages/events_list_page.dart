import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/events_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../widgets/event_card.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/loading_widget.dart';
import '../../../../widgets/custom_button.dart';
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
    final user = ref.watch(currentUserProvider);
    final isOrganizer = user?.role == 'organizer' || user?.role == 'owner';

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
          if (isOrganizer)
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
      floatingActionButton: isOrganizer
          ? FloatingActionButton.extended(
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
            )
          : null,
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
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

        // Filtrer par recherche
        if (_searchQuery.isNotEmpty) {
          final filteredEvents = filteredByDate.where((event) {
            return event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   event.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   event.location.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredEvents.isEmpty) {
            return _buildEmptyState('Aucun événement trouvé pour "$_searchQuery"');
          }

          return _buildEventsListWidget(eventList: filteredEvents);
        }

        if (filteredByDate.isEmpty) {
          return _buildEmptyState(_getEmptyStateMessage(filter));
        }

        return _buildEventsListWidget(eventList: filteredByDate);
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
    // TODO: Implémenter l'inscription à un événement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'inscription à implémenter'),
      ),
    );
  }
}

/// Filtres d'événements
enum EventsFilter {
  all,
  upcoming,
  past,
}
