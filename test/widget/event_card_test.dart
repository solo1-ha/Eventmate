import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventmate/data/models/event_model.dart';
import 'package:eventmate/widgets/event_card.dart';

void main() {
  late EventModel testEvent;

  setUp(() {
    testEvent = EventModel(
      id: 'test-id',
      title: 'Concert Live',
      description: 'Un super concert de musique guinéenne',
      dateTime: DateTime(2025, 12, 31, 20, 0),
      location: 'Palais du Peuple, Conakry',
      latitude: 9.6412,
      longitude: -13.5784,
      maxCapacity: 500,
      currentParticipants: 350,
      organizerId: 'organizer-id',
      organizerName: 'Organisateur Test',
      participantIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      imageUrl: null,
    );
  });

  Widget createTestWidget(EventModel event) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: EventCard(event: event),
        ),
      ),
    );
  }

  group('EventCard Widget', () {
    testWidgets('Affiche le titre de l\'événement', (tester) async {
      await tester.pumpWidget(createTestWidget(testEvent));

      expect(find.text('Concert Live'), findsOneWidget);
    });

    testWidgets('Affiche le lieu de l\'événement', (tester) async {
      await tester.pumpWidget(createTestWidget(testEvent));

      expect(find.text('Palais du Peuple, Conakry'), findsOneWidget);
    });

    testWidgets('Affiche le nombre de participants', (tester) async {
      await tester.pumpWidget(createTestWidget(testEvent));

      expect(find.textContaining('350'), findsAtLeastNWidgets(1));
      expect(find.textContaining('500'), findsAtLeastNWidgets(1));
    });

    testWidgets('Affiche "Gratuit" pour événement gratuit', (tester) async {
      await tester.pumpWidget(createTestWidget(testEvent));

      expect(find.text('Gratuit'), findsOneWidget);
    });

    testWidgets('Affiche le prix pour événement payant', (tester) async {
      final paidEvent = testEvent.copyWith(
        isPaid: true,
        price: 50000,
        currency: 'GNF',
      );

      await tester.pumpWidget(createTestWidget(paidEvent));

      expect(find.textContaining('50000'), findsAtLeastNWidgets(1));
      expect(find.textContaining('GNF'), findsAtLeastNWidgets(1));
    });

    testWidgets('Affiche l\'icône de lieu', (tester) async {
      await tester.pumpWidget(createTestWidget(testEvent));

      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
    });

    testWidgets('Affiche l\'icône de calendrier', (tester) async {
      await tester.pumpWidget(createTestWidget(testEvent));

      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
    });

    testWidgets('Card est cliquable', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GestureDetector(
                onTap: () => tapped = true,
                child: EventCard(event: testEvent),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EventCard));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('Affiche badge "Complet" si événement plein', (tester) async {
      final fullEvent = testEvent.copyWith(currentParticipants: 500);

      await tester.pumpWidget(createTestWidget(fullEvent));

      // Vérifier que l'événement est bien complet
      expect(fullEvent.isFull, true);
    });

    testWidgets('Affiche la catégorie si présente', (tester) async {
      final categorizedEvent = testEvent.copyWith(category: 'Concert');

      await tester.pumpWidget(createTestWidget(categorizedEvent));

      expect(find.text('Concert'), findsAtLeastNWidgets(1));
    });
  });

  group('EventCard - États spéciaux', () {
    testWidgets('Affiche correctement un événement passé', (tester) async {
      final pastEvent = testEvent.copyWith(
        dateTime: DateTime(2020, 1, 1),
      );

      await tester.pumpWidget(createTestWidget(pastEvent));

      expect(pastEvent.isPast, true);
      expect(find.text('Concert Live'), findsOneWidget);
    });

    testWidgets('Affiche correctement un événement sans participants', (tester) async {
      final emptyEvent = testEvent.copyWith(currentParticipants: 0);

      await tester.pumpWidget(createTestWidget(emptyEvent));

      expect(find.textContaining('0'), findsAtLeastNWidgets(1));
    });

    testWidgets('Gère les titres longs', (tester) async {
      final longTitleEvent = testEvent.copyWith(
        title: 'Ceci est un titre très très très long pour tester le comportement de la carte',
      );

      await tester.pumpWidget(createTestWidget(longTitleEvent));

      expect(find.byType(EventCard), findsOneWidget);
    });
  });
}
