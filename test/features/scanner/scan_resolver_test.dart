import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/errors/failures.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';
import 'package:qstory/features/scanner/domain/scan_resolver.dart';

import '../../helpers/fakes.dart';

void main() {
  late TestEnv env;
  late FakeClient wiki;
  late ScanResolver resolver;

  setUp(() async {
    env = await TestEnv.create();
    wiki = FakeClient(PlaceSource.wikipedia, detail: place('ru:42', source: PlaceSource.wikipedia, title: 'Статья'));
    resolver = ScanResolver(env.placesRepo([wiki]));
  });
  tearDown(() => env.dispose());

  test('qstory reference is resolved through the source', () async {
    final out = await resolver.resolve('qstory:wikipedia:ru:42');
    expect(out, isA<ScanFoundPlace>());
    expect((out as ScanFoundPlace).place.title, 'Статья');
    expect(wiki.fetchCalls, 1);
  });

  test('Wikipedia URL is recognised as a place', () async {
    final out = await resolver.resolve('https://ru.wikipedia.org/wiki/Казанский_собор');
    expect(out, isA<ScanFoundPlace>());
  });

  test('source failure becomes ScanFailed', () async {
    wiki.error = Exception('offline');
    final out = await resolver.resolve('qstory:wikipedia:ru:42');
    expect(out, isA<ScanFailed>());
    expect((out as ScanFailed).failure, isA<UnknownFailure>());
  });

  test('missing place becomes ScanFailed(NotFound)', () async {
    wiki.detail = null;
    final out = await resolver.resolve('qstory:wikipedia:ru:404');
    expect((out as ScanFailed).failure, isA<NotFoundFailure>());
  });

  test('inline JSON place is remembered without network', () async {
    final json = jsonEncode(place('u7', source: PlaceSource.user, title: 'Табличка').toJson());
    final out = await resolver.resolve(json);
    expect((out as ScanFoundPlace).place.title, 'Табличка');
    expect(wiki.fetchCalls, 0);
    final repo = env.placesRepo([wiki]);
    expect((await repo.cached('user:u7'))?.title, 'Табличка'); // same id as encoded
  });

  test('other links and plain text', () async {
    expect(await resolver.resolve('https://example.com/promo'), isA<ScanLink>());
    final unknown = await resolver.resolve('просто текст');
    expect(unknown, isA<ScanUnknown>());
    expect((unknown as ScanUnknown).raw, 'просто текст');
  });
}
