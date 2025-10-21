import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/ticket_type.dart';

/// Fonction utilitaire pour créer un événement de test avec tickets multiples
Future<void> createTestEventWithTickets(String userId, String userName) async {
  final eventsCollection = FirebaseFirestore.instance.collection('events');
  
  try {
    await eventsCollection.add({
      'title': '🎸 Concert Rock - Test Tickets',
      'description': 'Événement de test avec 3 types de tickets différents. Cliquez sur S\'inscrire pour voir la sélection de tickets !',
      'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      'location': 'Palais du Peuple, Conakry',
      'latitude': 9.5092,
      'longitude': -13.7122,
      'maxCapacity': 500,
      'currentParticipants': 0,
      'imageUrl': 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=800',
      'organizerId': userId,
      'organizerName': userName,
      'participantIds': [],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'isActive': true,
      'isPaid': true,
      'price': null,
      'ticketTypes': [
        {'type': 'Standard', 'price': 5000},
        {'type': 'VIP', 'price': 15000},
        {'type': 'Super VIP', 'price': 25000},
      ],
      'currency': 'GNF',
      'soldTickets': 0,
      'category': 'Musique',
    });
    
    print('✅ Événement de test créé avec succès !');
  } catch (e) {
    print('❌ Erreur lors de la création de l\'événement de test: $e');
    rethrow;
  }
}

/// Créer plusieurs événements de test
Future<void> createMultipleTestEvents(String userId, String userName) async {
  final eventsCollection = FirebaseFirestore.instance.collection('events');
  
  // Événement 1 : Concert avec 3 types de tickets
  await eventsCollection.add({
    'title': '🎸 Concert Rock Live',
    'description': 'Grand concert de rock avec plusieurs types de places disponibles',
    'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
    'location': 'Palais du Peuple, Conakry',
    'latitude': 9.5092,
    'longitude': -13.7122,
    'maxCapacity': 500,
    'currentParticipants': 0,
    'imageUrl': 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=800',
    'organizerId': userId,
    'organizerName': userName,
    'participantIds': [],
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
    'isActive': true,
    'isPaid': true,
    'price': null,
    'ticketTypes': [
      {'type': 'Standard', 'price': 5000},
      {'type': 'VIP', 'price': 15000},
      {'type': 'Super VIP', 'price': 25000},
    ],
    'currency': 'GNF',
    'soldTickets': 0,
    'category': 'Musique',
  });

  // Événement 2 : Conférence avec 2 types de tickets
  await eventsCollection.add({
    'title': '💼 Conférence Tech 2025',
    'description': 'Conférence sur les nouvelles technologies avec accès standard ou premium',
    'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 20))),
    'location': 'Centre de Conférence, Conakry',
    'latitude': 9.5370,
    'longitude': -13.6785,
    'maxCapacity': 300,
    'currentParticipants': 0,
    'imageUrl': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
    'organizerId': userId,
    'organizerName': userName,
    'participantIds': [],
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
    'isActive': true,
    'isPaid': true,
    'price': null,
    'ticketTypes': [
      {'type': 'Standard', 'price': 10000},
      {'type': 'Premium', 'price': 20000},
    ],
    'currency': 'GNF',
    'soldTickets': 0,
    'category': 'Technologie',
  });

  // Événement 3 : Match de football avec 4 types de tickets
  await eventsCollection.add({
    'title': '⚽ Match de Football',
    'description': 'Grand match avec plusieurs catégories de places',
    'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 10))),
    'location': 'Stade du 28 Septembre, Conakry',
    'latitude': 9.5150,
    'longitude': -13.6900,
    'maxCapacity': 1000,
    'currentParticipants': 0,
    'imageUrl': 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800',
    'organizerId': userId,
    'organizerName': userName,
    'participantIds': [],
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
    'isActive': true,
    'isPaid': true,
    'price': null,
    'ticketTypes': [
      {'type': 'Tribune', 'price': 3000},
      {'type': 'Pelouse', 'price': 5000},
      {'type': 'Carré VIP', 'price': 15000},
      {'type': 'Loge Présidentielle', 'price': 50000},
    ],
    'currency': 'GNF',
    'soldTickets': 0,
    'category': 'Sport',
  });

  print('✅ 3 événements de test créés avec succès !');
}
