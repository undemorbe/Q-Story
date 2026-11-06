import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import 'core/di/service_locator.dart';
import 'core/l10n/app_localizations.dart';
import 'core/navigation/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/activity/presentation/stores/tracking_store.dart';
import 'features/settings/presentation/stores/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();

  await NotificationService.initialize();
  if (await NotificationService.getNotificationEnabled()) {
    await NotificationService.scheduleDailyNotification();
  }

  runApp(QStoryApp(router: buildRouter()));
}

class QStoryApp extends StatefulWidget {
  const QStoryApp({super.key, required this.router});
  final GoRouter router;

  @override
  State<QStoryApp> createState() => _QStoryAppState();
}

class _QStoryAppState extends State<QStoryApp> with WidgetsBindingObserver {
  bool _resumeTracking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final tracking = getIt<TrackingStore>();
    final settings = getIt<SettingsStore>();
    if (state == AppLifecycleState.paused) {
      // Always persist; stop sensors unless background tracking is on.
      tracking.flush();
      if (!settings.backgroundTracking && tracking.isTracking) {
        _resumeTracking = true;
        tracking.stop();
      }
    } else if (state == AppLifecycleState.resumed && _resumeTracking) {
      _resumeTracking = false;
      tracking.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = getIt<SettingsStore>();
    return Observer(
      builder: (_) => MaterialApp.router(
        title: 'QStory',
        debugShowCheckedModeBanner: false,
        routerConfig: widget.router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: settings.locale,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settings.themeMode,
      ),
    );
  }
}
