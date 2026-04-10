import 'package:shared_preferences/shared_preferences.dart';

class CompletedMarkersLocalDataSource {
  static const String _key = 'completed_marker_ids';

  Future<Set<String>> getCompletedMarkerIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.toSet();
  }

  Future<void> markAsCompleted(String markerId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCompletedMarkerIds();
    current.add(markerId);
    await prefs.setStringList(_key, current.toList());
  }

  Future<bool> isCompleted(String markerId) async {
    final ids = await getCompletedMarkerIds();
    return ids.contains(markerId);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
