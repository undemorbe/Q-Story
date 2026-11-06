// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import 'package:sembast/sembast.dart';

import '../../../../core/storage/app_database.dart';
import '../../../activity/domain/entities/activity.dart';
import '../../../activity/presentation/stores/journal_store.dart';
import '../../../places/domain/entities/place.dart';

part 'favorites_store.g.dart';

class FavoritesStore = _FavoritesStore with _$FavoritesStore;

abstract class _FavoritesStore with Store {
  _FavoritesStore(AppDatabase database, this._journal) : _db = database.db;

  final Database _db;
  final JournalStore _journal;

  @observable
  ObservableList<Place> items = ObservableList<Place>();

  @computed
  bool get hasFavorites => items.isNotEmpty;

  @computed
  Set<String> get ids => items.map((p) => p.id).toSet();

  bool isFavorite(String id) => ids.contains(id);

  @action
  Future<void> load() async {
    final recs = await AppDatabase.favorites.find(_db, finder: Finder(sortOrders: [SortOrder('_addedAt', false)]));
    items = ObservableList.of(recs.map((r) => Place.fromJson(r.value)));
  }

  @action
  Future<void> toggle(Place place) async {
    final rec = AppDatabase.favorites.record(place.id);
    if (isFavorite(place.id)) {
      await rec.delete(_db);
      items.removeWhere((p) => p.id == place.id);
      await _journal.log(ActivityEventType.unfavorite, place: place);
    } else {
      await rec.put(_db, {...place.toJson(), '_addedAt': DateTime.now().millisecondsSinceEpoch});
      items.insert(0, place);
      await _journal.log(ActivityEventType.favorite, place: place);
    }
  }
}
