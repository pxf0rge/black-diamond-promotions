import '../datasources/abstract/settings_data_source.dart';
import '../models/app_settings_model.dart';

class SettingsRepository {
  SettingsRepository(this._dataSource);

  final SettingsDataSource _dataSource;

  Future<AppSettingsModel> getSettings() => _dataSource.getSettings();

  Future<AppSettingsModel> updateSettings(AppSettingsModel settings) =>
      _dataSource.updateSettings(settings);

  Future<bool> isInitialized() => _dataSource.isInitialized();

  Future<void> setInitialized(bool value) => _dataSource.setInitialized(value);

  Future<void> setReceiptCounter(int value) =>
      _dataSource.setReceiptCounter(value);
}
