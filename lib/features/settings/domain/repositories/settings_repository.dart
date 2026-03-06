abstract class SettingsRepository {
  Future<void> setLocale(String languageCode);
  Future<String?> getLocale();
}
