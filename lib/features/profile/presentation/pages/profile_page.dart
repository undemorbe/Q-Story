import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../activity/presentation/stores/journal_store.dart';
import '../../../activity/presentation/stores/tracking_store.dart';
import '../../../favorites/presentation/stores/favorites_store.dart';
import '../../../history/presentation/pages/daily_history_page.dart';
import '../../../places/presentation/widgets/place_labels.dart';
import '../../../settings/presentation/pages/notification_settings_page.dart';
import 'help_support_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final journal = getIt<JournalStore>();
    final favorites = getIt<FavoritesStore>();
    final tracking = getIt<TrackingStore>();
    final l = AppLocalizations.of(context)!;
    final gold = context.gold;

    Widget navTile(IconData icon, String title, VoidCallback onTap, {String? subtitle}) => ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle),
          trailing: Icon(Icons.chevron_right, color: context.outlineClr),
          onTap: onTap,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profileTitle),
        actions: [IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.push('/settings'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 8),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.goldContainer,
              border: Border.all(color: gold, width: 2),
              boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.25), blurRadius: 20, spreadRadius: 3)],
            ),
            child: Icon(Icons.explore, size: 48, color: gold),
          ),
          const SizedBox(height: 14),
          Text(l.explorerTitle,
              style: GoogleFonts.cinzelDecorative(color: context.onBg, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const GothicDivider(),
          const SizedBox(height: 20),
          Observer(builder: (_) {
            return Row(children: [
              Expanded(child: _stat(context, l.visited, '${journal.visitedIds.length}', Icons.place)),
              const SizedBox(width: 10),
              Expanded(child: _stat(context, l.favorites, '${favorites.items.length}', Icons.favorite)),
              const SizedBox(width: 10),
              Expanded(child: _stat(context, l.statsToday, '${tracking.todaySteps}', Icons.directions_walk)),
            ]);
          }),
          const SizedBox(height: 10),
          Observer(builder: (_) {
            final h = tracking.activeHunt;
            if (h == null) return const SizedBox.shrink();
            return GothicCard(
              child: ListTile(
                leading: Icon(Icons.explore, color: gold),
                title: Text(l.huntSearching(h.placeTitle)),
                subtitle: Text('${h.steps} · ${l.distance(h.distanceM)}'),
                onTap: () => context.go('/map'),
              ),
            );
          }),
          const SizedBox(height: 14),
          GothicCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              navTile(Icons.insights_outlined, l.statsTitle, () => context.go('/stats')),
              Divider(height: 1, color: context.outlineVar),
              navTile(Icons.history, l.dailyHistory, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyHistoryPage()));
              }, subtitle: l.dailyHistorySubtitle),
              Divider(height: 1, color: context.outlineVar),
              navTile(Icons.notifications_outlined, l.notifications, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsPage()));
              }, subtitle: l.notificationsSubtitle),
              Divider(height: 1, color: context.outlineVar),
              navTile(Icons.help_outline, l.helpAndSupport, () {
                showModalBottomSheet(
                    context: context, isScrollControlled: true, builder: (_) => const HelpSupportSheet());
              }),
              Divider(height: 1, color: context.outlineVar),
              navTile(Icons.info_outline, l.aboutTitle, () => context.push('/about')),
            ]),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, IconData icon) {
    return GothicCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(children: [
        Icon(icon, size: 24, color: context.gold),
        const SizedBox(height: 8),
        FittedBox(
          child: Text(value,
              style: GoogleFonts.cinzelDecorative(color: context.onBg, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.cinzel(color: context.onBg, fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}
