// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$StatsStore on _StatsStore, Store {
  late final _$snapshotAtom = Atom(name: '_StatsStore.snapshot', context: context);

  @override
  StatsSnapshot? get snapshot {
    _$snapshotAtom.reportRead();
    return super.snapshot;
  }

  @override
  set snapshot(StatsSnapshot? value) {
    _$snapshotAtom.reportWrite(value, super.snapshot, () {
      super.snapshot = value;
    });
  }

  late final _$isLoadingAtom = Atom(name: '_StatsStore.isLoading', context: context);

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

  late final _$refreshAsyncAction = AsyncAction('_StatsStore.refresh', context: context);

  @override
  Future<void> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  late final _$resetAllAsyncAction = AsyncAction('_StatsStore.resetAll', context: context);

  @override
  Future<void> resetAll() {
    return _$resetAllAsyncAction.run(() => super.resetAll());
  }

  @override
  String toString() {
    return '''
snapshot: ${snapshot},
isLoading: ${isLoading}
    ''';
  }
}
