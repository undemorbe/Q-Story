import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/gothic_widgets.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
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
                    border: Border.all(color: AppColors.primaryGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 52,
                    backgroundImage:
                        NetworkImage('https://i.pravatar.cc/300'),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '✦',
                  style: TextStyle(
                    color: AppColors.primaryGold.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Историк',
                  style: GoogleFonts.cinzelDecorative(
                    color: AppColors.onBackground,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'user@qstory.com',
                  style: GoogleFonts.crimsonText(
                    color: AppColors.onSurface,
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
                        'Сканировано',
                        qrStore.scanHistory.length.toString(),
                        Icons.qr_code_scanner,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Избранное',
                        favoritesStore.favoriteItems.length.toString(),
                        Icons.favorite,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Посещено',
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
                        title: const Text('История дня'),
                        subtitle: const Text('Откройте для себя сегодняшнюю историю'),
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.outline),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DailyHistoryPage(),
                            ),
                          );
                        },
                      ),
                      Container(height: 1, color: AppColors.outlineVariant),
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined),
                        title: const Text('Уведомления'),
                        subtitle: const Text('Настройте ежедневные уведомления'),
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.outline),
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
                      Container(height: 1, color: AppColors.outlineVariant),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('Помощь и поддержка'),
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.outline),
                        onTap: () {},
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
          Icon(icon, size: 26, color: AppColors.primaryGold),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cinzelDecorative(
              color: AppColors.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cinzel(
                color: AppColors.onSurface, fontSize: 9, letterSpacing: 0.3),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
