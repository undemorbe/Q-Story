import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../stores/settings_store.dart';
import 'notification_settings_page.dart';

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
              _buildSectionHeader(context, l10n.notifications),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(l10n.notifications),
                subtitle: Text(l10n.notificationsSubtitle),
                trailing:
                    Icon(Icons.chevron_right, color: context.outlineClr),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsPage(),
                    ),
                  );
                },
              ),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: Text(l10n.pushNotifications),
                subtitle: Text(l10n.pushNotificationsSubtitle),
                value: _store.notificationsEnabled,
                onChanged: (bool? value) async {
                  if (value != null) {
                    _store.toggleNotifications(value);
                    if (value) {
                      await NotificationService.scheduleDailyNotification();
                    } else {
                      await NotificationService.cancelDailyNotification();
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.notification_important_outlined),
                title: Text(l10n.checkNotification),
                subtitle: Text(l10n.checkNotificationSubtitle),
                onTap: () async {
                  await NotificationService.showTestNotification();
                },
              ),
              _buildSectionHeader(context, l10n.preferences),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.data_usage_outlined),
                title: Text(l10n.dataSaver),
                subtitle: Text(l10n.dataSaverSubtitle),
                value: _store.dataSaverEnabled,
                onChanged: (bool? value) {
                  if (value != null) _store.toggleDataSaver(value);
                },
              ),
              _buildSectionHeader(context, l10n.data),
              ListTile(
                leading: const Icon(Icons.file_download_outlined),
                title: Text(l10n.exportData),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.dataExported)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_upload_outlined),
                title: Text(l10n.importData),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.dataImported)),
                  );
                },
              ),
              _buildSectionHeader(context, l10n.about),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.about),
                subtitle: Text(l10n.version),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'QStory',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 QStory Inc.',
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          );
        },
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
            style: GoogleFonts.cinzel(
              color: context.gold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
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
