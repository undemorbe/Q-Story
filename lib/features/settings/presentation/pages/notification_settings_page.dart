import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/theme_ext.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _service = getIt<NotificationService>();
  late bool _enabled = _service.enabled;
  late TimeOfDay _time = _service.time;
  bool _busy = false;

  Future<void> _run(Future<void> Function(AppLocalizations l) action) async {
    final l = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await action(l);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _toggle(bool value) => _run((l) async {
    final ok = await _service.setEnabled(value, l);
    if (!ok) return _snack(l.notificationsPermissionDenied);
    setState(() => _enabled = value);
    _snack(value ? l.notificationsEnabledMsg : l.notificationsDisabledMsg);
  });

  Future<void> _pickTime() async {
    final l = AppLocalizations.of(context)!;
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: l.notificationTime,
      confirmText: l.ok,
      cancelText: l.cancel,
    );
    if (picked == null || picked == _time) return;
    setState(() => _time = picked);
    await _run((l) => _service.setTime(picked, l));
  }

  Future<void> _test() => _run((l) async {
    await _service.showTest(l);
    _snack(l.testNotificationSent);
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final gold = context.gold;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(_time, alwaysUse24HourFormat: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.notifSettingsTitle),
        bottom: _busy ? const PreferredSize(preferredSize: Size.fromHeight(2), child: LinearProgressIndicator()) : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _enabled,
                  onChanged: _busy ? null : _toggle,
                  title: Text(l.dailyNotificationsTitle),
                  subtitle: Text(l.dailyNotificationsDesc),
                ),
                if (_enabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.schedule, color: gold),
                    title: Text(l.notificationTime),
                    subtitle: Text(time, style: theme.textTheme.titleMedium?.copyWith(color: gold)),
                    trailing: Icon(Icons.chevron_right, color: context.outlineClr),
                    onTap: _busy ? null : _pickTime,
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications_active, color: gold),
                    title: Text(l.testNotification),
                    subtitle: Text(l.testNotificationDesc),
                    trailing: Icon(Icons.send, size: 16, color: context.outlineClr),
                    onTap: _busy ? null : _test,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.aboutNotificationsTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(l.aboutNotificationsText, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          if (_enabled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.check_circle, color: gold, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(l.dailyNotificationsActivated(time), style: theme.textTheme.bodyMedium)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
