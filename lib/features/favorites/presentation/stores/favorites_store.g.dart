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
      (_$hasFavoritesComputed ??= Computed<bool>(() => super.hasFavorites, name: '_FavoritesStore.hasFavorites')).value;
  Computed<Set<String>>? _$idsComputed;

  @override
  Set<String> get ids => (_$idsComputed ??= Computed<Set<String>>(() => super.ids, name: '_FavoritesStore.ids')).value;

  late final _$itemsAtom = Atom(name: '_FavoritesStore.items', context: context);

  @override
  ObservableList<Place> get items {
    _$itemsAtom.reportRead();
    return super.items;
  }

  @override
  set items(ObservableList<Place> value) {
    _$itemsAtom.reportWrite(value, super.items, () {
      super.items = value;
    });
  }

  late final _$loadAsyncAction = AsyncAction('_FavoritesStore.load', context: context);

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$toggleAsyncAction = AsyncAction('_FavoritesStore.toggle', context: context);

  @override
  Future<void> toggle(Place place) {
    return _$toggleAsyncAction.run(() => super.toggle(place));
  }

  @override
  String toString() {
    return '''
items: ${items},
hasFavorites: ${hasFavorites},
ids: ${ids}
    ''';
  }
}
