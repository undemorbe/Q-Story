import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/l10n/app_localizations.dart';
import 'package:qstory/core/theme/app_theme.dart';

/// Wraps [child] in a localized, themed app.
Widget testApp(Widget child, {Locale locale = const Locale('en'), bool dark = false}) => MaterialApp(
      locale: locale,
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget child, {Locale locale = const Locale('en'), bool dark = false}) async {
    await pumpWidget(testApp(child, locale: locale, dark: dark));
    await pump();
  }
}
