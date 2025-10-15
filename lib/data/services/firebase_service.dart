import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';

/// Service Firebase pour les opérations CRUD
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getters pour les instances
  static FirebaseAuth get auth => _auth;
  static FirebaseFirestore get firestore => _firestore;
  static FirebaseStorage get storage => _storage;

  // Collections
  static CollectionReference get usersCollection => 
      _firestore.collection('users');
  static CollectionReference get eventsCollection => 
      _firestore.collection('events');
  static CollectionReference get registrationsCollection => 
      _firestore.collection('registrations');

  /// Utilisateur actuel
  static User? get currentUser => _auth.currentUser;

  /// Vérifie si l'utilisateur est connecté
  static bool get isLoggedIn => _auth.currentUser != null;

  /// Stream de l'utilisateur actuel
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Connexion avec email et mot de passe
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Inscription avec email et mot de passe
  static Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Déconnexion
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Réinitialisation de mot de passe
  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Mise à jour du profil utilisateur
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    }
  }

  /// Sauvegarde des données utilisateur dans Firestore
  static Future<void> saveUserData(UserModel user) async {
    await usersCollection.doc(user.id).set(user.toFirestore());
  }

  /// Récupération des données utilisateur depuis Firestore
  static Future<UserModel?> getUserData(String userId) async {
    final doc = await usersCollection.doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  /// Stream des données utilisateur
  static Stream<UserModel?> getUserDataStream(String userId) {
    return usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Sauvegarde d'un événement
  static Future<void> saveEvent(EventModel event) async {
    await eventsCollection.doc(event.id).set(event.toFirestore());
  }

  /// Récupération d'un événement
  static Future<EventModel?> getEvent(String eventId) async {
    final doc = await eventsCollection.doc(eventId).get();
    if (doc.exists) {
      return EventModel.fromFirestore(doc);
    }
    return null;
  }

  /// Stream d'un événement
  static Stream<EventModel?> getEventStream(String eventId) {
    return eventsCollection.doc(eventId).snapshots().map((doc) {
      if (doc.exists) {
        return EventModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Récupération de tous les événements
  static Future<List<EventModel>> getAllEvents() async {
    final querySnapshot = await eventsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('dateTime')
        .get();
    
    return querySnapshot.docs
        .map((doc) => EventModel.fromFirestore(doc))
        .toList();
  }

  /// Stream de tous les événements
  static Stream<List<EventModel>> getAllEventsStream() {
    return eventsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  /// Récupération des événements d'un organisateur
  static Future<List<EventModel>> getEventsByOrganizer(String organizerId) async {
    final querySnapshot = await eventsCollection
        .where('organizerId', isEqualTo: organizerId)
        .where('isActive', isEqualTo: true)
        .orderBy('dateTime')
        .get();
    
    return querySnapshot.docs
        .map((doc) => EventModel.fromFirestore(doc))
        .toList();
  }

  /// Suppression d'un événement
  static Future<void> deleteEvent(String eventId) async {
    await eventsCollection.doc(eventId).update({'isActive': false});
  }

  /// Inscription à un événement
  static Future<void> registerForEvent(RegistrationModel registration) async {
    await registrationsCollection.doc(registration.id).set(registration.toFirestore());
  }

  /// Récupération des inscriptions d'un utilisateur
  static Future<List<RegistrationModel>> getUserRegistrations(String userId) async {
    final querySnapshot = await registrationsCollection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('registeredAt', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => RegistrationModel.fromFirestore(doc))
        .toList();
  }

  /// Récupération des participants d'un événement
  static Future<List<RegistrationModel>> getEventParticipants(String eventId) async {
    final querySnapshot = await registrationsCollection
        .where('eventId', isEqualTo: eventId)
        .where('isActive', isEqualTo: true)
        .orderBy('registeredAt')
        .get();
    
    return querySnapshot.docs
        .map((doc) => RegistrationModel.fromFirestore(doc))
        .toList();
  }

  /// Check-in d'un participant
  static Future<void> checkInParticipant(String registrationId) async {
    await registrationsCollection.doc(registrationId).update({
      'checkedInAt': Timestamp.now(),
    });
  }

  /// Upload d'image vers Firebase Storage
  static Future<String> uploadImage(String path, Uint8List imageBytes) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putData(imageBytes);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Suppression d'image de Firebase Storage
  static Future<void> deleteImage(String imageUrl) async {
    final ref = _storage.refFromURL(imageUrl);
    await ref.delete();
  }
}
