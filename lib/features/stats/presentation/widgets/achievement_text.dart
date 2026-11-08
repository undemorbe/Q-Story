import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/stats_snapshot.dart';

/// Localized (title, description, icon) of an achievement.
(String, String, IconData) achievementText(AppLocalizations l, AchievementId id) => switch (id) {
  AchievementId.firstDiscovery => (l.achFirstDiscovery, l.achFirstDiscoveryDesc, Icons.place_outlined),
  AchievementId.tenDiscoveries => (l.achTenDiscoveries, l.achTenDiscoveriesDesc, Icons.map_outlined),
  AchievementId.fiftyDiscoveries => (l.achFiftyDiscoveries, l.achFiftyDiscoveriesDesc, Icons.auto_stories),
  AchievementId.firstHunt => (l.achFirstHunt, l.achFirstHuntDesc, Icons.explore_outlined),
  AchievementId.fiveHunts => (l.achFiveHunts, l.achFiveHuntsDesc, Icons.diamond_outlined),
  AchievementId.straightShooter => (l.achStraightShooter, l.achStraightShooterDesc, Icons.straight),
  AchievementId.tenKDay => (l.achTenKDay, l.achTenKDayDesc, Icons.directions_run),
  AchievementId.hundredKTotal => (l.achHundredKTotal, l.achHundredKTotalDesc, Icons.military_tech_outlined),
  AchievementId.marathon => (l.achMarathon, l.achMarathonDesc, Icons.sports_score),
  AchievementId.explorer => (l.achExplorer, l.achExplorerDesc, Icons.travel_explore),
  AchievementId.scanner => (l.achScanner, l.achScannerDesc, Icons.qr_code_scanner),
  AchievementId.allSources => (l.achAllSources, l.achAllSourcesDesc, Icons.library_books_outlined),
  AchievementId.weekStreak => (l.achWeekStreak, l.achWeekStreakDesc, Icons.whatshot_outlined),
  AchievementId.timeTraveler => (l.achTimeTraveler, l.achTimeTravelerDesc, Icons.hourglass_bottom),
  AchievementId.curator => (l.achCurator, l.achCuratorDesc, Icons.favorite_outline),
  AchievementId.cartographer => (l.achCartographer, l.achCartographerDesc, Icons.edit_location_alt_outlined),
};
