import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/theme_ext.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationsEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await NotificationService.getNotificationEnabled();
    final time = await NotificationService.getNotificationTime();
    setState(() {
      _notificationsEnabled = enabled;
      _selectedTime = time;
      _isLoading = false;
    });
  }

  Future<void> _selectTime() async {
    final l10n = AppLocalizations.of(context)!;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: l10n.notificationTime,
      confirmText: l10n.ok,
      cancelText: l10n.cancel,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
      await NotificationService.setNotificationTime(picked);
      if (_notificationsEnabled) {
        await NotificationService.scheduleDailyNotification();
      }
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _notificationsEnabled = value);
    await NotificationService.setNotificationEnabled(value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? l10n.notificationsEnabledMsg : l10n.notificationsDisabledMsg,
          ),
        ),
      );
    }
  }

  Future<void> _testNotification() async {
    final l10n = AppLocalizations.of(context)!;
    await NotificationService.showTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.testNotificationSent)),
      );
    }
  }

  String _formatTime() =>
      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gold = context.gold;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifSettingsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.dailyNotificationsTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.dailyNotificationsDesc,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _notificationsEnabled,
                          onChanged: _toggleNotifications,
                        ),
                      ],
                    ),
                    if (_notificationsEnabled) ...[
                      const Divider(height: 24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.schedule, color: gold),
                        title: Text(l10n.notificationTime),
                        subtitle: Text(
                          _formatTime(),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: gold),
                        ),
                        trailing: Icon(Icons.chevron_right,
                            color: context.outlineClr),
                        onTap: _selectTime,
                      ),
                      const SizedBox(height: 4),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:
                            Icon(Icons.notifications_active, color: gold),
                        title: Text(l10n.testNotification),
                        subtitle: Text(l10n.testNotificationDesc),
                        trailing: Icon(Icons.send,
                            size: 16, color: context.outlineClr),
                        onTap: _testNotification,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aboutNotificationsTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.aboutNotificationsText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: gold, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.notificationsWorkInDnd,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (_notificationsEnabled)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.goldContainer,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: context.outlineClr),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.dailyNotificationsActivated(_formatTime()),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: gold),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
