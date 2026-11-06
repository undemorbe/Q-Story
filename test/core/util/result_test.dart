import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/errors/failures.dart';
import 'package:qstory/core/util/result.dart';

void main() {
  group('Result<T>', () {
    group('Ok', () {
      test('creates Ok with value', () {
        final result = Result<String>.ok('test value');

        expect(result, isA<Ok<String>>());
        expect(result.isOk, true);
        expect(result.isErr, false);
      });

      test('valueOrNull returns value on Ok', () {
        final result = Result<int>.ok(42);

        expect(result.valueOrNull, 42);
      });

      test('failureOrNull returns null on Ok', () {
        final result = Result<String>.ok('success');

        expect(result.failureOrNull, null);
      });

      test('can hold any type', () {
        final resultInt = Result<int>.ok(100);
        final resultList = Result<List<String>>.ok(['a', 'b']);
        final resultMap = Result<Map<String, int>>.ok({'key': 1});

        expect(resultInt.valueOrNull, 100);
        expect(resultList.valueOrNull, ['a', 'b']);
        expect(resultMap.valueOrNull, {'key': 1});
      });
    });

    group('Err', () {
      test('creates Err with failure', () {
        final failure = NetworkFailure('Connection failed');
        final result = Result<String>.err(failure);

        expect(result, isA<Err<String>>());
        expect(result.isOk, false);
        expect(result.isErr, true);
      });

      test('failureOrNull returns failure on Err', () {
        final failure = ServerFailure('500 error', statusCode: 500);
        final result = Result<String>.err(failure);

        expect(result.failureOrNull, failure);
        expect(result.failureOrNull?.message, '500 error');
      });

      test('valueOrNull returns null on Err', () {
        final result = Result<int>.err(NotFoundFailure());

        expect(result.valueOrNull, null);
      });

      test('preserves specific failure types', () {
        final netFailure = NetworkFailure('offline');
        final valFailure = ValidationFailure('invalid input');

        final resultNet = Result<String>.err(netFailure);
        final resultVal = Result<String>.err(valFailure);

        expect(resultNet.failureOrNull, isA<NetworkFailure>());
        expect(resultVal.failureOrNull, isA<ValidationFailure>());
      });
    });

    group('pattern matching', () {
      test('switch exhaustiveness on Ok', () {
        final result = Result<String>.ok('value');

        String matched = switch (result) {
          Ok(value: final v) => 'ok: $v',
          Err() => 'error',
        };

        expect(matched, 'ok: value');
      });

      test('switch exhaustiveness on Err', () {
        final result = Result<String>.err(NetworkFailure());

        String matched = switch (result) {
          Ok(value: final v) => 'ok: $v',
          Err(failure: final f) => 'error: ${f.message}',
        };

        expect(matched.startsWith('error:'), true);
      });
    });

    group('null safety', () {
      test('Ok<int?> can hold null', () {
        final result = Result<int?>.ok(null);

        expect(result.isOk, true);
        expect(result.valueOrNull, null);
      });

      test('distinguishes Ok<null> from Err<int>', () {
        final okNull = Result<int?>.ok(null);
        final errInt = Result<int>.err(UnknownFailure());

        expect(okNull.isOk, true);
        expect(errInt.isErr, true);
      });
    });
  });
}
