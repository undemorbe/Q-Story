// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HistoryStore on _HistoryStore, Store {
  late final _$historyListAtom =
      Atom(name: '_HistoryStore.historyList', context: context);

  @override
  List<HistoryEntity> get historyList {
    _$historyListAtom.reportRead();
    return super.historyList;
  }

  @override
  set historyList(List<HistoryEntity> value) {
    _$historyListAtom.reportWrite(value, super.historyList, () {
      super.historyList = value;
    });
  }

  late final _$filteredListAtom =
      Atom(name: '_HistoryStore.filteredList', context: context);

  @override
  List<HistoryEntity> get filteredList {
    _$filteredListAtom.reportRead();
    return super.filteredList;
  }

  @override
  set filteredList(List<HistoryEntity> value) {
    _$filteredListAtom.reportWrite(value, super.filteredList, () {
      super.filteredList = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_HistoryStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_HistoryStore.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$loadHistoryAsyncAction =
      AsyncAction('_HistoryStore.loadHistory', context: context);

  @override
  Future<void> loadHistory() {
    return _$loadHistoryAsyncAction.run(() => super.loadHistory());
  }

  late final _$addHistoryItemAsyncAction =
      AsyncAction('_HistoryStore.addHistoryItem', context: context);

  @override
  Future<void> addHistoryItem(HistoryEntity item) {
    return _$addHistoryItemAsyncAction.run(() => super.addHistoryItem(item));
  }

  late final _$_HistoryStoreActionController =
      ActionController(name: '_HistoryStore', context: context);

  @override
  void filterHistory(String query) {
    final _$actionInfo = _$_HistoryStoreActionController.startAction(
        name: '_HistoryStore.filterHistory');
    try {
      return super.filterHistory(query);
    } finally {
      _$_HistoryStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
historyList: ${historyList},
filteredList: ${filteredList},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
