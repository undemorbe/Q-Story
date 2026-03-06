import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_model.dart';

abstract class HistoryLocalDataSource {
  Future<List<HistoryModel>> getHistory();
  Future<void> cacheHistory(List<HistoryModel> history);
  Future<void> addHistoryItem(HistoryModel item);
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final SharedPreferences sharedPreferences;

  HistoryLocalDataSourceImpl({required this.sharedPreferences});

  static const String cachedHistoryKey = 'CACHED_HISTORY';

  @override
  Future<List<HistoryModel>> getHistory() {
    final jsonString = sharedPreferences.getString(cachedHistoryKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(jsonList.map((e) => HistoryModel.fromJson(e)).toList());
    } else {
      // Return default dummy data if empty for now, or empty list
      return Future.value(_getDummyData());
    }
  }

  @override
  Future<void> cacheHistory(List<HistoryModel> history) {
    final String jsonString = json.encode(history.map((e) => e.toJson()).toList());
    return sharedPreferences.setString(cachedHistoryKey, jsonString);
  }

  @override
  Future<void> addHistoryItem(HistoryModel item) async {
    final currentList = await getHistory();
    currentList.add(item);
    await cacheHistory(currentList);
  }

  List<HistoryModel> _getDummyData() {
    return [
      const HistoryModel(
        id: '1',
        title: 'Industrial Revolution',
        subtitle: 'Transition to new manufacturing processes',
        description: 'The Industrial Revolution was the transition to new manufacturing processes in Great Britain, continental Europe, and the United States.',
        imageUrl: 'https://picsum.photos/id/1/400/300',
        yearRange: '1760 - 1840',
      ),
      const HistoryModel(
        id: '2',
        title: 'French Revolution',
        subtitle: 'Period of radical political and societal change',
        description: 'The French Revolution was a period of radical political and societal change in France that began with the Estates General of 1789 and ended with the formation of the French Consulate in November 1799.',
        imageUrl: 'https://picsum.photos/id/10/400/300',
        yearRange: '1789 - 1799',
      ),
      const HistoryModel(
        id: '3',
        title: 'American Civil War',
        subtitle: 'Civil war in the United States',
        description: 'The American Civil War was a civil war in the United States between the Union and the Confederacy.',
        imageUrl: 'https://picsum.photos/id/20/400/300',
        yearRange: '1861 - 1865',
      ),
      const HistoryModel(
        id: '4',
        title: 'Moon Landing',
        subtitle: 'First manned mission to land on the Moon',
        description: 'Apollo 11 was the American spaceflight that first landed humans on the Moon. Commander Neil Armstrong and lunar module pilot Buzz Aldrin.',
        imageUrl: 'https://picsum.photos/id/30/400/300',
        yearRange: '1969',
      ),
    ];
  }
}
