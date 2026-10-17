import '../../core/constants/hive_constants.dart';
import '../../models/app_settings_model.dart';
import '../abstract/settings_data_source.dart';
import '../../storage/storage_service.dart';

class HiveSettingsDataSource implements SettingsDataSource {
  HiveSettingsDataSource(this._storage);

  final StorageService _storage;

  @override
  Future<AppSettingsModel> getSettings() async {
    return _storage.settings.get('default') ?? AppSettingsModel();
  }

  @override
  Future<AppSettingsModel> updateSettings(AppSettingsModel settings) async {
    await _storage.settings.put('default', settings);
    return settings;
  }

  @override
  Future<int> getReceiptCounter() async {
    return _storage.meta.get(MetaKeys.receiptCounter) as int? ?? 0;
  }

  @override
  Future<int> incrementReceiptCounter() async {
    final next = await getReceiptCounter() + 1;
    await _storage.meta.put(MetaKeys.receiptCounter, next);
    return next;
  }

  @override
  Future<void> setReceiptCounter(int value) async {
    await _storage.meta.put(MetaKeys.receiptCounter, value);
  }

  @override
  Future<bool> isInitialized() async {
    return _storage.meta.get(MetaKeys.initialized) == true;
  }

  @override
  Future<void> setInitialized(bool value) async {
    await _storage.meta.put(MetaKeys.initialized, value);
  }
}
