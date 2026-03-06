import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<bool> authenticateWithBiometrics();
  Future<bool> canCheckBiometrics();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final LocalAuthentication localAuth;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.localAuth,
  });

  static const String authTokenKey = 'auth_token';

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: authTokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: authTokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await secureStorage.delete(key: authTokenKey);
  }

  @override
  Future<bool> canCheckBiometrics() async {
    final bool canAuthenticateWithBiometrics = await localAuth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await localAuth.isDeviceSupported();
    if (!canAuthenticate) return false;
    
    final List<BiometricType> availableBiometrics = await localAuth.getAvailableBiometrics();
    return availableBiometrics.isNotEmpty;
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await localAuth.authenticate(
        localizedReason: 'Please authenticate to login',
        // biometricOnly: true, // If available
        // stickyAuth: true,    // If available
      );
    } catch (e) {
      return false;
    }
  }
}
