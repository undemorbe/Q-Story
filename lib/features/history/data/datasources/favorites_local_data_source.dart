import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesLocalDataSource {
  static const String _key = 'favorite_history_items';

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isFavorite(String id) async {
    final favorites = await getFavorites();
    return favorites.any((item) => item['id'] == id);
  }

  Future<void> addToFavorites(Map<String, dynamic> historyItem) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFavorites();
    
    // Check if already exists
    if (!current.any((item) => item['id'] == historyItem['id'])) {
      current.add(historyItem);
      await prefs.setString(_key, jsonEncode(current));
    }
  }

  Future<void> removeFromFavorites(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFavorites();
    current.removeWhere((item) => item['id'] == id);
    await prefs.setString(_key, jsonEncode(current));
  }

  Future<void> toggleFavorite(Map<String, dynamic> historyItem) async {
    final isFav = await isFavorite(historyItem['id']);
    if (isFav) {
      await removeFromFavorites(historyItem['id']);
    } else {
      await addToFavorites(historyItem);
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
