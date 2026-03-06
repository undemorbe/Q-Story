import '../../../../core/errors/failures.dart';
import '../datasources/auth_local_data_source.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<UserEntity> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (email == 'user@example.com' && password == 'password') {
      final user = UserEntity(id: '1', email: email, username: 'User');
      // Save token if needed, for now just simulation
      await localDataSource.saveToken('dummy_token');
      return user;
    } else {
      throw ServerFailure('Invalid email or password');
    }
  }

  @override
  Future<UserEntity> register(String email, String username, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    return UserEntity(id: '2', email: email, username: username);
  }

  @override
  Future<void> logout() async {
    await localDataSource.deleteToken();
  }

  @override
  Future<bool> checkBiometrics() async {
    return await localDataSource.canCheckBiometrics();
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    return await localDataSource.authenticateWithBiometrics();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getToken();
    return token != null;
  }
}
