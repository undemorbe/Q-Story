import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/notification_service.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Observer(
        builder: (_) {
          return ListView(
            children: [
              _buildSectionHeader(context, 'Внешний вид'),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Тема'),
                subtitle: Text(_getThemeModeName(_store.themeMode)),
                onTap: () {
                  _showThemeDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Язык'),
                subtitle: Text(_getLanguageName(_store.locale)),
                onTap: () {
                  _showLanguageDialog(context);
                },
              ),
              const Divider(),
              _buildSectionHeader(context, 'Уведомления'),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Уведомления'),
                subtitle: const Text('Настройте ежедневные исторические уведомления'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                secondary: const Icon(Icons.notifications_active),
                title: const Text('Push-уведомления'),
                subtitle: const Text('Получайте ежедневные исторические факты'),
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
                leading: const Icon(Icons.notification_important),
                title: const Text('Проверить уведомление'),
                subtitle: const Text('Отправить тестовое уведомление сейчас'),
                onTap: () async {
                  await NotificationService.showTestNotification();
                },
              ),
              const Divider(),
              _buildSectionHeader(context, 'Предпочтения'),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.data_usage),
                title: const Text('Экономия трафика'),
                subtitle: const Text('Снижайте качество изображений'),
                value: _store.dataSaverEnabled,
                onChanged: (bool? value) {
                  if (value != null) {
                    _store.toggleDataSaver(value);
                  }
                },
              ),
              const Divider(),
              _buildSectionHeader(context, 'Данные'),
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('Экспорт данных'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Данные экспортированы успешно')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: const Text('Импорт данных'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Данные импортированы успешно')),
                  );
                },
              ),
              const Divider(),
              _buildSectionHeader(context, 'О приложении'),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('О приложении'),
                subtitle: const Text('Версия 1.0.0'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'QStory',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 QStory Inc.',
                    children: [
                      const Text('Политика конфиденциальности: https://qstory.com/privacy'),
                      const Text('Условия использования: https://qstory.com/terms'),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Системная';
      case ThemeMode.light:
        return 'Светлая';
      case ThemeMode.dark:
        return 'Темная';
    }
  }

  String _getLanguageName(Locale locale) {
    if (locale.languageCode == 'en') return 'English';
    if (locale.languageCode == 'es') return 'Español';
    return locale.languageCode;
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SimpleDialog(
          title: const Text('Выберите тему'),
          children: ThemeMode.values.map((mode) {
            return ListTile(
              title: Text(_getThemeModeName(mode)),
              leading: Radio<ThemeMode>(
                value: mode,
                groupValue: _store.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    _store.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
              ),
              onTap: () {
                _store.setThemeMode(mode);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SimpleDialog(
          title: const Text('Выберите язык'),
          children: const [
            Locale('en'),
            Locale('es'),
          ].map((locale) {
            return ListTile(
              title: Text(_getLanguageName(locale)),
              leading: Radio<Locale>(
                value: locale,
                groupValue: _store.locale,
                onChanged: (value) {
                  if (value != null) {
                    _store.setLocale(value);
                    Navigator.pop(context);
                  }
                },
              ),
              onTap: () {
                _store.setLocale(locale);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
