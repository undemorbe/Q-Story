// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'favorites_store.g.dart';

class FavoritesStore = _FavoritesStore with _$FavoritesStore;

abstract class _FavoritesStore with Store {
  final SharedPreferences _prefs;
  static const String _favoritesKey = 'favorites_list';

  _FavoritesStore(this._prefs) {
    _loadFavorites();
  }

  @observable
  ObservableList<String> favoriteIds = ObservableList<String>();

  @computed
  bool get hasFavorites => favoriteIds.isNotEmpty;

  @action
  Future<void> _loadFavorites() async {
    final List<String>? storedFavorites = _prefs.getStringList(_favoritesKey);
    if (storedFavorites != null) {
      favoriteIds = ObservableList.of(storedFavorites);
    }
  }

  @action
  Future<void> toggleFavorite(String id) async {
    if (favoriteIds.contains(id)) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }
    await _prefs.setStringList(_favoritesKey, favoriteIds.toList());
  }

  bool isFavorite(String id) {
    return favoriteIds.contains(id);
  }
}
