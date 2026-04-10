// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import '../../../history/data/datasources/favorites_local_data_source.dart';

part 'favorites_store.g.dart';

class FavoritesStore = _FavoritesStore with _$FavoritesStore;

abstract class _FavoritesStore with Store {
  final FavoritesLocalDataSource _localDataSource;

  _FavoritesStore(this._localDataSource) {
    _loadFavorites();
  }

  @observable
  ObservableList<Map<String, dynamic>> favoriteItems = ObservableList<Map<String, dynamic>>();

  @computed
  bool get hasFavorites => favoriteItems.isNotEmpty;

  @action
  Future<void> _loadFavorites() async {
    final items = await _localDataSource.getFavorites();
    favoriteItems = ObservableList.of(items);
  }

  @action
  Future<void> toggleFavorite(Map<String, dynamic> historyItem) async {
    await _localDataSource.toggleFavorite(historyItem);
    await _loadFavorites();
  }

  @action
  Future<void> removeFavorite(String id) async {
    await _localDataSource.removeFromFavorites(id);
    await _loadFavorites();
  }

  bool isFavorite(String id) {
    return favoriteItems.any((item) => item['id'] == id);
  }
}
