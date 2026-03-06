import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/features/auth/domain/entities/user_entity.dart';
import 'package:qstory/features/auth/domain/repositories/auth_repository.dart';
import 'package:qstory/features/auth/presentation/stores/auth_store.dart';
import 'package:qstory/core/errors/failures.dart';

import 'auth_store_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late AuthStore store;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    store = AuthStore(mockRepository);
  });

  const tUser = UserEntity(id: '1', email: 'test@example.com');

  test('should login successfully', () async {
    // arrange
    when(mockRepository.login(any, any)).thenAnswer((_) async => tUser);

    // act
    await store.login('test@example.com', 'password');

    // assert
    expect(store.isAuthenticated, true);
    expect(store.isLoading, false);
    expect(store.errorMessage, isNull);
    verify(mockRepository.login('test@example.com', 'password'));
  });

  test('should handle login error', () async {
    // arrange
    when(mockRepository.login(any, any)).thenThrow(ServerFailure('Error'));

    // act
    await store.login('test@example.com', 'password');

    // assert
    expect(store.isAuthenticated, false);
    expect(store.isLoading, false);
    expect(store.errorMessage, contains('Error'));
  });

  test('should logout successfully', () async {
    // arrange
    store.isAuthenticated = true;
    when(mockRepository.logout()).thenAnswer((_) async {});

    // act
    await store.logout();

    // assert
    expect(store.isAuthenticated, false);
    verify(mockRepository.logout());
  });

  test('should check login status', () async {
    // arrange
    when(mockRepository.isLoggedIn()).thenAnswer((_) async => true);

    // act
    await store.checkLoginStatus();

    // assert
    expect(store.isAuthenticated, true);
  });
}
