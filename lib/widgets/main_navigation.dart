import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/events/presentation/pages/events_list_page.dart';
import '../features/maps/presentation/pages/map_page.dart';
import '../features/auth/presentation/pages/profile_page.dart';
import '../features/organizer/presentation/pages/dashboard_page.dart';
import '../features/qr/presentation/pages/qr_scanner_page.dart';
import '../data/providers/auth_provider.dart';

/// Navigation principale de l'application
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isOrganizer = user?.role == 'organizer' || user?.role == 'owner';

    // Navigation items dynamiques selon le rôle
    final navigationItems = [
      NavigationItem(
        icon: Icons.event,
        label: 'Événements',
        page: const EventsListPage(),
      ),
      NavigationItem(
        icon: Icons.map,
        label: 'Carte',
        page: const MapPage(),
      ),
      if (isOrganizer)
        NavigationItem(
          icon: Icons.dashboard_rounded,
          label: 'Dashboard',
          page: const OrganizerDashboardPage(),
        ),
      NavigationItem(
        icon: Icons.qr_code_scanner,
        label: 'Scanner',
        page: const QRScannerPage(),
      ),
      NavigationItem(
        icon: Icons.person,
        label: 'Profil',
        page: const ProfilePage(),
      ),
    ];

    return Scaffold(
      body: navigationItems[_currentIndex].page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

/// Élément de navigation
class NavigationItem {
  final IconData icon;
  final String label;
  final Widget page;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}

