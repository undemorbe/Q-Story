// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$JournalStore on _JournalStore, Store {
  late final _$visitedIdsAtom = Atom(name: '_JournalStore.visitedIds', context: context);

  @override
  ObservableSet<String> get visitedIds {
    _$visitedIdsAtom.reportRead();
    return super.visitedIds;
  }

  @override
  set visitedIds(ObservableSet<String> value) {
    _$visitedIdsAtom.reportWrite(value, super.visitedIds, () {
      super.visitedIds = value;
    });
  }

  late final _$revisionAtom = Atom(name: '_JournalStore.revision', context: context);

  @override
  int get revision {
    _$revisionAtom.reportRead();
    return super.revision;
  }

  @override
  set revision(int value) {
    _$revisionAtom.reportWrite(value, super.revision, () {
      super.revision = value;
    });
  }

  late final _$initAsyncAction = AsyncAction('_JournalStore.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$recordVisitAsyncAction = AsyncAction('_JournalStore.recordVisit', context: context);

  @override
  Future<bool> recordVisit(Place place, VisitMethod method) {
    return _$recordVisitAsyncAction.run(() => super.recordVisit(place, method));
  }

  late final _$logAsyncAction = AsyncAction('_JournalStore.log', context: context);

  @override
  Future<void> log(ActivityEventType type, {Place? place, num? value}) {
    return _$logAsyncAction.run(() => super.log(type, place: place, value: value));
  }

  @override
  String toString() {
    return '''
visitedIds: ${visitedIds},
revision: ${revision}
    ''';
  }
}
