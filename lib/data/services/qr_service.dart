import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service de gestion des QR Codes pour les événements
class QRService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Générer les données du QR Code pour une inscription
  Future<String> generateRegistrationQRData(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    try {
      // Vérifier que l'utilisateur est bien inscrit
      final registrations = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (registrations.docs.isEmpty) {
        throw Exception('Vous n\'êtes pas inscrit à cet événement');
      }

      final registration = registrations.docs.first;
      final registrationId = registration.id;

      // Créer les données du QR Code
      final qrData = {
        'type': 'event_registration',
        'eventId': eventId,
        'userId': user.uid,
        'registrationId': registrationId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Encoder en JSON
      return jsonEncode(qrData);
    } catch (e) {
      throw Exception('Erreur lors de la génération du QR Code: $e');
    }
  }

  /// Scanner et valider un QR Code
  Future<Map<String, dynamic>> validateQRCode(String qrData) async {
    try {
      // Décoder les données JSON
      final Map<String, dynamic> data = jsonDecode(qrData);

      // Vérifier le type
      if (data['type'] != 'event_registration') {
        throw Exception('QR Code invalide');
      }

      final String eventId = data['eventId'];
      final String userId = data['userId'];
      final String registrationId = data['registrationId'];

      // Vérifier que l'inscription existe
      final registrationDoc = await _firestore
          .collection('registrations')
          .doc(registrationId)
          .get();

      if (!registrationDoc.exists) {
        throw Exception('Inscription non trouvée');
      }

      final registrationData = registrationDoc.data()!;

      // Vérifier que les données correspondent
      if (registrationData['eventId'] != eventId ||
          registrationData['userId'] != userId) {
        throw Exception('QR Code invalide');
      }

      // Récupérer les informations de l'événement
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Événement non trouvé');
      }

      final eventData = eventDoc.data()!;

      // Récupérer les informations de l'utilisateur
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};

      return {
        'valid': true,
        'eventId': eventId,
        'eventTitle': eventData['title'],
        'userId': userId,
        'userName': userData['firstName'] != null && userData['lastName'] != null
            ? '${userData['firstName']} ${userData['lastName']}'
            : registrationData['userName'],
        'userEmail': registrationData['userEmail'],
        'registrationId': registrationId,
        'checkedIn': registrationData['checkedIn'] ?? false,
        'registeredAt': (registrationData['registeredAt'] as Timestamp).toDate(),
      };
    } catch (e) {
      throw Exception('Erreur lors de la validation du QR Code: $e');
    }
  }

  /// Effectuer le check-in d'un participant
  Future<void> checkInParticipant(String registrationId) async {
    try {
      final registrationDoc = await _firestore
          .collection('registrations')
          .doc(registrationId)
          .get();

      if (!registrationDoc.exists) {
        throw Exception('Inscription non trouvée');
      }

      final data = registrationDoc.data()!;

      // Vérifier si déjà check-in
      if (data['checkedIn'] == true) {
        throw Exception('Participant déjà enregistré');
      }

      // Effectuer le check-in
      await _firestore.collection('registrations').doc(registrationId).update({
        'checkedIn': true,
        'checkedInAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors du check-in: $e');
    }
  }

  /// Vérifier si l'utilisateur actuel est l'organisateur de l'événement
  Future<bool> isEventOrganizer(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) return false;

      final eventData = eventDoc.data()!;
      return eventData['organizerId'] == user.uid;
    } catch (e) {
      return false;
    }
  }

  /// Générer un QR Code pour l'événement (pour l'organisateur)
  String generateEventQRData(String eventId) {
    final qrData = {
      'type': 'event_info',
      'eventId': eventId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    return jsonEncode(qrData);
  }

  /// Valider un QR Code d'événement
  Future<Map<String, dynamic>> validateEventQRCode(String qrData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(qrData);

      if (data['type'] != 'event_info') {
        throw Exception('QR Code invalide');
      }

      final String eventId = data['eventId'];

      // Récupérer les informations de l'événement
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Événement non trouvé');
      }

      final eventData = eventDoc.data()!;

      return {
        'valid': true,
        'eventId': eventId,
        'eventTitle': eventData['title'],
        'eventDescription': eventData['description'],
        'eventDate': (eventData['dateTime'] as Timestamp).toDate(),
        'eventLocation': eventData['location'],
      };
    } catch (e) {
      throw Exception('Erreur lors de la validation: $e');
    }
  }
}
