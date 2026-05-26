// ignore_for_file: library_private_types_in_public_api

import 'dart:math';

import 'package:mobx/mobx.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/util/result.dart';
import '../../domain/entities/daily_fact_entity.dart';
import '../../domain/repositories/daily_fact_repository.dart';

part 'daily_fact_store.g.dart';

class DailyFactStore = _DailyFactStore with _$DailyFactStore;

abstract class _DailyFactStore with Store {
  final DailyFactRepository _repository;
  final Random _random = Random();

  _DailyFactStore(this._repository);

  @observable
  List<DailyFactEntity> facts = [];

  @observable
  DailyFactEntity? currentFact;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  /// Date the facts are cached for. Used to refetch when day changes.
  DateTime? _loadedFor;

  @action
  Future<void> loadDailyFact({bool force = false}) async {
    final now = DateTime.now();
    final sameDay = _loadedFor != null &&
        _loadedFor!.year == now.year &&
        _loadedFor!.month == now.month &&
        _loadedFor!.day == now.day;

    if (!force && sameDay && currentFact != null) return;

    isLoading = true;
    errorMessage = null;
    final result = await _repository.getFactsForDate(now.month, now.day);
    isLoading = false;
    switch (result) {
      case Ok<List<DailyFactEntity>>(value: final list):
        facts = list;
        _loadedFor = DateTime(now.year, now.month, now.day);
        currentFact = list.isEmpty ? null : _pickRandom(list, exclude: null);
      case Err<List<DailyFactEntity>>(failure: final f):
        errorMessage = _humanize(f);
    }
  }

  /// Pick a different fact from the already-loaded set without re-fetching.
  /// Falls back to refetch if the set is empty.
  @action
  Future<void> nextFact() async {
    if (facts.isEmpty) {
      await loadDailyFact(force: true);
      return;
    }
    if (facts.length == 1) {
      currentFact = facts.first;
      return;
    }
    currentFact = _pickRandom(facts, exclude: currentFact);
  }

  DailyFactEntity _pickRandom(
    List<DailyFactEntity> list, {
    required DailyFactEntity? exclude,
  }) {
    if (exclude == null) return list[_random.nextInt(list.length)];
    final candidates =
        list.where((f) => identical(f, exclude) == false).toList();
    if (candidates.isEmpty) return list.first;
    return candidates[_random.nextInt(candidates.length)];
  }

  String _humanize(Failure f) => switch (f) {
        NetworkFailure() => 'Нет соединения с сервером Wikipedia',
        NotFoundFailure() => 'На этот день фактов нет',
        ServerFailure(message: final m) => m,
        ValidationFailure(message: final m) => m,
        CacheFailure(message: final m) => m,
        UnknownFailure() => 'Не удалось загрузить факт дня',
      };
}
