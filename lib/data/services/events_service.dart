import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';

/// Service de gestion des événements avec Firebase
class EventsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Récupérer tous les événements (triés du plus récent au plus ancien)
  Stream<List<EventModel>> getAllEvents() {
    return _firestore
        .collection('events')
        .orderBy('dateTime', descending: true) // Événements récents en premier
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Récupérer les événements d'un utilisateur
  Stream<List<EventModel>> getUserEvents(String userId) {
    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();
      
      // Trier localement par date
      events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return events;
    });
  }

  /// Récupérer les événements auxquels l'utilisateur est inscrit
  Stream<List<EventModel>> getRegisteredEvents(String userId) {
    return _firestore
        .collection('registrations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((registrations) async {
      if (registrations.docs.isEmpty) return [];

      final eventIds = registrations.docs
          .map((doc) => doc.data()['eventId'] as String)
          .toList();

      final events = await Future.wait(
        eventIds.map((id) => getEventById(id)),
      );

      return events.whereType<EventModel>().toList();
    });
  }

  /// Récupérer un événement par ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (!doc.exists) return null;
      return EventModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'événement: $e');
    }
  }

  /// Créer un nouvel événement
  Future<EventModel> createEvent({
    required String title,
    required String description,
    required DateTime dateTime,
    required String location,
    required double latitude,
    required double longitude,
    required int maxParticipants,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    try {
      final eventRef = _firestore.collection('events').doc();
      
      final event = EventModel(
        id: eventRef.id,
        title: title,
        description: description,
        dateTime: dateTime,
        location: location,
        latitude: latitude,
        longitude: longitude,
        organizerId: user.uid,
        organizerName: user.displayName ?? 'Organisateur',
        maxCapacity: maxParticipants,
        currentParticipants: 0,
        participantIds: [],
        imageUrl: imageUrl,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await eventRef.set(event.toFirestore());
      return event;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'événement: $e');
    }
  }

  /// Mettre à jour un événement
  Future<void> updateEvent({
    required String eventId,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    double? latitude,
    double? longitude,
    int? maxParticipants,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Événement non trouvé');
      }

      final event = EventModel.fromFirestore(eventDoc);
      if (event.organizerId != user.uid) {
        throw Exception('Vous n\'êtes pas l\'organisateur de cet événement');
      }

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (dateTime != null) updates['dateTime'] = Timestamp.fromDate(dateTime);
      if (location != null) updates['location'] = location;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;
      if (maxParticipants != null) updates['maxParticipants'] = maxParticipants;
      if (imageUrl != null) updates['imageUrl'] = imageUrl;

      await _firestore.collection('events').doc(eventId).update(updates);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'événement: $e');
    }
  }

  /// Supprimer un événement
  Future<void> deleteEvent(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Événement non trouvé');
      }

      final event = EventModel.fromFirestore(eventDoc);
      if (event.organizerId != user.uid) {
        throw Exception('Vous n\'êtes pas l\'organisateur de cet événement');
      }

      // Supprimer toutes les inscriptions liées
      final registrations = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .get();

      final batch = _firestore.batch();
      for (var doc in registrations.docs) {
        batch.delete(doc.reference);
      }

      // Supprimer l'événement
      batch.delete(_firestore.collection('events').doc(eventId));
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'événement: $e');
    }
  }

  /// Rechercher des événements
  Stream<List<EventModel>> searchEvents(String query) {
    return _firestore
        .collection('events')
        .orderBy('title')
        .snapshots()
        .map((snapshot) {
      final allEvents = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();

      if (query.isEmpty) return allEvents;

      return allEvents.where((event) {
        final titleMatch = event.title.toLowerCase().contains(query.toLowerCase());
        final locationMatch = event.location.toLowerCase().contains(query.toLowerCase());
        final descriptionMatch = event.description.toLowerCase().contains(query.toLowerCase());
        return titleMatch || locationMatch || descriptionMatch;
      }).toList();
    });
  }

  /// Récupérer les événements à proximité
  Future<List<EventModel>> getNearbyEvents({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      // Note: Pour une recherche géographique précise, utilisez GeoFlutterFire
      // Ici, on récupère tous les événements et on filtre localement
      final snapshot = await _firestore
          .collection('events')
          .orderBy('dateTime')
          .get();

      final events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();

      return events.where((event) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          event.latitude,
          event.longitude,
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche d\'événements: $e');
    }
  }

  /// Calculer la distance entre deux points (formule de Haversine)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
