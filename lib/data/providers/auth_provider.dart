import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// MODE PRODUCTION - Services Firebase
final authService = Provider((ref) => AuthService());

/// Provider pour l'état d'authentification Firebase
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final service = ref.watch(authService);
  return service.authStateChanges();
});

/// Provider pour l'utilisateur actuel avec ses données
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider pour l'état de connexion
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

