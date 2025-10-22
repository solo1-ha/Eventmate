import '../../data/models/event_model.dart';
import '../../data/models/user_model.dart';

/// Données mockées pour le développement frontend
class MockData {
  // Utilisateur connecté par défaut
  static final UserModel currentUser = UserModel(
    id: 'mock-user-1',
    email: 'demo@eventmate.gn',
    firstName: 'Utilisateur',
    lastName: 'Demo',
    role: 'user', // Utilisateur normal
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );

  // Utilisateur admin pour les tests
  static final UserModel adminUser = UserModel(
    id: 'mock-admin-1',
    email: 'admin@eventmate.gn',
    firstName: 'Admin',
    lastName: 'EventMate',
    role: 'admin', // Administrateur
    createdAt: DateTime.now().subtract(const Duration(days: 100)),
    updatedAt: DateTime.now(),
  );

  // Liste d'événements mockés
  static final List<EventModel> events = [
    EventModel(
      id: 'event-1',
      title: 'Festival de Musique Conakry 2025',
      description: 'Grand festival de musique avec des artistes guinéens et internationaux. Une soirée inoubliable avec les meilleurs talents de la région.',
      dateTime: DateTime.now().add(const Duration(days: 15)),
      location: 'Palais du Peuple, Conakry',
      latitude: 9.5092,
      longitude: -13.7122,
      maxCapacity: 500,
      currentParticipants: 234,
      imageUrl: 'https://picsum.photos/seed/event1/400/300',
      organizerId: 'mock-user-1',
      organizerName: 'Utilisateur Demo',
      participantIds: [],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
      isActive: true,
    ),
    EventModel(
      id: 'event-2',
      title: 'Conférence Tech Guinée',
      description: 'Conférence sur les nouvelles technologies et l\'innovation en Guinée. Rencontrez des entrepreneurs et développeurs.',
      dateTime: DateTime.now().add(const Duration(days: 7)),
      location: 'Centre de Conférence de Kaloum',
      latitude: 9.5370,
      longitude: -13.6785,
      maxCapacity: 200,
      currentParticipants: 156,
      imageUrl: 'https://picsum.photos/seed/event2/400/300',
      organizerId: 'mock-user-2',
      organizerName: 'Tech Community GN',
      participantIds: [],
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
      isActive: true,
    ),
    EventModel(
      id: 'event-3',
      title: 'Marathon de Conakry',
      description: 'Course annuelle de 10km à travers les rues de Conakry. Ouvert à tous les niveaux.',
      dateTime: DateTime.now().add(const Duration(days: 30)),
      location: 'Stade du 28 Septembre',
      latitude: 9.5150,
      longitude: -13.7050,
      maxCapacity: 1000,
      currentParticipants: 567,
      imageUrl: 'https://picsum.photos/seed/event3/400/300',
      organizerId: 'mock-user-3',
      organizerName: 'Club Athlétique',
      participantIds: [],
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now(),
      isActive: true,
    ),
    EventModel(
      id: 'event-4',
      title: 'Exposition d\'Art Contemporain',
      description: 'Découvrez les œuvres d\'artistes guinéens contemporains. Peinture, sculpture et installations.',
      dateTime: DateTime.now().add(const Duration(days: 5)),
      location: 'Musée National de Conakry',
      latitude: 9.5095,
      longitude: -13.7100,
      maxCapacity: 150,
      currentParticipants: 89,
      imageUrl: 'https://picsum.photos/seed/event4/400/300',
      organizerId: 'mock-user-4',
      organizerName: 'Association des Artistes',
      participantIds: [],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
      isActive: true,
    ),
    EventModel(
      id: 'event-5',
      title: 'Atelier Entrepreneuriat',
      description: 'Formation pratique sur la création et la gestion d\'entreprise en Guinée.',
      dateTime: DateTime.now().add(const Duration(days: 3)),
      location: 'Chambre de Commerce, Conakry',
      latitude: 9.5180,
      longitude: -13.6950,
      maxCapacity: 80,
      currentParticipants: 72,
      imageUrl: 'https://picsum.photos/seed/event5/400/300',
      organizerId: 'mock-user-1',
      organizerName: 'Utilisateur Demo',
      participantIds: [],
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now(),
      isActive: true,
    ),
    EventModel(
      id: 'event-6',
      title: 'Concert de Jazz',
      description: 'Soirée jazz avec des musiciens locaux et internationaux dans une ambiance intimiste.',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      location: 'Café Culturel, Kaloum',
      latitude: 9.5320,
      longitude: -13.6820,
      maxCapacity: 100,
      currentParticipants: 95,
      imageUrl: 'https://picsum.photos/seed/event6/400/300',
      organizerId: 'mock-user-5',
      organizerName: 'Jazz Club GN',
      participantIds: [],
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
      isActive: true,
    ),
  ];

  // Utilisateurs mockés
  static final List<UserModel> users = [
    currentUser,
    adminUser,
    UserModel(
      id: 'mock-user-2',
      email: 'tech@eventmate.gn',
      firstName: 'Tech',
      lastName: 'Community GN',
      role: 'organizer',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: 'mock-user-3',
      email: 'sport@eventmate.gn',
      firstName: 'Club',
      lastName: 'Athlétique',
      role: 'organizer',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: 'mock-user-4',
      email: 'art@eventmate.gn',
      firstName: 'Association',
      lastName: 'des Artistes',
      role: 'user',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: 'mock-user-5',
      email: 'jazz@eventmate.gn',
      firstName: 'Jazz',
      lastName: 'Club GN',
      role: 'user',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Événements de l'utilisateur connecté
  static List<EventModel> get myEvents {
    return events.where((e) => e.organizerId == currentUser.id).toList();
  }

  // Événements à venir
  static List<EventModel> get upcomingEvents {
    return events
        .where((e) => e.dateTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // Événements passés
  static List<EventModel> get pastEvents {
    return events
        .where((e) => e.dateTime.isBefore(DateTime.now()))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }
}
