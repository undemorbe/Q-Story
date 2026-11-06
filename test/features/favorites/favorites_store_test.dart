import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/favorites/presentation/stores/favorites_store.dart';

import '../../helpers/fakes.dart';

void main() {
  late TestEnv env;
  late FavoritesStore store;

  setUp(() async {
    env = await TestEnv.create();
    store = FavoritesStore(env.db, env.journal);
    await store.load();
  });
  tearDown(() => env.dispose());

  test('starts empty', () {
    expect(store.hasFavorites, isFalse);
    expect(store.ids, isEmpty);
  });

  test('toggle adds to the front and removes, logging both', () async {
    final a = place('a'), b = place('b');
    await store.toggle(a);
    await store.toggle(b);
    expect(store.items.map((p) => p.id), [b.id, a.id]);
    expect(store.isFavorite(a.id), isTrue);
    await store.toggle(a);
    expect(store.isFavorite(a.id), isFalse);
    final types = (await env.activity.events()).map((e) => e.type).toList();
    expect(types, [ActivityEventType.favorite, ActivityEventType.favorite, ActivityEventType.unfavorite]);
  });

  test('persists across instances, newest first', () async {
    await store.toggle(place('a', title: 'Первое'));
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await store.toggle(place('b', title: 'Второе'));
    final other = FavoritesStore(env.db, env.journal);
    await other.load();
    expect(other.items.map((p) => p.title), ['Второе', 'Первое']);
  });
}
