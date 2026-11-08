// Guards for things Google Play / App Store review checks, so a release
// isn't rejected for something a test could have caught.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/constants/app_info.dart';

String _read(String path) => File(path).readAsStringSync();

(int, int) _pngSize(String path) {
  final b = ByteData.sublistView(File(path).readAsBytesSync());
  expect(b.getUint32(0), 0x89504E47, reason: '$path is not a PNG');
  return (b.getUint32(16), b.getUint32(20));
}

void main() {
  final pubspec = _read('pubspec.yaml');
  final version = RegExp(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)', multiLine: true).firstMatch(pubspec)!;
  final versionName = version.group(1)!;
  final buildNumber = version.group(2)!;

  group('versions', () {
    test('AppInfo.version matches pubspec', () => expect(AppInfo.version, versionName));

    test('CHANGELOG has a section for the current version', () {
      expect(_read('CHANGELOG.md'), contains('## [$versionName]'));
    });
  });

  group('Android', () {
    final manifest = _read('android/app/src/main/AndroidManifest.xml');
    final gradle = _read('android/app/build.gradle.kts');

    test('no permissions that Play restricts or that the app does not need', () {
      for (final p in [
        'USE_EXACT_ALARM',
        'SCHEDULE_EXACT_ALARM',
        'ACCESS_BACKGROUND_LOCATION',
        'QUERY_ALL_PACKAGES',
        'READ_EXTERNAL_STORAGE',
        'WRITE_EXTERNAL_STORAGE',
        'READ_MEDIA_IMAGES',
        'MANAGE_EXTERNAL_STORAGE',
      ]) {
        expect(manifest, isNot(contains('android.permission.$p')), reason: p);
      }
    });

    test('application id and namespace are the published ones', () {
      expect(gradle, contains('applicationId = "io.github.undemorbe.qstory"'));
      expect(gradle, contains('namespace = "io.github.undemorbe.qstory"'));
    });

    test('release build is minified and not signed with a hard-coded key', () {
      expect(gradle, contains('isMinifyEnabled = true'));
      expect(gradle, isNot(contains('storePassword = "')));
      final ignores = '${_read('.gitignore')}\n${_read('android/.gitignore')}';
      expect(ignores, contains('key.properties'));
      expect(ignores, contains('.jks'));
    });
  });

  group('iOS', () {
    final plist = _read('ios/Runner/Info.plist');

    test('every sensitive API has a usage description', () {
      for (final k in [
        'NSCameraUsageDescription',
        'NSLocationWhenInUseUsageDescription',
        'NSLocationAlwaysAndWhenInUseUsageDescription',
        'NSMotionUsageDescription',
      ]) {
        expect(plist, contains('<key>$k</key>'), reason: k);
      }
    });

    test('the 1024 px App Store icon has no alpha channel', () {
      const icon = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png';
      expect(_pngSize(icon), (1024, 1024));
      // Colour type 2 = RGB without alpha.
      expect(File(icon).readAsBytesSync()[25], 2);
    });
  });

  group('store listing', () {
    const root = 'fastlane/metadata/android';
    for (final locale in ['ru-RU', 'en-US']) {
      group(locale, () {
        String text(String f) => _read('$root/$locale/$f').trimRight();

        test('texts fit Play Console limits', () {
          expect(text('title.txt').length, inInclusiveRange(1, 30));
          expect(text('short_description.txt').length, inInclusiveRange(1, 80));
          expect(text('full_description.txt').length, inInclusiveRange(1, 4000));
        });

        test('release notes exist for the current build and fit 500 chars', () {
          expect(text('changelogs/$buildNumber.txt').length, inInclusiveRange(1, 500));
        });

        test('graphics have the required sizes', () {
          expect(_pngSize('$root/$locale/images/icon.png'), (512, 512));
          expect(_pngSize('$root/$locale/images/featureGraphic.png'), (1024, 500));
          final shots = Directory('$root/$locale/images/phoneScreenshots').listSync().whereType<File>().toList();
          expect(shots.length, inInclusiveRange(2, 8));
          for (final s in shots) {
            final (w, h) = _pngSize(s.path);
            expect(h / w, inInclusiveRange(16 / 9 - 0.01, 2.0), reason: s.path);
          }
        });
      });
    }
  });

  group('privacy', () {
    test('policy file exists and is linked from the app', () {
      expect(File('PRIVACY.md').existsSync(), isTrue);
      expect(AppInfo.privacyPolicyUrl, endsWith('/PRIVACY.md'));
      expect(_read('lib/features/about/presentation/pages/about_page.dart'), contains('privacyPolicyUrl'));
    });
  });
}
