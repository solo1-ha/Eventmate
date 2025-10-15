import '../models/event_model.dart';
import 'mock_data.dart';

/// Service d'événements mocké pour le développement frontend
class MockEventService {
  final List<EventModel> _events = List.from(MockData.events);

  /// Récupérer tous les événements
  Stream<List<EventModel>> getEvents() async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield _events;
  }

  /// Récupérer un événement par ID
  Future<EventModel?> getEventById(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _events.firstWhere((e) => e.id == eventId);
    } catch (e) {
      return null;
    }
  }

  /// Récupérer les événements d'un utilisateur
  Stream<List<EventModel>> getUserEvents(String userId) async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield _events.where((e) => e.organizerId == userId).toList();
  }

  /// Créer un événement
  Future<String> createEvent(EventModel event) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final newEvent = EventModel(
      id: 'event-${DateTime.now().millisecondsSinceEpoch}',
      title: event.title,
      description: event.description,
      dateTime: event.dateTime,
      location: event.location,
      latitude: event.latitude,
      longitude: event.longitude,
      maxCapacity: event.maxCapacity,
      currentParticipants: 0,
      imageUrl: event.imageUrl ?? 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/300',
      organizerId: event.organizerId,
      organizerName: event.organizerName,
      participantIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );
    
    _events.add(newEvent);
    return newEvent.id;
  }

  /// Mettre à jour un événement
  Future<void> updateEvent(String eventId, EventModel updatedEvent) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _events[index] = updatedEvent;
    }
  }

  /// Supprimer un événement
  Future<void> deleteEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _events.removeWhere((e) => e.id == eventId);
  }

  /// S'inscrire à un événement
  Future<void> registerForEvent(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = _events[index];
      _events[index] = EventModel(
        id: event.id,
        title: event.title,
        description: event.description,
        dateTime: event.dateTime,
        location: event.location,
        latitude: event.latitude,
        longitude: event.longitude,
        maxCapacity: event.maxCapacity,
        currentParticipants: event.currentParticipants + 1,
        imageUrl: event.imageUrl,
        organizerId: event.organizerId,
        organizerName: event.organizerName,
        participantIds: event.participantIds,
        createdAt: event.createdAt,
        updatedAt: DateTime.now(),
        isActive: event.isActive,
      );
    }
  }

  /// Se désinscrire d'un événement
  Future<void> unregisterFromEvent(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = _events[index];
      _events[index] = EventModel(
        id: event.id,
        title: event.title,
        description: event.description,
        dateTime: event.dateTime,
        location: event.location,
        latitude: event.latitude,
        longitude: event.longitude,
        maxCapacity: event.maxCapacity,
        currentParticipants: event.currentParticipants - 1,
        imageUrl: event.imageUrl,
        organizerId: event.organizerId,
        organizerName: event.organizerName,
        participantIds: event.participantIds,
        createdAt: event.createdAt,
        updatedAt: DateTime.now(),
        isActive: event.isActive,
      );
    }
  }

  /// Vérifier si un utilisateur est inscrit à un événement
  Future<bool> isUserRegistered(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Simulation: retourner true pour certains événements
    return eventId.hashCode % 3 == 0;
  }

  /// Rechercher des événements
  Future<List<EventModel>> searchEvents(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final lowerQuery = query.toLowerCase();
    return _events.where((event) {
      return event.title.toLowerCase().contains(lowerQuery) ||
          event.description.toLowerCase().contains(lowerQuery) ||
          event.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filtrer les événements par catégorie
  Future<List<EventModel>> getEventsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Catégorie retirée du modèle, retourner tous les événements
    return _events;
  }

  /// Récupérer les événements à venir
  Future<List<EventModel>> getUpcomingEvents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _events
        .where((e) => e.dateTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Récupérer les événements passés
  Future<List<EventModel>> getPastEvents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _events
        .where((e) => e.dateTime.isBefore(DateTime.now()))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }
}
