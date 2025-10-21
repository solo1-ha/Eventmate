/// Constantes de l'application EventMate
class AppConstants {
  // Couleurs de l'application
  static const String primaryColor = '#4CAF50';
  static const String secondaryColor = '#FFC107';
  static const String backgroundColor = '#F5F5F5';
  static const String textColor = '#212121';
  
  // Collections Firestore
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String registrationsCollection = 'registrations';
  
  // Préférences
  static const String themeKey = 'theme_mode';
  
  // Limites
  static const int maxEventCapacity = 1000;
  static const int maxEventTitleLength = 100;
  static const int maxEventDescriptionLength = 500;
  
  // Formats de date
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Messages d'erreur
  static const String errorGeneric = 'Une erreur est survenue';
  static const String errorNetwork = 'Problème de connexion';
  static const String errorAuth = 'Erreur d\'authentification';
  static const String errorPermission = 'Permissions insuffisantes';
  
  // Messages de succès
  static const String successEventCreated = 'Événement créé avec succès';
  static const String successEventUpdated = 'Événement modifié avec succès';
  static const String successEventDeleted = 'Événement supprimé avec succès';
  static const String successRegistration = 'Inscription réussie';
  static const String successCheckIn = 'Check-in effectué avec succès';
  
  // Catégories d'événements
  static const List<String> eventCategories = [
    'Concert',
    'Conférence',
    'Sport',
    'Festival',
    'Meetup',
    'Formation',
    'Autre',
  ];
}

