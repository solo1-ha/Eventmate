import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/registration_model.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

/// Service pour gérer les inscriptions aux événements
class InscriptionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _registrationsCollection = 'registrations';

  /// Génère un QR code unique pour une inscription
  /// Format: eventId|userId|timestamp|randomId
  static String generateQRCode(String eventId, String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomId = const Uuid().v4().substring(0, 8);
    return '$eventId|$userId|$timestamp|$randomId';
  }

  /// Vérifie si un utilisateur est déjà inscrit à un événement
  static Future<bool> isUserRegistered(String eventId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_registrationsCollection)
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification de l\'inscription: $e');
      return false;
    }
  }

  /// Récupère l'inscription d'un utilisateur pour un événement
  static Future<RegistrationModel?> getUserRegistration(
    String eventId,
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_registrationsCollection)
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return RegistrationModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      print('Erreur lors de la récupération de l\'inscription: $e');
      return null;
    }
  }

  /// Inscrit un utilisateur à un événement gratuit
  /// 
  /// Paramètres :
  /// - [event] : L'événement auquel s'inscrire
  /// - [user] : L'utilisateur qui s'inscrit
  /// - [quantity] : Nombre de tickets (1 à 10) - permet d'acheter pour plusieurs personnes
  /// - [attendeeNames] : Liste optionnelle des noms des participants
  /// 
  /// Retourne : L'inscription créée avec le QR code généré
  /// 
  /// Lance une exception si :
  /// - L'événement est passé
  /// - L'utilisateur est l'organisateur
  /// - L'utilisateur est déjà inscrit
  /// - Pas assez de places disponibles
  static Future<RegistrationModel> registerToFreeEvent({
    required EventModel event,
    required UserModel user,
    int quantity = 1,
    List<String>? attendeeNames,
  }) async {
    try {
      // ========================================
      // VÉRIFICATION 1 : Événement passé
      // ========================================
      // Empêche toute inscription aux événements terminés
      if (event.dateTime.isBefore(DateTime.now())) {
        throw Exception('Cet événement est terminé. Les inscriptions sont fermées.');
      }

      // ========================================
      // VÉRIFICATION 2 : Organisateur
      // ========================================
      // L'organisateur ne peut pas s'inscrire à son propre événement
      if (event.organizerId == user.id) {
        throw Exception('Vous ne pouvez pas vous inscrire à votre propre événement.');
      }

      // ========================================
      // VÉRIFICATION 3 : Déjà inscrit
      // ========================================
      final isRegistered = await isUserRegistered(event.id, user.id);
      if (isRegistered) {
        throw Exception('Vous êtes déjà inscrit à cet événement');
      }

      // ========================================
      // VÉRIFICATION 4 : Capacité disponible
      // ========================================
      // Vérifier qu'il y a assez de places pour la quantité demandée
      if (event.currentParticipants + quantity > event.maxCapacity) {
        throw Exception('Pas assez de places disponibles (${event.maxCapacity - event.currentParticipants} places restantes)');
      }

      // ========================================
      // GÉNÉRATION DU QR CODE
      // ========================================
      // Créer un QR code unique pour cette inscription
      final qrCode = generateQRCode(event.id, user.id);

      // ========================================
      // CRÉATION DE L'INSCRIPTION
      // ========================================
      final registrationId = const Uuid().v4();
      final registration = RegistrationModel(
        id: registrationId,
        eventId: event.id,
        userId: user.id,
        userName: user.fullName,
        userEmail: user.email,
        userPhone: user.phone,
        registeredAt: DateTime.now(),
        qrCode: qrCode,
        isActive: true,
        ticketType: 'Gratuit',
        ticketPrice: 0.0,
        ticketQuantity: quantity,        // Nombre de tickets achetés
        attendeeNames: attendeeNames,     // Noms des participants (optionnel)
      );

      // ========================================
      // SAUVEGARDE DANS FIRESTORE
      // ========================================
      await _firestore
          .collection(_registrationsCollection)
          .doc(registrationId)
          .set(registration.toFirestore());

      // ========================================
      // MISE À JOUR DU NOMBRE DE PARTICIPANTS
      // ========================================
      // Incrémenter le compteur avec la quantité de tickets achetés
      await _firestore.collection('events').doc(event.id).update({
        'currentParticipants': FieldValue.increment(quantity),
        'participantIds': FieldValue.arrayUnion([user.id]),
      });

      return registration;
    } catch (e) {
      print('Erreur lors de l\'inscription gratuite: $e');
      rethrow;
    }
  }

  /// Inscrit un utilisateur à un événement payant
  static Future<RegistrationModel> registerToPaidEvent({
    required EventModel event,
    required UserModel user,
    required String ticketType,
    required double ticketPrice,
    required String paymentMethod,
    required String phoneNumber,
    int quantity = 1,
    List<String>? attendeeNames,
  }) async {
    try {
      // Vérifier si l'événement est passé
      if (event.dateTime.isBefore(DateTime.now())) {
        throw Exception('Cet événement est terminé. Les inscriptions sont fermées.');
      }

      // Vérifier si l'utilisateur est l'organisateur
      if (event.organizerId == user.id) {
        throw Exception('Vous ne pouvez pas vous inscrire à votre propre événement.');
      }

      // Vérifier si déjà inscrit
      final isRegistered = await isUserRegistered(event.id, user.id);
      if (isRegistered) {
        throw Exception('Vous êtes déjà inscrit à cet événement');
      }

      // Vérifier la capacité avec la quantité demandée
      if (event.currentParticipants + quantity > event.maxCapacity) {
        throw Exception('Pas assez de places disponibles (${event.maxCapacity - event.currentParticipants} places restantes)');
      }

      // Simuler le paiement (à remplacer par une vraie intégration)
      // Calculer le montant total
      final totalAmount = ticketPrice * quantity;
      await _simulatePayment(phoneNumber, totalAmount, paymentMethod);

      // Générer le QR code
      final qrCode = generateQRCode(event.id, user.id);

      // Créer l'inscription
      final registrationId = const Uuid().v4();
      final registration = RegistrationModel(
        id: registrationId,
        eventId: event.id,
        userId: user.id,
        userName: user.fullName,
        userEmail: user.email,
        userPhone: phoneNumber,
        registeredAt: DateTime.now(),
        qrCode: qrCode,
        isActive: true,
        ticketType: ticketType,
        ticketPrice: ticketPrice,
        ticketQuantity: quantity,
        attendeeNames: attendeeNames,
      );

      // Sauvegarder dans Firestore
      await _firestore
          .collection(_registrationsCollection)
          .doc(registrationId)
          .set(registration.toFirestore());

      // Mettre à jour le nombre de participants et les tickets vendus (avec la quantité)
      await _firestore.collection('events').doc(event.id).update({
        'currentParticipants': FieldValue.increment(quantity),
        'participantIds': FieldValue.arrayUnion([user.id]),
        'soldTickets': FieldValue.increment(quantity),
      });

      return registration;
    } catch (e) {
      print('Erreur lors de l\'inscription payante: $e');
      rethrow;
    }
  }

  /// Simule un paiement (à remplacer par une vraie intégration Orange Money)
  static Future<void> _simulatePayment(
    String phoneNumber,
    double amount,
    String method,
  ) async {
    // Simuler un délai de traitement
    await Future.delayed(const Duration(seconds: 2));

    // Ici, vous intégreriez l'API Orange Money réelle
    // Pour l'instant, on simule un paiement réussi
    print('Paiement simulé: $amount GNF via $method pour $phoneNumber');
  }

  /// Annule une inscription
  static Future<void> cancelRegistration(String registrationId) async {
    try {
      final registration = await _firestore
          .collection(_registrationsCollection)
          .doc(registrationId)
          .get();

      if (!registration.exists) {
        throw Exception('Inscription introuvable');
      }

      final data = registration.data()!;
      final eventId = data['eventId'];

      // Désactiver l'inscription
      await _firestore
          .collection(_registrationsCollection)
          .doc(registrationId)
          .update({'isActive': false});

      // Mettre à jour le nombre de participants
      await _firestore.collection('events').doc(eventId).update({
        'currentParticipants': FieldValue.increment(-1),
        'participantIds': FieldValue.arrayRemove([data['userId']]),
      });
    } catch (e) {
      print('Erreur lors de l\'annulation: $e');
      rethrow;
    }
  }

  /// Effectue le check-in d'un participant
  static Future<void> checkIn(String qrCode) async {
    try {
      // Décoder le QR code
      final parts = qrCode.split('|');
      if (parts.length != 4) {
        throw Exception('QR code invalide');
      }

      final eventId = parts[0];
      final userId = parts[1];

      // Trouver l'inscription
      final querySnapshot = await _firestore
          .collection(_registrationsCollection)
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .where('qrCode', isEqualTo: qrCode)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Inscription introuvable ou invalide');
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();

      // Vérifier si déjà check-in
      if (data['checkedInAt'] != null) {
        throw Exception('Check-in déjà effectué');
      }

      // Effectuer le check-in
      await _firestore
          .collection(_registrationsCollection)
          .doc(doc.id)
          .update({'checkedInAt': Timestamp.now()});
    } catch (e) {
      print('Erreur lors du check-in: $e');
      rethrow;
    }
  }

  /// Récupère toutes les inscriptions d'un événement
  static Stream<List<RegistrationModel>> getEventRegistrations(String eventId) {
    return _firestore
        .collection(_registrationsCollection)
        .where('eventId', isEqualTo: eventId)
        .where('isActive', isEqualTo: true)
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RegistrationModel.fromFirestore(doc))
            .toList());
  }

  /// Récupère toutes les inscriptions d'un utilisateur
  static Stream<List<RegistrationModel>> getUserRegistrations(String userId) {
    return _firestore
        .collection(_registrationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RegistrationModel.fromFirestore(doc))
            .toList());
  }
}
