import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../di/service_locator.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme_ext.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Lets tabs that stay alive in the IndexedStack (camera!) know
    // whether they are visible.
    final currentTab = getIt<ValueNotifier<int>>(instanceName: 'currentTab');
    WidgetsBinding.instance.addPostFrameCallback((_) => currentTab.value = navigationShell.currentIndex);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: context.outlineClr),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              currentTab.value = index;
              navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
            },
            destinations: [
              NavigationDestination(
                  icon: const Icon(Icons.map_outlined), selectedIcon: const Icon(Icons.map), label: l.navMap),
              NavigationDestination(
                icon: const Icon(Icons.qr_code_scanner_outlined),
                selectedIcon: const Icon(Icons.qr_code_scanner),
                label: l.navScanner,
              ),
              NavigationDestination(
                  icon: const Icon(Icons.insights_outlined),
                  selectedIcon: const Icon(Icons.insights),
                  label: l.navStats),
              NavigationDestination(
                  icon: const Icon(Icons.favorite_outline),
                  selectedIcon: const Icon(Icons.favorite),
                  label: l.navFavorites),
              NavigationDestination(
                  icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: l.navProfile),
            ],
          ),
        ],
      ),
    );
  }
}
