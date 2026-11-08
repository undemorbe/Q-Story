import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobx/mobx.dart';

import 'core/di/service_locator.dart';
import 'core/l10n/app_localizations.dart';
import 'core/navigation/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/activity/presentation/stores/tracking_store.dart';
import 'features/settings/presentation/stores/settings_store.dart';
import 'features/stats/domain/milestones.dart';
import 'features/stats/presentation/stores/milestone_service.dart';
import 'features/stats/presentation/widgets/achievement_text.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts ship in assets/google_fonts: no network request to Google.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(_fontLicenses);
  await setupServiceLocator();

  runApp(QStoryApp(router: buildRouter()));
  unawaited(_initReminders());
}

/// Sets up local notifications and re-plans the coming week of reminders.
/// Never asks for permission here; that happens when the user enables them.
Future<void> _initReminders() async {
  try {
    final service = getIt<NotificationService>();
    await service.init();
    await service.reschedule(_currentL10n());
  } catch (e, st) {
    debugPrint('Reminder setup failed: $e\n$st');
  }
}

AppLocalizations _currentL10n() {
  final code = getIt<SettingsStore>().locale.languageCode;
  final supported = AppLocalizations.supportedLocales.map((l) => l.languageCode);
  return lookupAppLocalizations(Locale(supported.contains(code) ? code : 'en'));
}

Stream<LicenseEntry> _fontLicenses() async* {
  for (final (family, file) in [
    ('Cinzel Decorative', 'OFL-CinzelDecorative.txt'),
    ('Cormorant Garamond', 'OFL-CormorantGaramond.txt'),
    ('Cormorant SC', 'OFL-CormorantSC.txt'),
  ]) {
    yield LicenseEntryWithLineBreaks([family], await rootBundle.loadString('assets/google_fonts/$file'));
  }
}

class QStoryApp extends StatefulWidget {
  const QStoryApp({super.key, required this.router});
  final GoRouter router;

  @override
  State<QStoryApp> createState() => _QStoryAppState();
}

class _QStoryAppState extends State<QStoryApp> with WidgetsBindingObserver {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<Milestone>? _milestones;
  ReactionDisposer? _localeReaction;
  bool _resumeTracking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _milestones = getIt<MilestoneService>().milestones.listen(_celebrate);
    // Reminder texts follow the app language.
    _localeReaction = reaction<Locale>((_) => getIt<SettingsStore>().locale, (_) {
      if (getIt.isRegistered<NotificationService>() && getIt<NotificationService>().enabled) {
        unawaited(
          getIt<NotificationService>().reschedule(_currentL10n()).catchError((Object e) {
            debugPrint('Reminder reschedule failed: $e');
          }),
        );
      }
    });
  }

  @override
  void dispose() {
    _milestones?.cancel();
    _localeReaction?.call();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _celebrate(Milestone m) {
    final messenger = _messengerKey.currentState;
    final ctx = _messengerKey.currentContext;
    if (messenger == null || ctx == null) return;
    final l = AppLocalizations.of(ctx)!;
    final (icon, text) = switch (m) {
      GoalReached(:final goal) => (Icons.flag, l.milestoneGoal('$goal')),
      AchievementUnlocked(:final id) => (Icons.workspace_premium, l.milestoneAchievement(achievementText(l, id).$1)),
    };
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(icon, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
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
        scaffoldMessengerKey: _messengerKey,
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
