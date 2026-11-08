// Fonts are bundled and runtime fetching is off, so every family/weight the
// code asks for must exist in assets/google_fonts; otherwise the text would
// silently fall back to the system font on devices.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qstory/core/theme/app_fonts.dart';

const _dir = 'assets/google_fonts';

String _variant(FontWeight w, FontStyle s) {
  final base = switch (w.value) {
    500 => 'Medium',
    600 => 'SemiBold',
    700 => 'Bold',
    _ => 'Regular',
  };
  if (s == FontStyle.italic) return base == 'Regular' ? 'Italic' : '${base}Italic';
  return base;
}

/// Every `AppFonts.x(...)` call in lib/, as (method, weight, style).
Set<(String, FontWeight?, FontStyle)> _callsInSource() {
  final calls = <(String, FontWeight?, FontStyle)>{};
  final weights = {'w500': FontWeight.w500, 'w600': FontWeight.w600, 'w700': FontWeight.w700, 'bold': FontWeight.w700};
  for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
    final s = f.readAsStringSync();
    for (final m in RegExp(r'AppFonts\.(display|body|logo)\(').allMatches(s)) {
      var depth = 1, j = m.end;
      while (depth > 0) {
        if (s[j] == '(') depth++;
        if (s[j] == ')') depth--;
        j++;
      }
      final args = s.substring(m.end, j - 1);
      final w = RegExp(r'fontWeight: FontWeight\.(\w+)').firstMatch(args)?.group(1);
      expect(w == null || weights.containsKey(w), isTrue, reason: '${f.path}: unbundled weight $w');
      calls.add((
        m.group(1)!,
        w == null ? null : weights[w],
        args.contains('FontStyle.italic') ? FontStyle.italic : FontStyle.normal,
      ));
    }
  }
  return calls;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const defaults = {'display': FontWeight.w600, 'body': FontWeight.w500, 'logo': FontWeight.w700};
  const families = {'display': 'CormorantSC', 'body': 'CormorantGaramond', 'logo': 'CinzelDecorative'};

  test('every font variant used in the code is bundled', () {
    final calls = _callsInSource();
    expect(calls, isNotEmpty);
    for (final (method, weight, style) in calls) {
      final file = '$_dir/${families[method]}-${_variant(weight ?? defaults[method]!, style)}.ttf';
      expect(File(file).existsSync(), isTrue, reason: 'AppFonts.$method needs $file');
    }
  });

  test('no bundled font file is unused', () {
    final used = {
      for (final (method, weight, style) in _callsInSource())
        '${families[method]}-${_variant(weight ?? defaults[method]!, style)}.ttf',
    };
    final bundled = Directory(_dir).listSync().map((e) => e.uri.pathSegments.last).where((n) => n.endsWith('.ttf'));
    for (final f in bundled) {
      expect(used, contains(f), reason: '$f is shipped but never used');
    }
  });

  test('each bundled family has its OFL text registered in main.dart', () {
    final main = File('lib/main.dart').readAsStringSync();
    for (final family in families.values) {
      final ofl = 'OFL-$family.txt';
      expect(File('$_dir/$ofl').existsSync(), isTrue, reason: ofl);
      expect(main, contains(ofl));
    }
  });

  test('the styles use the expected families and defaults', () {
    expect(AppFonts.display().fontFamily, startsWith('CormorantSC'));
    expect(AppFonts.display().fontWeight, FontWeight.w600);
    expect(AppFonts.body().fontFamily, startsWith('CormorantGaramond'));
    expect(AppFonts.body().fontWeight, FontWeight.w500);
    expect(AppFonts.logo().fontFamily, startsWith('CinzelDecorative'));
  });

  test('fonts load from the bundled assets without the network', () async {
    await expectLater(
      GoogleFonts.pendingFonts([
        AppFonts.display(),
        AppFonts.display(fontWeight: FontWeight.w500),
        AppFonts.display(fontWeight: FontWeight.w700),
        AppFonts.body(),
        AppFonts.body(fontStyle: FontStyle.italic),
        AppFonts.logo(),
      ]),
      completes,
    );
  });
}
