import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/profile_page.dart';
import '../features/events/presentation/pages/events_list_page.dart';
import '../features/events/presentation/pages/event_detail_page.dart';
import '../features/events/presentation/pages/create_event_page.dart';
import '../features/events/presentation/pages/my_tickets_page.dart';
import '../features/events/presentation/pages/scan_qr_page.dart';
import '../features/events/presentation/pages/test_scanners_page.dart';
import '../features/maps/presentation/pages/map_page.dart';
import '../features/maps/presentation/pages/openstreetmap_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/admin/admin_page.dart';
import '../widgets/main_navigation.dart';

/// Routeur principal de l'application
class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String events = '/events';
  static const String eventDetail = '/event-detail';
  static const String createEvent = '/create-event';
  static const String myTickets = '/my-tickets';
  static const String scanQr = '/scan-qr';
  static const String testScanners = '/test-scanners';
  static const String map = '/map';
  static const String openStreetMap = '/openstreetmap';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String admin = '/admin';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: routeSettings,
        );
      
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: routeSettings,
        );
      
      case home:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(),
          settings: routeSettings,
        );
      
      case events:
        return MaterialPageRoute(
          builder: (_) => const EventsListPage(),
          settings: routeSettings,
        );
      
      case eventDetail:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final eventId = args?['eventId'] as String?;
        if (eventId == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('ID d\'événement manquant')),
            ),
            settings: routeSettings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => EventDetailPage(eventId: eventId),
          settings: routeSettings,
        );
      
      case createEvent:
        return MaterialPageRoute(
          builder: (_) => const CreateEventPage(),
          settings: routeSettings,
        );
      
      case myTickets:
        return MaterialPageRoute(
          builder: (_) => const MyTicketsPage(),
          settings: routeSettings,
        );
      
      case scanQr:
        return MaterialPageRoute(
          builder: (_) => const ScanQrPage(),
          settings: routeSettings,
        );
      
      case testScanners:
        return MaterialPageRoute(
          builder: (_) => const TestScannersPage(),
          settings: routeSettings,
        );
      
      case map:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final latitude = args?['latitude'] as double?;
        final longitude = args?['longitude'] as double?;
        final title = args?['title'] as String?;
        return MaterialPageRoute(
          builder: (_) => MapPage(
            latitude: latitude,
            longitude: longitude,
            title: title,
          ),
          settings: routeSettings,
        );
      
      case openStreetMap:
        return MaterialPageRoute(
          builder: (_) => const OpenStreetMapPage(),
          settings: routeSettings,
        );
      
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: routeSettings,
        );
      
      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: routeSettings,
        );
      
      case admin:
        return MaterialPageRoute(
          builder: (_) => const AdminPage(),
          settings: routeSettings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page non trouvée')),
          ),
          settings: routeSettings,
        );
    }
  }
}

/// Provider pour la navigation
final routerProvider = Provider<AppRouter>((ref) => AppRouter());

