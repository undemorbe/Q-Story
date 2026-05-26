// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_fact_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DailyFactStore on _DailyFactStore, Store {
  late final _$factsAtom =
      Atom(name: '_DailyFactStore.facts', context: context);

  @override
  List<DailyFactEntity> get facts {
    _$factsAtom.reportRead();
    return super.facts;
  }

  @override
  set facts(List<DailyFactEntity> value) {
    _$factsAtom.reportWrite(value, super.facts, () {
      super.facts = value;
    });
  }

  late final _$currentFactAtom =
      Atom(name: '_DailyFactStore.currentFact', context: context);

  @override
  DailyFactEntity? get currentFact {
    _$currentFactAtom.reportRead();
    return super.currentFact;
  }

  @override
  set currentFact(DailyFactEntity? value) {
    _$currentFactAtom.reportWrite(value, super.currentFact, () {
      super.currentFact = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_DailyFactStore.isLoading', context: context);

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
      Atom(name: '_DailyFactStore.errorMessage', context: context);

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

  late final _$loadDailyFactAsyncAction =
      AsyncAction('_DailyFactStore.loadDailyFact', context: context);

  @override
  Future<void> loadDailyFact({bool force = false}) {
    return _$loadDailyFactAsyncAction
        .run(() => super.loadDailyFact(force: force));
  }

  late final _$nextFactAsyncAction =
      AsyncAction('_DailyFactStore.nextFact', context: context);

  @override
  Future<void> nextFact() {
    return _$nextFactAsyncAction.run(() => super.nextFact());
  }

  @override
  String toString() {
    return '''
facts: ${facts},
currentFact: ${currentFact},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
