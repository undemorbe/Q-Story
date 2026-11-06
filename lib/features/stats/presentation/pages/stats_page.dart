import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../activity/domain/entities/activity.dart';
import '../../../activity/presentation/stores/journal_store.dart';
import '../../../activity/presentation/stores/tracking_store.dart';
import '../../../places/presentation/widgets/place_labels.dart';
import '../../domain/stats_snapshot.dart';
import '../stores/stats_store.dart';
import '../widgets/stats_widgets.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final StatsStore _store = getIt<StatsStore>();
  final TrackingStore _tracking = getIt<TrackingStore>();
  final List<ReactionDisposer> _disposers = [];

  @override
  void initState() {
    super.initState();
    _store.refresh();
    // Refresh whenever something is logged or a hunt ends.
    _disposers
      ..add(reaction((_) => getIt<JournalStore>().revision, (_) => _store.refresh(), delay: 800))
      ..add(reaction((_) => _tracking.activeHunt?.status, (_) => _store.refresh(), delay: 800));
  }

  @override
  void dispose() {
    for (final d in _disposers) {
      d();
    }
    super.dispose();
  }

  Future<void> _confirmReset() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.statsReset),
        content: Text(l.statsResetConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: context.blood),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.statsReset),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _store.resetAll();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.statsResetDone)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.statsTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (_) => _confirmReset(),
            itemBuilder: (_) => [PopupMenuItem(value: 'reset', child: Text(l.statsReset))],
          ),
        ],
      ),
      body: Observer(builder: (_) {
        final s = _store.snapshot;
        if (s == null) return const Center(child: CircularProgressIndicator());
        // Live values from the tracker override the (periodically flushed) snapshot.
        final todaySteps = _tracking.todaySteps > s.todaySteps ? _tracking.todaySteps : s.todaySteps;
        return RefreshIndicator(
          onRefresh: _store.refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _Header(s: s, todaySteps: todaySteps, tracking: _tracking),
              _Movement(s: s),
              _Charts(s: s),
              _Hunts(s: s),
              _Discoveries(s: s),
              _Engagement(s: s),
              _Achievements(s: s),
              const SizedBox(height: 20),
              Row(children: [
                Icon(Icons.lock_outline, size: 14, color: context.dim),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(l.statsLocalOnly,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.dim))),
              ]),
            ],
          ),
        );
      }),
    );
  }
}

String _n(BuildContext context, num v) =>
    NumberFormat.decimalPattern(Localizations.localeOf(context).languageCode).format(v);

class _Header extends StatelessWidget {
  const _Header({required this.s, required this.todaySteps, required this.tracking});
  final StatsSnapshot s;
  final int todaySteps;
  final TrackingStore tracking;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final ratio = s.dailyGoal == 0 ? 0.0 : (todaySteps / s.dailyGoal).clamp(0.0, 1.0);
    return GothicCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.statsToday.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: context.gold, letterSpacing: 2)),
        const SizedBox(height: 12),
        GoalRing(
          ratio: ratio,
          center: _n(context, todaySteps),
          caption: [
            l.statsGoal('${(ratio * 100).round()}', _n(context, s.dailyGoal)),
            '${l.statsDistance}: ${l.distance(tracking.todayDistanceM > s.todayDistanceM ? tracking.todayDistanceM : s.todayDistanceM)}',
            '${l.statsStreak}: ${l.statsDays(s.currentStreak)}',
          ].join('\n'),
        ),
        if (!tracking.stepSensorAvailable && s.totalSteps > 0) ...[
          const SizedBox(height: 10),
          Text(l.statsEstimated, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.dim)),
        ],
      ]),
    );
  }
}

class _Movement extends StatelessWidget {
  const _Movement({required this.s});
  final StatsSnapshot s;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final df = DateFormat.MMMd(Localizations.localeOf(context).languageCode);
    return StatsSection(title: l.statsMovement, icon: Icons.directions_walk, children: [
      StatGrid(tiles: [
        StatTile(icon: Icons.directions_walk, label: l.statsSteps, value: _n(context, s.totalSteps)),
        StatTile(icon: Icons.route, label: l.statsDistance, value: l.distance(s.totalDistanceM)),
        StatTile(icon: Icons.timer_outlined, label: l.statsActiveTime, value: l.duration(s.activeTime)),
        StatTile(
            icon: Icons.local_fire_department_outlined,
            label: l.statsCalories,
            value: '${_n(context, s.caloriesKcal.round())} ${l.unitKcal}'),
        StatTile(
            icon: Icons.calendar_view_day_outlined,
            label: l.statsAvgDaily,
            value: _n(context, s.avgDailySteps.round())),
        StatTile(
          icon: Icons.emoji_events_outlined,
          label: l.statsBestDay,
          value: s.bestDay == null ? l.noData : _n(context, s.bestDay!.steps),
          hint: s.bestDay == null ? null : df.format(s.bestDay!.date),
        ),
        StatTile(icon: Icons.flag_outlined, label: l.statsGoalDays, value: l.statsDays(s.goalDays)),
        StatTile(icon: Icons.hiking, label: l.statsLongestDay, value: l.distance(s.longestDayDistanceM)),
        StatTile(
            icon: Icons.speed,
            label: l.statsMaxSpeed,
            value: '${(s.maxSpeedMps * 3.6).toStringAsFixed(1)} ${l.unitKmh}'),
        StatTile(icon: Icons.whatshot_outlined, label: l.statsStreak, value: l.statsDays(s.currentStreak)),
        StatTile(icon: Icons.military_tech_outlined, label: l.statsLongestStreak, value: l.statsDays(s.longestStreak)),
        StatTile(icon: Icons.event_available_outlined, label: l.statsActiveDays, value: '${s.activeDays}'),
      ]),
    ]);
  }
}

class _Charts extends StatelessWidget {
  const _Charts({required this.s});
  final StatsSnapshot s;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final dayF = DateFormat.d(lang);
    final fullF = DateFormat.MMMEd(lang);
    // Monday-first short weekday names.
    final monday = DateTime(2024, 1, 1);
    final wd = List.generate(7, (i) => DateFormat.E(lang).format(monday.add(Duration(days: i))));
    final hour = s.mostActiveHour;
    final day = s.mostActiveWeekday;
    final todayIdx = s.last30.length - 1;
    return StatsSection(title: l.stats30Days, icon: Icons.bar_chart, children: [
      GothicCard(
        padding: const EdgeInsets.fromLTRB(8, 16, 12, 8),
        child: SimpleBarChart(
          values: s.last30.map((d) => d.steps).toList(),
          referenceLine: s.dailyGoal.toDouble(),
          labelEvery: 5,
          highlightIndex: todayIdx,
          bottomLabel: (i) => dayF.format(s.last30[i].date),
          tooltip: (i) =>
              '${fullF.format(s.last30[i].date)}\n${_n(context, s.last30[i].steps)} · ${l.distance(s.last30[i].distanceM)}',
        ),
      ),
      const SizedBox(height: 16),
      Text(l.statsByHour, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      GothicCard(
        padding: const EdgeInsets.fromLTRB(8, 16, 12, 8),
        child: SimpleBarChart(
          height: 140,
          values: s.stepsByHour,
          labelEvery: 6,
          highlightIndex: hour,
          bottomLabel: (i) => '$i',
          tooltip: (i) => '$i:00–${i + 1}:00\n${_n(context, s.stepsByHour[i])}',
        ),
      ),
      const SizedBox(height: 16),
      Text(l.statsByWeekday, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      GothicCard(
        padding: const EdgeInsets.fromLTRB(8, 16, 12, 8),
        child: SimpleBarChart(
          height: 140,
          values: s.stepsByWeekday,
          highlightIndex: day,
          bottomLabel: (i) => wd[i],
          tooltip: (i) => '${wd[i]}\n${_n(context, s.stepsByWeekday[i])}',
        ),
      ),
      if (hour != null && day != null) ...[
        const SizedBox(height: 8),
        Text(l.statsMostActive(wd[day], '$hour'), style: Theme.of(context).textTheme.bodySmall),
      ],
    ]);
  }
}

class _Hunts extends StatelessWidget {
  const _Hunts({required this.s});
  final StatsSnapshot s;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final h = s.hunts;
    final df = DateFormat.MMMd(Localizations.localeOf(context).languageCode).add_Hm();
    String huntLine(Hunt x) =>
        '${x.placeTitle} — ${_n(context, x.steps)} · ${l.distance(x.distanceM)} · ${l.duration(x.duration(s.generatedAt))}';
    return StatsSection(title: l.statsHunts, icon: Icons.explore_outlined, children: [
      StatGrid(tiles: [
        StatTile(label: l.statsHuntsTotal, value: '${h.total}', icon: Icons.play_arrow_outlined),
        StatTile(label: l.statsHuntsFound, value: '${h.found}', icon: Icons.check_circle_outline),
        StatTile(label: l.statsHuntsAbandoned, value: '${h.abandoned}', icon: Icons.cancel_outlined),
        StatTile(label: l.statsSuccessRate, value: '${(h.successRate * 100).round()}%', icon: Icons.percent),
        StatTile(label: l.statsAvgStepsHunt, value: _n(context, h.avgSteps.round()), icon: Icons.directions_walk),
        StatTile(label: l.statsAvgDistanceHunt, value: l.distance(h.avgDistanceM), icon: Icons.route),
        StatTile(label: l.statsAvgTimeHunt, value: l.duration(h.avgDuration), icon: Icons.timer_outlined),
        StatTile(label: l.statsTotalHuntSteps, value: _n(context, h.totalSteps), icon: Icons.stacked_line_chart),
        StatTile(
          label: l.statsDetour,
          value: h.avgDetourRatio == null ? l.noData : '×${h.avgDetourRatio!.toStringAsFixed(2)}',
          icon: Icons.alt_route,
          hint: l.statsDetourHint,
        ),
      ]),
      if (h.fewestSteps != null) ...[
        const SizedBox(height: 12),
        _record(context, Icons.arrow_downward, l.statsFewestSteps, huntLine(h.fewestSteps!)),
        _record(context, Icons.arrow_upward, l.statsMostSteps, huntLine(h.mostSteps!)),
        _record(context, Icons.bolt, l.statsFastest, huntLine(h.fastest!)),
      ],
      if (h.recent.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(l.statsRecentHunts, style: Theme.of(context).textTheme.titleSmall),
        for (final x in h.recent)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              switch (x.status) {
                HuntStatus.found => Icons.check_circle,
                HuntStatus.abandoned => Icons.cancel_outlined,
                HuntStatus.active => Icons.explore,
              },
              color: x.status == HuntStatus.found ? context.gold : context.dim,
            ),
            title: Text(x.placeTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text([
              df.format(x.startedAt),
              switch (x.status) {
                HuntStatus.found => l.huntStatusFound,
                HuntStatus.abandoned => l.huntStatusAbandoned,
                HuntStatus.active => l.huntStatusActive,
              },
              '${_n(context, x.steps)}${x.stepsEstimated ? '≈' : ''} ${l.statsSteps.toLowerCase()}',
              l.distance(x.distanceM),
              l.duration(x.duration(s.generatedAt)),
            ].join(' · ')),
          ),
      ],
    ]);
  }

  Widget _record(BuildContext context, IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: context.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(text: value),
            ])),
          ),
        ]),
      );
}

class _Discoveries extends StatelessWidget {
  const _Discoveries({required this.s});
  final StatsSnapshot s;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final df = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final bySource = s.visitsBySource.entries.toList()..sort((a, b) => a.key.index.compareTo(b.key.index));
    final byCat = s.visitsByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final methodLabel = {
      VisitMethod.qr: (l.methodQr, Icons.qr_code_scanner),
      VisitMethod.geofence: (l.methodGeofence, Icons.gps_fixed),
      VisitMethod.manual: (l.methodManual, Icons.touch_app_outlined),
    };
    return StatsSection(title: l.statsDiscoveries, icon: Icons.account_balance_outlined, children: [
      StatGrid(tiles: [
        StatTile(label: l.statsVisitsTotal, value: '${s.visitsTotal}', icon: Icons.place),
        StatTile(label: l.statsVisitsWeek, value: '${s.visitsThisWeek}', icon: Icons.date_range),
        StatTile(
            label: l.statsStepsPerDiscovery,
            value: s.stepsPerDiscovery == null ? l.noData : _n(context, s.stepsPerDiscovery!.round()),
            icon: Icons.directions_walk),
        StatTile(
            label: l.statsMetersPerDiscovery,
            value: s.metersPerDiscovery == null ? l.noData : l.distance(s.metersPerDiscovery!),
            icon: Icons.route),
        StatTile(
            label: l.statsExploredArea, value: '${s.exploredKm2.toStringAsFixed(2)} ${l.unitKm2}', icon: Icons.grid_on),
        StatTile(label: l.statsOldestYear, value: s.oldestVisitedYear?.toString() ?? l.noData, icon: Icons.history_edu),
      ]),
      if (s.firstVisit != null) ...[
        const SizedBox(height: 10),
        Text('${l.statsFirstDiscovery}: ${s.firstVisit!.title} (${df.format(s.firstVisit!.at)})',
            style: Theme.of(context).textTheme.bodySmall),
        Text('${l.statsLastDiscovery}: ${s.lastVisit!.title} (${df.format(s.lastVisit!.at)})',
            style: Theme.of(context).textTheme.bodySmall),
      ],
      if (bySource.isNotEmpty) ...[
        const SizedBox(height: 14),
        Text(l.statsBySource, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        BreakdownBars(items: [
          for (final e in bySource)
            BreakdownItem(label: e.key.label(l), value: e.value, icon: e.key.icon, color: e.key.color),
        ]),
      ],
      if (byCat.isNotEmpty) ...[
        const SizedBox(height: 14),
        Text(l.statsByCategory, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        BreakdownBars(items: [
          for (final e in byCat) BreakdownItem(label: e.key.label(l), value: e.value, icon: e.key.icon),
        ]),
      ],
      if (s.visitsByMethod.isNotEmpty) ...[
        const SizedBox(height: 14),
        Text(l.statsByMethod, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        BreakdownBars(items: [
          for (final e in s.visitsByMethod.entries)
            BreakdownItem(label: methodLabel[e.key]!.$1, value: e.value, icon: methodLabel[e.key]!.$2),
        ]),
      ],
      if (s.visitsTotal == 0) ...[
        const SizedBox(height: 8),
        Text(l.statsEmpty, style: Theme.of(context).textTheme.bodySmall),
      ],
    ]);
  }
}

class _Engagement extends StatelessWidget {
  const _Engagement({required this.s});
  final StatsSnapshot s;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StatsSection(title: l.statsEngagement, icon: Icons.auto_stories_outlined, children: [
      StatGrid(tiles: [
        StatTile(label: l.statsScans, value: '${s.scans}', icon: Icons.qr_code_scanner),
        StatTile(label: l.statsUniqueScans, value: '${s.uniqueScans}', icon: Icons.qr_code_2),
        StatTile(label: l.statsViews, value: '${s.views}', icon: Icons.menu_book_outlined),
        StatTile(label: l.statsUniqueViews, value: '${s.uniqueViews}', icon: Icons.chrome_reader_mode_outlined),
        StatTile(label: l.statsFavorites, value: '${s.favorites}', icon: Icons.favorite_outline),
        StatTile(label: l.statsUserPlaces, value: '${s.userPlaces}', icon: Icons.add_location_alt_outlined),
        StatTile(label: l.statsPlacesLoaded, value: _n(context, s.placesLoaded), icon: Icons.cloud_download_outlined),
        StatTile(label: l.statsExploredCells, value: '${s.exploredCells}', icon: Icons.grid_4x4),
      ]),
    ]);
  }
}

class _Achievements extends StatelessWidget {
  const _Achievements({required this.s});
  final StatsSnapshot s;

  (String, String, IconData) _text(AppLocalizations l, AchievementId id) => switch (id) {
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final list = s.achievements.toList()..sort((a, b) => (b.unlocked ? 1 : 0).compareTo(a.unlocked ? 1 : 0));
    return StatsSection(
      title: l.statsAchievements('${s.unlockedAchievements}', '${s.achievements.length}'),
      icon: Icons.workspace_premium_outlined,
      children: [
        for (final a in list)
          Builder(builder: (context) {
            final (title, desc, icon) = _text(l, a.id);
            final color = a.unlocked ? context.gold : context.dim;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: a.unlocked ? context.goldContainer : Colors.transparent,
                    border: Border.all(color: color),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: context.onBg)),
                    Text(desc, style: Theme.of(context).textTheme.bodySmall),
                    if (!a.unlocked) ...[
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: a.ratio,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                        color: context.gold,
                        backgroundColor: context.outlineVar.withValues(alpha: 0.3),
                      ),
                    ],
                  ]),
                ),
                if (a.unlocked) Icon(Icons.check, color: context.gold),
              ]),
            );
          }),
      ],
    );
  }
}
