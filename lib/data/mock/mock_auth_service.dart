import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';
import 'mock_data.dart';

/// Service d'authentification mocké pour le développement frontend
class MockAuthService {
  UserModel? _currentUser;
  
  MockAuthService() {
    // Connexion automatique avec l'utilisateur demo
    _currentUser = MockData.currentUser;
  }

  /// Utilisateur actuellement connecté
  UserModel? get currentUser => _currentUser;

  /// Stream de l'état d'authentification
  Stream<UserModel?> authStateChanges() async* {
    yield _currentUser;
  }

  /// Connexion avec email et mot de passe
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Simulation d'un délai réseau
    await Future.delayed(const Duration(seconds: 1));
    
    // Accepter n'importe quel email/mot de passe
    _currentUser = MockData.currentUser;
    return _currentUser!;
  }

  /// Inscription avec email et mot de passe
  Future<UserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Simulation d'un délai réseau
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = UserModel(
      id: 'mock-new-user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      firstName: displayName.split(' ').first,
      lastName: displayName.split(' ').length > 1 ? displayName.split(' ').last : '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    return _currentUser!;
  }

  /// Déconnexion
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  /// Réinitialisation du mot de passe
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulation réussie
  }

  /// Mise à jour du profil
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        email: _currentUser!.email,
        firstName: displayName?.split(' ').first ?? _currentUser!.firstName,
        lastName: displayName?.split(' ').last ?? _currentUser!.lastName,
        profileImageUrl: photoURL ?? _currentUser!.profileImageUrl,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Mise à jour de l'email
  Future<void> updateEmail(String newEmail) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        email: newEmail,
        firstName: _currentUser!.firstName,
        lastName: _currentUser!.lastName,
        profileImageUrl: _currentUser!.profileImageUrl,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Mise à jour du mot de passe
  Future<void> updatePassword(String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulation réussie
  }

  /// Suppression du compte
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = null;
  }
}
