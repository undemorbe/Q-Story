import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Thin wrapper around `geolocator` that returns a typed result instead of
/// throwing. UI code can match on the union and show the right snackbar.
class LocationService {
  static const Duration _timeout = Duration(seconds: 10);

  Future<LocationResult> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationResult.disabled();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationResult.denied();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationResult.deniedForever();
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: _timeout,
        ),
      );
      return LocationResult.success(LatLng(pos.latitude, pos.longitude));
    } catch (e) {
      return LocationResult.error(e.toString());
    }
  }
}

sealed class LocationResult {
  const LocationResult();
  factory LocationResult.success(LatLng point) = LocationSuccess;
  factory LocationResult.disabled() = LocationServiceDisabled;
  factory LocationResult.denied() = LocationDenied;
  factory LocationResult.deniedForever() = LocationDeniedForever;
  factory LocationResult.error(String message) = LocationError;
}

class LocationSuccess extends LocationResult {
  final LatLng point;
  const LocationSuccess(this.point);
}

class LocationServiceDisabled extends LocationResult {
  const LocationServiceDisabled();
}

class LocationDenied extends LocationResult {
  const LocationDenied();
}

class LocationDeniedForever extends LocationResult {
  const LocationDeniedForever();
}

class LocationError extends LocationResult {
  final String message;
  const LocationError(this.message);
}
