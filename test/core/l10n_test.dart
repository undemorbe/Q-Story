import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/l10n/app_localizations.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';
import 'package:qstory/features/places/presentation/widgets/place_labels.dart';
import 'package:qstory/features/stats/domain/stats_snapshot.dart';
import 'package:qstory/features/stats/presentation/widgets/achievement_text.dart';

Map<String, dynamic> arb(String lang) =>
    jsonDecode(File('lib/core/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>;

void main() {
  test('ru and en define the same messages', () {
    Set<String> keys(Map<String, dynamic> m) => m.keys.where((k) => !k.startsWith('@')).toSet();
    final en = keys(arb('en')), ru = keys(arb('ru'));
    expect(en.difference(ru), isEmpty, reason: 'missing in ru');
    expect(ru.difference(en), isEmpty, reason: 'missing in en');
  });

  test('placeholders match between languages', () {
    final en = arb('en'), ru = arb('ru');
    final re = RegExp(r'\{(\w+)[,}]');
    for (final k in en.keys.where((k) => !k.startsWith('@'))) {
      final a = re.allMatches(en[k] as String).map((m) => m[1]).toSet();
      final b = re.allMatches(ru[k] as String).map((m) => m[1]).toSet();
      expect(b, a, reason: k);
    }
  });

  for (final locale in AppLocalizations.supportedLocales) {
    test('every label is translated (${locale.languageCode})', () {
      final l = lookupAppLocalizations(locale);
      for (final id in AchievementId.values) {
        final (title, desc, _) = achievementText(l, id);
        expect(title, isNotEmpty, reason: id.name);
        expect(desc, isNotEmpty, reason: id.name);
      }
      for (final c in PlaceCategory.values) {
        expect(c.label(l), isNotEmpty, reason: c.name);
      }
      for (final s in PlaceSource.values) {
        expect(s.label(l), isNotEmpty);
        expect(s.description(l), isNotEmpty);
      }
    });
  }

  test('units helpers use localized units', () {
    final ru = lookupAppLocalizations(const Locale('ru'));
    expect(ru.distance(500), contains(ru.unitM));
    expect(ru.duration(const Duration(minutes: 3)), contains(ru.unitMin));
  });
}
