import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/util/geo.dart';

void main() {
  group('Geo.distanceM', () {
    test('zero for the same point', () {
      expect(Geo.distanceM(59.93, 30.33, 59.93, 30.33), 0);
    });

    test('one degree of latitude is ~111 km', () {
      expect(Geo.distanceM(0, 0, 1, 0), closeTo(111195, 50));
    });

    test('is symmetric', () {
      final a = Geo.distanceM(55.75, 37.62, 59.94, 30.31);
      final b = Geo.distanceM(59.94, 30.31, 55.75, 37.62);
      expect(a, closeTo(b, 1e-6));
    });

    test('Moscow → Saint Petersburg ≈ 634 km', () {
      expect(Geo.distanceM(55.7558, 37.6173, 59.9343, 30.3351) / 1000, closeTo(634, 3));
    });

    test('antipodes stay finite (≈ half the circumference)', () {
      expect(Geo.distanceM(0, 0, 0, 180), closeTo(20015087, 100));
    });
  });

  group('Geo.bearingDeg', () {
    test('cardinal directions', () {
      expect(Geo.bearingDeg(0, 0, 1, 0), closeTo(0, 1e-9));
      expect(Geo.bearingDeg(0, 0, 0, 1), closeTo(90, 1e-9));
      expect(Geo.bearingDeg(0, 0, -1, 0), closeTo(180, 1e-9));
      expect(Geo.bearingDeg(0, 0, 0, -1), closeTo(270, 1e-9));
    });

    test('always within [0, 360)', () {
      for (final (lat, lon) in [(10.0, -10.0), (-5.0, -5.0), (3.0, 179.0), (-80.0, 20.0)]) {
        final b = Geo.bearingDeg(0, 0, lat, lon);
        expect(b, greaterThanOrEqualTo(0));
        expect(b, lessThan(360));
      }
    });
  });

  group('Geo.cellKey', () {
    test('points a few metres apart share a cell', () {
      expect(Geo.cellKey(59.93431, 30.33511), Geo.cellKey(59.93432, 30.33512));
    });

    test('points ~1 km apart are in different cells', () {
      expect(Geo.cellKey(59.9343, 30.3351), isNot(Geo.cellKey(59.9433, 30.3351)));
    });

    test('larger cells merge more points', () {
      final a = Geo.cellKey(59.9343, 30.3351, cellM: 5000);
      final b = Geo.cellKey(59.9363, 30.3371, cellM: 5000);
      expect(a, b);
    });

    test('format is row:col', () {
      expect(Geo.cellKey(1, 1), matches(RegExp(r'^-?\d+:-?\d+$')));
    });
  });

  test('tileKey rounds coordinates', () {
    expect(Geo.tileKey(59.93431, 30.33511), '59.93,30.34');
    expect(Geo.tileKey(59.93431, 30.33511, decimals: 3), '59.934,30.335');
  });

  group('formatDistance', () {
    test('metres under 1 km', () {
      expect(formatDistance(0), '0 m');
      expect(formatDistance(849.6), '850 m');
    });

    test('kilometres with 2 decimals under 10 km, 1 above', () {
      expect(formatDistance(1234), '1.23 km');
      expect(formatDistance(12345), '12.3 km');
    });

    test('custom units', () {
      expect(formatDistance(500, m: 'м', km: 'км'), '500 м');
      expect(formatDistance(2500, m: 'м', km: 'км'), '2.50 км');
    });
  });

  group('formatDuration', () {
    test('seconds, minutes, hours', () {
      expect(formatDuration(const Duration(seconds: 45)), '45 s');
      expect(formatDuration(const Duration(minutes: 12, seconds: 59)), '12 min');
      expect(formatDuration(const Duration(hours: 1, minutes: 5)), '1 h 05 min');
    });

    test('custom units', () {
      expect(formatDuration(const Duration(hours: 2), h: 'ч', min: 'мин'), '2 ч 00 мин');
    });
  });

  group('formatChange', () {
    test('positive, negative and zero', () {
      expect(formatChange(0.254), '+25%');
      expect(formatChange(-0.1), '−10%');
      expect(formatChange(0.001), '±0%');
    });

    test('large growth', () {
      expect(formatChange(3), '+300%');
    });
  });
}
