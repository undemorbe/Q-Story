// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import '../../domain/entities/history_entity.dart';
import '../../domain/repositories/history_repository.dart';

part 'history_store.g.dart';

class HistoryStore = _HistoryStore with _$HistoryStore;

abstract class _HistoryStore with Store {
  final HistoryRepository _repository;

  _HistoryStore(this._repository);

  @observable
  List<HistoryEntity> historyList = [];

  @observable
  List<HistoryEntity> filteredList = [];

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  Future<void> loadHistory() async {
    isLoading = true;
    errorMessage = null;
    try {
      final result = await _repository.getHistory();
      historyList = result;
      filteredList = result;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void filterHistory(String query) {
    if (query.isEmpty) {
      filteredList = historyList;
    } else {
      filteredList = historyList.where((event) {
        final q = query.toLowerCase();
        return event.title.toLowerCase().contains(q) ||
            event.subtitle.toLowerCase().contains(q);
      }).toList();
    }
  }

  @action
  Future<void> addHistoryItem(HistoryEntity item) async {
    try {
      await _repository.addHistoryItem(item);
      await loadHistory();
    } catch (e) {
      errorMessage = e.toString();
    }
  }
}
