import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/app_router.dart';
import 'data/providers/theme_provider.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/fcm_provider.dart';
import 'data/services/fcm_service.dart';
import 'widgets/main_navigation.dart';
import 'features/auth/presentation/pages/login_page.dart';

// MODE PRODUCTION - Firebase activé
// Connexion à Firebase pour l'authentification et les données

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialiser Firebase Cloud Messaging
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Initialiser les données de localisation pour le formatage des dates
  await initializeDateFormatting('fr_FR', null);
  
  runApp(
    const ProviderScope(
      child: EventMateApp(),
    ),
  );
}

class EventMateApp extends ConsumerWidget {
  const EventMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authStateProvider);

    // Initialiser FCM quand l'utilisateur est connecté
    authState.whenData((user) {
      if (user != null) {
        ref.read(fcmInitializerProvider);
      }
    });

    return MaterialApp(
      title: 'EventMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const MainNavigation();
          } else {
            return const LoginPage();
          }
        },
        loading: () => const SplashScreen(),
        error: (error, stack) => const ErrorScreen(),
      ),
      onGenerateRoute: (settings) => AppRouter.generateRoute(settings),
    );
  }
}

/// Écran de chargement
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'EventMate',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Gestion d\'événements communautaires',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Écran d'erreur
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Une erreur est survenue lors du chargement de l\'application',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Redémarrer l'application
                // TODO: Implémenter le redémarrage
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
