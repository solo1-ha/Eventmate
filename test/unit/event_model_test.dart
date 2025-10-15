import 'package:flutter_test/flutter_test.dart';
import 'package:eventmate/data/models/event_model.dart';

void main() {
  group('EventModel', () {
    late EventModel testEvent;

    setUp(() {
      testEvent = EventModel(
        id: 'test-id',
        title: 'Test Event',
        description: 'Test Description',
        dateTime: DateTime(2025, 12, 31, 18, 0),
        location: 'Conakry',
        latitude: 9.6412,
        longitude: -13.5784,
        maxCapacity: 100,
        currentParticipants: 75,
        organizerId: 'organizer-id',
        organizerName: 'Test Organizer',
        participantIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );
    });

    test('Calcul des places disponibles', () {
      expect(testEvent.availableSeats, 25);
    });

    test('Vérification événement complet', () {
      final fullEvent = testEvent.copyWith(currentParticipants: 100);
      expect(fullEvent.isFull, true);
      expect(testEvent.isFull, false);
    });

    test('Calcul du pourcentage de remplissage', () {
      expect(testEvent.fillPercentage, 0.75);
    });

    test('Vérification événement passé', () {
      final pastEvent = testEvent.copyWith(
        dateTime: DateTime(2020, 1, 1),
      );
      expect(pastEvent.isPast, true);
      expect(testEvent.isPast, false);
    });

    test('Prix formaté pour événement gratuit', () {
      expect(testEvent.formattedPrice, 'Gratuit');
    });

    test('Prix formaté pour événement payant', () {
      final paidEvent = testEvent.copyWith(
        isPaid: true,
        price: 50000,
        currency: 'GNF',
      );
      expect(paidEvent.formattedPrice, '50000 GNF');
    });

    test('Calcul du revenu total', () {
      final paidEvent = testEvent.copyWith(
        isPaid: true,
        price: 10000,
        soldTickets: 50,
      );
      expect(paidEvent.totalRevenue, 500000);
    });

    test('Tickets disponibles', () {
      final paidEvent = testEvent.copyWith(
        soldTickets: 30,
      );
      expect(paidEvent.availableTickets, 70);
    });

    test('CopyWith fonctionne correctement', () {
      final modifiedEvent = testEvent.copyWith(
        title: 'Modified Title',
        maxCapacity: 200,
      );

      expect(modifiedEvent.title, 'Modified Title');
      expect(modifiedEvent.maxCapacity, 200);
      expect(modifiedEvent.id, testEvent.id);
      expect(modifiedEvent.description, testEvent.description);
    });

    test('Égalité basée sur l\'ID', () {
      final sameEvent = EventModel(
        id: 'test-id',
        title: 'Different Title',
        description: 'Different Description',
        dateTime: DateTime.now(),
        location: 'Different Location',
        latitude: 0,
        longitude: 0,
        maxCapacity: 50,
        currentParticipants: 0,
        organizerId: 'different-organizer',
        organizerName: 'Different Organizer',
        participantIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      expect(testEvent == sameEvent, true);
      expect(testEvent.hashCode, sameEvent.hashCode);
    });

    test('Événements différents ne sont pas égaux', () {
      final differentEvent = testEvent.copyWith(id: 'different-id');
      expect(testEvent == differentEvent, false);
    });
  });

  group('EventModel - Cas limites', () {
    test('Événement avec 0 participants', () {
      final emptyEvent = EventModel(
        id: 'empty',
        title: 'Empty Event',
        description: 'No participants',
        dateTime: DateTime.now(),
        location: 'Test',
        latitude: 0,
        longitude: 0,
        maxCapacity: 100,
        currentParticipants: 0,
        organizerId: 'org',
        organizerName: 'Organizer',
        participantIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      expect(emptyEvent.fillPercentage, 0);
      expect(emptyEvent.isFull, false);
      expect(emptyEvent.availableSeats, 100);
    });

    test('Événement avec capacité 0', () {
      final zeroCapacityEvent = EventModel(
        id: 'zero',
        title: 'Zero Capacity',
        description: 'Test',
        dateTime: DateTime.now(),
        location: 'Test',
        latitude: 0,
        longitude: 0,
        maxCapacity: 0,
        currentParticipants: 0,
        organizerId: 'org',
        organizerName: 'Organizer',
        participantIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      expect(zeroCapacityEvent.availableSeats, 0);
      // fillPercentage avec capacité 0 retourne NaN (0/0)
      expect(zeroCapacityEvent.fillPercentage.isNaN, true);
    });
  });
}
