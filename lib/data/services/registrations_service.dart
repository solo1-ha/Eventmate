import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service de gestion des inscriptions aux événements
class RegistrationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// S'inscrire à un événement
  Future<void> registerToEvent(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    try {
      // Vérifier si l'événement existe
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Événement non trouvé');
      }

      final eventData = eventDoc.data()!;
      final currentParticipants = eventData['currentParticipants'] as int? ?? 0;
      final maxParticipants = eventData['maxParticipants'] as int;

      // Vérifier si l'événement est complet
      if (currentParticipants >= maxParticipants) {
        throw Exception('L\'événement est complet');
      }

      // Vérifier si déjà inscrit
      final existingRegistration = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (existingRegistration.docs.isNotEmpty) {
        throw Exception('Vous êtes déjà inscrit à cet événement');
      }

      // Créer l'inscription
      final registrationRef = _firestore.collection('registrations').doc();
      await registrationRef.set({
        'id': registrationRef.id,
        'eventId': eventId,
        'userId': user.uid,
        'userName': user.displayName ?? 'Utilisateur',
        'userEmail': user.email ?? '',
        'registeredAt': Timestamp.fromDate(DateTime.now()),
        'checkedIn': false,
      });

      // Incrémenter le nombre de participants
      await _firestore.collection('events').doc(eventId).update({
        'currentParticipants': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  /// Se désinscrire d'un événement
  Future<void> unregisterFromEvent(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    try {
      // Trouver l'inscription
      final registrations = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (registrations.docs.isEmpty) {
        throw Exception('Vous n\'êtes pas inscrit à cet événement');
      }

      // Supprimer l'inscription
      await registrations.docs.first.reference.delete();

      // Décrémenter le nombre de participants
      await _firestore.collection('events').doc(eventId).update({
        'currentParticipants': FieldValue.increment(-1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la désinscription: $e');
    }
  }

  /// Vérifier si l'utilisateur est inscrit à un événement
  Future<bool> isRegistered(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final registrations = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: user.uid)
          .get();

      return registrations.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Stream pour vérifier si l'utilisateur est inscrit
  Stream<bool> isRegisteredStream(String eventId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  /// Récupérer les participants d'un événement
  Stream<List<Map<String, dynamic>>> getEventParticipants(String eventId) {
    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': data['id'],
          'userId': data['userId'],
          'userName': data['userName'],
          'userEmail': data['userEmail'],
          'registeredAt': (data['registeredAt'] as Timestamp).toDate(),
          'checkedIn': data['checkedIn'] ?? false,
        };
      }).toList();
    });
  }

  /// Marquer un participant comme présent (check-in)
  Future<void> checkInParticipant(String eventId, String userId) async {
    try {
      final registrations = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();

      if (registrations.docs.isEmpty) {
        throw Exception('Inscription non trouvée');
      }

      await registrations.docs.first.reference.update({
        'checkedIn': true,
        'checkedInAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors du check-in: $e');
    }
  }

  /// Récupérer le nombre de participants d'un événement
  Future<int> getParticipantsCount(String eventId) async {
    try {
      final registrations = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .get();

      return registrations.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Récupérer les statistiques d'un événement
  Future<Map<String, int>> getEventStats(String eventId) async {
    try {
      final registrations = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .get();

      final total = registrations.docs.length;
      final checkedIn = registrations.docs
          .where((doc) => doc.data()['checkedIn'] == true)
          .length;

      return {
        'total': total,
        'checkedIn': checkedIn,
        'pending': total - checkedIn,
      };
    } catch (e) {
      return {'total': 0, 'checkedIn': 0, 'pending': 0};
    }
  }
}
