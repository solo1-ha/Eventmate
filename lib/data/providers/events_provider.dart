import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../services/events_service.dart';
import '../services/registrations_service.dart';
import '../services/storage_service.dart';
import '../services/qr_service.dart';
import '../services/notification_service.dart';
import '../services/payment_service.dart';
import '../services/cache_service.dart';

// MODE PRODUCTION - Services Firebase
final eventsService = Provider((ref) => EventsService());
final registrationsService = Provider((ref) => RegistrationsService());
final storageService = Provider((ref) => StorageService());
final qrService = Provider((ref) => QRService());
final notificationService = Provider((ref) => NotificationService());
final paymentService = Provider((ref) => PaymentService());

// Cache Service (async)
final cacheServiceProvider = FutureProvider<CacheService>((ref) async {
  return await CacheService.create();
});

/// Provider pour tous les événements
final eventsProvider = StreamProvider<List<EventModel>>((ref) {
  final service = ref.watch(eventsService);
  return service.getAllEvents();
});

/// Provider pour un événement spécifique
final eventProvider = FutureProvider.family<EventModel?, String>((ref, eventId) async {
  final service = ref.watch(eventsService);
  return await service.getEventById(eventId);
});

/// Provider pour les événements d'un organisateur
final organizerEventsProvider = StreamProvider.family<List<EventModel>, String>((ref, organizerId) {
  final service = ref.watch(eventsService);
  return service.getUserEvents(organizerId);
});

/// Provider pour les événements auxquels l'utilisateur est inscrit
final registeredEventsProvider = StreamProvider.family<List<EventModel>, String>((ref, userId) {
  final service = ref.watch(eventsService);
  return service.getRegisteredEvents(userId);
});

/// Provider pour vérifier si un utilisateur est inscrit à un événement
final isUserRegisteredProvider = StreamProvider.family<bool, String>((ref, eventId) {
  final service = ref.watch(registrationsService);
  return service.isRegisteredStream(eventId);
});

/// Provider pour les événements avec recherche
final searchEventsProvider = StreamProvider.family<List<EventModel>, String>((ref, query) {
  final service = ref.watch(eventsService);
  return service.searchEvents(query);
});

/// Provider pour les participants d'un événement
final eventParticipantsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, eventId) {
  final service = ref.watch(registrationsService);
  return service.getEventParticipants(eventId);
});

/// Provider pour les notifications de l'utilisateur
final userNotificationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(notificationService);
  return service.getUserNotifications();
});

/// Provider pour le nombre de notifications non lues
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final service = ref.watch(notificationService);
  return service.getUnreadCount();
});

