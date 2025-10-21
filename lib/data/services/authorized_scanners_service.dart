import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/authorized_scanner_model.dart';

/// Service pour gérer les scanners autorisés d'un événement
class AuthorizedScannersService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ajouter un scanner autorisé à un événement
  /// 
  /// Seul l'organisateur de l'événement peut ajouter des scanners
  static Future<void> addAuthorizedScanner({
    required String eventId,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('authorizedScanners')
          .doc(userId)
          .set({
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du scanner: $e');
    }
  }

  /// Supprimer un scanner autorisé
  /// 
  /// Seul l'organisateur peut supprimer des scanners
  static Future<void> removeAuthorizedScanner({
    required String eventId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('authorizedScanners')
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du scanner: $e');
    }
  }

  /// Récupérer la liste des scanners autorisés pour un événement
  static Stream<List<AuthorizedScannerModel>> getAuthorizedScanners(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('authorizedScanners')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AuthorizedScannerModel.fromFirestore(doc);
      }).toList();
    });
  }

  /// Vérifier si un utilisateur est autorisé à scanner pour un événement
  /// 
  /// Retourne true si l'utilisateur est l'organisateur OU dans la liste des scanners autorisés
  static Future<bool> isAuthorizedToScan({
    required String eventId,
    required String userId,
  }) async {
    try {
      // Récupérer l'événement
      final eventDoc = await _firestore
          .collection('events')
          .doc(eventId)
          .get();

      if (!eventDoc.exists) {
        throw Exception('Événement introuvable');
      }

      final eventData = eventDoc.data()!;
      final organizerId = eventData['organizerId'] as String;

      // Si l'utilisateur est l'organisateur, il est autorisé
      if (userId == organizerId) {
        return true;
      }

      // Sinon, vérifier s'il est dans la liste des scanners autorisés
      final scannerDoc = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('authorizedScanners')
          .doc(userId)
          .get();

      return scannerDoc.exists;
    } catch (e) {
      throw Exception('Erreur lors de la vérification: $e');
    }
  }

  /// Récupérer le nombre de scanners autorisés pour un événement
  static Future<int> getAuthorizedScannersCount(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('authorizedScanners')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Rechercher un utilisateur par email pour l'ajouter comme scanner
  static Future<Map<String, dynamic>?> searchUserByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return {
        'id': doc.id,
        'name': doc.data()['name'] ?? 'Utilisateur',
        'email': doc.data()['email'] ?? email,
        'photoUrl': doc.data()['photoUrl'],
      };
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }
}
