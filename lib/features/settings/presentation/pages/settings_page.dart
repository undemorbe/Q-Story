import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../activity/presentation/stores/tracking_store.dart';
import '../../../places/domain/entities/place_source.dart';
import '../../../places/presentation/stores/places_store.dart';
import '../../../places/presentation/widgets/place_labels.dart';
import '../stores/settings_store.dart';
import 'notification_settings_page.dart';
import '../../../../core/theme/app_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsStore _store = getIt<SettingsStore>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Observer(
        builder: (_) {
          return ListView(
            children: [
              _buildSectionHeader(context, l10n.appearance),
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: Text(l10n.theme),
                subtitle: Text(_getThemeModeName(l10n, _store.themeMode)),
                onTap: () => _showThemeDialog(context, l10n),
              ),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l10n.language),
                subtitle: Text(_getLanguageName(l10n, _store.locale)),
                onTap: () => _showLanguageDialog(context, l10n),
              ),
              _buildSectionHeader(context, l10n.sectionSources),
              for (final src in PlaceSource.remote)
                SwitchListTile.adaptive(
                  secondary: Icon(src.icon, color: src.color),
                  title: Text(src.label(l10n)),
                  subtitle: Text(src.description(l10n)),
                  value: _store.enabledSources.contains(src),
                  onChanged: (v) {
                    _store.toggleSource(src, v);
                    final places = getIt<PlacesStore>();
                    if (places.lastLat != null) places.loadAround(places.lastLat!, places.lastLon!, force: true);
                  },
                ),
              _sliderTile(
                context,
                icon: Icons.radar,
                title: l10n.searchRadius,
                valueLabel: l10n.distance(_store.searchRadiusM.toDouble()),
                value: _store.searchRadiusM.toDouble(),
                min: 300,
                max: 5000,
                divisions: 47,
                onChanged: (v) => _store.setSearchRadiusM((v / 100).round() * 100),
              ),
              _buildSectionHeader(context, l10n.sectionTracking),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.directions_walk),
                title: Text(l10n.autoTracking),
                subtitle: Text(l10n.autoTrackingSubtitle),
                value: _store.autoTracking,
                onChanged: _store.setAutoTracking,
              ),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.nightlight_outlined),
                title: Text(l10n.backgroundTracking),
                subtitle: Text(l10n.backgroundTrackingSubtitle),
                value: _store.backgroundTracking,
                onChanged: (v) async {
                  await _store.setBackgroundTracking(v);
                  await getIt<TrackingStore>().restart();
                },
              ),
              _sliderTile(
                context,
                icon: Icons.flag_outlined,
                title: l10n.dailyGoal,
                valueLabel: '${_store.dailyStepGoal}',
                value: _store.dailyStepGoal.toDouble(),
                min: 1000,
                max: 30000,
                divisions: 58,
                onChanged: (v) => _store.setDailyStepGoal((v / 500).round() * 500),
              ),
              _sliderTile(
                context,
                icon: Icons.straighten,
                title: l10n.stepLength,
                valueLabel: '${_store.stepLengthCm} ${l10n.unitCm}',
                value: _store.stepLengthCm.toDouble(),
                min: 40,
                max: 110,
                divisions: 70,
                onChanged: (v) => _store.setStepLengthCm(v.round()),
              ),
              _sliderTile(
                context,
                icon: Icons.my_location,
                title: l10n.geofenceRadius,
                subtitle: l10n.geofenceRadiusSubtitle,
                valueLabel: '${_store.geofenceRadiusM} ${l10n.unitM}',
                value: _store.geofenceRadiusM.toDouble(),
                min: 15,
                max: 150,
                divisions: 27,
                onChanged: (v) => _store.setGeofenceRadiusM((v / 5).round() * 5),
              ),
              _buildSectionHeader(context, l10n.notifications),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(l10n.notifications),
                subtitle: Text(l10n.notificationsSubtitle),
                trailing: Icon(Icons.chevron_right, color: context.outlineClr),
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsPage())),
              ),
              _buildSectionHeader(context, l10n.about),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.aboutTitle),
                subtitle: Text('${AppInfo.name} ${AppInfo.version}'),
                trailing: Icon(Icons.chevron_right, color: context.outlineClr),
                onTap: () => context.push('/about'),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _sliderTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            valueLabel,
            style: TextStyle(color: context.gold, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) Text(subtitle),
          Slider(value: value.clamp(min, max), min: min, max: max, divisions: divisions, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GothicDivider(),
          const SizedBox(height: 6),
          Text(
            title.toUpperCase(),
            style: AppFonts.display(color: context.gold, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  String _getThemeModeName(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.systemTheme;
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
    }
  }

  String _getLanguageName(AppLocalizations l10n, Locale locale) {
    if (locale.languageCode == 'ru') return l10n.russian;
    return l10n.english;
  }

  void _showThemeDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.chooseTheme),
        children: [
          RadioGroup<ThemeMode>(
            groupValue: _store.themeMode,
            onChanged: (value) {
              if (value != null) {
                _store.setThemeMode(value);
                Navigator.pop(context);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ThemeMode.values.map((mode) {
                return ListTile(
                  title: Text(_getThemeModeName(l10n, mode)),
                  leading: Radio<ThemeMode>(value: mode),
                  onTap: () {
                    _store.setThemeMode(mode);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.selectLanguage),
        children: [
          RadioGroup<String>(
            groupValue: _store.locale.languageCode,
            onChanged: (value) {
              if (value != null) {
                _store.setLocale(Locale(value));
                Navigator.pop(context);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(l10n.russian),
                  leading: const Radio<String>(value: 'ru'),
                  onTap: () {
                    _store.setLocale(const Locale('ru'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(l10n.english),
                  leading: const Radio<String>(value: 'en'),
                  onTap: () {
                    _store.setLocale(const Locale('en'));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
