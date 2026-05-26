import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qstory/features/settings/presentation/pages/settings_page.dart';
import '../../../../core/di/service_locator.dart';
import 'help_support_sheet.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../history/presentation/pages/daily_history_page.dart';
import '../../../qr_operations/presentation/stores/qr_store.dart';
import '../../../favorites/presentation/stores/favorites_store.dart';
import '../../../settings/presentation/pages/notification_settings_page.dart';
import '../../../map/presentation/stores/map_store.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final qrStore = getIt<QrStore>();
    final favoritesStore = getIt<FavoritesStore>();
    final mapStore = getIt<MapStore>();
    final l10n = AppLocalizations.of(context)!;
    final gold = context.gold;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: gold.withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 52,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '✦',
                  style: TextStyle(
                    color: gold.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Историк',
                  style: GoogleFonts.cinzelDecorative(
                    color: context.onBg,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'user@qstory.com',
                  style: GoogleFonts.crimsonText(
                    color: context.onBg,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 28),
                const GothicDivider(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        l10n.scanned,
                        qrStore.scanHistory.length.toString(),
                        Icons.qr_code_scanner,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        l10n.favorites,
                        favoritesStore.favoriteItems.length.toString(),
                        Icons.favorite,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        l10n.visited,
                        mapStore.markers
                            .where((m) => m.isCompleted)
                            .length
                            .toString(),
                        Icons.location_on,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const GothicDivider(),
                const SizedBox(height: 8),
                GothicCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(l10n.dailyHistory),
                        subtitle: Text(l10n.dailyHistorySubtitle),
                        trailing: Icon(Icons.chevron_right,
                            color: context.outlineClr),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DailyHistoryPage(),
                            ),
                          );
                        },
                      ),
                      Container(height: 1, color: context.outlineVar),
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined),
                        title: Text(l10n.notifications),
                        subtitle: Text(l10n.notificationsSubtitle),
                        trailing: Icon(Icons.chevron_right,
                            color: context.outlineClr),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NotificationSettingsPage(),
                            ),
                          );
                        },
                      ),
                      Container(height: 1, color: context.outlineVar),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: Text(l10n.helpAndSupport),
                        trailing: Icon(Icons.chevron_right,
                            color: context.outlineClr),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const HelpSupportSheet(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return GothicCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 26, color: context.gold),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cinzelDecorative(
              color: context.onBg,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cinzel(
                color: context.onBg, fontSize: 9, letterSpacing: 0.3),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
