import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _dataSource;

  SettingsRepositoryImpl(this._dataSource);

  @override
  Future<String?> getLocale() => _dataSource.getLocale();

  @override
  Future<void> setLocale(String languageCode) => _dataSource.saveLocale(languageCode);
}
