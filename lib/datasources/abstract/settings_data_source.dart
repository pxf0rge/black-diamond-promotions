import '../../models/app_settings_model.dart';

abstract class SettingsDataSource {
  Future<AppSettingsModel> getSettings();
  Future<AppSettingsModel> updateSettings(AppSettingsModel settings);
  Future<int> getReceiptCounter();
  Future<int> incrementReceiptCounter();
  Future<void> setReceiptCounter(int value);
  Future<bool> isInitialized();
  Future<void> setInitialized(bool value);
}
