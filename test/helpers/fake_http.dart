import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef Responder = Object? Function(RequestOptions options);

/// Dio adapter answering from a function: return a JSON-encodable object,
/// a [DioException] to fail, or an `int` status code for an empty error.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.responder);
  final Responder responder;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
      RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final r = responder(options);
    if (r is DioException) throw r;
    if (r is int) return ResponseBody.fromString('', r);
    return ResponseBody.fromString(
      jsonEncode(r),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio fakeDio(Responder responder) => Dio()..httpClientAdapter = FakeAdapter(responder);
