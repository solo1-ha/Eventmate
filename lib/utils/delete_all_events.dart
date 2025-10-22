import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Utilitaire pour supprimer tous les événements
/// ATTENTION : À utiliser uniquement en développement !
class DeleteAllEventsUtil {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Supprimer tous les événements de la base de données
  /// ATTENTION : Cette action est irréversible !
  static Future<Map<String, dynamic>> deleteAllEvents({
    bool deleteRegistrations = true,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      int eventsDeleted = 0;
      int registrationsDeleted = 0;

      // 1. Récupérer tous les événements
      final eventsSnapshot = await _firestore.collection('events').get();
      
      print('📊 Nombre d\'événements trouvés : ${eventsSnapshot.docs.length}');

      // 2. Supprimer tous les événements par batch (max 500 par batch)
      final eventBatches = <WriteBatch>[];
      WriteBatch currentBatch = _firestore.batch();
      int operationCount = 0;

      for (var doc in eventsSnapshot.docs) {
        currentBatch.delete(doc.reference);
        operationCount++;
        eventsDeleted++;

        // Firebase limite à 500 opérations par batch
        if (operationCount >= 500) {
          eventBatches.add(currentBatch);
          currentBatch = _firestore.batch();
          operationCount = 0;
        }
      }

      // Ajouter le dernier batch s'il contient des opérations
      if (operationCount > 0) {
        eventBatches.add(currentBatch);
      }

      // Exécuter tous les batches d'événements
      for (var batch in eventBatches) {
        await batch.commit();
      }

      print('✅ $eventsDeleted événements supprimés');

      // 3. Supprimer toutes les inscriptions si demandé
      if (deleteRegistrations) {
        final registrationsSnapshot = await _firestore.collection('registrations').get();
        
        print('📊 Nombre d\'inscriptions trouvées : ${registrationsSnapshot.docs.length}');

        final registrationBatches = <WriteBatch>[];
        currentBatch = _firestore.batch();
        operationCount = 0;

        for (var doc in registrationsSnapshot.docs) {
          currentBatch.delete(doc.reference);
          operationCount++;
          registrationsDeleted++;

          if (operationCount >= 500) {
            registrationBatches.add(currentBatch);
            currentBatch = _firestore.batch();
            operationCount = 0;
          }
        }

        if (operationCount > 0) {
          registrationBatches.add(currentBatch);
        }

        for (var batch in registrationBatches) {
          await batch.commit();
        }

        print('✅ $registrationsDeleted inscriptions supprimées');
      }

      return {
        'success': true,
        'eventsDeleted': eventsDeleted,
        'registrationsDeleted': registrationsDeleted,
        'message': 'Suppression réussie : $eventsDeleted événements et $registrationsDeleted inscriptions supprimés',
      };

    } catch (e) {
      print('❌ Erreur lors de la suppression : $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Erreur lors de la suppression : $e',
      };
    }
  }

  /// Supprimer uniquement les événements passés
  static Future<Map<String, dynamic>> deletePastEvents() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      int eventsDeleted = 0;
      final now = DateTime.now();

      // Récupérer tous les événements
      final eventsSnapshot = await _firestore.collection('events').get();

      final batch = _firestore.batch();
      int operationCount = 0;

      for (var doc in eventsSnapshot.docs) {
        final data = doc.data();
        final dateTime = (data['dateTime'] as Timestamp).toDate();

        // Supprimer uniquement si l'événement est passé
        if (dateTime.isBefore(now)) {
          batch.delete(doc.reference);
          operationCount++;
          eventsDeleted++;

          // Supprimer aussi les inscriptions liées
          final registrations = await _firestore
              .collection('registrations')
              .where('eventId', isEqualTo: doc.id)
              .get();

          for (var reg in registrations.docs) {
            batch.delete(reg.reference);
            operationCount++;
          }

          // Commit si on atteint la limite
          if (operationCount >= 450) {
            await batch.commit();
            operationCount = 0;
          }
        }
      }

      // Commit final
      if (operationCount > 0) {
        await batch.commit();
      }

      return {
        'success': true,
        'eventsDeleted': eventsDeleted,
        'message': '$eventsDeleted événements passés supprimés',
      };

    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Erreur lors de la suppression : $e',
      };
    }
  }

  /// Supprimer les événements d'un utilisateur spécifique
  static Future<Map<String, dynamic>> deleteUserEvents(String userId) async {
    try {
      int eventsDeleted = 0;

      final eventsSnapshot = await _firestore
          .collection('events')
          .where('organizerId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();

      for (var doc in eventsSnapshot.docs) {
        batch.delete(doc.reference);
        eventsDeleted++;

        // Supprimer les inscriptions liées
        final registrations = await _firestore
            .collection('registrations')
            .where('eventId', isEqualTo: doc.id)
            .get();

        for (var reg in registrations.docs) {
          batch.delete(reg.reference);
        }
      }

      await batch.commit();

      return {
        'success': true,
        'eventsDeleted': eventsDeleted,
        'message': '$eventsDeleted événements de l\'utilisateur supprimés',
      };

    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Erreur lors de la suppression : $e',
      };
    }
  }
}
