/// Static, build-independent information about the app.
abstract final class AppInfo {
  static const String name = 'QStory';

  /// Must match `version:` in pubspec.yaml (checked by a test).
  static const String version = '1.0.0';
  static const String repositoryUrl = 'https://github.com/undemorbe/Q-Story';
  static const String issuesUrl = '$repositoryUrl/issues';

  /// Public privacy policy (also linked from the store listing).
  static const String privacyPolicyUrl = '$repositoryUrl/blob/main/PRIVACY.md';
  static const String supportEmail = 'stankovb08@gmail.com';
  static const String license = 'PolyForm Noncommercial 1.0.0';

  /// Identifying UA string required by Wikimedia / OSM API policies.
  static const String userAgent = '$name/$version (+$repositoryUrl)';
}
