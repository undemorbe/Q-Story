import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/errors/failures.dart';

void main() {
  group('Failures', () {
    group('NetworkFailure', () {
      test('creates with default message', () {
        final failure = NetworkFailure();

        expect(failure.message, 'Нет соединения');
        expect(failure.toString(), 'Нет соединения');
      });

      test('creates with custom message', () {
        final failure = NetworkFailure('Custom network error');

        expect(failure.message, 'Custom network error');
      });
    });

    group('ServerFailure', () {
      test('creates with message and optional status code', () {
        final failure = ServerFailure('Server error', statusCode: 500);

        expect(failure.message, 'Server error');
        expect(failure.statusCode, 500);
      });

      test('status code is optional', () {
        final failure = ServerFailure('Error without code');

        expect(failure.message, 'Error without code');
        expect(failure.statusCode, null);
      });

      test('handles various status codes', () {
        expect(ServerFailure('Bad request', statusCode: 400).statusCode, 400);
        expect(ServerFailure('Unauthorized', statusCode: 401).statusCode, 401);
        expect(ServerFailure('Not found', statusCode: 404).statusCode, 404);
        expect(ServerFailure('Server error', statusCode: 503).statusCode, 503);
      });
    });

    group('NotFoundFailure', () {
      test('creates with default message', () {
        final failure = NotFoundFailure();

        expect(failure.message, 'Не найдено');
      });

      test('creates with custom message', () {
        final failure = NotFoundFailure('User not found');

        expect(failure.message, 'User not found');
      });
    });

    group('ValidationFailure', () {
      test('requires explicit message', () {
        final failure = ValidationFailure('Invalid email format');

        expect(failure.message, 'Invalid email format');
      });

      test('preserves exact message', () {
        const msg = 'Field "username" is required and must be 3-20 chars';
        final failure = ValidationFailure(msg);

        expect(failure.message, msg);
      });
    });

    group('CacheFailure', () {
      test('creates with default message', () {
        final failure = CacheFailure();

        expect(failure.message, 'Ошибка локального хранилища');
      });

      test('creates with custom message', () {
        final failure = CacheFailure('Cache corrupted');

        expect(failure.message, 'Cache corrupted');
      });
    });

    group('UnknownFailure', () {
      test('creates with default message', () {
        final failure = UnknownFailure();

        expect(failure.message, 'Неизвестная ошибка');
        expect(failure.cause, null);
      });

      test('creates with custom message and cause', () {
        final error = Exception('Root cause');
        final failure = UnknownFailure('Wrapped error', error);

        expect(failure.message, 'Wrapped error');
        expect(failure.cause, error);
      });

      test('stores arbitrary cause objects', () {
        final failure1 = UnknownFailure('Error', 'string cause');
        final failure2 = UnknownFailure('Error', 123);
        final failure3 = UnknownFailure('Error', {'key': 'value'});

        expect(failure1.cause, 'string cause');
        expect(failure2.cause, 123);
        expect(failure3.cause, {'key': 'value'});
      });
    });

    group('Failure base class', () {
      test('sealed prevents external extensions', () {
        // This is enforced by analyzer, just verify known subclasses exist
        expect(NetworkFailure(), isA<Failure>());
        expect(ServerFailure('msg'), isA<Failure>());
        expect(NotFoundFailure(), isA<Failure>());
        expect(ValidationFailure('msg'), isA<Failure>());
        expect(CacheFailure(), isA<Failure>());
        expect(UnknownFailure(), isA<Failure>());
      });

      test('toString returns message', () {
        final failures = [
          NetworkFailure('offline'),
          ServerFailure('error'),
          NotFoundFailure('missing'),
          ValidationFailure('invalid'),
          CacheFailure('corrupted'),
          UnknownFailure('mystery'),
        ];

        for (final f in failures) {
          expect(f.toString(), f.message);
        }
      });

      test('message immutability after construction', () {
        final failure = NetworkFailure('initial');

        expect(failure.message, 'initial');
        // Message is final, so this would be compile error if attempted:
        // failure.message = 'changed'; // ← compiler error
      });
    });

    group('pattern matching', () {
      test('exhaustive switch on all failure types', () {
        final failures = <Failure>[
          NetworkFailure(),
          ServerFailure('msg'),
          NotFoundFailure(),
          ValidationFailure('msg'),
          CacheFailure(),
          UnknownFailure(),
        ];

        for (final f in failures) {
          final matched = switch (f) {
            NetworkFailure() => 'network',
            ServerFailure(:final statusCode) =>
              statusCode != null ? 'server-with-code' : 'server',
            NotFoundFailure() => 'notfound',
            ValidationFailure() => 'validation',
            CacheFailure() => 'cache',
            UnknownFailure() => 'unknown',
          };

          expect(matched, isNotEmpty);
        }
      });
    });
  });
}
