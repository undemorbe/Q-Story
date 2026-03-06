import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<void> saveLocale(String languageCode);
  Future<String?> getLocale();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences _prefs;

  SettingsLocalDataSourceImpl(this._prefs);

  static const String _kLocaleKey = 'locale';

  @override
  Future<void> saveLocale(String languageCode) async {
    await _prefs.setString(_kLocaleKey, languageCode);
  }

  @override
  Future<String?> getLocale() async {
    return _prefs.getString(_kLocaleKey);
  }
}
