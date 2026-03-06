import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String username, String password);
  Future<void> logout();
  Future<bool> checkBiometrics();
  Future<bool> authenticateWithBiometrics();
  Future<bool> isLoggedIn();
}
