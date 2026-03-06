import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../stores/settings_store.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsStore = getIt<SettingsStore>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settings,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.selectLanguage,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Observer(
            builder: (_) {
              return StatefulBuilder(
                builder: (context, setState) => Column(
                  children: [
                    ListTile(
                      title: const Text('English'),
                      leading: Radio<String>(
                        value: 'en',
                        groupValue: settingsStore.locale.languageCode,
                        onChanged: (value) {
                          if (value != null) {
                            settingsStore.setLocale(Locale(value));
                            Navigator.pop(context);
                          }
                        },
                      ),
                      onTap: () {
                        settingsStore.setLocale(const Locale('en'));
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Español'),
                      leading: Radio<String>(
                        value: 'es',
                        groupValue: settingsStore.locale.languageCode,
                        onChanged: (value) {
                          if (value != null) {
                            settingsStore.setLocale(Locale(value));
                            Navigator.pop(context);
                          }
                        },
                      ),
                      onTap: () {
                        settingsStore.setLocale(const Locale('es'));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
