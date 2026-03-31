import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/history/presentation/pages/history_detail_page.dart';
import '../../features/history/domain/entities/history_entity.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/notification_settings_page.dart';
import '../../features/qr_operations/presentation/pages/qr_scanner_view.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../di/service_locator.dart';
import 'scaffold_with_navbar.dart';

import '../../features/qr_operations/presentation/pages/qr_result_page.dart';
import '../../features/qr_operations/data/models/qr_content_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/map',
  redirect: (context, state) async {
    final prefs = getIt<SharedPreferences>();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    
    // If onboarding not seen, redirect to onboarding
    if (!hasSeenOnboarding && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }

    // If onboarding seen and trying to access root, go to map
    if (state.matchedLocation == '/') {
       return hasSeenOnboarding ? '/map' : '/onboarding';
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    // Login and Register routes removed as per request to remove auth
    // We can keep them commented out or remove entirely. 
    // Removing them to follow instructions strictly.
    GoRoute(
      path: '/history/:id',
      builder: (context, state) {
        final entity = state.extra as HistoryEntity;
        return HistoryDetailPage(entity: entity);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsPage(),
    ),
    GoRoute(
      path: '/qr-result',
      builder: (context, state) {
        final content = state.extra as QrContentModel;
        return QrResultPage(content: content);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scanner',
              builder: (context, state) => const QrScannerView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
