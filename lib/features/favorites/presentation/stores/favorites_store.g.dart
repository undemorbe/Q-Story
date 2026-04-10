// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FavoritesStore on _FavoritesStore, Store {
  Computed<bool>? _$hasFavoritesComputed;

  @override
  bool get hasFavorites =>
      (_$hasFavoritesComputed ??= Computed<bool>(() => super.hasFavorites,
              name: '_FavoritesStore.hasFavorites'))
          .value;

  late final _$favoriteItemsAtom =
      Atom(name: '_FavoritesStore.favoriteItems', context: context);

  @override
  ObservableList<Map<String, dynamic>> get favoriteItems {
    _$favoriteItemsAtom.reportRead();
    return super.favoriteItems;
  }

  @override
  set favoriteItems(ObservableList<Map<String, dynamic>> value) {
    _$favoriteItemsAtom.reportWrite(value, super.favoriteItems, () {
      super.favoriteItems = value;
    });
  }

  late final _$_loadFavoritesAsyncAction =
      AsyncAction('_FavoritesStore._loadFavorites', context: context);

  @override
  Future<void> _loadFavorites() {
    return _$_loadFavoritesAsyncAction.run(() => super._loadFavorites());
  }

  late final _$toggleFavoriteAsyncAction =
      AsyncAction('_FavoritesStore.toggleFavorite', context: context);

  @override
  Future<void> toggleFavorite(Map<String, dynamic> historyItem) {
    return _$toggleFavoriteAsyncAction
        .run(() => super.toggleFavorite(historyItem));
  }

  late final _$removeFavoriteAsyncAction =
      AsyncAction('_FavoritesStore.removeFavorite', context: context);

  @override
  Future<void> removeFavorite(String id) {
    return _$removeFavoriteAsyncAction.run(() => super.removeFavorite(id));
  }

  @override
  String toString() {
    return '''
favoriteItems: ${favoriteItems},
hasFavorites: ${hasFavorites}
    ''';
  }
}
