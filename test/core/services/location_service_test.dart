import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:qstory/core/services/location_service.dart';

void main() {
  group('LocationService', () {
    group('LocationResult sealed types', () {
      test('LocationSuccess holds LatLng point', () {
        final point = LatLng(55.7558, 37.6173);
        final success = LocationResult.success(point);

        expect(success, isA<LocationSuccess>());
        expect((success as LocationSuccess).point, point);
      });

      test('LocationServiceDisabled factory', () {
        final disabled = LocationResult.disabled();

        expect(disabled, isA<LocationServiceDisabled>());
      });

      test('LocationDenied factory', () {
        final denied = LocationResult.denied();

        expect(denied, isA<LocationDenied>());
      });

      test('LocationDeniedForever factory', () {
        final forever = LocationResult.deniedForever();

        expect(forever, isA<LocationDeniedForever>());
      });

      test('LocationError holds error message', () {
        const msg = 'timeout';
        final error = LocationResult.error(msg);

        expect(error, isA<LocationError>());
        expect((error as LocationError).message, msg);
      });
    });

    group('pattern matching on LocationResult', () {
      test('exhaustive switch covers all cases', () {
        final results = <LocationResult>[
          LocationResult.success(LatLng(0, 0)),
          LocationResult.disabled(),
          LocationResult.denied(),
          LocationResult.deniedForever(),
          LocationResult.error('msg'),
        ];

        for (final result in results) {
          final matched = switch (result) {
            LocationSuccess(point: final p) => 'success(${p.latitude})',
            LocationServiceDisabled() => 'disabled',
            LocationDenied() => 'denied',
            LocationDeniedForever() => 'denied-forever',
            LocationError(message: final m) => 'error: $m',
          };

          expect(matched, isNotEmpty);
        }
      });

      test('LocationSuccess extracts coordinates', () {
        final success = LocationResult.success(LatLng(55.7, 37.6));

        final (lat, lon) = switch (success) {
          LocationSuccess(point: final p) => (p.latitude, p.longitude),
          _ => (0.0, 0.0),
        };

        expect(lat, 55.7);
        expect(lon, 37.6);
      });
    });

    group('getCurrentPosition method', () {
      test('method exists and returns Future', () {
        final service = LocationService();

        expect(service.getCurrentPosition, isNotNull);
        expect(service.getCurrentPosition(), isA<Future<LocationResult>>());
      });
    });
  });
}
