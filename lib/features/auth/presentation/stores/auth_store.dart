import 'package:mobx/mobx.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  final AuthRepository _authRepository;

  _AuthStore(this._authRepository);

  @observable
  bool isAuthenticated = false;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool rememberMe = false;

  @action
  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    try {
      await _authRepository.login(email, password);
      isAuthenticated = true;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> register(String email, String username, String password) async {
    isLoading = true;
    errorMessage = null;
    try {
      await _authRepository.register(email, username, password);
      isAuthenticated = true;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      isAuthenticated = false;
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  @action
  Future<void> checkBiometrics() async {
    try {
      final canCheck = await _authRepository.checkBiometrics();
      if (canCheck) {
        final authenticated = await _authRepository.authenticateWithBiometrics();
        if (authenticated) {
          isAuthenticated = true;
        }
      }
    } catch (e) {
      errorMessage = 'Biometric authentication failed: $e';
    }
  }

  @action
  Future<void> checkLoginStatus() async {
    try {
      isAuthenticated = await _authRepository.isLoggedIn();
    } catch (e) {
      isAuthenticated = false;
    }
  }

  @action
  void setRememberMe(bool value) {
    rememberMe = value;
  }
}
