import 'package:flutter/material.dart';
import 'event_ticket_screen.dart';

/// Exemple d'utilisation du widget EventTicketScreen
class EventTicketScreenExample extends StatelessWidget {
  const EventTicketScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemple de données de ticket
    final exampleTicket = EventTicket(
      id: 'evt_123456',
      title: 'Concert "Made in Guinée"',
      imageUrl: 'https://example.com/event-image.jpg', // Remplacer par une vraie URL
      location: 'Palais du Peuple, Conakry',
      date: '15 Décembre 2024',
      time: '20:00',
      category: 'Concert',
      code: '24536675',
      qrData: 'EVT_123456_USER_789_REG_456', // Données encodées dans le QR code
      ticketType: 'VIP',
      price: '150 000 GNF',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple de Ticket'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigation vers l'écran du ticket
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventTicketScreen(ticket: exampleTicket),
              ),
            );
          },
          child: const Text('Voir le Ticket'),
        ),
      ),
    );
  }
}

/// Exemple d'intégration avec les modèles existants de EventMate
/// 
/// Pour utiliser ce widget avec vos modèles existants (EventModel et RegistrationModel),
/// vous pouvez créer une fonction de conversion :
/// 
/// ```dart
/// EventTicket convertToEventTicket(EventModel event, RegistrationModel registration) {
///   return EventTicket(
///     id: event.id,
///     title: event.title,
///     imageUrl: event.imageUrl,
///     location: event.location,
///     date: DateFormat('dd MMMM yyyy', 'fr_FR').format(event.dateTime),
///     time: DateFormat('HH:mm', 'fr_FR').format(event.dateTime),
///     category: event.category,
///     code: registration.id.substring(0, 8), // Utilise les 8 premiers caractères de l'ID
///     qrData: registration.qrCode,
///     ticketType: registration.ticketType,
///     price: registration.ticketPrice != null 
///         ? '${registration.ticketPrice!.toStringAsFixed(0)} ${event.currency}'
///         : null,
///   );
/// }
/// ```
/// 
/// Puis l'utiliser ainsi :
/// 
/// ```dart
/// final eventTicket = convertToEventTicket(event, registration);
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => EventTicketScreen(ticket: eventTicket),
///   ),
/// );
/// ```

/// Widget de démonstration avec plusieurs exemples de tickets
class EventTicketDemoPage extends StatelessWidget {
  const EventTicketDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tickets = [
      EventTicket(
        id: 'evt_001',
        title: 'Concert "Made in Guinée"',
        imageUrl: '',
        location: 'Palais du Peuple, Conakry',
        date: '15 Décembre 2024',
        time: '20:00',
        category: 'Concert',
        code: '24536675',
        qrData: 'EVT_001_USER_123_REG_456',
        ticketType: 'VIP',
        price: '150 000 GNF',
      ),
      EventTicket(
        id: 'evt_002',
        title: 'Festival de Musique Traditionnelle',
        imageUrl: '',
        location: 'Stade du 28 Septembre',
        date: '20 Janvier 2025',
        time: '18:00',
        category: 'Festival',
        code: '98765432',
        qrData: 'EVT_002_USER_123_REG_789',
        ticketType: 'Standard',
        price: '50 000 GNF',
      ),
      EventTicket(
        id: 'evt_003',
        title: 'Conférence Tech Guinée 2025',
        imageUrl: '',
        location: 'Centre de Conférence Noom',
        date: '10 Février 2025',
        time: '09:00',
        category: 'Conférence',
        code: '11223344',
        qrData: 'EVT_003_USER_123_REG_101',
        ticketType: 'Premium',
        price: '200 000 GNF',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Tickets'),
        backgroundColor: const Color(0xFF1F2A44),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventTicketScreen(ticket: ticket),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(ticket.date),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),
                        Text(ticket.time),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(ticket.location)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
