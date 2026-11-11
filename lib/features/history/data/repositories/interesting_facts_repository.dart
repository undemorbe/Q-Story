import 'package:flutter/foundation.dart';

import '../../../activity/domain/repositories/activity_repository.dart';
import '../../../places/domain/entities/place.dart';
import '../../../places/domain/repositories/places_repository.dart';
import '../../domain/interesting_fact.dart';
import '../datasources/wiki_facts_client.dart';

/// Gathers reminder candidates. Every source fails soft: a network error
/// just means fewer candidates, never a broken reminder.
class InterestingFactsRepository {
  InterestingFactsRepository(this._wiki, this._places, this._activity);

  final WikiFactsClient _wiki;
  final PlacesRepository _places;
  final ActivityRepository _activity;

  Future<List<InterestingFact>> didYouKnow(String lang) => _soft('did you know', () => _wiki.didYouKnow(lang));

  Future<List<InterestingFact>> onThisDay(String lang, int month, int day) =>
      _soft('on this day', () => _wiki.onThisDay(lang, month, day));

  /// Unvisited places from the area the user last browsed on the map,
  /// presented by the first sentences of their description.
  Future<List<InterestingFact>> nearby() => _soft('nearby', () async {
    final visited = await _activity.visitedIds();
    return [
      for (final p in await _places.recentlyLoaded())
        if (!visited.contains(p.id) && p.category != PlaceCategory.photo) ?placeFact(p),
    ];
  });

  static InterestingFact? placeFact(Place p) {
    final source = (p.description?.isNotEmpty ?? false) ? p.description! : p.summary;
    final text = FactCurator.lead(source);
    if (text.length < FactCurator.minLength) return null;
    // Wikipedia extracts start by repeating the title; that's fine, the
    // notification title names the place anyway.
    return InterestingFact(
      id: 'place:${p.id}',
      kind: FactKind.nearby,
      text: text,
      title: p.title,
      year: p.yearStart ?? p.yearEnd,
      url: p.url,
      hasImage: p.imageUrl != null,
    );
  }

  Future<List<InterestingFact>> _soft(String what, Future<List<InterestingFact>> Function() load) async {
    try {
      return await load();
    } catch (e) {
      debugPrint('Facts ($what) unavailable: $e');
      return const [];
    }
  }
}
