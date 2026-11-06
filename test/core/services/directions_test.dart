import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/services/directions.dart';

void main() {
  group('Directions.uris', () {
    test('Android: geo: intent first with label, then OSM web', () {
      final uris = Directions.uris(lat: 59.9343, lon: 30.3351, label: 'Дом Зингера', platform: TargetPlatform.android);
      expect(uris, hasLength(2));
      expect(uris.first.scheme, 'geo');
      expect(uris.first.toString(), startsWith('geo:59.934300,30.335100?q=59.934300,30.335100('));
      expect(uris.first.toString(), contains(Uri.encodeComponent('Дом Зингера')));
      expect(uris.last.host, 'www.openstreetmap.org');
    });

    test('Android without label omits the parentheses', () {
      final uri = Directions.uris(lat: 1, lon: 2, platform: TargetPlatform.android).first;
      expect(uri.toString(), 'geo:1.000000,2.000000?q=1.000000,2.000000');
    });

    test('iOS: Apple Maps walking directions', () {
      final uri = Directions.uris(lat: 1, lon: 2, label: 'X', platform: TargetPlatform.iOS).first;
      expect(uri.host, 'maps.apple.com');
      expect(uri.queryParameters['daddr'], '1.000000,2.000000');
      expect(uri.queryParameters['dirflg'], 'w');
      expect(uri.queryParameters['q'], 'X');
    });

    test('other platforms: only the web route, on foot', () {
      final uris = Directions.uris(lat: 1, lon: 2, platform: TargetPlatform.linux);
      expect(uris, hasLength(1));
      expect(uris.single.path, '/directions');
      expect(uris.single.queryParameters['engine'], contains('foot'));
      expect(uris.single.queryParameters['route'], ';1.000000,2.000000');
    });
  });

  group('openDirections', () {
    test('stops at the first link that opens', () async {
      final tried = <Uri>[];
      final ok = await openDirections(
        lat: 1,
        lon: 2,
        platform: TargetPlatform.android,
        open: (u) async {
          tried.add(u);
          return true;
        },
      );
      expect(ok, isTrue);
      expect(tried, hasLength(1));
    });

    test('falls back when an app is missing or throws', () async {
      final tried = <String>[];
      final ok = await openDirections(
        lat: 1,
        lon: 2,
        platform: TargetPlatform.android,
        open: (u) async {
          tried.add(u.scheme);
          if (u.scheme == 'geo') throw Exception('no handler');
          return true;
        },
      );
      expect(ok, isTrue);
      expect(tried, ['geo', 'https']);
    });

    test('returns false when nothing can open the route', () async {
      final ok = await openDirections(lat: 1, lon: 2, platform: TargetPlatform.iOS, open: (_) async => false);
      expect(ok, isFalse);
    });
  });
}
