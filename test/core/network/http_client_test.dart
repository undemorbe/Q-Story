import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/constants/app_info.dart';
import 'package:qstory/core/errors/failures.dart';
import 'package:qstory/core/network/http_client.dart';

DioException dioError(DioExceptionType type, {int? status}) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    type: type,
    response: status == null ? null : Response(requestOptions: req, statusCode: status),
    message: 'boom',
  );
}

void main() {
  group('createHttpClient', () {
    test('identifies itself with a User-Agent and accepts JSON', () {
      final dio = createHttpClient();
      expect(dio.options.headers['User-Agent'], AppInfo.userAgent);
      expect(dio.options.headers['Accept'], 'application/json');
    });

    test('applies the timeout to connect and receive', () {
      final dio = createHttpClient(timeout: const Duration(seconds: 3));
      expect(dio.options.connectTimeout, const Duration(seconds: 3));
      expect(dio.options.receiveTimeout, const Duration(seconds: 3));
    });

    test('User-Agent points at the repository (Wikimedia/OSM policy)', () {
      expect(AppInfo.userAgent, contains('QStory/'));
      expect(AppInfo.userAgent, contains(AppInfo.repositoryUrl));
    });
  });

  group('toFailure', () {
    test('passes failures through', () {
      const f = NotFoundFailure();
      expect(identical(toFailure(f), f), isTrue);
    });

    test('timeouts and connection errors are network failures', () {
      for (final t in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        expect(toFailure(dioError(t)), isA<NetworkFailure>(), reason: t.name);
      }
    });

    test('404 → not found, other statuses → server failure with code', () {
      expect(toFailure(dioError(DioExceptionType.badResponse, status: 404)), isA<NotFoundFailure>());
      final f = toFailure(dioError(DioExceptionType.badResponse, status: 503));
      expect(f, isA<ServerFailure>());
      expect((f as ServerFailure).statusCode, 503);
      expect(f.message, contains('503'));
    });

    test('cancel and unknown → unknown failure', () {
      expect(toFailure(dioError(DioExceptionType.cancel)), isA<UnknownFailure>());
      expect(toFailure(dioError(DioExceptionType.unknown)), isA<UnknownFailure>());
      expect(toFailure(dioError(DioExceptionType.badCertificate)), isA<UnknownFailure>());
    });

    test('bad payloads → server failure', () {
      expect(toFailure(const FormatException('bad json')), isA<ServerFailure>());
    });

    test('anything else → unknown failure keeping the cause', () {
      final e = StateError('x');
      final f = toFailure(e);
      expect(f, isA<UnknownFailure>());
      expect((f as UnknownFailure).cause, e);
    });
  });
}
