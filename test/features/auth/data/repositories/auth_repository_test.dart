import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:qstory/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:qstory/features/auth/domain/entities/user_entity.dart';
import 'package:qstory/core/errors/failures.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([AuthLocalDataSource])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  test('should login successfully with correct credentials', () async {
    // arrange
    when(mockLocalDataSource.saveToken(any)).thenAnswer((_) async {});

    // act
    final result = await repository.login('user@example.com', 'password');

    // assert
    expect(result, isA<UserEntity>());
    expect(result.email, 'user@example.com');
    verify(mockLocalDataSource.saveToken(any));
  });

  test('should throw ServerFailure with incorrect credentials', () async {
    // act & assert
    expect(
      () => repository.login('wrong@example.com', 'password'),
      throwsA(isA<ServerFailure>()),
    );
    verifyNever(mockLocalDataSource.saveToken(any));
  });

  test('should return true if token exists', () async {
    // arrange
    when(mockLocalDataSource.getToken()).thenAnswer((_) async => 'token');

    // act
    final result = await repository.isLoggedIn();

    // assert
    expect(result, true);
  });

  test('should return false if token does not exist', () async {
    // arrange
    when(mockLocalDataSource.getToken()).thenAnswer((_) async => null);

    // act
    final result = await repository.isLoggedIn();

    // assert
    expect(result, false);
  });
}
