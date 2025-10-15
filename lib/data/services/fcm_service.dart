import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service de gestion des notifications push Firebase Cloud Messaging
class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialiser FCM
  Future<void> initialize() async {
    try {
      // Demander la permission pour les notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('✅ Permission accordée pour les notifications');
        }

        // Obtenir le token FCM
        final token = await _messaging.getToken();
        if (token != null) {
          await _saveTokenToFirestore(token);
          if (kDebugMode) {
            print('📱 Token FCM: $token');
          }
        }

        // Écouter les changements de token
        _messaging.onTokenRefresh.listen(_saveTokenToFirestore);

        // Configurer les handlers de messages
        _setupMessageHandlers();
      } else {
        if (kDebugMode) {
          print('❌ Permission refusée pour les notifications');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'initialisation FCM: $e');
      }
    }
  }

  /// Sauvegarder le token FCM dans Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': Timestamp.fromDate(DateTime.now()),
      });
      if (kDebugMode) {
        print('✅ Token FCM sauvegardé dans Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la sauvegarde du token: $e');
      }
    }
  }

  /// Configurer les handlers de messages
  void _setupMessageHandlers() {
    // Message reçu quand l'app est au premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Message reçu quand l'app est en arrière-plan et l'utilisateur clique dessus
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Vérifier si l'app a été ouverte depuis une notification
    _checkInitialMessage();
  }

  /// Gérer les messages reçus au premier plan
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('📬 Message reçu au premier plan:');
      print('Titre: ${message.notification?.title}');
      print('Corps: ${message.notification?.body}');
      print('Données: ${message.data}');
    }

    // Créer une notification locale (nécessite flutter_local_notifications)
    // Pour l'instant, on log juste le message
    // TODO: Implémenter les notifications locales
  }

  /// Gérer les messages reçus en arrière-plan
  void _handleBackgroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('📬 Message ouvert depuis l\'arrière-plan:');
      print('Titre: ${message.notification?.title}');
      print('Corps: ${message.notification?.body}');
      print('Données: ${message.data}');
    }

    // Navigation vers l'événement si eventId est présent
    final eventId = message.data['eventId'];
    if (eventId != null) {
      // TODO: Naviguer vers la page de détails de l'événement
      if (kDebugMode) {
        print('🔗 Naviguer vers l\'événement: $eventId');
      }
    }
  }

  /// Vérifier si l'app a été ouverte depuis une notification
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  /// S'abonner à un topic (ex: tous les événements)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('✅ Abonné au topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'abonnement au topic: $e');
      }
    }
  }

  /// Se désabonner d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('✅ Désabonné du topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors du désabonnement du topic: $e');
      }
    }
  }

  /// Envoyer une notification à un utilisateur spécifique
  /// Note: Cette fonction nécessite un backend (Cloud Functions)
  /// Pour l'instant, elle crée juste une notification dans Firestore
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Récupérer le token FCM de l'utilisateur
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken == null) {
        if (kDebugMode) {
          print('⚠️ Utilisateur n\'a pas de token FCM');
        }
        return;
      }

      // Créer une notification dans Firestore
      // Un Cloud Function devrait écouter cette collection et envoyer la notification
      await _firestore.collection('fcm_notifications').add({
        'userId': userId,
        'fcmToken': fcmToken,
        'title': title,
        'body': body,
        'data': data,
        'sent': false,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      if (kDebugMode) {
        print('✅ Notification créée pour l\'utilisateur: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'envoi de la notification: $e');
      }
    }
  }

  /// Envoyer une notification à tous les participants d'un événement
  Future<void> notifyEventParticipants({
    required String eventId,
    required String title,
    required String body,
  }) async {
    try {
      // Récupérer tous les participants
      final registrations = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .get();

      // Envoyer une notification à chaque participant
      for (var doc in registrations.docs) {
        final userId = doc.data()['userId'] as String;
        await sendNotificationToUser(
          userId: userId,
          title: title,
          body: body,
          data: {'eventId': eventId},
        );
      }

      if (kDebugMode) {
        print('✅ Notifications envoyées à ${registrations.docs.length} participants');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la notification des participants: $e');
      }
    }
  }

  /// Supprimer le token FCM lors de la déconnexion
  Future<void> deleteToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _messaging.deleteToken();
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': FieldValue.delete(),
      });
      if (kDebugMode) {
        print('✅ Token FCM supprimé');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la suppression du token: $e');
      }
    }
  }
}

/// Handler pour les messages en arrière-plan (doit être une fonction top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📬 Message reçu en arrière-plan:');
    print('Titre: ${message.notification?.title}');
    print('Corps: ${message.notification?.body}');
  }
}
