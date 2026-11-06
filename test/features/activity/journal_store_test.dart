import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/activity/presentation/stores/journal_store.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';

import '../../helpers/fakes.dart';

void main() {
  late TestEnv env;
  final now = DateTime(2026, 11, 7, 12);

  setUp(() async => env = await TestEnv.create(clock: () => now));
  tearDown(() => env.dispose());

  test('recordVisit stores the visit, logs an event and notifies listeners once', () async {
    final heard = <Visit>[];
    env.journal.addVisitListener(heard.add);
    final p = place('node/1');
    final rev = env.journal.revision;

    expect(await env.journal.recordVisit(p, VisitMethod.geofence), isTrue);
    expect(await env.journal.recordVisit(p, VisitMethod.manual), isFalse);

    expect(env.journal.isVisited(p.id), isTrue);
    expect(heard, hasLength(1));
    expect(heard.single.method, VisitMethod.geofence);
    expect(heard.single.at, now);
    expect(env.journal.revision, rev + 1);
    final events = await env.activity.events();
    expect(events.single.type, ActivityEventType.visit);
    expect(events.single.source, PlaceSource.osm);
  });

  test('log bumps the revision and records place and value', () async {
    await env.journal.log(ActivityEventType.view, place: place('x'), value: 2);
    expect(env.journal.revision, 1);
    final e = (await env.activity.events()).single;
    expect(e.placeId, 'osm:x');
    expect(e.value, 2);
    expect(e.at, now);
  });

  test('init restores visited ids from storage', () async {
    await env.journal.recordVisit(place('a'), VisitMethod.qr);
    final fresh = JournalStore(env.activity);
    expect(fresh.isVisited('osm:a'), isFalse);
    await fresh.init();
    expect(fresh.isVisited('osm:a'), isTrue);
  });
}
