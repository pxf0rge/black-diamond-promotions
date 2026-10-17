import '../datasources/abstract/settings_data_source.dart';

class ReceiptService {
  ReceiptService(this._settingsSource);

  final SettingsDataSource _settingsSource;

  Future<String> generateNext() async {
    final settings = await _settingsSource.getSettings();
    final counter = await _settingsSource.incrementReceiptCounter();
    final year = DateTime.now().year;
    final prefix = settings.receiptPrefix;
    return '$prefix-$year-${counter.toString().padLeft(6, '0')}';
  }
}
