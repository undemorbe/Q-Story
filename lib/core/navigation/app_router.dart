import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/presentation/pages/about_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/places/domain/entities/place.dart';
import '../../features/places/presentation/pages/map_page.dart';
import '../../features/places/presentation/pages/place_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/settings/presentation/pages/notification_settings_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/stats/presentation/pages/stats_page.dart';
import '../di/service_locator.dart';
import '../storage/app_preferences.dart';
import 'scaffold_with_navbar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter buildRouter() => GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/map',
      redirect: (context, state) {
        final seen = getIt<AppPreferences>().hasSeenOnboarding;
        if (!seen && state.matchedLocation != '/onboarding') return '/onboarding';
        if (state.matchedLocation == '/') return '/map';
        return null;
      },
      routes: [
        GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
        GoRoute(
          path: '/place',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, state) {
            final place = state.extra;
            if (place is! Place) {
              return const Scaffold(body: Center(child: Icon(Icons.help_outline, size: 48)));
            }
            return PlaceDetailPage(place: place);
          },
        ),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
        GoRoute(path: '/notification-settings', builder: (_, __) => const NotificationSettingsPage()),
        GoRoute(path: '/about', builder: (_, __) => const AboutPage()),
        StatefulShellRoute.indexedStack(
          builder: (_, __, shell) => ScaffoldWithNavBar(navigationShell: shell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/map', builder: (_, __) => const MapPage())]),
            StatefulShellBranch(routes: [GoRoute(path: '/scanner', builder: (_, __) => const ScannerPage())]),
            StatefulShellBranch(routes: [GoRoute(path: '/stats', builder: (_, __) => const StatsPage())]),
            StatefulShellBranch(routes: [GoRoute(path: '/favorites', builder: (_, __) => const FavoritesPage())]),
            StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfilePage())]),
          ],
        ),
      ],
    );
