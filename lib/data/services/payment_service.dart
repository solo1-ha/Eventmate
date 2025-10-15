import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';

/// Résultat d'un paiement
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? ticketId;
  final String? errorMessage;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.ticketId,
    this.errorMessage,
  });
}

/// Méthodes de paiement disponibles
enum PaymentMethod {
  mobileMoney,
  orangeMoney,
  mtnMoney,
  card,
  cash,
}

/// Service de gestion des paiements
class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initier un paiement pour un événement
  Future<PaymentResult> initiatePayment({
    required String eventId,
    required PaymentMethod method,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return PaymentResult(
        success: false,
        errorMessage: 'Utilisateur non connecté',
      );
    }

    try {
      // Récupérer l'événement
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        return PaymentResult(
          success: false,
          errorMessage: 'Événement non trouvé',
        );
      }

      final event = EventModel.fromFirestore(eventDoc);

      // Vérifier que c'est un événement payant
      if (!event.isPaid || event.price == null) {
        return PaymentResult(
          success: false,
          errorMessage: 'Cet événement est gratuit',
        );
      }

      // Vérifier les places disponibles
      if (event.soldTickets >= event.maxCapacity) {
        return PaymentResult(
          success: false,
          errorMessage: 'Plus de tickets disponibles',
        );
      }

      // Vérifier si déjà acheté
      final existingTicket = await _firestore
          .collection('tickets')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'valid')
          .get();

      if (existingTicket.docs.isNotEmpty) {
        return PaymentResult(
          success: false,
          errorMessage: 'Vous avez déjà acheté un ticket pour cet événement',
        );
      }

      // Créer la transaction
      final transactionRef = _firestore.collection('transactions').doc();
      final transactionId = transactionRef.id;

      await transactionRef.set({
        'id': transactionId,
        'eventId': eventId,
        'userId': user.uid,
        'amount': event.price,
        'currency': event.currency,
        'method': method.name,
        'status': 'pending',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      // Simuler le paiement (en production, appeler l'API de paiement)
      final paymentSuccess = await _simulatePayment(
        amount: event.price!,
        method: method,
        transactionId: transactionId,
      );

      if (paymentSuccess) {
        // Générer le ticket
        final ticketId = await _generateTicket(
          eventId: eventId,
          userId: user.uid,
          transactionId: transactionId,
          amount: event.price!,
        );

        // Mettre à jour le nombre de tickets vendus
        await _firestore.collection('events').doc(eventId).update({
          'soldTickets': FieldValue.increment(1),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });

        // Mettre à jour la transaction
        await transactionRef.update({
          'status': 'completed',
          'ticketId': ticketId,
          'completedAt': Timestamp.fromDate(DateTime.now()),
        });

        return PaymentResult(
          success: true,
          transactionId: transactionId,
          ticketId: ticketId,
        );
      } else {
        // Échec du paiement
        await transactionRef.update({
          'status': 'failed',
          'failedAt': Timestamp.fromDate(DateTime.now()),
        });

        return PaymentResult(
          success: false,
          errorMessage: 'Le paiement a échoué',
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Erreur lors du paiement: $e',
      );
    }
  }

  /// Simuler un paiement (à remplacer par vraie API en production)
  Future<bool> _simulatePayment({
    required double amount,
    required PaymentMethod method,
    required String transactionId,
  }) async {
    // Simuler un délai de traitement
    await Future.delayed(const Duration(seconds: 2));

    // Simuler un succès (90% de réussite)
    return DateTime.now().millisecond % 10 != 0;
  }

  /// Générer un ticket après paiement réussi
  Future<String> _generateTicket({
    required String eventId,
    required String userId,
    required String transactionId,
    required double amount,
  }) async {
    final ticketRef = _firestore.collection('tickets').doc();
    final ticketId = ticketRef.id;

    // Récupérer les infos utilisateur
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};

    await ticketRef.set({
      'id': ticketId,
      'eventId': eventId,
      'userId': userId,
      'userName': userData['firstName'] != null && userData['lastName'] != null
          ? '${userData['firstName']} ${userData['lastName']}'
          : 'Utilisateur',
      'userEmail': userData['email'] ?? '',
      'transactionId': transactionId,
      'amount': amount,
      'status': 'valid', // valid, used, cancelled
      'purchasedAt': Timestamp.fromDate(DateTime.now()),
      'usedAt': null,
    });

    // Créer aussi une inscription (registration)
    final registrationRef = _firestore.collection('registrations').doc();
    await registrationRef.set({
      'id': registrationRef.id,
      'eventId': eventId,
      'userId': userId,
      'userName': userData['firstName'] != null && userData['lastName'] != null
          ? '${userData['firstName']} ${userData['lastName']}'
          : 'Utilisateur',
      'userEmail': userData['email'] ?? '',
      'registeredAt': Timestamp.fromDate(DateTime.now()),
      'checkedIn': false,
      'ticketId': ticketId,
      'isPaid': true,
    });

    return ticketId;
  }

  /// Récupérer un ticket par ID
  Future<Map<String, dynamic>?> getTicket(String ticketId) async {
    try {
      final ticketDoc = await _firestore.collection('tickets').doc(ticketId).get();
      if (!ticketDoc.exists) return null;

      return ticketDoc.data();
    } catch (e) {
      return null;
    }
  }

  /// Récupérer les tickets d'un utilisateur
  Stream<List<Map<String, dynamic>>> getUserTickets() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('tickets')
        .where('userId', isEqualTo: user.uid)
        .orderBy('purchasedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Valider un ticket (marquer comme utilisé)
  Future<bool> validateTicket(String ticketId) async {
    try {
      final ticketDoc = await _firestore.collection('tickets').doc(ticketId).get();
      if (!ticketDoc.exists) return false;

      final ticketData = ticketDoc.data()!;

      // Vérifier le statut
      if (ticketData['status'] != 'valid') {
        return false;
      }

      // Marquer comme utilisé
      await _firestore.collection('tickets').doc(ticketId).update({
        'status': 'used',
        'usedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Annuler un ticket (remboursement)
  Future<bool> cancelTicket(String ticketId) async {
    try {
      final ticketDoc = await _firestore.collection('tickets').doc(ticketId).get();
      if (!ticketDoc.exists) return false;

      final ticketData = ticketDoc.data()!;

      // Vérifier que le ticket n'a pas été utilisé
      if (ticketData['status'] == 'used') {
        return false;
      }

      final eventId = ticketData['eventId'];

      // Marquer comme annulé
      await _firestore.collection('tickets').doc(ticketId).update({
        'status': 'cancelled',
        'cancelledAt': Timestamp.fromDate(DateTime.now()),
      });

      // Décrémenter le nombre de tickets vendus
      await _firestore.collection('events').doc(eventId).update({
        'soldTickets': FieldValue.increment(-1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtenir les statistiques de vente d'un événement
  Future<Map<String, dynamic>> getSalesStats(String eventId) async {
    try {
      final tickets = await _firestore
          .collection('tickets')
          .where('eventId', isEqualTo: eventId)
          .get();

      int totalSold = 0;
      int validTickets = 0;
      int usedTickets = 0;
      int cancelledTickets = 0;
      double totalRevenue = 0;

      for (var doc in tickets.docs) {
        final data = doc.data();
        totalSold++;

        switch (data['status']) {
          case 'valid':
            validTickets++;
            break;
          case 'used':
            usedTickets++;
            break;
          case 'cancelled':
            cancelledTickets++;
            break;
        }

        if (data['status'] != 'cancelled') {
          totalRevenue += (data['amount'] ?? 0).toDouble();
        }
      }

      return {
        'totalSold': totalSold,
        'validTickets': validTickets,
        'usedTickets': usedTickets,
        'cancelledTickets': cancelledTickets,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      return {
        'totalSold': 0,
        'validTickets': 0,
        'usedTickets': 0,
        'cancelledTickets': 0,
        'totalRevenue': 0.0,
      };
    }
  }
}
