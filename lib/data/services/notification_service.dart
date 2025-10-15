import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service de gestion des notifications
/// Note: Pour les notifications push réelles, il faut configurer Firebase Cloud Messaging
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Créer une notification dans Firestore
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    String? eventId,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'eventId': eventId,
        'imageUrl': imageUrl,
        'data': data,
        'read': false,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Erreur lors de la création de la notification: $e');
    }
  }

  /// Notifier l'inscription à un événement
  Future<void> notifyEventRegistration(String eventId, String eventTitle) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await createNotification(
      userId: user.uid,
      title: 'Inscription confirmée',
      body: 'Vous êtes inscrit à "$eventTitle"',
      eventId: eventId,
    );
  }

  /// Notifier l'organisateur d'une nouvelle inscription
  Future<void> notifyOrganizerNewRegistration({
    required String organizerId,
    required String eventId,
    required String eventTitle,
    required String participantName,
  }) async {
    await createNotification(
      userId: organizerId,
      title: 'Nouvelle inscription',
      body: '$participantName s\'est inscrit à "$eventTitle"',
      eventId: eventId,
    );
  }

  /// Notifier un événement à venir (rappel)
  Future<void> notifyUpcomingEvent({
    required String userId,
    required String eventId,
    required String eventTitle,
    required DateTime eventDate,
  }) async {
    final hoursUntil = eventDate.difference(DateTime.now()).inHours;
    
    await createNotification(
      userId: userId,
      title: 'Événement à venir',
      body: '"$eventTitle" commence dans $hoursUntil heures',
      eventId: eventId,
    );
  }

  /// Notifier une modification d'événement
  Future<void> notifyEventUpdate({
    required String eventId,
    required String eventTitle,
    required String updateMessage,
  }) async {
    try {
      // Récupérer tous les participants
      final registrations = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .get();

      // Notifier chaque participant
      for (var doc in registrations.docs) {
        final userId = doc.data()['userId'] as String;
        await createNotification(
          userId: userId,
          title: 'Événement modifié',
          body: '"$eventTitle" - $updateMessage',
          eventId: eventId,
        );
      }
    } catch (e) {
      print('Erreur lors de la notification de mise à jour: $e');
    }
  }

  /// Notifier l'annulation d'un événement
  Future<void> notifyEventCancellation({
    required String eventId,
    required String eventTitle,
  }) async {
    try {
      // Récupérer tous les participants
      final registrations = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .get();

      // Notifier chaque participant
      for (var doc in registrations.docs) {
        final userId = doc.data()['userId'] as String;
        await createNotification(
          userId: userId,
          title: 'Événement annulé',
          body: '"$eventTitle" a été annulé',
          eventId: eventId,
        );
      }
    } catch (e) {
      print('Erreur lors de la notification d\'annulation: $e');
    }
  }

  /// Récupérer les notifications de l'utilisateur
  Stream<List<Map<String, dynamic>>> getUserNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'],
          'body': data['body'],
          'eventId': data['eventId'],
          'imageUrl': data['imageUrl'],
          'read': data['read'] ?? false,
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
          'data': data['data'],
        };
      }).toList();
    });
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
        'readAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Erreur lors du marquage de la notification: $e');
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in notifications.docs) {
        batch.update(doc.reference, {
          'read': true,
          'readAt': Timestamp.fromDate(DateTime.now()),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Erreur lors du marquage des notifications: $e');
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Erreur lors de la suppression de la notification: $e');
    }
  }

  /// Supprimer toutes les notifications
  Future<void> deleteAllNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .get();

      final batch = _firestore.batch();
      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Erreur lors de la suppression des notifications: $e');
    }
  }

  /// Compter les notifications non lues
  Stream<int> getUnreadCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
